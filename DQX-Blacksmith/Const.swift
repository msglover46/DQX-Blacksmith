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
    static let White = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    static let BorderBrown = DarkBrown.cgColor
    static let BorderGray = CGColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    
    
    static let BorderGreen = CGColor(red: 109/255, green: 212/255, blue: 0, alpha: 1.0)
    static let StartGreen = CGColor(red: 239/255, green: 247/255, blue: 221/255, alpha: 1.0)
    static let EndGreen = CGColor(red: 218/255, green: 236/255, blue: 184/255, alpha: 1.0)
    
    static let BorderPink = CGColor(red: 255/255, green: 142/255, blue: 251/255, alpha: 1.0)
    static let StartPink = CGColor(red: 247/255, green: 207/255, blue: 255/255, alpha: 1.0)
    static let EndPink = CGColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
    
    static let BorderOrange = CGColor(red: 247/255, green: 181/255, blue: 0, alpha: 1.0)
    static let StartYellow = CGColor(red: 253/255, green: 252/255, blue: 143/255, alpha: 1.0)
    static let EndYellow = CGColor(red: 250/255, green: 247/255, blue: 103/255, alpha: 1.0)
    
    static let BorderBlue = CGColor(red: 50/255, green: 197/255, blue: 255/255, alpha: 1.0)
    static let StartBlue = CGColor(red: 207/255, green: 255/255, blue: 253/255, alpha: 1.0)
    static let EndBlue = CGColor(red: 235/255, green: 245/255, blue: 245/255, alpha: 1.0)
    
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
    static let naviTitle = UIFont.systemFont(ofSize: 20.0)
    static let itemTitle = UIFont.systemFont(ofSize: 18.0)
    static let tableText = UIFont.systemFont(ofSize: 18.0)
}
