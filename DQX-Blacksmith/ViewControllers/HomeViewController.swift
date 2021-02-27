//
//  ViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/26.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import RealmSwift
import MaterialComponents
import SVProgressHUD

// ホーム画面
class HomeViewController: CommonViewController {
    @IBOutlet weak var appTitleLabel: UILabel! // アプリのタイトルを表示
    @IBOutlet weak var newsLabel: CBAutoScrollLabel! // Firestoreから取得したお知らせ情報を表示
    @IBOutlet weak var selectProductButton: PushButton! // 「作るものを選ぶ」ボタン
    @IBOutlet weak var customProductButton: PushButton! // 「作るものをカスタマイズする」ボタン
    @IBOutlet weak var mailButton: SubButton! // 「お問い合わせ」ボタン
    @IBOutlet weak var settingButton: SubButton! // 「設定」ボタン
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel()  // アプリのタイトルを表示する。
        designNewsLabel()
        mailButton.setImage(UIImage(named: "mail"), for: .normal)
        settingButton.setImage(UIImage(named: "setting"), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getInitFirestore { result in
            self.setUserDefault()
            self.setNewsLabel()   // お知らせ情報を表示する。
            self.setAllMasterData()
        }
        navigationController?.setNavigationBarHidden(true, animated: animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // アプリのタイトルを表示する。
    func setTitleLabel() {
        appTitleLabel.textColor = UIColor.white
        appTitleLabel.backgroundColor = Color.DarkBrown
    }

    // Firestoreから取得したお知らせ情報を表示する。
    func setNewsLabel() {
        
        newsLabel.scrollSpeed = 80.0
        newsLabel.pauseInterval = 0
        newsLabel.labelSpacing = Int(newsLabel.frame.width)
        newsLabel.textAlignment = NSTextAlignment.left
        
        let userdefault = UserDefaults.standard
        
        self.newsLabel.text = userdefault.string(forKey: "newsText")
        let color = userdefault.dictionary(forKey: "newsColor")

        self.newsLabel.textColor = UIColor(red: CGFloat(color!["red"] as! Int/255), green: CGFloat(color!["green"] as! Int/255), blue: CGFloat(color!["blue"] as! Int/255), alpha: 1.0)
        self.newsLabel.observeApplicationNotifications()
    }
    
    func designNewsLabel() {
        // newsLabelのプロパティを設定する。
        newsLabel.backgroundColor = Color.Yellow
        let topBorder = CALayer(layer: newsLabel.layer)
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: newsLabel.frame.width, height: 1.0)
        topBorder.backgroundColor = Color.BorderOrange
        newsLabel.layer.addSublayer(topBorder)
        let bottomBorder = CALayer(layer: newsLabel.layer)
        bottomBorder.frame = CGRect(x: 0.0, y: newsLabel.frame.height - 1.0, width: newsLabel.frame.width, height: 1.0)
        bottomBorder.backgroundColor = Color.BorderOrange
        newsLabel.layer.addSublayer(bottomBorder)
    }
    
    // Firestoreから初期情報を取得するメソッド
    func getInitFirestore(completion: @escaping (Bool) -> Void) {
        SVProgressHUD.show()
        let startCollection = Firestore.firestore().collection(Path.StartCollectionPath)
        let userdefault:UserDefaults = UserDefaults.standard
        userdefault.register(defaults: ["newsText": "DQX鍛冶職人のためのアプリ「DQX 鍛冶サポート」へようこそ！",
                                        "newsColor": ["red": 0, "blue": 0, "green": 0],
                                        "version": 0])
        startCollection.getDocuments{(snaps, error) in
            if let error = error {
                print("DEBUG_PRINT:", error.localizedDescription)
                SVProgressHUD.dismiss()
                completion(false)
            } else {
                if let snaps = snaps {
                    for document in snaps.documents {
                        if document.documentID == "news" {
                            let newsData = document.data()
                            userdefault.setValue(newsData["text"], forKey: "newsText")
                            userdefault.setValue(newsData["color"], forKey: "newsColor")
                        } else if document.documentID == "version" {
                            let myVersion = userdefault.integer(forKey: "realmVersion")
                            let versionData = document.data()
                            let fsVersion = versionData["version"] as! Int
                            print("DEBUG_PRINT: FireStore Version ", fsVersion)
                            print("DEBUG_PRINT: RealmSwift Version ", myVersion)
                            userdefault.setValue(fsVersion, forKey: "firestoreVersion")
                        }
                    }
                    SVProgressHUD.dismiss()
                    completion(true)
                }
            }
        }
    }
    
    // UserDefaultsの初期値を設定するメソッド
    func setUserDefault() {
        let userdefault:UserDefaults = UserDefaults.standard
        let realm = try! Realm()
        
        // 職人種類の設定
        let initCraftsmanType = "武器鍛冶"
        userdefault.register(defaults: ["craftsman": initCraftsmanType])
        
        // レベルの設定
        let initLevel = realm.objects(Level.self).sorted(byKeyPath: "level", ascending: false).first?.level ?? 1
        let level = ["武器鍛冶": initLevel, "防具鍛冶": initLevel, "道具鍛冶": initLevel]
        userdefault.register(defaults: ["level": level])
        
        // 成功率の初期設定
        let rate = ["triple": 70, "double": 20, "single": 5, "none": 5, "failed": 0]
        userdefault.register(defaults: ["rate": rate])
        
        // 時間の初期設定
        let time = 60
        userdefault.register(defaults: ["time": time])
    }
    
    // Firestoreからマスタデータを取得するメソッド
    func setMasterData<T>(collectionPath: String, objectType: T.Type, completion: @escaping(Bool) -> Void) where T:Object, T:Codable {
        let collection = Firestore.firestore().collection(collectionPath)
        // Firestoreから<引数1>コレクションのドキュメントを全て取得する。
        collection.getDocuments{(snaps, error) in
            if let error = error {
                print("DEBUG_PRINT:" + error.localizedDescription)
                completion(false)
            } else {
                if let snaps = snaps {
                    // Firestoreデータを取り込む前にRealmのデータを全削除する。
                    let realm = try! Realm()
                    let result = realm.objects(objectType)
                    try! realm.write {
                        realm.delete(result)
                    }
                    print("DEBUG_PRINT:\(collectionPath)コレクションから\(snaps.documents.count)個のdocumentを取得")
                    // Firestoreから読み込んだドキュメントを１つずつRealmに書き込む。
                    for document in snaps.documents {
                        let result = Result {
                            try document.data(as: objectType)
                        }
                        switch result {
                        case .success(let data):
                            if let data = data {
                                try! realm.write {
                                    realm.add(data)
                                }
                            } else {
                                print("DEBUG_PRINT: Document doesn't exist.")
                            }
                        case .failure(let error):
                            print("DEBUG_PRINT:" + error.localizedDescription)
                        }
                    }
                    print("DEBUG_PRINT: \(objectType)テーブルに\(realm.objects(objectType).count)個のデータを登録")
                    completion(true)
                }
            }
        }
    }
    
    func setAllMasterData() {
        let userdefault = UserDefaults.standard
        let realmVersion = userdefault.integer(forKey: "realmVersion")
        let firestoreVersion = userdefault.integer(forKey: "firestoreVersion")
        if firestoreVersion > realmVersion {
            SVProgressHUD.show()
            self.setMasterData(collectionPath: Path.ProductCollectionPath, objectType: Product.self) { result in
                if result == true {
                    self.setMasterData(collectionPath: Path.CategoryCollectionPath, objectType: Category.self) { result in
                        if result == true {
                            self.setMasterData(collectionPath: Path.MaterialCollectionPath, objectType: Material.self) { result in
                                if result == true {
                                    self.setMasterData(collectionPath: Path.LevelCollectionPath, objectType: Level.self) { result in
                                        if result == true {
                                            self.setMasterData(collectionPath: Path.ToolCollectionPath, objectType: Tool.self) { result in
                                                if result == true {
                                                    userdefault.setValue(firestoreVersion, forKey: "realmVersion")
                                                    SVProgressHUD.dismiss()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

