//
//  Tool.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/27.
//

import RealmSwift

// 職人道具テーブル
class Tool: Object, Codable {
    
    @objc dynamic var id = 0 // 職人道具ID（主キー）
    @objc dynamic var name = "" // 職人道具名
    @objc dynamic var star = 0 // できのよさ
    @objc dynamic var concentration = 0 // 集中力
    @objc dynamic var criticalRate = 0.0 // 会心率（%）
    @objc dynamic var times = 0 // 使用回数
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
