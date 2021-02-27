//
//  BlackSmithPracticeViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/31.
//

import UIKit
import RealmSwift

class PracticeViewController: CommonViewController {

    var delegate: SetButtonTitle?
    var blacksmith = Blacksmith()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let product = realm.objects(Product.self).filter("id == %@", self.blacksmith.productID).first?.name
        self.title = product!
        
        // Do any additional setup after loading the view.
    }

}
