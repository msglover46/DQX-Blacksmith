//
//  CustomDetailViewController.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2020/12/31.
//

import UIKit
import Firebase
import MaterialComponents
import Rswift

class CustomDetailViewController: CommonViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let layout = UICollectionViewFlowLayout()
    let borderwidth:CGFloat = 2.0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.customCell.identifier, for: indexPath) as! CustomProductCollectionViewCell
        
        cell.setGauge(indexPath: indexPath)
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = Color.BorderBrown
        cell.layer.borderWidth = borderwidth
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = Color.BackGroundColor
        let nib = UINib(nibName: R.nib.customProductCollectionViewCell.name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: R.reuseIdentifier.customCell.identifier)
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
}
