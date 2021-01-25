//
//  Category.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/27.
//

import RealmSwift

// 製品カテゴリーテーブル
class Category: Object, Codable {
    
    @objc dynamic var id = 0 // 製品分類ID（主キー）
    @objc dynamic var name = "" // 製品分類名
    @objc dynamic var craftsmanType = "" // 職人種類 {武器鍛冶, 防具鍛冶, 道具鍛冶}
    @objc dynamic var maxError: MaxError!
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class MaxError: Object, Codable {
    @objc dynamic var triple = 0
    @objc dynamic var double = 0
    @objc dynamic var single = 0
    @objc dynamic var none = 0
}
