//
//  OtherBalloonView.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/08/11.
//

import UIKit

final class OtherBalloonView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let line = UIBezierPath()
        UIColor.systemGray6.setFill()
        UIColor.clear.setStroke()
        line.move(to: CGPoint(x: 20, y: 15))
        line.addQuadCurve(to: CGPoint(x: 5, y: 5), controlPoint: CGPoint(x: 5, y: 7))
        line.addQuadCurve(to: CGPoint(x: 10, y: 20), controlPoint: CGPoint(x: 0, y: 5))
        line.close()
        line.fill()
        line.stroke()
    }
}
