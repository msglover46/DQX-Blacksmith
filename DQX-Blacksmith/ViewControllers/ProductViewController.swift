//
//  ProductViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/29.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import RealmSwift
import SVProgressHUD
import Alamofire
import Kanna
import SafariServices

protocol SetButtonTitle {
    func returnCraftsmanType(title: String)
    func returnLevel(level: Int)
    func returnCategory(category: Category)
    func returnProduct(product: Product)
    func returnTool(tool: Tool)
    func returnRate(blacksmith: Blacksmith)
    func returnTime(blacksmith: Blacksmith)
}

class ProductViewController: CommonViewController, SetButtonTitle {
    

    @IBOutlet weak var craftsmanTypeButton: SelectItemButton!
    @IBOutlet weak var levelButton: SelectItemButton!
    @IBOutlet weak var productCategoryButton: SelectItemButton!
    @IBOutlet weak var productButton: SelectItemButton!
    @IBOutlet weak var toolButton: SelectItemButton!
    @IBOutlet weak var rateLabel: TitleLabel!
    @IBOutlet weak var referenceRateButton: SelectItemButton!
    @IBOutlet weak var referenceTimeButton: SelectItemButton!
    @IBOutlet weak var tripleLabel: UILabel!
    @IBOutlet weak var doubleLabel: UILabel!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var noneLabel: UILabel!
    @IBOutlet weak var failedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTitleLabel: TitleLabel!
    @IBOutlet weak var earningButton: PushButton!
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var inquiryButton: PushButton!
    
    @IBAction func tapInquiry(_ sender: Any) {
        let webPage = "https://docs.google.com/forms/d/e/1FAIpQLSe3c1YcdPSZazo5sIPD4mBExhviiGu_e-Ly690_ssnQygzC5g/viewform?usp=sf_link"
        let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
        safariVC.modalPresentationStyle = .fullScreen
        present(safariVC, animated: false, completion: nil)
    }
    
