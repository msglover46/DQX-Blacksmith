//
//  ProductViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/29.
//

import UIKit
import RealmSwift

protocol SetButtonTitle {
    func returnCraftsmanType(title: String)
    func returnLevel(level: Int)
    func returnCategory(category: Category)
    func returnProduct(product: Product)
    func returnTool(tool: Tool)
}

class ProductViewController: CommonViewController, SetButtonTitle {

    
    @IBOutlet weak var craftsmanTypeButton: SelectItemButton!
    @IBOutlet weak var levelButton: SelectItemButton!
    @IBOutlet weak var productCategoryButton: SelectItemButton!
    @IBOutlet weak var productButton: SelectItemButton!
    @IBOutlet weak var masterButton: SelectItemButton!
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
    
    var craftsmanType = ""
    var level = 0
    var category = Category()
    var product = Product()
    var enabled = true
    var master = true
    var tool = Tool()
    var rate = SuccessRate()
    var time = 0
    var blacksmith = Blacksmith()
     
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawRateBorder() // 成功率の枠線を描く。
        drawTimeBorder() // 1個あたりの作業時間の枠線を描く。
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
        initializeButtonLabels()
    }
    
    func initializeButtonLabels() {
        self.craftsmanType = setCraftsmanButton()
        self.level = setLevelButton(craftsmanType: craftsmanType)
        self.category = setCategoryButton(craftsmanType: craftsmanType)
        let productProperty = setProductButton(category: self.category, level: self.level)
        self.product = productProperty.product
        self.enabled = productProperty.enabled
        self.master = setMasterButton(enabled: self.enabled, master: true)
        self.tool = setToolButton()
        self.setRateTime(enabled: self.enabled, product: self.product, tool: self.tool)
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
    
    func setMasterButton(enabled:Bool, master: Bool) -> Bool {
        if enabled {
            if master {
                self.masterButton.setTitle("あり", for: .normal)
            } else {
                self.masterButton.setTitle("なし", for: .normal)
            }
        } else {
            self.masterButton.setTitle("--", for: .normal)
        }
        return master
    }
    
    @IBAction func selectMaster(_ sender: Any) {
        if self.master {
            self.master = self.setMasterButton(enabled: true, master: false)
        } else {
            self.master = self.setMasterButton(enabled: true, master: true)
        }
    }
    
    func setToolButton() -> Tool {
            let realm = try! Realm()
            let tool = realm.objects(Tool.self).sorted(byKeyPath: "id").first
            let star = tool?.star as! Int
            let toolName = setToolTitle(name: tool!.name, star: star)
            self.toolButton.setTitle(toolName, for: .normal)
        
        return tool!
    }
    
    func setToolTitle(name: String, star:Int) -> String {
        let toolName = name + String(repeating: "★", count: star)
        return toolName
    }
    
    func getProductInformation(product: Product, tool: Tool) -> Blacksmith {
        let realm = try! Realm()
        let keyID = "1.\(product.id).\(tool.id)"
        let blacksmith = realm.objects(Blacksmith.self).filter("keyID == %@", keyID).first ?? Blacksmith()
        return blacksmith
    }
    
    func quantityToRate(quantity: Quantity) -> SuccessRate {
        let rate = SuccessRate()
        rate.triple = Int(Double(quantity.triple) / Double(quantity.total))
        rate.double = Int(Double(quantity.double) / Double(quantity.total))
        rate.single = Int(Double(quantity.single) / Double(quantity.total))
        rate.none = Int(Double(quantity.none) / Double(quantity.total))
        rate.failed = 100 - (rate.triple + rate.double + rate.single + rate.none)
        return rate
    }
  
    func setRateTime(enabled: Bool, product: Product, tool: Tool) {
        if enabled {
            self.blacksmith = self.getProductInformation(product: product, tool: tool)
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
        }
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
            rate = blacksmith.setRate!
            self.referenceRateButton.setTitle("自分で値を設定する", for: .normal)
        
        case 2: // 2:練習の実績値を設定する
            let quantity = blacksmith.practice?.quantity
            rate = quantityToRate(quantity: quantity!)
            self.referenceRateButton.setTitle("練習の実績値を設定する", for: .normal)

        case 3: // 3:本番の実績値を設定する
            let quantity = blacksmith.real?.quantity
            rate = quantityToRate(quantity: quantity!)
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
            seconds = (blacksmith.practice?.time!.total)! / (blacksmith.practice?.quantity!.total)!
            self.referenceTimeButton.setTitle("練習の実績値を設定する", for: .normal)
        case 3: // 3:本番の実績値を設定する
            seconds = (blacksmith.real?.time!.total)! / (blacksmith.real?.quantity!.total)!
            self.referenceTimeButton.setTitle("本番の実績値を設定する", for: .normal)
            
        default:
            break
        }
        
        let mstime = SecondsToMinutes(seconds: seconds)
        let title = String(mstime.minutes) + "分" + String(mstime.seconds) + "秒"
        self.timeLabel.text = title
        
        return seconds
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        
        case "craftsman":
            let nextVC = segue.destination as! SettingProductViewController
            nextVC.delegate = self
            nextVC.button = segue.identifier!
            nextVC.craftsmanType = self.craftsmanType
        case "level":
            let nextVC = segue.destination as! SettingProductViewController
            nextVC.delegate = self
            nextVC.button = segue.identifier!

            nextVC.craftsmanType = self.craftsmanType
            nextVC.level = self.level
        case "category":
            let nextVC = segue.destination as! SettingProductViewController
            nextVC.delegate = self
            nextVC.button = segue.identifier!
            nextVC.craftsmanType = self.craftsmanType
            nextVC.category = self.category
        case "product":
            let nextVC = segue.destination as! SettingProductViewController
            nextVC.delegate = self
            nextVC.button = segue.identifier!
            nextVC.level = self.level
            nextVC.category = self.category
            nextVC.product = self.product
        case "tool":
            let nextVC = segue.destination as! SettingProductViewController
            nextVC.delegate = self
            nextVC.button = segue.identifier!
            nextVC.tool = self.tool
        case "rate":
            let nextVC = segue.destination as! SettingProductViewController
            nextVC.delegate = self
            nextVC.button = segue.identifier!
        case "time":
            let nextVC = segue.destination as! SettingProductViewController
            nextVC.delegate = self
            nextVC.button = segue.identifier!
        case "earnings":
            let nextVC = segue.destination as! ProductInfoViewController
        
        case "real":
            let nextVC = segue.destination as! RealViewController
            
        case "practice":
            let nextVC = segue.destination as! PracticeViewController
        
        default: break
        }
    }
    
    func returnCraftsmanType(title: String) {
        self.craftsmanTypeButton.setTitle(title, for: .normal)
        self.craftsmanType = title
        self.level = setLevelButton(craftsmanType: title)
        self.category = setCategoryButton(craftsmanType: title)
        let productProperty = setProductButton(category: self.category, level: level)
        self.product = productProperty.product
        self.enabled = productProperty.enabled
        self.master = setMasterButton(enabled: self.enabled, master: true)
        self.setRateTime(enabled: self.enabled, product: self.product, tool: self.tool)
    }
    
    func returnLevel(level: Int) {
        self.levelButton.setTitle(String(level), for: .normal)
        self.level = level
        let productProperty = setProductButton(category: self.category, level: level)
        self.product = productProperty.product
        self.enabled = productProperty.enabled
        self.master = setMasterButton(enabled: self.enabled, master: true)
        self.setRateTime(enabled: self.enabled, product: self.product, tool: self.tool)
    }
    
    func returnCategory(category: Category) {
        self.productCategoryButton.setTitle(category.name, for: .normal)
        self.category = category
        let productProperty = setProductButton(category: self.category, level: level)
        self.product = productProperty.product
        self.enabled = productProperty.enabled
        self.master = setMasterButton(enabled: self.enabled, master: true)
        self.setRateTime(enabled: self.enabled, product: self.product, tool: self.tool)
    }
    
    func returnProduct(product: Product) {
        self.productButton.setTitle(product.name, for: .normal)
        self.product = product
        self.enabled = true
        self.master = setMasterButton(enabled: self.enabled, master: true)
        self.setRateTime(enabled: self.enabled, product: self.product, tool: self.tool)
    }
    
    func returnTool(tool: Tool) {
        let toolName = setToolTitle(name: tool.name, star: tool.star)
        self.toolButton.setTitle(toolName, for: .normal)
        self.tool = tool
        self.setRateTime(enabled: self.enabled, product: self.product, tool: self.tool)
    }
}

class MSTime: Object {
    var minutes = 0
    var seconds = 0
}
