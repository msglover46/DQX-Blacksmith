//
//  CustomProductCollectionViewCell.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/03.
//

import UIKit

class CustomProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gauge: Gauge!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("CustomProductCollectionViewCell", owner: self, options: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setGauge(indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            gauge.direction = "left"
        } else {
            gauge.direction = "right"
        }
    }

}
