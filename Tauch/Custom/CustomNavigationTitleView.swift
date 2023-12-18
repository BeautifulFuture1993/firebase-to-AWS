//
//  CustomNavigationTitleView.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/05/30.
//

import UIKit

final class CustomNavigationTitleView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CustomNavigationTitleView", owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func configure(title: String, imageURL: String) {
        self.iconImageView.clipsToBounds = true
        self.iconImageView.layer.cornerRadius = 2.0
        self.iconImageView.contentMode = .scaleAspectFill
        self.iconImageView.setImage(withURLString: imageURL)
        
        self.titleLabel.text = title
        self.titleLabel.textColor = .fontColor
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.titleLabel.sizeToFit()
        
        self.contentView.backgroundColor = .clear
        self.backgroundView.backgroundColor = .clear
    }
    
}


