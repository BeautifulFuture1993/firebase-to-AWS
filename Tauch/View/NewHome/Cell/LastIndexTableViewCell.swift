//
//  LastIndexTableViewCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/31.
//

import UIKit

class LastIndexTableViewCell: UITableViewCell {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    static let height: CGFloat = 180
    static let cellIdentifier = "LastIndexTableViewCell"
    static let nibName = "LastIndexTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainImage.image = UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        mainTitleLabel.text = "以上です"
        mainTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        mainTitleLabel.textColor = .fontColor
        mainTitleLabel.textAlignment = .center
        subTitleLabel.text = "設定中の条件のユーザーは全て表示しました。\n検索条件を広げてください！"
        subTitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subTitleLabel.textColor = .fontColor
        subTitleLabel.textAlignment = .center
    }
    
    func cellIsTransParent() {
        mainImage.alpha = 0.0
        mainTitleLabel.alpha = 0.0
        subTitleLabel.alpha = 0.0
    }
    
    func showCell() {
        UIView.animate(withDuration: 0.8, delay: 0.0, animations: {
            self.mainImage.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.mainTitleLabel.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    self.subTitleLabel.alpha = 1.0
                }
            })
        })
    }
}
