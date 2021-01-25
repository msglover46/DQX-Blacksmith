//
//  Commodity.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/26.
//

import RealmSwift
import Firebase

// 製品テーブル
class Product: Object, Codable {
    
    @objc dynamic var id = 0 // 製品ID（主キー）
    @objc dynamic var name = "" // 製品名
    @objc dynamic var productCategoryID = 0 // 製品分類ID
    @objc dynamic var level = 0 // 作成可能レベル
    @objc dynamic var groundMetal = 0 // 地金： 0:なし, 1:たたき変化, 2:メーター減少, 3:集中力変化, 4:威力会心率上昇
    @objc dynamic var successfulProduct = "" // 大成功品名 *製品分類が「家具・庭具」の場合のみ
    var standardValue = List<StandardValue>()
    var recipe = List<Recipe>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

class StandardValue:Object, Codable {
    @objc dynamic var index = 0
    @objc dynamic var max = 0
    @objc dynamic var min = 0
}

class Recipe:Object, Codable {
    @objc dynamic var id = 0
    @objc dynamic var quantity = 0
}
