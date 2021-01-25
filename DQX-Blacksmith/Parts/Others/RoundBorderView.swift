//
//  RoundBorder.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/01.
//

import UIKit

class RoundBorderView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        designBorder(rect)
    }

    // 枠線のデザイン
    func designBorder(_ rect: CGRect) {
        
        let borderLayer = CALayer(layer: layer)
        borderLayer.frame = rect
        borderLayer.cornerRadius = 5.0
        borderLayer.borderColor = Color.BorderBrown
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.borderWidth = 1.0
        layer.insertSublayer(borderLayer, at: 0)
    }
}
