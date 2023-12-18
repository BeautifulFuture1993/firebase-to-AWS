//
//  VisitorButtonBarCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/06.
//

import UIKit

class VisitorButtonBarCell: UICollectionViewCell {
    
    static let nibName = "VisitorButtonBarCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let angle = 30 * CGFloat.pi / 180
        let transRotate = CGAffineTransform(rotationAngle: CGFloat(angle))
        iconImageView.transform = transRotate
    }

}
