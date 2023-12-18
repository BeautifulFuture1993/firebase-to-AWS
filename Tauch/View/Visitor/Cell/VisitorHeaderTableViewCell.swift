//
//  VisitorHeaderTableViewCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/07.
//

import UIKit

protocol VisitorHeaderTableViewCellwDelegate: AnyObject {
    func didTapped()
}

class VisitorHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var headerImg: UIImageView!
    @IBOutlet weak var headerTitle: UILabel!
    
    static var height: CGFloat = 170    // ひとまず自動的に高さの計算することはしない
    static let nib = UINib(nibName: "VisitorHeaderTableViewCell", bundle: nil)
    static let cellIdentifier = "VisitorHeaderTableViewCell"
    
    weak var headerDelegate: VisitorHeaderTableViewCellwDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerImg.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped))
        headerImg.addGestureRecognizer(tap)
        
        headerTitle.adjustsFontSizeToFitWidth = true
    }
    
    @objc func imgTapped(_ target: UITapGestureRecognizer) { headerDelegate?.didTapped() }
}
