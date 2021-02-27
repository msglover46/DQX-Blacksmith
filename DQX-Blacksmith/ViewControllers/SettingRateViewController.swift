//
//  Setting RateViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/25.
//

import UIKit
import RealmSwift
import SVProgressHUD

class SettingRateViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var delegate: SetButtonTitle?
    var blacksmith = Blacksmith()
    
    @IBOutlet weak var tableView: SettingProductTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = Color.BackGroundColor
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        try! realm.write {
            self.blacksmith.referenceRate = indexPath.row
        }
        let cell = tableView.cellForRow(at: indexPath)!
        switch indexPath.row {
        case 1:
            let tripleTextField = cell.viewWithTag(1) as! DesignedTextField
            let doubleTextField = cell.viewWithTag(2) as! DesignedTextField
            let singleTextField = cell.viewWithTag(3) as! DesignedTextField
            let noneTextField = cell.viewWithTag(4) as! DesignedTextField
            let failedTextField = cell.viewWithTag(5) as! DesignedTextField
            let rate = SuccessRate()
            rate.triple = Int(tripleTextField.text ?? "0") ?? 0
            rate.double = Int(doubleTextField.text ?? "0") ?? 0
            rate.single = Int(singleTextField.text ?? "0") ?? 0
            rate.none = Int(noneTextField.text ?? "0") ?? 0
            rate.failed = Int(failedTextField.text ?? "0") ?? 0
            let rateResult = rateCheck(rate: rate)
            if rateResult {
                try! realm.write {
                    self.blacksmith.setRate = rate
                }
                delegate?.returnRate(blacksmith: self.blacksmith)
                navigationController?.popViewController(animated: false)
            } else {
                cell.isSelected = false
            }
        default:
            delegate?.returnRate(blacksmith: self.blacksmith)
            navigationController?.popViewController(animated: false)
        }
    }
    
    func rateCheck(rate: SuccessRate) -> Bool {
        var status = true
        let sum = rate.triple + rate.double + rate.single + rate.none + rate.failed
        if rate.triple < 0 || rate.triple > 100 {
            status = false
        } else if rate.double < 0 || rate.double > 100 {
            status = false
        } else if rate.single < 0 || rate.single > 100 {
            status = false
        } else if rate.none < 0 || rate.none > 100 {
            status = false
        } else if rate.failed < 0 || rate.failed > 100 {
            status = false
        } else if sum != 100 {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: "合計で100%になるように入力してください。")
            status = false
        }
        return status
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.initialRateCell, for: indexPath)!
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customRateCell, for: indexPath)!
            let tripleTextField = cell.viewWithTag(1) as! DesignedTextField
            let doubleTextField = cell.viewWithTag(2) as! DesignedTextField
            let singleTextField = cell.viewWithTag(3) as! DesignedTextField
            let noneTextField = cell.viewWithTag(4) as! DesignedTextField
            let failedTextField = cell.viewWithTag(5) as! DesignedTextField
            tripleTextField.delegate = self
            doubleTextField.delegate = self
            singleTextField.delegate = self
            noneTextField.delegate = self
            failedTextField.delegate = self
            tripleTextField.text = String(self.blacksmith.setRate?.triple ?? 0)
            doubleTextField.text = String(self.blacksmith.setRate?.double ?? 0)
            singleTextField.text = String(self.blacksmith.setRate?.single ?? 0)
            noneTextField.text = String(self.blacksmith.setRate?.none ?? 0)
            failedTextField.text = String(self.blacksmith.setRate?.failed ?? 0)
            
        case 2, 3:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.performanceRateCell, for: indexPath)!
            let sectionLabel = cell.viewWithTag(1) as! UILabel
            let tripleTimesLabel = cell.viewWithTag(2) as! UILabel
            let doubleTimesLabel = cell.viewWithTag(3) as! UILabel
            let singleTimesLabel = cell.viewWithTag(4) as! UILabel
            let noneTimesLabel = cell.viewWithTag(5) as! UILabel
            let failedTimesLabel = cell.viewWithTag(6) as! UILabel
            let totalTimesLabel = cell.viewWithTag(7) as! UILabel
            let tripleRateLabel = cell.viewWithTag(8) as! UILabel
            let doubleRateLabel = cell.viewWithTag(9) as! UILabel
            let singleRateLabel = cell.viewWithTag(10) as! UILabel
            let noneRateLabel = cell.viewWithTag(11) as! UILabel
            let failedRateLabel = cell.viewWithTag(12) as! UILabel
            let totalRateLabel = cell.viewWithTag(13) as! UILabel
            var quantity = Quantity()
            if indexPath.row == 2 {
                sectionLabel.text = "練習の実績値を設定する"
                quantity = self.blacksmith.practice?.quantity ?? Quantity()
            } else if indexPath.row == 3 {
                sectionLabel.text = "本番の実績値を設定する"
                quantity = self.blacksmith.real?.quantity ?? Quantity()
            }
            let rate = quantityToRate(quantity: quantity)
            tripleTimesLabel.text = String(quantity.triple) + " 回"
            doubleTimesLabel.text = String(quantity.double) + " 回"
            singleTimesLabel.text = String(quantity.single) + " 回"
            noneTimesLabel.text = String(quantity.none) + " 回"
            failedTimesLabel.text = String(quantity.failed) + " 回"
            totalTimesLabel.text = String(quantity.total) + " 回"
            tripleRateLabel.text = String(rate.triple) + " %"
            doubleRateLabel.text = String(rate.double) + " %"
            singleRateLabel.text = String(rate.single) + " %"
            noneRateLabel.text = String(rate.single) + " %"
            failedRateLabel.text = String(rate.failed) + " %"
            totalRateLabel.text = ""
            
        default:
            break
        }
        
        cell.backgroundColor = Color.BackGroundColor
        let checkedCellIndexPathRow = self.blacksmith.referenceRate
        if indexPath.row == checkedCellIndexPathRow {
            cell.accessoryType = .checkmark
            cell.tintColor = Color.DarkBrown
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.row {
        case 0:
            return indexPath
        case 1:
            return indexPath
        case 2:
            let total = self.blacksmith.practice?.quantity?.total ?? 0
            if total > 0 {
                return indexPath
            } else {
                return nil
            }
        case 3:
            let total = self.blacksmith.real?.quantity?.total ?? 0
            if total > 0 {
                return indexPath
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
            textField.selectAll(textField.text)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let number = Int(textField.text ?? "0") ?? 0
        if number < 0 || number > 100 {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: "0〜100の整数を入力してください。")
            textField.text = ""
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
}
