//
//  BubbleView.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/06.
//

//MARK: - Preview

//import SwiftUI
//
//#if DEBUG
//struct BubbleViewRepresentable: UIViewRepresentable {
//
//    func makeUIView(context: Context) -> BubbleView {
//        return BubbleView()
//    }
//    func updateUIView(_ uiView: BubbleView, context: Context) {
//        // nil
//    }
//}
//struct BubbleView_Previews: PreviewProvider {
//    static var previews: some View {
//        BubbleViewRepresentable()
//            .previewLayout(.fixed(width: 430, height: 50))
//    }
//}
//#endif

//MARK: - CustomView

import UIKit

@IBDesignable
class BubbleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        super.backgroundColor = .clear
    }
    
    private var bubbleColor: UIColor = .clear
    
    enum IntendedPurpose: String {
        case visitor = "visitor"
        case bbs = "BBS"
    }
    
    var intendedPurpose: IntendedPurpose = .visitor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var intendedPurposeIB: String {
        get {
            return intendedPurpose.rawValue
        }
        set {
            if let purpose = IntendedPurpose(rawValue: newValue) {
                intendedPurpose = purpose
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let borderWidth = 1.0
        // rect
        let bottom = rect.height - borderWidth
        let right = rect.width - borderWidth
        let top = borderWidth
        let left = borderWidth
        
        if intendedPurpose == .visitor {
            // 足あと機能の吹き出し図形
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: (left + 38), y: (bottom - 7)))
            bezierPath.addLine(to: CGPoint(x: (left + 33), y: bottom))
            bezierPath.addLine(to: CGPoint(x: (left + 28), y: (bottom - 7)))
            bezierPath.addLine(to: CGPoint(x: (left + 1), y: (bottom - 7)))
            bezierPath.addCurve(to: CGPoint(x: left, y: (bottom - 8)), controlPoint1: CGPoint(x: (left + 0.5), y: (bottom - 7)), controlPoint2: CGPoint(x: left, y: (bottom - 7.5)))
            bezierPath.addLine(to: CGPoint(x: left, y: (top + 1)))
            bezierPath.addCurve(to: CGPoint(x: (left + 1), y: top), controlPoint1: CGPoint(x: left, y: (top + 0.5)), controlPoint2: CGPoint(x: (left + 0.5), y: top))
            bezierPath.addLine(to: CGPoint(x: (right - 1), y: top))
            bezierPath.addCurve(to: CGPoint(x: right, y: (top + 1)), controlPoint1: CGPoint(x: (right - 0.5), y: top), controlPoint2: CGPoint(x: right, y: (top + 0.5)))
            bezierPath.addLine(to: CGPoint(x: right, y: (bottom - 8)))
            bezierPath.addCurve(to: CGPoint(x: (right - 1), y: (bottom - 7)), controlPoint1: CGPoint(x: right, y: (bottom - 7.5)), controlPoint2: CGPoint(x: (right - 0.5), y: (bottom - 7)))
            bezierPath.addLine(to: CGPoint(x: (left + 38), y: (bottom - 7)))
            bezierPath.close()
            // 内側は透明
            UIColor.clear.setFill()
            bezierPath.fill()
            // 線の色
            UIColor.systemGray5.setStroke()
            bezierPath.lineWidth = borderWidth
            bezierPath.stroke()
            
        } else if intendedPurpose == .bbs {
            // 掲示板機能の吹き出し図形
            let bezierPath = UIBezierPath()
            let triangleWidth = 10 * sqrt(3)
            bezierPath.move(to: CGPoint(x: (right / 2 + triangleWidth / 2), y: (bottom - 10)))
            bezierPath.addLine(to: CGPoint(x: (right / 2 + 2), y: (bottom - 2)))
            bezierPath.addCurve(to: CGPoint(x: (right / 2 - 2), y: (bottom - 2)), controlPoint1: CGPoint(x: (right / 2 + 1), y: bottom), controlPoint2: CGPoint(x: (right / 2 - 1), y: bottom))
            bezierPath.addLine(to: CGPoint(x: (right / 2 - triangleWidth / 2), y: (bottom - 10)))
            bezierPath.addLine(to: CGPoint(x: (left + 10), y: (bottom - 10)))
            bezierPath.addCurve(to: CGPoint(x: left, y: (bottom - 20)), controlPoint1: CGPoint(x: (left + 5), y: (bottom - 10)), controlPoint2: CGPoint(x: left, y: (bottom - 15)))
            bezierPath.addLine(to: CGPoint(x: left, y: (top + 10)))
            bezierPath.addCurve(to: CGPoint(x: (left + 10), y: top), controlPoint1: CGPoint(x: left, y: (top + 5)), controlPoint2: CGPoint(x: (left + 5), y: top))
            bezierPath.addLine(to: CGPoint(x: (right - 10), y: top))
            bezierPath.addCurve(to: CGPoint(x: right, y: (top + 10)), controlPoint1: CGPoint(x: (right - 5), y: top), controlPoint2: CGPoint(x: right, y: (top + 5)))
            bezierPath.addLine(to: CGPoint(x: right, y: (bottom - 20)))
            bezierPath.addCurve(to: CGPoint(x: (right - 10), y: (bottom - 10)), controlPoint1: CGPoint(x: right, y: (bottom - 15)), controlPoint2: CGPoint(x: (right - 5), y: (bottom - 10)))
            bezierPath.addLine(to: CGPoint(x: (right / 2 + triangleWidth / 2), y: (bottom - 10)))
            bezierPath.close()
            
            UIColor.white.setFill()
            bezierPath.fill()
            
            UIColor.white.setStroke()
            bezierPath.lineWidth = borderWidth
            bezierPath.stroke()
        }
    }
    
}
