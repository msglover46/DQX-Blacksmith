//
//  BlackSmithRealViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/31.
//

import UIKit
import RealmSwift

class RealViewController: CommonViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var blacksmith = Blacksmith()
    let realm = try! Realm()
    var delegate: SetButtonTitle?
    var temperature = 1000
    var level = try! Realm().objects(Level.self).sorted(byKeyPath: "level", ascending: false).first?.level
    var concentration = 0

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var concentrationTitleLabel: UILabel!
    @IBOutlet weak var concentrationLabel: UILabel!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var hissatsuButton: SkillButton!
    @IBOutlet weak var jougeButton: SkillButton!
    @IBOutlet weak var yonrenButton: SkillButton!
    @IBOutlet weak var chouyonrenButton: SkillButton!
    @IBOutlet weak var nanameButton: SkillButton!
    @IBOutlet weak var tekagenButton: SkillButton!
    @IBOutlet weak var tatakuButton: SkillButton!
    @IBOutlet weak var nibaiButton: SkillButton!
    @IBOutlet weak var sanbaiButton: SkillButton!
    @IBOutlet weak var neraiButton: SkillButton!
    @IBOutlet weak var jougeNeraiButton: SkillButton!
    @IBOutlet weak var karyokuButton: SkillButton!
    @IBOutlet weak var siageButton: SkillButton!
    @IBOutlet weak var hiyashiButton: SkillButton!
    @IBOutlet weak var midareButton: SkillButton!
    @IBOutlet weak var neppuButton: SkillButton!
    @IBOutlet weak var resetButton: SkillButton!
    @IBOutlet weak var stopButton: SkillButton!
    
    
    let layout = UICollectionViewFlowLayout()
    let borderwidth:CGFloat = 2.0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.realLeftCell.identifier, for: indexPath)
        if indexPath.row % 2 == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.realRightCell.identifier, for: indexPath)
        }
        let gauge = cell.viewWithTag(4) as! Gauge
        
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = Color.BorderBrown
        cell.layer.borderWidth = borderwidth
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let product = realm.objects(Product.self).filter("id == %@", self.blacksmith.productID).first?.name
        
        self.title = product!
        self.view.backgroundColor = Color.BackGroundColor
        self.temperatureLabel.backgroundColor = .white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: R.nib.customProductCollectionViewCell.name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: R.reuseIdentifier.customCell.identifier)
        
        temperatureLabel.text = String(temperature) + "℃"
        temperatureLabel.textColor = .red
        
        stateView.layer.borderWidth = 1.0
        stateView.layer.borderColor = Color.BorderGreen
        stateView.backgroundColor = Color.Gray
        stateView.layer.cornerRadius = 5.0
        
        concentrationTitleLabel.backgroundColor = .green
        concentrationTitleLabel.textColor = Color.White
        errorTitleLabel.backgroundColor = .green
        errorTitleLabel.textColor = Color.White
        
        messageLabel.layer.borderWidth = 1.0
        messageLabel.layer.borderColor = Color.BorderGray
        messageLabel.backgroundColor = Color.Gray
        messageLabel.layer.cornerRadius = 5.0
        
        setButtonColors()
        concentration = realm.objects(Level.self).filter("level == %@", self.level).first!.concentration
        concentrationLabel.text = "999 / " + String(concentration)
    }
    
    func setButtonColors() {
        hissatsuButton.color = "blue"
        siageButton.color = "pink"
        resetButton.color = "gray"
        stopButton.color = "gray"
    }
    
    override func viewDidLayoutSubviews() {
        
        // 基準値設定コレクションの外枠を決定
        let width = collectionView.frame.width / 2 - 0.2
        let height = collectionView.frame.height / 4
        layout.estimatedItemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        collectionView.collectionViewLayout = layout
    }
    
    func damage(temperature: Int, skill: String) -> [Int] {
        let baseArray = [12, 13, 14, 15, 16, 17, 18]
        var damageArray: [Int] = []
        var damageRate = 0.0
        var mode = "a"
        
        switch skill {
        case "たたく", "ねらい打ち":
            damageRate = 1.0
            mode = "a"
        case "２倍打ち", "超４連打ち":
            damageRate = 2.0
            mode = "a"
        case "熱風おろし":
            damageRate = 2.5
            mode = "a"
        case "てかげん打ち":
            damageRate = 0.5
            mode = "a"
        case "３倍打ち":
            damageRate = 3.0
            mode = "a"
        case "上下打ち", "上下ねらい", "４連打ち":
            damageRate = 1.2
            mode = "b"
        case "みだれ打ち":
            damageRate = 0.8
            mode = "b"
        default:
            break
        }
        
        if mode == "a" {
            for base in baseArray {
                let damage = Int(ceil(ceil(Double(base) * damageRate) * ( 1.0 - 0.0005 * Double( 1000 - temperature ))))
                damageArray.append(damage)
            }
        } else if mode == "b" {
            for base in baseArray {
                let damage = Int(ceil(round(Double(base) * damageRate + 1.0) * ( 1.0 - 0.0005 * Double( 1000 - temperature))))
                damageArray.append(damage)
            }
        }
        return damageArray
    }
    
    func concentration(temperature: Int, groundMetal: Int, skill: String) -> Int {
        
        return 0
    }
}
