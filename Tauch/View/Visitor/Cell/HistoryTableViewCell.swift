//
//  HistoryTableViewCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/06.
//

import UIKit
import TagListView

protocol HistoryTableViewCellDelegate: AnyObject {
    func didTapGoDetail(cell: HistoryTableViewCell)
    func didTapVisitorAction(cell: HistoryTableViewCell)
}

class HistoryTableViewCell: UITableViewCell {
    
    static var heightWithComment: CGFloat = 135 // 高さは可変にしたい
    static var height: CGFloat = 100
    static let cellIdentifier = "HistoryTableViewCell"
    static let nib: UINib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var newBadge: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusMessageView: UIStackView!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var hobbyTagListView: TagListView!
    // カスタムButton
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var buttonBackgroundImage: UIImageView!
    @IBOutlet weak var buttonIconImageView: UIImageView!
    @IBOutlet weak var reactionButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    // 足あとコメント
    @IBOutlet weak var visitCommentView: UIView!
    @IBOutlet weak var visitCommentIcon: UIImageView!
    @IBOutlet weak var visitCommentLabel: UILabel!
    
    weak var cellDelegate: HistoryTableViewCellDelegate?
    var user: User?
    var actionType: String?
    private var hobbyTag: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureBasicSettings()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func reactionButtonPressed(_ sender: UIButton) {
        cellDelegate?.didTapVisitorAction(cell: self)
    }
    
    @objc func iconImageTapped(_ sender : UITapGestureRecognizer) {
        cellDelegate?.didTapGoDetail(cell: self)
    }
}


//MARK: - Appearance

extension HistoryTableViewCell {
    
    private func configureBasicSettings() {
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = (iconImageView.frame.height / 2)
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = .systemGray5
        iconImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(iconImageTapped(_:)))
        iconImageView.addGestureRecognizer(tapGesture)
        
        newBadge.clipsToBounds = true
        newBadge.layer.cornerRadius = (newBadge.frame.height / 2)
        newBadge.backgroundColor = .accentColor
        
        ageLabel.font = .systemFont(ofSize: 10.0, weight: .bold)
        ageLabel.textAlignment = .right
        ageLabel.adjustsFontSizeToFitWidth = true
        
        addressLabel.font = .systemFont(ofSize: 10.0, weight: .bold)
        addressLabel.textAlignment = .left
        addressLabel.adjustsFontSizeToFitWidth = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .heavy)
        
        statusMessageView.backgroundColor = .clear
        statusMessageLabel.textColor = .fontColor
        statusMessageLabel.font = .systemFont(ofSize: 10.0, weight: .medium)
        
        buttonBackgroundImage.clipsToBounds = true
        buttonBackgroundImage.layer.cornerRadius = (buttonBackgroundImage.frame.height / 2)
        buttonBackgroundImage.contentMode = .scaleToFill
        buttonIconImageView.tintColor = .white
        buttonIconImageView.backgroundColor = .clear
        
        reactionButton.configuration = nil
        reactionButton.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .heavy)
        reactionButton.backgroundColor = .clear
        reactionButton.tintColor = .clear
        reactionButton.setTitleColor(.white, for: .normal)
        
        timeLabel.font = .systemFont(ofSize: 11.0)
        timeLabel.textColor = .fontColor
        timeLabel.textAlignment = .right
        
        hobbyTagListView.textFont = .systemFont(ofSize: 10.0, weight: .bold)
        
        visitCommentView.backgroundColor = .clear
        visitCommentIcon.image = UIImage(systemName: "pawprint")
        visitCommentIcon.tintColor = .accentColor
        visitCommentLabel.font = .systemFont(ofSize: 10.0, weight: .bold)
        visitCommentLabel.textAlignment = .left
        visitCommentLabel.textColor = .fontColor
        visitCommentLabel.adjustsFontSizeToFitWidth = true
    }
}

//MARK: - set user info

extension HistoryTableViewCell {
    
