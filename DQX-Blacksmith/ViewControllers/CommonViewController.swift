//
//  CommonViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/31.
//

import UIKit

/* ViewControllerの階層構造 ---------------------------------------------------------/
 　　UIViewController
      └ CommonViewController                        全画面で共通の処理を記述する。
          ├ HomeViewController                      ホーム画面
          ├ ProductViewController                   製品選択画面
          ├ CustomSummaryViewController             カスタム製品一覧画面
          ├ CustomDetailViewController              製品カスタマイズ画面
          ├ CommonMaterialViewController            素材関連画面に共通の処理を記述する。
          │   ├ MaterialSummaryViewController       素材概要画面
          │   ├ MaterialTwitterViewController       素材Twitter画面
          │   └ MaterialBoardViewController         素材掲示板画面
          ├ CommonProductViewController             製品関連画面に共通の処理を記述する。
          │   ├ ProductInfoViewController           製品情報画面
          │   └ CommonBlackSmithViewController      鍛冶職人画面に共通の処理を記述する。
          │       ├ PracticeViewController          鍛冶職人練習画面
          │       └ RealViewController              鍛冶職人本番画面
          ├ InquiryViewController                   問い合わせ画面
          └ SettingViewController                   設定画面
 /--------------------------------------------------------------------------------*/

class CommonViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.BackGroundColor
        self.navigationItem.hidesBackButton = true
        
        // Homeボタンの実装
        let homeBarButtonItem = UIBarButtonItem(image: UIImage(named: "home")!, style: .plain, target: self, action: #selector(homeBarButtonTapped))
        navigationItem.rightBarButtonItem = homeBarButtonItem
        
        // 戻るボタンの実装
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "back")!, style: .plain, target: self, action: #selector(backBarButtonTapped))
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    @objc func homeBarButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func backBarButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: false)
    }
}
