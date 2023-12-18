//
//  HobbyCardCollectionViewCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/04/21.
//

import UIKit

class HobbyCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let cellIdentifier = "HobbyCardCollectionViewCell"
    static let nib = UINib(nibName: "HobbyCardCollectionViewCell", bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        titleLabel.font = UIFont.systemFont(ofSize: 10.0, weight: .regular)
        titleLabel.textColor = .fontColor
    }

    func setData(imageURL: String, text: String) {
        titleLabel.text = text
        iconImageView.setImage(withURLString: imageURL)
        iconImageView.contentMode = .scaleAspectFill
    }
}
