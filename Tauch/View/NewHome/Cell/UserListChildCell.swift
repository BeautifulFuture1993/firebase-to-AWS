//
//  UserListChildCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/31.
//

import UIKit

protocol UserListChildCellDelegate: AnyObject {
    func didTapGoDetail(cell: UserListChildCell)
}

class UserListChildCell: UICollectionViewCell {
    
    @IBOutlet weak var userIconImage: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    
    static let nibName = "UserListChildCell"
    static let cellIdentifier = "UserListChildCell"
    static let height: CGFloat = 80
    static let width: CGFloat = 60
    
    weak var delegate : UserListChildCellDelegate?
    
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userIconImage.layer.cornerRadius = userIconImage.bounds.height / 2
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGoDetail))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configure(with user: User) {
        
        self.user = user
        
        let profileIconImg = user.profile_icon_img
        let age = user.birth_date.calcAge()
        let address = user.address.removePrefectureCharacters()
        
        userIconImage.setImage(withURLString: profileIconImg)
        ageLabel.text = age
        areaLabel.text = address
    }
    
    @objc func didTapGoDetail() {
        delegate?.didTapGoDetail(cell: self)
    }
}
