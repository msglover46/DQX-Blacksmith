//
//  ProductInfoViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/31.
//

import UIKit
import RealmSwift
import SVProgressHUD
import Alamofire
import Kanna
import TPKeyboardAvoiding

class ProductInfoViewController: CommonViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: SetButtonTitle?
    var blacksmith = Blacksmith()
    var rate = SuccessRate()
    var time = 1
    var product = Product()
    var tool = Tool()
    var category = Category()
    var recipe = List<Recipe>()
    var times = 1
    var hrefs: [Href] = []
    var initPrice = Price(product: ProductInfo())
    var price = Price(product: ProductInfo())
    var node = Node()
    var result = CalcResult()
    let realm = try! Realm()
    let cellHeight = CGFloat(50.0)
    var cellCount = ["material": 0, "tool": 1, "product": 0]
    let formatter = NumberFormatter()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timesTextField: DesignedTextField!
    @IBOutlet weak var toolButton: PushButton!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var costPriceLabel: UILabel!
    @IBOutlet weak var materialTableView: UITableView!
    @IBOutlet weak var materialTableHeight: NSLayoutConstraint!
    @IBOutlet weak var toolTableView: UITableView!
    @IBOutlet weak var toolTableHeight: NSLayoutConstraint!
    @IBOutlet weak var earningLabel: UILabel!
    @IBOutlet weak var earningPriceLabel: UILabel!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var productTableHeight: NSLayoutConstraint!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var profitPriceLabel: UILabel!
    @IBOutlet weak var profitHourLabel: UILabel!
    @IBOutlet weak var profitHourPriceLabel: UILabel!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    @IBAction func changeTimes(_ sender: Any) {
        timesTextField.text = String(self.tool.times)
        self.times = self.tool.times
        self.result = self.calcEarning(price: self.price)
        try! realm.write {
            self.blacksmith.times = self.times
            realm.add(self.blacksmith, update: .modified)
        }
    }

    @IBAction func resetCost(_ sender: Any) {
        self.price.tool = self.initPrice.tool
        self.price.material = self.initPrice.material
        self.materialTableView.reloadData()
        self.toolTableView.reloadData()
        self.result = self.calcEarning(price: self.price)
    }
    
    @IBAction func resetEarning(_ sender: Any) {
        self.price.product = self.initPrice.product
        self.productTableView.reloadData()
        self.result = self.calcEarning(price: self.price)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        timesTextField.delegate = self
        timesTextField.text = formatter.string(from: NSNumber(integerLiteral: blacksmith.times))
        times = blacksmith.times
        materialTableView.delegate = self
        materialTableView.dataSource = self
        toolTableView.delegate = self
        toolTableView.dataSource = self
        productTableView.delegate = self
        productTableView.dataSource = self
        costLabel.backgroundColor = Color.DarkBrown
        costLabel.textColor = .white
        earningLabel.backgroundColor = Color.DarkBrown
        earningLabel.textColor = .white
        profitLabel.backgroundColor = Color.DarkBrown
        profitLabel.textColor = .white
        profitHourLabel.backgroundColor = Color.DarkBrown
        profitHourLabel.textColor = .white
        contentView.backgroundColor = Color.BackGroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.product = realm.objects(Product.self).filter("id == %@", self.blacksmith.productID).first!
        self.category = realm.objects(Category.self).filter("id == %@", self.product.productCategoryID).first!
        self.tool = realm.objects(Tool.self).filter("id == %@", self.blacksmith.toolID).first!
        self.title = product.name
        for row in self.product.recipe {
            if row.id > 0 {
                self.recipe.append(row)
            }
        }
        self.setCellCount()
        self.result = self.calcEarning(price: self.price)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.materialTableHeight.constant = CGFloat(materialTableView.contentSize.height)
        self.toolTableHeight.constant = CGFloat(toolTableView.contentSize.height)
        self.productTableHeight.constant = CGFloat(productTableView.contentSize.height)
        scrollView.contentSize = contentView.frame.size
        scrollView.flashScrollIndicators()
        self.contentViewHeight.constant = self.profitHourLabel.frame.maxY + CGFloat(10.0)
    }

    func setCellCount() {
        cellCount["material"] = self.recipe.count
        cellCount["tool"] = 1
        var count = 0
        if category.name == "素材" {
            count = 1
        } else if category.name == "家具・庭具" {
            count = 2
        } else {
            count = 4
        }
        cellCount["product"] = count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch tableView {
        case materialTableView:
            count = cellCount["material"]!
        case toolTableView:
            count = cellCount["tool"]!
        case productTableView:
            count = cellCount["product"]!
        default:
            break
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return showTableData(tableView, indexPath: indexPath, price: self.price)
    }
    
    func showTableData(_ tableView: UITableView, indexPath: IndexPath, price: Price) -> UITableViewCell {
        
        switch tableView {
        case materialTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.materialCell, for: indexPath)!
            let materialLabel = cell.viewWithTag(1) as! UILabel
            let priceTextField = cell.viewWithTag(2) as! DesignedTextField
            let quantityLabel = cell.viewWithTag(3) as! UILabel
            priceTextField.delegate = self
            let material = realm.objects(Material.self).filter("id == %@", self.recipe[indexPath.row].id).first
            materialLabel.text = material?.name
            let materialPrice = price.material.filter{$0.id == self.recipe[indexPath.row].id}.first!.price
            priceTextField.text = formatter.string(from: NSNumber(integerLiteral: materialPrice))
            quantityLabel.text = String(self.recipe[indexPath.row].quantity) + "個"
            if indexPath.row == cellCount["material"]! - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            return cell
        case toolTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.toolCell, for: indexPath)!
            let toolLabel = cell.viewWithTag(1) as! UILabel
            let priceTextField = cell.viewWithTag(2) as! DesignedTextField
            priceTextField.delegate = self
            toolLabel.text = self.tool.name + " " + String(repeating: "★", count: self.tool.star)
            priceTextField.text = formatter.string(from: NSNumber(integerLiteral: price.tool ))
            if indexPath.row == cellCount["tool"]! - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            return cell
        case productTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productCell, for: indexPath)!
            let productLabel = cell.viewWithTag(1) as! UILabel
            let priceTextField = cell.viewWithTag(2) as! DesignedTextField
            priceTextField.delegate = self
            switch category.name {
            case "素材":
                productLabel.text = self.product.name
                priceTextField.text = formatter.string(from: NSNumber(integerLiteral: price.product.none ))
            case "家具・庭具":
                if indexPath.row == 0 {
                    productLabel.text = self.product.name
                    priceTextField.text = formatter.string(from: NSNumber(integerLiteral: price.product.none ))
                    // 家具・庭具の場合は、成功品：None、大成功品：triple
                } else {
                    productLabel.text = self.product.successfulProduct
                    priceTextField.text = formatter.string(from: NSNumber(integerLiteral: price.product.triple ))
                }
            default:
                productLabel.text = self.product.name + " " + String(repeating: "★", count: 3 - indexPath.row)
                switch indexPath.row {
                case 0:
                    priceTextField.text = formatter.string(from: NSNumber(integerLiteral: price.product.triple ))
                case 1:
                    priceTextField.text = formatter.string(from: NSNumber(integerLiteral: price.product.double ))
                case 2:
                    priceTextField.text = formatter.string(from: NSNumber(integerLiteral: price.product.single ))
                case 3:
                    priceTextField.text = formatter.string(from: NSNumber(integerLiteral: price.product.none ))
                default:
                    break
                }
            }
            if indexPath.row == cellCount["product"]! - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.materialCell, for: indexPath)!
            return cell
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = "0123456789"
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: string)
        let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
        return alphabet
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.keyboardType = .numberPad
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            textField.text = textField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
            textField.selectAll(textField.text)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == timesTextField {
            let times = Int(textField.text ?? "0")!
            if times <= 0 || times >= 1000 {
                SVProgressHUD.showError(withStatus: "1以上999以下の値を入力してくだい。")
                textField.text = formatter.string(from:NSNumber(integerLiteral: self.times))
            }
            self.times = Int(textField.text ?? "1") ?? 1
            self.result = self.calcEarning(price: self.price)
            try! realm.write {
                self.blacksmith.times = self.times
                realm.add(self.blacksmith, update: .modified)
            }
        } else {
            let number = Int(textField.text ?? "0") ?? 0
            if number >= 1000000000 {
                SVProgressHUD.showError(withStatus: "値段は999,999,999G以下の値を入力してください。")
                textField.text = "0"
            }
            self.price = self.getTextFieldValues()
            self.result = self.calcEarning(price: self.price)
        }
        textField.text = formatter.string(from: NSNumber(integerLiteral: Int(textField.text ?? "0") ?? 0))
    }
    
    func calcEarning(price: Price) -> CalcResult {
        var result = CalcResult()
        
        // 原価の計算
        var totalCost = 0
        for material in price.material {
            let quantity = self.recipe.filter{$0.id == material.id}.first!.quantity
            totalCost += material.price * quantity
        }
        totalCost *= self.tool.times
        totalCost += price.tool
        
        result.cost = Int(totalCost / self.tool.times) * self.times
        
        // 売上の計算
        var totalEarning = 0.0
        if self.category.name == "素材" {
            totalEarning = Double(self.price.product.none) * 0.95 * Double(self.rate.triple) * 0.01 * 10
            totalEarning += Double(self.price.product.none) * 0.95 * Double(self.rate.double) * 0.01 * 3
            totalEarning += Double(self.price.product.none) * 0.95 * Double(self.rate.single) * 0.01 * 2
            totalEarning += Double(self.price.product.none) * 0.95 * Double(self.rate.none) * 0.01 * 1
            result.earning = Int(totalEarning)
        } else if self.category.name == "家具・庭具" {
            totalEarning = Double(self.price.product.triple) * 0.95 * Double(self.rate.triple) * 0.01
            totalEarning += Double(self.price.product.none) * 0.95 * Double(self.rate.double) * 0.01
            totalEarning += Double(self.price.product.none) * 0.95 * Double(self.rate.single) * 0.01
            totalEarning += Double(self.price.product.none) * 0.95 * Double(self.rate.none) * 0.01
            result.earning = Int(totalEarning)
        } else {
            totalEarning = Double(self.price.product.triple) * 0.95 * Double(self.rate.triple) * 0.01
            totalEarning += Double(self.price.product.double) * 0.95 * Double(self.rate.double) * 0.01
            totalEarning += Double(self.price.product.single) * 0.95 * Double(self.rate.single) * 0.01
            totalEarning += Double(self.price.product.none) * 0.95 * Double(self.rate.none) * 0.01
            result.earning = Int(totalEarning)
        }
        result.earning *= self.times
        
        // 利益の計算
        result.profit = result.earning - result.cost
        
        // 時給の計算
        let quantity = Int(3600 / self.time)
        result.profitHour = result.profit * quantity / self.times
        
        if result.profit < 0 {
            self.profitPriceLabel.textColor = .red
            self.profitHourPriceLabel.textColor = .red
        } else {
            self.profitPriceLabel.textColor = .black
            self.profitHourPriceLabel.textColor = .black
        }

        self.costPriceLabel.text = formatter.string(from: NSNumber(integerLiteral: result.cost))! + " G"
        self.earningPriceLabel.text = formatter.string(from: NSNumber(integerLiteral: result.earning))! + " G"
        self.profitPriceLabel.text = formatter.string(from: NSNumber(integerLiteral: result.profit))! + " G"
        self.profitHourPriceLabel.text = formatter.string(from: NSNumber(integerLiteral: result.profitHour))! + " G"
        return result
    }
    
    func getTextFieldValues() -> Price {
        var price = Price(product: ProductInfo())
        for i in 0...cellCount["material"]! - 1 {
            var materialInfo = MaterialInfo()
            let cell = materialTableView.cellForRow(at: [0, i])
            let priceTextField = cell?.viewWithTag(2) as! DesignedTextField
            let materialPrice = Int(priceTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil) ?? "0") ?? 0
            materialInfo.id = self.recipe[i].id
            materialInfo.price = materialPrice
            price.material.append(materialInfo)
        }
        
        let cell = toolTableView.cellForRow(at: [0, 0])
        let priceTextField = cell?.viewWithTag(2) as! DesignedTextField
        price.tool = Int(priceTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil) ?? "0") ?? 0
        
        if self.category.name == "素材" {
            let cell = productTableView.cellForRow(at: [0, 0])
            let priceTextField = cell?.viewWithTag(2) as! DesignedTextField
            price.product.none = Int(priceTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil) ?? "0") ?? 0
        } else if self.category.name == "家具・庭具" {
            let normalCell = productTableView.cellForRow(at: [0, 0])
            let normalPriceTextField = normalCell?.viewWithTag(2) as! DesignedTextField
            price.product.none = Int(normalPriceTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil) ?? "0") ?? 0
            let successCell = productTableView.cellForRow(at: [0, 1])
            let successPriceTextField = successCell?.viewWithTag(2) as! DesignedTextField
            price.product.triple = Int(successPriceTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil) ?? "0") ?? 0
        } else {
            for i in 0...cellCount["product"]! - 1 {
                let cell = productTableView.cellForRow(at: [0, i])
                let priceTextField = cell?.viewWithTag(2) as! DesignedTextField
                let productPrice = Int(priceTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil) ?? "0") ?? 0
                
                switch i {
                case 0:
                    price.product.triple = productPrice
                case 1:
                    price.product.double = productPrice
                case 2:
                    price.product.single = productPrice
                case 3:
                    price.product.none = productPrice
                default:
                    break
                }
            }
        }
        return price
    }
}

struct CalcResult {
    var cost = 0
    var earning = 0
    var profit = 0
    var profitHour = 0
}
