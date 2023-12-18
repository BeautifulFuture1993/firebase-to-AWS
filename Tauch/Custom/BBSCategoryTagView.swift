//
//  BBSCategoryTagView.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/10.
//

import UIKit

@IBDesignable
final class BBSCategoryTagView: UIView {
    
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
    
    private var tagColor: UIColor? = .tintColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var backgroundColor: UIColor? {
        get { return tagColor }
        set { tagColor = newValue }
    }
    
    override func draw(_ rect: CGRect) {
        
        let top = 0.0
        let left = 0.0
        let right = rect.width
        let bottom = rect.height
        
        let bezierPath = drawBezierPath(
            startPoint: CGPoint(x: left, y: top),
            positions: [
                (left, bottom),
                (right, bottom),
                ((right - bottom / 2), (bottom / 2)),
                (right, top)
            ])
        tagColor?.setFill()
        bezierPath.fill()
    }
    
    private func drawBezierPath(startPoint: CGPoint, positions: [(CGFloat, CGFloat)]) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: startPoint)
        positions.forEach { position in
            bezierPath.addLine(to: CGPoint(x: position.0, y: position.1))
        }
        bezierPath.addLine(to: startPoint)
        bezierPath.close()
        
        return bezierPath
    }
}
