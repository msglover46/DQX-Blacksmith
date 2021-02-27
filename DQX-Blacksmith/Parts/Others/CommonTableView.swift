//
//  CommonTableView.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/30.
//

import UIKit

class CommonTableView: UITableView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .white
        self.layer.borderColor = Color.BorderBrown
        self.layer.cornerRadius = 10
        self.isScrollEnabled = false
        
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }

}