    var craftsmanType = ""
    var preCraftsmanType = ""
    var level = 0
    var category = Category()
    var preCategory = Category()
    var product = Product()
    var preProduct = Product()
    var enabled = true
    var master = true
    var tool = Tool()
    var preTool = Tool()
    var rate = SuccessRate()
    var time = 0
    var blacksmith = Blacksmith()
    let urlString = "http://bazaar.d-quest-10.com"
    var price = Price(product: ProductInfo())
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        SVProgressHUD.setDefaultMaskType(.clear)
    }
     
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawRateBorder() // 成功率の枠線を描く。
        drawTimeBorder() // 1個あたりの作業時間の枠線を描く。
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func drawRateBorder() {
        let borderView = RoundBorderView()
        
        // borderViewのframeを算出
        let x = CGFloat(10.0) // x: 10.0pt
        let y = rateLabel.frame.midY // y: 「成功率」ラベルの真ん中。
        let width = self.view.frame.width - 20.0 // 幅: 全体から両端を10.0ptずつ除く。
        let height = referenceRateButton.frame.maxY - y + 10.0 // 高さ: 「成功率参照先」ボタンから10.0pt下に線が引かれるように調整。
        borderView.frame = CGRect(x: x, y: y, width: width, height: height)
        view.insertSubview(borderView, at: 0)
    }
    
    func drawTimeBorder() {
        let borderView = RoundBorderView()
        
        // borderViewのframeを算出
        let x = CGFloat(10.0) // x: 10.0pt
        let y = timeTitleLabel.frame.midY // 「1個あたりの作業時間」ラベルの真ん中
        let width = self.view.frame.width - 20.0 // 幅: 全体から両端を10.0ptずつ除く。
        let height = referenceTimeButton.frame.maxY - y + 10.0 // 高さ: 「時間参照先」ボタンから10.0pt下に線が引かれるように調整。
        borderView.frame = CGRect(x: x, y: y, width: width, height: height)
        view.insertSubview(borderView, at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel()
        getInitFirestore { result in
            self.setAllMasterData { result in
                self.setUserDefault()
                self.initializeButtonLabels()
            }
        }
    }
    
    // アプリのタイトルを表示する。
    func setTitleLabel() {
        appTitleLabel.textColor = UIColor.white
        appTitleLabel.backgroundColor = Color.DarkBrown
    }
    
    func initializeButtonLabels() {
        let item = try! Realm().objects(Product.self).count
        print(item)
        self.craftsmanType = setCraftsmanButton()
        self.level = setLevelButton(craftsmanType: craftsmanType)
        self.category = setCategoryButton(craftsmanType: craftsmanType)
        (self.product, self.enabled) = setProductButton(category: self.category, level: level)
        self.tool = setToolButton()
        self.blacksmith = self.setRateTime(enabled: self.enabled, preProduct: self.preProduct, preTool: self.preTool, product: self.product, tool: self.tool)
        self.setBlacksmithValue(blacksmith: self.blacksmith, product: self.product, tool: self.tool)
//        self.master = setMasterButton(enabled: self.enabled, master: self.blacksmith.masterFlg)
        self.setPushButtons(enabled: self.enabled)
    }
    
    func setCraftsmanButton() -> String {
        let userdefault = UserDefaults.standard
        let craftsman = userdefault.string(forKey: "craftsman")
        self.craftsmanTypeButton.setTitle(craftsman, for: .normal)
        return craftsman!
    }
    
    func setLevelButton(craftsmanType: String) -> Int {
        let userdefault = UserDefaults.standard
        let levels = userdefault.dictionary(forKey: "level")
        let level = levels![craftsmanType] as? Int
        self.levelButton.setTitle(String(level!), for: .normal)
        return level!
    }
    
    func setCategoryButton(craftsmanType: String) -> Category {
        let realm = try! Realm()
        let category = realm.objects(Category.self).filter("craftsmanType == %@", craftsmanType).first
        self.productCategoryButton.setTitle(category?.name, for: .normal)
        return category!
    }
    
    func setProductButton(category: Category, level: Int) -> (product: Product, enabled: Bool) {
        let realm = try! Realm()
        var product = realm.objects(Product.self).filter("productCategoryID == %@ && level <= %@", category.id, level).first
        var enabled = true
        if let product = product {
            self.productButton.setTitle(product.name, for: .normal)
        } else {
            product = Product()
            self.productButton.setTitle("--", for: .normal)
            enabled = false
        }
        return (product!, enabled)
    }
    
//    func setMasterButton(enabled:Bool, master: Bool) -> Bool {
//        if enabled {
//            if master {
//                self.masterButton.setTitle("あり", for: .normal)
//            } else {
//                self.masterButton.setTitle("なし", for: .normal)
//            }
//        } else {
//            self.masterButton.setTitle("--", for: .normal)
//        }
//        return master
//    }
    
//    @IBAction func selectMaster(_ sender: Any) {
//        let realm = try! Realm()
//        if self.master {
//            self.master = self.setMasterButton(enabled: true, master: false)
//            try! realm.write {
//                self.blacksmith.masterFlg = false
//            }
//        } else {
//            self.master = self.setMasterButton(enabled: true, master: true)
//            try! realm.write {
//                self.blacksmith.masterFlg = true
//            }
//        }
//    }
    
    func setToolButton() -> Tool {
            let realm = try! Realm()
            let tool = realm.objects(Tool.self).sorted(byKeyPath: "id").first
            let star = tool?.star as! Int
            let toolName = setToolTitle(name: tool!.name, star: star)
            self.toolButton.setTitle(toolName, for: .normal)
        
        return tool!
    }
    
    func setToolTitle(name: String, star:Int) -> String {
        let toolName = name + " " + String(repeating: "★", count: star)
        return toolName
    }
    
    func getProductInformation(preProduct: Product, preTool: Tool, product: Product, tool: Tool) -> Blacksmith {
        var blacksmith = Blacksmith()
        if preProduct == product && preTool == tool {
            blacksmith = self.blacksmith
        } else {
            let realm = try! Realm()
            let keyID = "1.\(product.id).\(tool.id)"
            blacksmith = realm.objects(Blacksmith.self).filter("keyID == %@", keyID).first ?? Blacksmith()
        }
        return blacksmith
    }
    
    func setBlacksmithValue(blacksmith: Blacksmith, product: Product, tool: Tool) {
        if blacksmith.productID == 0 {
            blacksmith.productClass = 1
            blacksmith.productID = self.product.id
            blacksmith.toolID = self.tool.id
            blacksmith.configure(blacksmith.productID, blacksmith.productClass, blacksmith.toolID)
        }
    }
    
    func quantityToRate(quantity: Quantity) -> SuccessRate {
        let rate = SuccessRate()
        if quantity.total > 0 {
            rate.triple = Int(Double(quantity.triple) / Double(quantity.total))
            rate.double = Int(Double(quantity.double) / Double(quantity.total))
            rate.single = Int(Double(quantity.single) / Double(quantity.total))
            rate.none = Int(Double(quantity.none) / Double(quantity.total))
            rate.failed = 100 - (rate.triple + rate.double + rate.single + rate.none)
        }
        return rate
    }
  
    func setRateTime(enabled: Bool, preProduct: Product, preTool: Tool, product: Product, tool: Tool) -> Blacksmith {
        var blacksmith = Blacksmith()
        if enabled {
            blacksmith = self.getProductInformation(preProduct: preProduct, preTool: preTool, product: product, tool: tool)
            self.rate = self.setRateLabels(blacksmith: blacksmith)
            self.time = self.setTimeLabel(blacksmith: blacksmith)
        } else {
            self.referenceRateButton.setTitle("--", for: .normal)
            self.referenceTimeButton.setTitle("--", for: .normal)
            self.tripleLabel.text = "--"
            self.doubleLabel.text = "--"
            self.singleLabel.text = "--"
            self.noneLabel.text = "--"
            self.failedLabel.text = "--"
            self.timeLabel.text = "--"
            blacksmith = self.blacksmith
        }
        return blacksmith
    }
    
    func setRateLabels(blacksmith: Blacksmith) -> SuccessRate {
        var rate = SuccessRate()
        switch blacksmith.referenceRate {
        case 0: // 0:初期値を設定する
            let userdefault = UserDefaults.standard
            let rateDic = userdefault.dictionary(forKey: "rate") as! [String: Int]
            rate.triple = rateDic["triple"]!
            rate.double = rateDic["double"]!
            rate.single = rateDic["single"]!
            rate.none = rateDic["none"]!
            rate.failed = rateDic["failed"]!
            self.referenceRateButton.setTitle("初期値を設定する", for: .normal)
            
        case 1: // 1:自分で値を設定する
            rate = blacksmith.setRate ?? SuccessRate()
            self.referenceRateButton.setTitle("自分で値を設定する", for: .normal)
        
        case 2: // 2:練習の実績値を設定する
            let quantity = blacksmith.practice?.quantity ?? Quantity()
            rate = quantityToRate(quantity: quantity)
            self.referenceRateButton.setTitle("練習の実績値を設定する", for: .normal)

        case 3: // 3:本番の実績値を設定する
            let quantity = blacksmith.real?.quantity ?? Quantity()
            rate = quantityToRate(quantity: quantity)
            self.referenceRateButton.setTitle("本番の実績値を設定する", for: .normal)

        default:
            break
        }
        
        self.tripleLabel.text = String(rate.triple) + "%"
        self.doubleLabel.text = String(rate.double) + "%"
        self.singleLabel.text = String(rate.single) + "%"
        self.noneLabel.text = String(rate.none) + "%"
        self.failedLabel.text = String(rate.failed) + "%"
        
        return rate
    }
    
    func SecondsToMinutes(seconds: Int) -> MSTime {
        let minute: Int = seconds / 60
        let second: Int = seconds % 60
        let mstime = MSTime()
        mstime.minutes = minute
        mstime.seconds = second
        return mstime
    }
    
    func MinutesToSeconds(mstime: MSTime) -> Int {
        let seconds = mstime.minutes * 60 + mstime.seconds
        return seconds
    }
    
    func setTimeLabel(blacksmith: Blacksmith) -> Int {
        var seconds = 0
        switch blacksmith.referenceTime {
        case 0: // 0:初期値を設定する
            let userdefault = UserDefaults.standard
            seconds = userdefault.integer(forKey: "time")
            self.referenceTimeButton.setTitle("初期値を設定する", for: .normal)
        case 1: // 1:自分で値を設定する
            seconds = blacksmith.setTime
            self.referenceTimeButton.setTitle("自分で値を設定する", for: .normal)
        case 2: // 2:練習の実績値を設定する
            let times = blacksmith.practice?.quantity?.total ?? 0
            if times > 0 {
                seconds = (blacksmith.practice?.time?.total ?? 0) / times
            }
            self.referenceTimeButton.setTitle("練習の実績値を設定する", for: .normal)
        case 3: // 3:本番の実績値を設定する
            let times = blacksmith.real?.quantity?.total ?? 0
            if times > 0 {
                seconds = (blacksmith.real?.time?.total ?? 0) / times
            }
            self.referenceTimeButton.setTitle("本番の実績値を設定する", for: .normal)
            
        default:
            break
        }
        
        let mstime = SecondsToMinutes(seconds: seconds)
        let title = String(mstime.minutes) + "分" + String(mstime.seconds) + "秒"
        self.timeLabel.text = title
        
        return seconds
    }
    
    func setPushButtons(enabled: Bool) {
        if enabled {
            earningButton.isEnabled = true
//            realButton.isEnabled = true
        } else {
            earningButton.isEnabled = false
//            realButton.isEnabled = false
        }
    }
    
    @IBAction func touchEarning(_ sender: Any) {
        var price = Price(product: ProductInfo())
        var materialURL: String = ""
        var toolURL: String = ""
        var productURL: String = ""
        var productURL2: String = ""
        let realm = try! Realm()
        let product = realm.objects(Product.self).filter("id == %@", self.blacksmith.productID).first!
        let category = realm.objects(Category.self).filter("id == %@", product.productCategoryID).first!
        let tool = realm.objects(Tool.self).filter("id == %@", self.blacksmith.toolID).first!
        var materials: [Material] = []
        var recipe: [Recipe] = []
        
        SVProgressHUD.show(withStatus: "計算中...")
        
        
        for item in product.recipe {
            if item.id > 0 {
                recipe.append(item)
            }
        }
        for item in recipe {
            let material = realm.objects(Material.self).filter("id == %@", item.id).first!
            materials.append(material)
        }
        
        // リンクの取得
        AF.request(urlString).responseString { response in
            if let html = response.value {
                if let doc = try? HTML(html: html, encoding: .utf8) {
                    for link in doc.css("a, link") {
                        if let item = link.text {
                            var href = Href()
                            href.category = item
                            href.href = self.urlString + (link["href"] ?? "")
                            
                            // 鍛冶道具（Tool）と素材（Material）のリンクを取得する。
                            if href.category == "鍛冶ハンマー" {
                                toolURL = href.href
                            } else if href.category == "素材" {
                                materialURL = href.href
                            }
                            
                            // 製品（Product）のリンクを取得する。
                            if category.name == "家具・庭具" {
                                if href.category == "家具" {
                                    productURL = href.href
                                } else if href.category == "庭具" {
                                    productURL2 = href.href
                                }
                            } else if category.name == "ルアー" {
                                if href.category == "釣り道具" {
                                    productURL = href.href
                                }
                            } else {
                                if href.category == category.name {
                                    productURL = href.href
                                }
                            }
                        }
                    }
                    
                    // 材料の値段を取得する。
                    AF.request(materialURL).responseString { response in
                        if let html = response.value {
                            if let doc = try? HTML(html: html, encoding: .utf8) {
                                for item in materials {
                                    let node = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(item.name)']]/td[4]")
                                    var materialInfo = MaterialInfo()
                                    materialInfo.id = item.id
                                    materialInfo.price = self.transformPrice(node: node)
                                    let storePrice = realm.objects(Material.self).filter("id == %@", item.id).first!.price
                                    if storePrice > 0 {
                                        if storePrice < materialInfo.price {
                                            materialInfo.price = storePrice
                                        }
                                    }
                                    price.material.append(materialInfo)
                                }
                                print("素材:", price.material)
                            }
                        }
                        
                        // 道具の値段を取得する。
                        AF.request(toolURL).responseString { response in
                            if let html = response.value {
                                if let doc = try? HTML(html: html, encoding: .utf8) {
                                    switch tool.star {
                                    case 0:
                                        let node = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(tool.name)']]/td[5]")
                                        price.tool = self.transformPrice(node: node)
                                    case 1:
                                        let node = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(tool.name)']]/td[6]")
                                        price.tool = self.transformPrice(node: node)
                                    case 2:
                                        let node = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(tool.name)']]/td[7]")
                                        price.tool = self.transformPrice(node: node)
                                    case 3:
                                        let node = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(tool.name)']]/td[8]")
                                        price.tool = self.transformPrice(node: node)
                                    default:
                                        break
                                    }
                                    print("道具:", price.tool)
                                }
                            }
                            
                            // 製品の値段を取得する。
                            if category.name == "家具・庭具" {
                                AF.request(productURL).responseString { response in
                                    if let html = response.value {
                                        if let doc = try? HTML(html: html, encoding: .utf8) {
                                            var node = Node()
                                            node.none = doc.xpath("//*[@id='BOX']/table//td[div[2]/a[text()='\(product.name)']]/div[3]")
                                            node.triple = doc.xpath("//*[@id='BOX']/table//td[div[2]/a[text()='\(product.successfulProduct)']]/div[3]")
                                            
                                            if price.product.none == 0 {
                                                price.product.none = self.transformPrice(node: node.none)
                                            }
                                            if price.product.triple == 0 {
                                                price.product.triple = self.transformPrice(node: node.triple)
                                            }
                                        }
                                    }
                                    AF.request(productURL2).responseString { response in
                                        if let html = response.value {
                                            if let doc = try? HTML(html: html, encoding: .utf8) {
                                                var node = Node()
                                                node.none = doc.xpath("//*[@id='BOX']/table//td[div[2]/a[text()='\(product.name)']]/div[3]")
                                                node.triple = doc.xpath("//*[@id='BOX']/table//td[div[2]/a[text()='\(product.successfulProduct)']]/div[3]")
                                                if price.product.none == 0 {
                                                    price.product.none = self.transformPrice(node: node.none)
                                                }
                                                if price.product.triple == 0 {
                                                    price.product.triple = self.transformPrice(node: node.triple)
                                                }
                                            }
                                        }
                                        print("製品:", price.product.triple, price.product.none)
                                        self.price = price
                                        SVProgressHUD.dismiss()
                                        self.performSegue(withIdentifier: R.segue.productViewController.earnings, sender: nil)
                                    }
                                }
                            } else {
                                AF.request(productURL).responseString { response in
                                    if let html = response.value {
                                        if let doc = try? HTML(html: html, encoding: .utf8) {
                                            var node = Node()
                                            if category.name == "素材" {
                                                let node = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(product.name)']]/td[4]")
                                                price.product.none = self.transformPrice(node: node)
                                            } else {
                                                node.none = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(product.name)']]/td[5]")
                                                node.single = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(product.name)']]/td[6]")
                                                node.double = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(product.name)']]/td[7]")
                                                node.triple = doc.xpath("//*[@id='BOX']/table//tr[td[1]/a[text()='\(product.name)']]/td[8]")
                                                price.product.none = self.transformPrice(node: node.none)
                                                price.product.single = self.transformPrice(node: node.single)
                                                price.product.double = self.transformPrice(node: node.double)
                                                price.product.triple = self.transformPrice(node: node.triple)
                                                print("製品:", price.product.triple, price.product.double, price.product.single, price.product.none)
                                            }
                                        }
                                    }
                                    self.price = price
                                    SVProgressHUD.dismiss()
                                    self.performSegue(withIdentifier: R.segue.productViewController.earnings, sender: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let vc = R.segue.productViewController.self
        switch segue.identifier {
        case vc.craftsman.identifier:
            let next = vc.craftsman(segue: segue)!.destination
            next.delegate = self
            next.button = segue.identifier!
            next.craftsmanType = self.craftsmanType
            next.level = self.level
            next.category = self.category
            next.product = self.product
            next.tool = self.tool
        case vc.level.identifier:
            let next = vc.level(segue: segue)!.destination
            next.delegate = self
            next.button = segue.identifier!
            next.craftsmanType = self.craftsmanType
            next.level = self.level
            next.category = self.category
            next.product = self.product
            next.tool = self.tool
        case vc.category.identifier:
            let next = vc.category(segue: segue)!.destination
            next.delegate = self
            next.button = segue.identifier!
            next.craftsmanType = self.craftsmanType
            next.level = self.level
            next.category = self.category
            next.product = self.product
            next.tool = self.tool
        case vc.product.identifier:
            let next = vc.product(segue: segue)!.destination
            next.delegate = self
            next.button = segue.identifier!
            next.craftsmanType = self.craftsmanType
            next.level = self.level
            next.category = self.category
            next.product = self.product
            next.tool = self.tool
        case vc.tool.identifier:
            let next = vc.tool(segue: segue)!.destination
            next.delegate = self
            next.button = segue.identifier!
            next.craftsmanType = self.craftsmanType
            next.level = self.level
            next.category = self.category
            next.product = self.product
            next.tool = self.tool
        case vc.rate.identifier:
            let next = vc.rate(segue: segue)!.destination
            next.delegate = self
            next.blacksmith = self.blacksmith
        case vc.time.identifier:
            let next = vc.time(segue: segue)!.destination
            next.delegate = self
            next.blacksmith = self.blacksmith
        case vc.earnings.identifier:
            let next = vc.earnings(segue: segue)!.destination
            next.delegate = self
            next.blacksmith = self.blacksmith
            next.initPrice = self.price
            next.price = self.price
            next.rate = self.rate
            next.time = self.time
            let realm = try! Realm()
            try! realm.write {
                realm.add(self.blacksmith, update: .modified)
            }
//        case vc.real.identifier:
//            let next = vc.real(segue: segue)!.destination
//            next.delegate = self
//            next.blacksmith = self.blacksmith
//            next.level = self.level
        default: break
        }
    }
    
    func returnCraftsmanType(title: String) {
        self.craftsmanTypeButton.setTitle(title, for: .normal)
        self.preCraftsmanType = self.craftsmanType
        self.craftsmanType = title
        if self.preCraftsmanType != self.craftsmanType {
            self.level = setLevelButton(craftsmanType: title)
            self.category = setCategoryButton(craftsmanType: title)
            self.preProduct = self.product
            (self.product, self.enabled) = setProductButton(category: self.category, level: level)
            let realm = try! Realm()
            try! realm.write {
                self.blacksmith = self.setRateTime(enabled: self.enabled, preProduct: self.preProduct, preTool: self.preTool, product: self.product, tool: self.tool)
                self.setBlacksmithValue(blacksmith: self.blacksmith, product: self.product, tool: self.tool)
            }
//            self.master = setMasterButton(enabled: self.enabled, master: self.blacksmith.masterFlg)
            self.setPushButtons(enabled: self.enabled)
        }
    }
    
    func returnLevel(level: Int) {
        let realm = try! Realm()
        self.levelButton.setTitle(String(level), for: .normal)
        self.level = level
        if self.product.level > level {
            self.preProduct = self.product
            self.preTool = self.tool
            (self.product, self.enabled) = setProductButton(category: self.category, level: level)
            try! realm.write {
                self.blacksmith = self.setRateTime(enabled: self.enabled, preProduct: self.preProduct, preTool: self.preTool, product: self.product, tool: self.tool)
                self.setBlacksmithValue(blacksmith: self.blacksmith, product: self.product, tool: self.tool)
            }
//            self.master = setMasterButton(enabled: self.enabled, master: self.blacksmith.masterFlg)
            self.setPushButtons(enabled: self.enabled)
        }
    }
    
    func returnCategory(category: Category) {
        self.productCategoryButton.setTitle(category.name, for: .normal)
        self.preCategory = self.category
        self.category = category
        if self.category != self.preCategory {
            self.preProduct = self.product
            self.preTool = self.tool
            (self.product, self.enabled) = setProductButton(category: self.category, level: level)
            let realm = try! Realm()
            try! realm.write {
                self.blacksmith = self.setRateTime(enabled: self.enabled, preProduct: self.preProduct, preTool: self.preTool, product: self.product, tool: self.tool)
                self.setBlacksmithValue(blacksmith: self.blacksmith, product: self.product, tool: self.tool)
            }
//            self.master = setMasterButton(enabled: self.enabled, master: self.blacksmith.masterFlg)
            self.setPushButtons(enabled: self.enabled)
        }
    }
    
    func returnProduct(product: Product) {
        self.productButton.setTitle(product.name, for: .normal)
        self.preProduct = self.product
        self.preTool = self.tool
        self.product = product
        self.enabled = true
        let realm = try! Realm()
        try! realm.write {
            self.blacksmith = self.setRateTime(enabled: self.enabled, preProduct: self.preProduct, preTool: self.preTool, product: self.product, tool: self.tool)
            self.setBlacksmithValue(blacksmith: self.blacksmith, product: self.product, tool: self.tool)
        }
//        self.master = setMasterButton(enabled: self.enabled, master: self.blacksmith.masterFlg)
        print(self.blacksmith)
        print(self.master)
        self.setPushButtons(enabled: self.enabled)
    }
    
    func returnTool(tool: Tool) {
        let toolName = setToolTitle(name: tool.name, star: tool.star)
        self.toolButton.setTitle(toolName, for: .normal)
        self.preProduct = self.product
        self.preTool = self.tool
        self.tool = tool
        let realm = try! Realm()
        try! realm.write {
            self.blacksmith = self.setRateTime(enabled: self.enabled, preProduct: self.preProduct, preTool: self.preTool, product: self.product, tool: self.tool)
            self.setBlacksmithValue(blacksmith: self.blacksmith, product: self.product, tool: self.tool)
        }
//        self.master = setMasterButton(enabled: self.enabled, master: self.blacksmith.masterFlg)
        self.setPushButtons(enabled: self.enabled)

    }
    
    func returnRate(blacksmith: Blacksmith) {
        let realm = try! Realm()
        try! realm.write {
            self.blacksmith = blacksmith
        }
        self.rate = self.setRateLabels(blacksmith: blacksmith)
    }
    
    func returnTime(blacksmith: Blacksmith) {
        let realm = try! Realm()
        try! realm.write {
            self.blacksmith = blacksmith
        }
        self.time = self.setTimeLabel(blacksmith: blacksmith)
    }
    
    func transformPrice(node: XPathObject) -> Int {
        var str = node.first?.content
        str = str?.replacingOccurrences(of: "G", with: "", options: .literal, range: nil)
        str = str?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
        str = str?.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
        let result = Int(str ?? "0") ?? 0
        return result
    }
    
    // Firestoreから初期情報を取得するメソッド
    func getInitFirestore(completion: @escaping (Bool) -> Void) {
        SVProgressHUD.show(withStatus: "Now Loading...")
        let startCollection = Firestore.firestore().collection(Path.StartCollectionPath)
        let userdefault:UserDefaults = UserDefaults.standard
        userdefault.register(defaults: ["newsText": "DQX鍛冶職人のためのアプリ「DQX 鍛冶サポート」へようこそ！",
                                        "newsColor": ["red": 0, "blue": 0, "green": 0],
                                        "version": 0])
        startCollection.getDocuments{(snaps, error) in
            if let error = error {
                print("DEBUG_PRINT:", error.localizedDescription)
                SVProgressHUD.dismiss()
                completion(false)
            } else {
                if let snaps = snaps {
                    for document in snaps.documents {
                        if document.documentID == "news" {
                            let newsData = document.data()
                            userdefault.setValue(newsData["text"], forKey: "newsText")
                            userdefault.setValue(newsData["color"], forKey: "newsColor")
                        } else if document.documentID == "version" {
                            let myVersion = userdefault.integer(forKey: "realmVersion")
                            let versionData = document.data()
                            let fsVersion = versionData["version"] as! Int
                            print("DEBUG_PRINT: FireStore Version ", fsVersion)
                            print("DEBUG_PRINT: RealmSwift Version ", myVersion)
                            userdefault.setValue(fsVersion, forKey: "firestoreVersion")
                        }
                    }
                    SVProgressHUD.dismiss()
                    completion(true)
                }
            }
        }
    }
    
    // UserDefaultsの初期値を設定するメソッド
    func setUserDefault() {
        let userdefault:UserDefaults = UserDefaults.standard
        let realm = try! Realm()
        
        // 職人種類の設定
        let initCraftsmanType = "武器鍛冶"
        userdefault.register(defaults: ["craftsman": initCraftsmanType])
        
        // レベルの設定
        let initLevel = realm.objects(Level.self).sorted(byKeyPath: "level", ascending: false).first?.level ?? 1
        let level = ["武器鍛冶": initLevel, "防具鍛冶": initLevel, "道具鍛冶": initLevel]
        userdefault.register(defaults: ["level": level])
        
        // 成功率の初期設定
        let rate = ["triple": 70, "double": 20, "single": 5, "none": 5, "failed": 0]
        userdefault.register(defaults: ["rate": rate])
        
        // 時間の初期設定
        let time = 60
        userdefault.register(defaults: ["time": time])
    }
    
    // Firestoreからマスタデータを取得するメソッド
    func setMasterData<T>(collectionPath: String, objectType: T.Type, completion: @escaping(Bool) -> Void) where T:Object, T:Codable {
        let collection = Firestore.firestore().collection(collectionPath)
        // Firestoreから<引数1>コレクションのドキュメントを全て取得する。
        collection.getDocuments{(snaps, error) in
            if let error = error {
                print("DEBUG_PRINT:" + error.localizedDescription)
                completion(false)
            } else {
                if let snaps = snaps {
                    // Firestoreデータを取り込む前にRealmのデータを全削除する。
                    let realm = try! Realm()
                    let result = realm.objects(objectType)
                    try! realm.write {
                        realm.delete(result)
                    }
                    print("DEBUG_PRINT:\(collectionPath)コレクションから\(snaps.documents.count)個のdocumentを取得")
                    // Firestoreから読み込んだドキュメントを１つずつRealmに書き込む。
                    for document in snaps.documents {
                        let result = Result {
                            try document.data(as: objectType)
                        }
                        switch result {
                        case .success(let data):
                            if let data = data {
                                try! realm.write {
                                    realm.add(data)
                                }
                            } else {
                                print("DEBUG_PRINT: Document doesn't exist.")
                            }
                        case .failure(let error):
                            print("DEBUG_PRINT:" + error.localizedDescription)
                        }
                    }
                    print("DEBUG_PRINT: \(objectType)テーブルに\(realm.objects(objectType).count)個のデータを登録")
                    completion(true)
                }
            }
        }
    }
    
    func setAllMasterData(completion: @escaping (Bool) -> Void) {
        let userdefault = UserDefaults.standard
        let realmVersion = userdefault.integer(forKey: "realmVersion")
        let firestoreVersion = userdefault.integer(forKey: "firestoreVersion")
        if firestoreVersion > realmVersion {
            SVProgressHUD.show(withStatus: "データロード中...")
            self.setMasterData(collectionPath: Path.ProductCollectionPath, objectType: Product.self) { result in
                if result == true {
                    self.setMasterData(collectionPath: Path.CategoryCollectionPath, objectType: Category.self) { result in
                        if result == true {
                            self.setMasterData(collectionPath: Path.MaterialCollectionPath, objectType: Material.self) { result in
                                if result == true {
                                    self.setMasterData(collectionPath: Path.LevelCollectionPath, objectType: Level.self) { result in
                                        if result == true {
                                            self.setMasterData(collectionPath: Path.ToolCollectionPath, objectType: Tool.self) { result in
                                                if result == true {
                                                    userdefault.setValue(firestoreVersion, forKey: "realmVersion")
                                                    SVProgressHUD.dismiss()
                                                    completion(true)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            completion(true)
        }
    }
}

class MSTime: Object {
    var minutes = 0
    var seconds = 0
}

struct Href {
    var category: String = ""
    var href: String = ""
}

struct ProductInfo {
    var triple = 0
    var double = 0
    var single = 0
    var none = 0
}

struct MaterialInfo {
    var id = 0
    var price = 0
}

struct Price {
    var material: [MaterialInfo] = []
    var product: ProductInfo
    var tool = 0
}

struct Node {
    var triple: XPathObject!
    var double: XPathObject!
    var single: XPathObject!
    var none: XPathObject!
}
