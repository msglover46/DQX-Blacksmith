//
//  CustomProduct.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/27.
//

import RealmSwift

// カスタム製品テーブル
class CustomProduct: Object {
    
    @objc dynamic var id = 0 // カスタム製品ID（主キー）
    @objc dynamic var name = "" // カスタム製品名
    @objc dynamic var groundMetal = 0 // 地金　0:ノーマル, 1:たたき変化, 2:メーター減少, 3:集中力変化, 4:威力会心率上昇
    @objc dynamic var displayOrder = 0 // 表示順
    @objc dynamic var deleteFlg = 0 // 削除フラグ　0:有効データ, 1:削除済みデータ
    let standardValue = List<StandardValue>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
