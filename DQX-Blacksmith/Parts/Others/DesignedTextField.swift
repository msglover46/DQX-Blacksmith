//
//  DesignedTextField.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/01.
//

import UIKit

class DesignedTextField: UITextField {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        designTextField()
        designKeyboard()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        designTextField()
        designKeyboard()
    }
    
    func designTextField() {
        layer.borderColor = Color.BorderGray
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        backgroundColor = Color.Gray
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    func designKeyboard() {
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default
        kbToolBar.sizeToFit()

        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.commitButtonTapped))
        kbToolBar.items = [spacer, commitButton]
        self.inputAccessoryView = kbToolBar
    }
    
    @objc func commitButtonTapped (){
        self.endEditing(true)
    }
}
