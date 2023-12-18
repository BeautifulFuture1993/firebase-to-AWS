//
//  RecommendUsersTopTableViewCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/31.
//

import UIKit

class RecommendUsersTopTableViewCell: UITableViewCell {

    @IBOutlet weak var RecommendUsersCellTopLabel: UILabel!
    
    static let nibName = "RecommendUsersTopTableViewCell"
    static let cellIdentifier = "RecommendUsersTopTableViewCell"
    static let height: CGFloat = 40
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
