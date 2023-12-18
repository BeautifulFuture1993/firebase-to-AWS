//
//  HomeNavigationTitleView.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/02.
//

import UIKit

class HomeNavigationTitleView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("HomeNavigationTitleView", owner: self, options: nil)
        contentView.fixInView(self)
    }

}
