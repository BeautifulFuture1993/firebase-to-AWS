//
//  CustomButton.swift
//  Tauch
//
//  Created by Apple on 2023/04/01.
//

import UIKit
import Foundation

final class CustomButton: UIButton {
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        if let imgView = self.imageView {
            return CGRect(x: rect.minX - imgView.image!.size.width / 2, y: rect.minY, width: rect.width, height: rect.height)
        }
        return rect
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        return CGRect(x: 20.0, y: rect.minY, width: rect.width, height: rect.height)
    }
}
