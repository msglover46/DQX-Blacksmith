//
//  SubButton.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/01.
//

import UIKit
import MaterialComponents

class SubButton: MDCFloatingButton {
    // storyboard上でボタンを実装した場合に呼ばれる初期化処理
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        designButton()
    }
    
    // コード上でボタンを実装した場合に呼ばれる初期化処理
    required override init(frame: CGRect, shape: MDCFloatingButtonShape) {
        super.init(frame: frame, shape: shape)
        designButton()
    }
    
    func designButton(){
        tintColor = UIColor.white
        backgroundColor = Color.DarkBrown
    }

}
