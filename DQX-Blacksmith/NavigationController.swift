//
//  NavigationController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/29.
//

import UIKit

class NavigationController: UINavigationController {

    var homeBarButtonItem: UIBarButtonItem!
    var backBarButtonItem: UIBarButtonItem!
    var bookmarkBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = Color.BackGroundColor // 背景色の設定
        navigationBar.tintColor = Color.DarkBrown // アイテム色の設定
        navigationBar.titleTextAttributes = [
            .foregroundColor: Color.DarkBrown, // 文字色の設定
            .font : Font.naviTitle
        ]
        
        //navigationBar.setTitleVerticalPositionAdjustment(5.0, for: .default)

        // ナビゲーションバーの上部に線を描く
        let topBorder = CALayer(layer: navigationBar)
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: navigationBar.frame.width, height:2.0)
        topBorder.backgroundColor = Color.BorderBrown
        navigationBar.layer.addSublayer(topBorder)
        
        // ナビゲーションバーの下部に線を描く
        let bottomBorder = CALayer(layer: navigationBar)
        bottomBorder.frame = CGRect(x: 0.0, y: navigationBar.frame.height - 2.0, width: navigationBar.frame.width, height: 2.0)
        bottomBorder.backgroundColor = Color.BorderBrown
        navigationBar.layer.addSublayer(bottomBorder)
    }

}
