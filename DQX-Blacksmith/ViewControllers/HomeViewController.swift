//
//  ViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/26.
//

import UIKit
import Firebase
import MaterialComponents

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        view.backgroundColor = Color.BackGroundColor
        setTitleLabel()  // アプリのタイトルを表示する。
        setNewsLabel()   // お知らせ情報を表示する。
        mailButton.setImage(UIImage(named: "mail"), for: .normal)
        settingButton.setImage(UIImage(named: "setting"), for: .normal)
        
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
}

