//
//  SettingTimeViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/25.
//

import UIKit
import RealmSwift
import SVProgressHUD

class SettingTimeViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    var delegate: SetButtonTitle?
    var blacksmith = Blacksmith()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = Color.BackGroundColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        let cell = tableView.cellForRow(at: indexPath)!
        switch indexPath.row {
        case 1:
            let minutesTextField = cell.viewWithTag(1) as! DesignedTextField
            let secondsTextField = cell.viewWithTag(2) as! DesignedTextField
            let mstime = MSTime()
            mstime.minutes = Int(minutesTextField.text ?? "0") ?? 0
            mstime.seconds = Int(secondsTextField.text ?? "0") ?? 0
            let timeResult = checkTime(mstime: mstime)
            if timeResult {
                try! realm.write {
                    self.blacksmith.setTime = mstime.minutes * 60 + mstime.seconds
                    self.blacksmith.referenceTime = indexPath.row
                }
                delegate?.returnTime(blacksmith: blacksmith)
                navigationController?.popViewController(animated: false)
            } else {
                cell.isSelected = false
            }
        default:
            try! realm.write {
                self.blacksmith.referenceTime = indexPath.row
            }
            delegate?.returnTime(blacksmith: blacksmith)
            navigationController?.popViewController(animated: false)
        }
    }
    
    func checkTime(mstime: MSTime) -> Bool {
        var status = true
        let time = mstime.minutes * 60 + mstime.seconds
        if mstime.minutes < 0 || mstime.minutes > 60 {
            status = false
        } else if mstime.seconds < 0 || mstime.seconds > 60 {
            status = false
        } else if time == 0 {
            status = false
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: "1秒〜59分59秒の値を入力してください。")
        }
        return status
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.initialTimeCell, for: indexPath)!
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customTimeCell, for: indexPath)!
            let minutesTextField = cell.viewWithTag(1) as! DesignedTextField
            let secondsTextField = cell.viewWithTag(2) as! DesignedTextField
            minutesTextField.delegate = self
            secondsTextField.delegate = self
            let mstime = SecondsToMinutes(seconds: self.blacksmith.setTime)
            minutesTextField.text = String(mstime.minutes)
            secondsTextField.text = String(mstime.seconds)
            
        case 2, 3:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.performanceTimeCell, for: indexPath)!
            let sectionLabel = cell.viewWithTag(1) as! UILabel
            let meanLabel = cell.viewWithTag(2) as! UILabel
            let bestLabel = cell.viewWithTag(3) as! UILabel
            var quantity = Quantity()
            var time = Time()
            if indexPath.row == 2 {
                sectionLabel.text = "練習の実績値を設定する"
                quantity = self.blacksmith.practice?.quantity ?? Quantity()
                time = self.blacksmith.practice?.time ?? Time()
            } else if indexPath.row == 3 {
                sectionLabel.text = "本番の実績値を設定する"
                quantity = self.blacksmith.real?.quantity ?? Quantity()
                time = self.blacksmith.real?.time ?? Time()
            }
            let msbest = SecondsToMinutes(seconds: time.best)
            var meanSeconds = 0
            if quantity.total > 0 {
                meanSeconds = time.total / quantity.total
            }
            let msmean = SecondsToMinutes(seconds: meanSeconds)
            meanLabel.text = String(msmean.minutes) + "分" + String(msmean.seconds) + "秒"
            bestLabel.text = String(msbest.minutes) + "分" + String(msbest.seconds) + "秒"
            
        
        default:
            break
        }
        cell.backgroundColor = Color.BackGroundColor
        let checkedCellIndexPathRow = self.blacksmith.referenceTime
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
        if number < 0 || number > 59 {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: "0〜59の間で入力してください。")
            textField.text = ""
        }
    }
    
    func SecondsToMinutes(seconds: Int) -> MSTime {
        let minute: Int = seconds / 60
        let second: Int = seconds % 60
        let mstime = MSTime()
        mstime.minutes = minute
        mstime.seconds = second
        return mstime
    }
}
