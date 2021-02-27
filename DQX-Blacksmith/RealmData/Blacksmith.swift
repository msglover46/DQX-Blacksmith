//
//  Blacksmith.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/27.
//

import RealmSwift

// 鍛冶テーブル
class Blacksmith: Object {

    @objc dynamic var productClass = 0 // 製品クラス 1:製品, 2:カスタム製品（主キー）
    @objc dynamic var productID = 0 // 製品ID（主キー）
    @objc dynamic var toolID = 0 // 職人道具ID（主キー）
    @objc dynamic var keyID = "" // 複合キー（製品クラス.製品ID.職人道具ID）
    @objc dynamic var practice: Performance? // 練習実績
    @objc dynamic var real: Performance? // 本番実績
    @objc dynamic var setRate: SuccessRate? // 前回の成功率
    @objc dynamic var setTime = 0 // 前回の作業時間
    @objc dynamic var referenceRate = 0 // 成功率参照先
    @objc dynamic var referenceTime = 0 // 作業時間参照先
     /* 参照先     0:初期値を設定する, 1: 前回の値を設定する
                  2:練習での実測値を設定する, 3:本番での実測値を設定する    */
    @objc dynamic var times = 1 // 利益算出時の職人回数
    @objc dynamic var masterFlg = true // コツ　false:なし, true:あり
    @objc dynamic var bookmark = false // ブックマーク false:なし, true:あり
    @objc dynamic var displayOrder = 0 // 表示順
    
    override static func primaryKey() -> String? {
        return "keyID"
    }
    
    // 複合主キーを設定するメソッド
    func configure(_ productID: Int, _ productClass: Int, _ toolID: Int) {
        self.productID = productID
        self.productClass = productClass
        self.toolID = toolID
        self.keyID = "\(self.productClass).\(self.productID).\(self.toolID)"
    }
}

// 実績クラス
class Performance: Object {
    @objc dynamic var quantity: Quantity? // 作成数
    @objc dynamic var time: Time? // 時間
}

// 作成数クラス
class Quantity: Object {
    @objc dynamic var total = 0 // 全ての作成個数
    @objc dynamic var triple = 0 // 星３の作成個数
    @objc dynamic var double = 0 // 星２の作成個数
    @objc dynamic var single = 0 // 星１の作成個数
    @objc dynamic var none = 0 // 星なしの作成個数
    @objc dynamic var failed = 0 // 失敗の回数
}

// 作業時間クラス
class Time: Object {
    @objc dynamic var total = 0 // 累計作成時間（秒）
    @objc dynamic var best = 0 // ベストタイム（秒）
}

// 成功率クラス
class SuccessRate: Object {
    @objc dynamic var triple = 0 // 星３の確率（％）
    @objc dynamic var double = 0 // 星２の確率（％）
    @objc dynamic var single = 0 // 星１の確率（％）
    @objc dynamic var none = 0 // 星なしの確率（％）
    @objc dynamic var failed = 0 // 失敗の確率（％）
}
