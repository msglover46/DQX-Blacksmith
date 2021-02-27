//
//  SkillButton.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/02/06.
//

import UIKit

class SkillButton: UIButton {
    
    var color = "yellow"

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
        self.designButton()
    }
    
    func designButton(){
        self.setTitleColor(UIColor.black, for: .normal)
        var gradientColors = [Color.StartGreen, Color.EndGreen]

        let gradientLocations: [NSNumber] = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        switch self.color {
        case "green":
            gradientLayer.borderColor = Color.BorderGreen
            gradientColors = [Color.StartGreen, Color.EndGreen]
        case "yellow":
            gradientLayer.borderColor = Color.BorderOrange
            gradientColors = [Color.StartYellow, Color.EndYellow]
        case "blue":
            gradientLayer.borderColor = Color.BorderBlue
            gradientColors = [Color.StartBlue, Color.EndBlue]
        case "pink":
            gradientLayer.borderColor = Color.BorderPink
            gradientColors = [Color.StartPink, Color.EndPink]
        case "gray":
            gradientLayer.borderColor = Color.BorderGray
            gradientColors = [Color.StartGray, Color.EndGray]
        default:
            break
        }
        
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.frame = CGRect(origin: .zero, size: self.bounds.size)
        gradientLayer.cornerRadius = self.bounds.midY / 2

        gradientLayer.borderWidth = 1.0
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

}
