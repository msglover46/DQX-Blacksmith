//
//  File.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/27.
//

import RealmSwift

// 材料ブックマークテーブル
class MaterialBookmark: Object {
    
    @objc dynamic var id = 0 // 材料ID（主キー）
    @objc dynamic var bookmark = 0 // ブックマーク 0:なし, 1:あり
    @objc dynamic var displayOrder = 0 // 表示順
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
