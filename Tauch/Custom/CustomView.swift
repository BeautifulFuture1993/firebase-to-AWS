//
//  CustomView.swift
//  Tauch
//
//  Created by Apple on 2022/07/23.
//

import UIKit

class CustomView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0.0

    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = (cornerRadius > 0)
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        super.draw(rect)
    }
}
