//
//  SelectItemButton.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/31.
//

import UIKit

class SelectItemButton: UIButton {
    
    // storyboard上でボタンを実装した場合に呼ばれる初期化処理
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // コード上でボタンを実装した場合に呼ばれる初期化処理
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // frameを利用している処理はAutoLayout反映後のタイミングで行わないとズレる。
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        designButton()
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        if state == .normal {
            UIView.performWithoutAnimation {
                super.setTitle(title, for: state)
                if title == "--" {
                    self.isEnabled = false
                } else {
                    self.isEnabled = true
                }
                self.layoutIfNeeded()
            }
        } else {
            super.setTitle(title, for: state)
        }
    }
    
    func designButton(){
        self.setTitleColor(UIColor.black, for: .normal)
                
        let gradientColors = [Color.StartGray, Color.EndGray]
        let gradientLocations: [NSNumber] = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        gradientLayer.frame = CGRect(origin: .zero, size: self.bounds.size)
        gradientLayer.cornerRadius = 5.0
        gradientLayer.borderColor = Color.BorderGray
        gradientLayer.borderWidth = 1.0
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
