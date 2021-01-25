//
//  TitleLabel.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/01.
//

import UIKit

class TitleLabel: UILabel {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        designLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        designLabel()
    }
    
    func designLabel() {
        self.textColor = Color.DarkBrown
        self.backgroundColor = Color.BackGroundColor
        self.font = Font.itemTitle
        self.sizeToFit()
    }
}
