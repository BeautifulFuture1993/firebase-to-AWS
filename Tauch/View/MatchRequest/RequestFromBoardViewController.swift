//
//  RequestFromBoardViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/16.
//

import UIKit
import TagListView

class RequestFromBoardViewController: UIBaseViewController {
    
    static let storyboardName = "RequestFromBoardView"
    static let storyboardId = "RequestFromBoardViewController"
    
    @IBOutlet weak var firstTitleLabel: LabelWithStroke!
    @IBOutlet weak var secondTitleLabel: LabelWithStroke!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var bubbleView: BubbleView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var onlineBadge: UIImageView!
    @IBOutlet weak var onlineStatusLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hobbyTagListView: TagListView!
    @IBOutlet weak var profileStatusLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var notApproveButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    private func setUserInfo(user: User) {
        
        profileImageView.setImage(withURLString: user.profile_icon_img)
        nameLabel.text = user.nick_name
        ageLabel.text = user.birth_date.calcAge()
        addressLabel.text = user.address.removePrefectureCharacters() + " " + user.address2
        for i in 0...5 {
            if let hobby = user.hobbies[safe: i] {
                hobbyTagListView.addTag(hobby)
            }
        }
//        user.hobbies.forEach { hobbyTagListView.addTag($0) }
        profileStatusLabel.text = user.profile_status
    }
}


//MARK: - Appearance

extension RequestFromBoardViewController {
    
    private func configure() {
        
        view.backgroundColor = .systemBackground
        
        // TitleLabel
        firstTitleLabel.text = "掲示板からメッセージが届きました!"
        firstTitleLabel.textColor = .white
        firstTitleLabel.strokeColor = .accentColor
        firstTitleLabel.strokeSize = 5.0
        firstTitleLabel.setCustomShadow(opacity: 0.4, width: 2, height: 2, shadowRadius: 3.0)
        
        secondTitleLabel.text = "マッチングして返信しますか？"
        secondTitleLabel.textColor = .white
        secondTitleLabel.strokeColor = .accentColor
        secondTitleLabel.strokeSize = 5.0
        secondTitleLabel.setCustomShadow(opacity: 0.4, width: 2, height: 2, shadowRadius: 3.0)
        
        // BubbleView
        bubbleView.setCustomShadow(opacity: 0.3, height: 5)
        
        // ProfileView
        profileImageView.contentMode = .scaleAspectFill
        hobbyTagListView.textFont = .systemFont(ofSize: 11, weight: .semibold)
        profileStatusLabel.font = .systemFont(ofSize: 13.0)
        profileScrollView.clipsToBounds = true
        profileScrollView.layer.cornerRadius = 20
        shadowView.clipsToBounds = false
        shadowView.layer.cornerRadius = 20
        shadowView.setCustomShadow(opacity: 0.3, width: 3, height: 5)
        
        // Buttons
        notApproveButton.setCustomShadow(opacity: 0.5, width: 3, height: 5)
        approveButton.setCustomShadow(opacity: 0.5, width: 3, height: 5)
    }
}
