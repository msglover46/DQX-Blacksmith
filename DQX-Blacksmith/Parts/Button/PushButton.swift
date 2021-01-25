//
//  PushButton.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/01.
//

import UIKit

class PushButton: UIButton {

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
    
    func designButton(){
        self.setTitleColor(UIColor.black, for: .normal)
        
        let gradientColors = [Color.StartGreen, Color.EndGreen]
        let gradientLocations: [NSNumber] = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.frame = CGRect(origin: .zero, size: self.bounds.size)
        gradientLayer.cornerRadius = self.bounds.midY
        gradientLayer.borderColor = Color.BorderGreen
        gradientLayer.borderWidth = 1.0
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