    func configure(with user: User, visitor: Visitor, comment: Bool, visitorUnreadList: [String] = []) {

        self.user = user
        
        let profileIconImg = user.profile_icon_img
        let nickName = user.nick_name
        let age = user.birth_date.calcAge()
        let address = user.address.removePrefectureCharacters()
        let profileStatus = user.profile_status
        let hobbies = user.hobbies.sorted(by: { $0.count < $1.count })
        
        let prevHobbyCount = hobbies.prefix(2).reduce(0, { totalHobbiesCount, currentHobbies in
            totalHobbiesCount + currentHobbies.count
        })
        let hobbyTag = (prevHobbyCount < 20 ? Array(hobbies.prefix(3)) : Array(hobbies.prefix(2)))
    
        iconImageView.setImage(withURLString: profileIconImg)
        nameLabel.text = nickName
        ageLabel.text = age
        addressLabel.text = address
        statusMessageLabel.text = profileStatus
        hobbyTagListView.removeAllTags()
        hobbyTagListView.addTags(hobbyTag)
        
        visitCommentView.isHidden = (comment ? false : true)
        newBadge.isHidden = (comment ? false : true)
        
        if comment {
            
            let visitorID = visitor.document_id
            let visitorComment = visitor.comment
            let visitorCommentImg = visitor.comment_img
            
            let isCommentView = (visitorComment != "" && visitorCommentImg != "")
            visitCommentView.isHidden = (isCommentView ? false : true)
            visitCommentLabel.text = visitorComment

            if isCommentView {

                let comeVisitor = (visitorCommentImg == "visitor")
                let boardVisitor = (visitorCommentImg == "board")

                if comeVisitor {
                    visitCommentIcon.image = UIImage(systemName: "pawprint.fill")
                    visitCommentIcon.transform = CGAffineTransform(rotationAngle: CGFloat(30 * CGFloat.pi / 180))
                } else if boardVisitor {
                    visitCommentIcon.image = UIImage(systemName: "list.bullet.clipboard.fill")
                    visitCommentIcon.transform = CGAffineTransform(rotationAngle: CGFloat(30 * CGFloat.pi / 180))
                } else {
                    visitCommentIcon.setImage(withURLString: visitorCommentImg)
                    visitCommentIcon.transform = .identity
                }
            }
            
            newBadge.isHidden = (visitorUnreadList.contains(visitorID) ? false : true)
        }
        
        let visitTime = visitor.updated_at.dateValue()
        timeLabel.text = ElapsedTime.customFormat(from: visitTime, type: "time")
        
        setReactionButtonStatus(user: user)
    }
    
    // ユーザの状態に合わせたボタンのUI・操作設定
    func setReactionButtonStatus(user: User) {
        /* 「いいね！」 */
        reactionButton.isUserInteractionEnabled = true
        reactionButton.setTitle("いいね！", for: .normal)
        buttonIconImageView.image = UIImage(systemName: "hand.thumbsup.fill")
        buttonBackgroundImage.image = UIImage()
        buttonBackgroundImage.backgroundColor = .accentColor
        
        actionType = "good"
        
        /* 「いいね！済み」 */
        let checkApproaches = checkApproaches(user: user)
        if checkApproaches {
            reactionButton.isUserInteractionEnabled = false
            reactionButton.setTitle("いいね！済み", for: .normal)
            buttonIconImageView.image = UIImage()
            buttonBackgroundImage.image = UIImage()
            buttonBackgroundImage.backgroundColor = .disableColor
            
            actionType = nil
        }
        
        /* 「ありがとう！」 */
        let checkApproacheds = checkApproacheds(user: user)
        if checkApproacheds {
            reactionButton.isUserInteractionEnabled = true
            reactionButton.setTitle("ありがとう！", for: .normal)
            buttonIconImageView.image = UIImage(systemName: "hand.thumbsup.fill")
            buttonBackgroundImage.backgroundColor = .blueAccentColor
            
            actionType = "match"
        }
        
        /* 「メッセージを送る」 */
        let determineUserIsPartner = determineUserIsPartner(user: user)
        if determineUserIsPartner {
            reactionButton.isUserInteractionEnabled = true
            reactionButton.setTitle("メッセージを送る", for: .normal)
            buttonIconImageView.image = UIImage(systemName: "ellipsis.message.fill")
            buttonBackgroundImage.image = UIImage()
            buttonBackgroundImage.backgroundColor = .accentColor
            
            actionType = "message"
        }
        
        /* 「退会済みのユーザです」 */
        let checkNotActive = checkNotActive(user: user)
        if checkNotActive {
            reactionButton.isUserInteractionEnabled = false
            reactionButton.setTitle("退会済みのユーザーです", for: .normal)
            buttonIconImageView.image = UIImage()
            buttonBackgroundImage.image = UIImage()
            buttonBackgroundImage.backgroundColor = .disableColor
            
            actionType = nil
        }
    }
}
