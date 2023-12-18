//
//  OwnBalloonView.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/08/09.
//

import UIKit

final class OwnBalloonView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        let line = UIBezierPath()
        UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0).setFill()
        line.move(to: CGPoint(x: 5, y: 10))
        line.addQuadCurve(to: CGPoint(x: 20, y: 0), controlPoint: CGPoint(x: 10, y: 20))
        line.addQuadCurve(to: CGPoint(x: 10, y: 20), controlPoint: CGPoint(x: 20, y: 30))
        line.close()
        line.fill()
    }
}
