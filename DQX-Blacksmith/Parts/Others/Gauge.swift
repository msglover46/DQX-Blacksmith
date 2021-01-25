//
//  Gauge.swift
//  DQX-Blacksmith
//
//  Created by 三輪駿 on 2021/01/02.
//

import UIKit

class Gauge: UIView {
    
    var max = 80 // 基準値の最大値
    var min = 70 // 基準値の最小値
    var direction = "right" // // ゲージの方向（right or left）
    var values: [Int] = [100, 60, 40, 50, 80, 90, 100, 75] // 全ての箇所の基準値の最大値を格納する配列
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawGauge()
    }
    
    // ゲージを描画するメソッド
    func drawGauge() {
        
        // --- ゲージ長の算出 ---
        // 基準値の最大値が最も大きい場所のゲージ長＋枠線の幅がviewの横幅と等しくなるように、ゲージの長さを定める。
        // ゲージ長の80%の部分に基準値の最大値が来るようにする。
        let borderWidth = frame.height / 6 // ゲージの枠幅
        let maxLength = ( self.frame.width - borderWidth * 2 ) // 最大のゲージ長
        let valueMaxRate: CGFloat = 0.8 // 基準値の最大値の割合
        let valueMax = CGFloat(values.max()!) // 基準値の最大値が最も大きい場所の基準値の最大値
        var lengthParUnit: CGFloat = 0.0 // 単位基準値あたりのゲージ長
        if valueMax != 0 {
            lengthParUnit = maxLength * valueMaxRate / valueMax
        }
        let length: CGFloat = lengthParUnit * CGFloat(self.max) / valueMaxRate // ゲージ長
        
        
        // --- topLayer（枠線のみで中身が透明のLayer）を表示 ---
        // 外枠の四角形と内枠の四角形を組み合わせて枠線を作る。
        let topLayer = CALayer()
        topLayer.backgroundColor = Color.BorderGray
        topLayer.frame = self.bounds
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = topLayer.bounds
        
        // 外枠の四角形を算出
        let outsideWidth: CGFloat = length + borderWidth * 2
        var outsideRect: CGRect
        if direction == "right" {
            outsideRect = CGRect(x: 0.0, y: 0.0, width: outsideWidth, height: bounds.height)
        } else {
            outsideRect = CGRect(x: bounds.width - outsideWidth, y: 0.0, width: outsideWidth, height: bounds.height)
        }
        
        var roundCorners: UIRectCorner // 尖らせる方向をdirectionから決定
        if direction == "right" {
            roundCorners = [.topRight, .bottomRight]
        } else {
            roundCorners = [.topLeft, .bottomLeft]
        }
        
        let cornerRadius: CGSize = frame.size
        let path = UIBezierPath(roundedRect: outsideRect, byRoundingCorners: roundCorners, cornerRadii: cornerRadius)

        // 内側の四角形を算出
        let insideHeight: CGFloat = bounds.height - borderWidth * 2
        var insideRect: CGRect
        if direction == "right" {
            insideRect = CGRect(x: borderWidth, y: borderWidth, width: length, height: insideHeight)
        } else {
            insideRect = CGRect(x: bounds.width - outsideWidth + borderWidth, y: borderWidth, width: length, height: insideHeight)
        }
        let insidePath = UIBezierPath(roundedRect: insideRect, byRoundingCorners: roundCorners, cornerRadii:  cornerRadius)
        path.append(insidePath)
        
        // ゲージの中心を算出 -> 塗りつぶしの判定に利用する。
        let center = CGPoint(x: maskLayer.bounds.width / 2, y: maskLayer.bounds.height / 2)
        maskLayer.position = center
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        topLayer.mask = maskLayer
        self.layer.insertSublayer(topLayer, at: 3)
        
        
        // --- valueLayer（基準値のLayer）の表示 ---
        let valueLayer = CALayer()
        valueLayer.backgroundColor = Color.BorderGreen
        valueLayer.opacity = 0.8
        
        let valueWidth: CGFloat = CGFloat(max - min) * lengthParUnit
        var valueRect: CGRect
        if direction == "right" {
            valueRect = CGRect(x: borderWidth + CGFloat(min) * lengthParUnit, y: borderWidth, width: valueWidth, height: insideHeight)
        } else {
            valueRect = CGRect(x: bounds.width - borderWidth - CGFloat(max) * lengthParUnit, y: borderWidth, width: valueWidth, height: insideHeight)
        }
        valueLayer.frame = valueRect
        self.layer.insertSublayer(valueLayer, at: 2)
        
        
        // --- bottomLayer（黒い部分のLayer）の表示 ---
        let bottomLayer = CALayer()
        bottomLayer.backgroundColor = UIColor.black.cgColor
        bottomLayer.frame = self.bounds
        
        let bottomShapeLayer = CAShapeLayer()
        bottomShapeLayer.frame = bottomLayer.bounds
        bottomShapeLayer.position = center
        bottomShapeLayer.fillRule = .evenOdd
        bottomShapeLayer.path = insidePath.cgPath
        bottomLayer.mask = bottomShapeLayer
        self.layer.insertSublayer(bottomLayer, at: 0)
    }

}
