//
//  Level.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/27.
//

import Firebase
import RealmSwift

// レベルテーブル
class Level: Object, Codable {
    
    @objc dynamic var level = 0 // 職人レベル（主キー）
    @objc dynamic var concentration = 0 // 集中力
    @objc dynamic var skill:Skill!
    @objc dynamic var criticalRate = 0.0 // 会心率
    
    override static func primaryKey() -> String? {
        return "level"
    }
}

class Skill: Object, Codable {
    @objc dynamic var name = ""
    @objc dynamic var concentration = 0
}
