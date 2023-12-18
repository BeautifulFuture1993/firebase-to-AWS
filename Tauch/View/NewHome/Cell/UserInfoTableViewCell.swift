//
//  UserInfoTableViewCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/31.
//

import UIKit
import TagListView
import Nuke
import NukeExtensions

protocol UserInfoTableViewCellDelegate: AnyObject {
    func didTapGoDetail(cell: UserInfoTableViewCell)
}

class UserInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellBaseView: UIView!
    @IBOutlet weak var photoStackView: UIStackView!
    @IBOutlet weak var subPhotoStackView: UIStackView!
    @IBOutlet weak var firstIconImage: UIImageView!
    @IBOutlet weak var secondIconView: UIView!
    @IBOutlet weak var secondIconImage: UIImageView!
    @IBOutlet weak var thirdIconView: UIView!
    @IBOutlet weak var thirdIconImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var onlineBadge: UIImageView!
    @IBOutlet weak var ageIcon: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var areaIcon: UIImageView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var statusMessageView: UIView!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var hobbyTagListView: TagListView!
    // constraint
    @IBOutlet weak var firstImageViewSmallWidthConstraint: NSLayoutConstraint!  // 2,3枚のとき
    @IBOutlet weak var subImageStackViewWidthConstraint: NSLayoutConstraint!  // 2,3枚のとき
    @IBOutlet weak var firstImageViewFullWidthConstraint: NSLayoutConstraint!  // 1枚のとき
    
    static let nibName = "UserInfoTableViewCell"
    static let cellIdentifier = "UserInfoTableViewCell"
    static let height: CGFloat = 275
    
    var user: User?
    weak var delegate : UserInfoTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBaseView.layer.cornerRadius = 15
        cellBaseView.setShadow(opacity: 0.1, color: UIColor.darkGray)
        
        onlineBadge.layer.cornerRadius = onlineBadge.bounds.height / 2
        onlineBadge.clipsToBounds = true
        userNameLabel.setShadow()
        ageIcon.setShadow()
        ageLabel.setShadow()
        areaIcon.setShadow()
        areaLabel.setShadow()
        photoStackView.clipsToBounds = true
        photoStackView.customUp()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGoDetail))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configure(with user: User) {
        
        self.user = user
        
        var hobbyListTotalString = 0
        var hobbyListCount = 0
        
        let nickName = user.nick_name
        let profileIconImg = user.profile_icon_img
        let age = user.birth_date.calcAge()
        let address = user.address.removePrefectureCharacters() + " " + user.address2
        let hobbies = user.hobbies
        let isLogined = user.is_logined
        let logoutTime = user.logouted_at.dateValue()
        let profileIconSubImgs = user.profile_icon_sub_imgs
        let profileStatus = user.profile_status
        
        userNameLabel.text = nickName
        ageLabel.text = age
        areaLabel.text = address
        hobbyTagListView.removeAllTags()
        hobbyTagListView.addTags(hobbies)
        hobbyListCount = hobbies.count
        hobbies.forEach { hobby in
            hobbyListTotalString += hobby.count
        }
        onlineBadge.isHidden = false
        onlineBadge.tintColor = .green
        let elaspedTime = elapsedTime(isLogin: isLogined, logoutTime: logoutTime)
        if let elaspedTimeDay = elaspedTime[4], elaspedTimeDay > 5 {
            onlineBadge.isHidden = true
        }

        var hobbyListViewWidth: CGFloat = 0
        if hobbyListCount * 40 + hobbyListTotalString * 14 < Int(UIScreen.main.bounds.width - 40) {
            hobbyListViewWidth = UIScreen.main.bounds.width - 40
            hobbyTagListView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            hobbyListViewWidth = CGFloat(hobbyListCount * 20 + hobbyListTotalString * 7)
        }
        hobbyTagListView.widthAnchor.constraint(equalToConstant: hobbyListViewWidth).isActive = true
        hobbyTagListView.textFont = UIFont.systemFont(ofSize: 11, weight: .bold)
        
        statusMessageLabel.text = profileStatus
        
        subPhotoStackView.isHidden = false
        secondIconView.isHidden = false
        secondIconImage.isHidden = false
        thirdIconView.isHidden = false
        thirdIconImage.isHidden = false
        
        firstIconImage.setImage(withURLString: profileIconImg)
        /* 画像stackViewの制約を動的に付け替える + 画像の埋め込み */
        if profileIconSubImgs.isEmpty {
            // 1枚表示
            NSLayoutConstraint.activate([firstImageViewFullWidthConstraint])
            NSLayoutConstraint.deactivate([firstImageViewSmallWidthConstraint, subImageStackViewWidthConstraint])
            subPhotoStackView.isHidden = true
            
        } else {
            // 2,3枚表示
            NSLayoutConstraint.deactivate([firstImageViewFullWidthConstraint])
            NSLayoutConstraint.activate([firstImageViewSmallWidthConstraint, subImageStackViewWidthConstraint])
            subPhotoStackView.isHidden = false
        
            if let firstSubImg = profileIconSubImgs[safe: 0], let url = URL(string: firstSubImg) {
                loadImage(with: ImageRequest(url: url), into: secondIconImage)
            } else {
                secondIconView.isHidden = true
            }
            
            if let secondSubImg = profileIconSubImgs[safe: 1], let url = URL(string: secondSubImg) {
                loadImage(with: ImageRequest(url: url), into: thirdIconImage)
            } else {
                thirdIconView.isHidden = true
            }
        }
    }
    // プロフィール詳細ページに移動
    @objc func didTapGoDetail() {
        delegate?.didTapGoDetail(cell: self)
    }
}
