//
//  Material.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/27.
//

import RealmSwift

// 材料テーブル
class Material: Object, Codable {
    
    @objc dynamic var id = 0 // 材料ID（主キー）
    @objc dynamic var name = "" // 材料名
    @objc dynamic var category = "" // 材料分類
    @objc dynamic var price = 0 // 店買値
    var store = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
