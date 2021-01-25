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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        designTextField()
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

}
