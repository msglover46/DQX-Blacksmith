//
//  Const.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/27.
//

import UIKit

struct Color {
    static let BackGroundColor = UIColor(red: 255/255, green: 245/255, blue: 234/255, alpha: 1.0)
        
    static let DarkBrown = UIColor(red: 130/255, green: 64/255, blue: 20/255, alpha: 1.0)
    static let Gray = UIColor(red: 244/255, green: 238/255, blue: 238/255, alpha: 1.0)
    static let Yellow = UIColor(red: 248/255, green: 250/255, blue: 180/255, alpha: 1.0)
    static let Green = UIColor(red: 239/255, green: 247/255, blue: 211/255, alpha: 1.0)
    
    static let BorderBrown = DarkBrown.cgColor
    static let BorderGray = CGColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    static let BorderOrange = CGColor(red: 247/255, green: 181/255, blue: 0, alpha: 1.0)
    static let BorderGreen = CGColor(red: 109/255, green: 212/255, blue: 0, alpha: 1.0)
    
    static let StartGreen = CGColor(red: 239/255, green: 247/255, blue: 221/255, alpha: 1.0)
    static let EndGreen = CGColor(red: 218/255, green: 236/255, blue: 184/255, alpha: 1.0)
    
    static let StartGray = CGColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
    static let EndGray = CGColor(red: 233/255, green: 218/255, blue: 218/255, alpha: 1.0)
}
    
struct Path {
    static let StartCollectionPath = "start"
    static let ProductCollectionPath = "product"
    static let LevelCollectionPath = "level"
    static let MaterialCollectionPath = "material"
    static let CategoryCollectionPath = "category"
    static let ToolCollectionPath = "tool"
}

struct Font {
    static let naviTitle = UIFont.systemFont(ofSize: 28.0)
    static let itemTitle = UIFont.systemFont(ofSize: 18.0)
    static let tableText = UIFont.systemFont(ofSize: 18.0)
}
