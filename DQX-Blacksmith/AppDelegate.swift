//
//  AppDelegate.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/26.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        self.getInitFirestore()
        self.setUserDefault()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateViewController(identifier: "root")
        window.rootViewController = initialVC
        window.makeKeyAndVisible()
        return true
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
        print(userdefault.dictionary(forKey: "level"))
        
        // 成功率の初期設定
        let rate = ["triple": 70, "double": 20, "single": 5, "none": 5, "failed": 0]
        userdefault.register(defaults: ["rate": rate])
        
        // 時間の初期設定
        let time = 60
        userdefault.register(defaults: ["time": time])
    }
    
    // Firestoreから初期情報を取得するメソッド
    func getInitFirestore() {
        let startCollection = Firestore.firestore().collection(Path.StartCollectionPath)
        let userdefault:UserDefaults = UserDefaults.standard
        userdefault.register(defaults: ["newsText": "DQX鍛冶職人のためのアプリ「DQX 鍛冶サポート」へようこそ！",
                                        "newsColor": ["red": 0, "blue": 0, "green": 0],
                                        "version": 0])
        startCollection.getDocuments{(snaps, error) in
            if let error = error {
                print("DEBUG_PRINT:" + error.localizedDescription)
            } else {
                if let snaps = snaps {
                    for document in snaps.documents {
                        if document.documentID == "news" {
                            let newsData = document.data()
                            userdefault.setValue(newsData["text"], forKey: "newsText")
                            userdefault.setValue(newsData["color"], forKey: "newsColor")
                        } else if document.documentID == "version" {
                            let myVersion = userdefault.integer(forKey: "version")
                            let versionData = document.data()
                            let fsVersion = versionData["version"] as! Int
                            print("DEBUG_PRINT: FireStore Version ", fsVersion)
                            print("DEBUG_PRINT: RealmSwift Version ", myVersion)

                            if fsVersion > myVersion {
                                self.setAllMasterData()
                                userdefault.setValue(fsVersion, forKey: "version")
                                print("DEBUG_PRINT: バージョンアップ実施")
                            } else {
                                print("DEBUG_PRINT: バージョンアップ不要")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setAllMasterData() {
        self.setMasterData(collectionPath: Path.ProductCollectionPath, objectType: Product.self)
        self.setMasterData(collectionPath: Path.CategoryCollectionPath, objectType: Category.self)
        self.setMasterData(collectionPath: Path.MaterialCollectionPath, objectType: Material.self)
        self.setMasterData(collectionPath: Path.LevelCollectionPath, objectType: Level.self)
        self.setMasterData(collectionPath: Path.ToolCollectionPath, objectType: Tool.self)
    }
    
    // Firestoreからマスタデータを取得するメソッド
    func setMasterData<T>(collectionPath: String, objectType: T.Type) where T:Object, T:Codable {
        let collection = Firestore.firestore().collection(collectionPath)
        // Firestoreから<引数1>コレクションのドキュメントを全て取得する。
        collection.getDocuments{(snaps, error) in
            if let error = error {
                print("DEBUG_PRINT:" + error.localizedDescription)
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
                                try! realm.write{
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
                }
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
