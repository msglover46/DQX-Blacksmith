//
//  SelectViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/18.
//

import UIKit
import RealmSwift

class SettingProductViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource{

    var delegate: SetButtonTitle?
    var button = ""
    let craftsmanArray = ["武器鍛冶", "防具鍛冶", "道具鍛冶"]
    var craftsmanType = ""
    let levelArray = try! Realm().objects(Level.self).sorted(byKeyPath: "level", ascending: false)
    var level = 0
    var category = Category()
    var categoryArray = try! Realm().objects(Category.self)
    var product = Product()
    var productArray = try! Realm().objects(Product.self)
    var tool = Tool()
    var toolArray = try! Realm().objects(Tool.self)
    
    @IBOutlet weak var tableView: SettingProductTableView!
    
    func setToolTitle(name: String, star:Int) -> String {
        let toolName = name + String(repeating: "★", count: star)
        return toolName
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        if self.button == "craftsman" {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        switch self.button {
        case "craftsman":
            self.title = "職人種類"
        case "level":
            self.title = "レベル"
        case "category":
            self.categoryArray = self.categoryArray.filter("craftsmanType = %@", self.craftsmanType).sorted(byKeyPath: "id")
            self.title = "カテゴリー"
        case "product":
            self.productArray = self.productArray.filter("level <= %@ && productCategoryID == %@", self.level, self.category.id).sorted(byKeyPath: "id", ascending: true)
            self.title = "アイテム"
        case "tool":
            self.title = "職人道具"
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.button {
        case "craftsman":
            let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell", for: indexPath)
            cell.backgroundColor =  Color.BackGroundColor
            cell.textLabel?.text = craftsmanArray[indexPath.row]
            cell.textLabel?.font = Font.tableText
            if cell.textLabel?.text == craftsmanType {
                cell.accessoryType = .checkmark
                cell.tintColor = Color.DarkBrown
            } else {
                cell.accessoryType = .none
            }
            return cell
            
        case "level":
            let cell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath)
            cell.backgroundColor =  Color.BackGroundColor
            let level = self.levelArray[indexPath.row]
            let levelLabel = cell.viewWithTag(1) as! UILabel
            levelLabel.text = String(level.level)
            let concentrationLabel = cell.viewWithTag(2) as! UILabel
            concentrationLabel.text = "集中力：" + String(level.concentration)
            if levelLabel.text == String(self.level) {
                cell.accessoryType = .checkmark
                cell.tintColor = Color.DarkBrown
            } else {
                cell.accessoryType = .none
            }
            let skillLabel = cell.viewWithTag(3) as! UILabel
            skillLabel.text = level.skill.name
            
            return cell
            
        case "category":
            let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell", for: indexPath)
            cell.backgroundColor =  Color.BackGroundColor
            cell.textLabel?.text = categoryArray[indexPath.row].name
            cell.textLabel?.font = Font.tableText
            if cell.textLabel?.text == self.category.name {
                cell.accessoryType = .checkmark
                cell.tintColor = Color.DarkBrown
            } else {
                cell.accessoryType = .none
            }
            return cell
        
        case "product":
            let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell", for: indexPath)
            cell.backgroundColor = Color.BackGroundColor
            cell.textLabel?.text = productArray[indexPath.row].name
            cell.textLabel?.font = Font.tableText
            if cell.textLabel?.text == self.product.name {
                cell.accessoryType = .checkmark
                cell.tintColor = Color.DarkBrown
            } else {
                cell.accessoryType = .none
            }
            return cell
            
        case "tool":
            let cell = tableView.dequeueReusableCell(withIdentifier: "toolCell", for: indexPath)
            cell.backgroundColor = Color.BackGroundColor
            let toolLabel = cell.viewWithTag(1) as! UILabel
            let concentrationLabel = cell.viewWithTag(2) as! UILabel
            let criticalLabel = cell.viewWithTag(3) as! UILabel
            let tool = toolArray[indexPath.row]
            let toolName = self.setToolTitle(name: tool.name, star: tool.star)
            toolLabel.text = toolName
            concentrationLabel.text = "集中＋" + String(tool.concentration)
            criticalLabel.text = "会心＋" + String(tool.criticalRate)
            if toolLabel.text == setToolTitle(name: self.tool.name, star: self.tool.star) {
                cell.accessoryType = .checkmark
                cell.tintColor = Color.DarkBrown
            } else {
                cell.accessoryType = .none
            }
            return cell

        default:
            return tableView.dequeueReusableCell(withIdentifier: "normalCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.button {
        case "craftsman":
            let userdefault = UserDefaults.standard
            userdefault.setValue(craftsmanArray[indexPath.row], forKey: "craftsman")
            delegate?.returnCraftsmanType(title: craftsmanArray[indexPath.row])
        case "level":
            level = levelArray[indexPath.row].level
            let userdefault = UserDefaults.standard
            var levels = userdefault.dictionary(forKey: "level")
            levels![self.craftsmanType] = level
            userdefault.setValue(levels, forKey: "level")
            delegate?.returnLevel(level: level)
        case "category":
            category = categoryArray[indexPath.row]
            delegate?.returnCategory(category: category)
        case "product":
            product = productArray[indexPath.row]
            delegate?.returnProduct(product: product)
        case "tool":
            tool = toolArray[indexPath.row]
            delegate?.returnTool(tool: tool)
        default:
            break
        }
        navigationController?.popViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch self.button {
        case "craftsman":
            count = self.craftsmanArray.count
        case "level":
            count = self.levelArray.count
        case "category":
            count = self.categoryArray.count
        case "product":
            count = self.productArray.count
        case "tool":
            count = self.toolArray.count
        default:
            break
        }
        return count
    }

}
