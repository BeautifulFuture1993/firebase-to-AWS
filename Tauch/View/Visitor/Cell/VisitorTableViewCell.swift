//
//  VisitorTableViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/05/29.
//

import UIKit

protocol VisitorTableViewCellDelegate: AnyObject {
    func didTapGoDetail(cell: VisitorTableViewCell)
    func didTapVisitorAction(cell: VisitorTableViewCell)
}

class VisitorTableViewCell: UITableViewCell {

    static let height: CGFloat = 110
    static let heightWithComment: CGFloat = 150
    static let cellIdentifier = "VisitorTableViewCell"
    static let nibName = "VisitorTableViewCell"
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var commentImg: UIImageView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var iconImgBtn: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var userDetailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    @IBOutlet weak var visitorBtn: UIButton!
    @IBOutlet weak var visitorImgView: UIImageView!
    
    weak var delegate : VisitorTableViewCellDelegate?
    
    var user: User?
    var actionType: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commentView.layer.cornerRadius = 10
        commentImg.layer.cornerRadius = 5
        iconImgView.layer.cornerRadius = iconImgView.frame.height / 2
        iconImgBtn.layer.cornerRadius = iconImgBtn.frame.height / 2
        visitorBtn.layer.cornerRadius = visitorBtn.frame.height / 2
    }
    
    @IBAction func profileDetailAction(_ sender: Any) {
        didTapGoDetail()
    }
    
    @IBAction func visitorAction(_ sender: Any) {
        didTapVisitorAction()
    }
    
    @objc func didTapGoDetail() {
        delegate?.didTapGoDetail(cell: self)
    }
    
    @objc func didTapVisitorAction() {
        delegate?.didTapVisitorAction(cell: self)
    }
    
    func configure(with user: User, visitor: Visitor, visitorUnreadList: [String]) {

        self.user = user
        
        let profileIconImg = user.profile_icon_img
        let nickName = user.nick_name
        let age = user.birth_date.calcAge()
        let address = user.address.removePrefectureCharacters() + " " + user.address2
        let visitorID = visitor.document_id
        let visitorComment = visitor.comment
        let visitorCommentImg = visitor.comment_img
        let visitTime = visitor.updated_at.dateValue()
        
        let isCommentView = (visitorComment != "" && visitorCommentImg != "")
        commentView.isHidden = (isCommentView ? false : true)
        comment.text = visitorComment
        
        if isCommentView {
            
            let comeVisitor = (visitorCommentImg == "visitor")
            let boardVisitor = (visitorCommentImg == "board")
            
            if comeVisitor {
                commentImg.image = UIImage(systemName: "pawprint.fill")
            } else if boardVisitor {
                commentImg.image = UIImage(systemName: "list.bullet.clipboard.fill")
            } else {
                commentImg.setImage(withURLString: visitorCommentImg)
            }
        }
        
        iconImgView.setImage(withURLString: profileIconImg)
        nickNameLabel.text = nickName
        userDetailLabel.text = age + " " + address
        dateLabel.text = ElapsedTime.customFormat(from: visitTime, type: "time")
        unreadLabel.isHidden = (visitorUnreadList.contains(visitorID) ? false : true)
        
        configureVisitorBtn(user: user)
    }
    
    func configureVisitorBtn(user: User) {
        
        visitorBtn.setTitle("いいね！", for: .normal)
        visitorBtn.backgroundColor = .accentColor
        visitorBtn.isUserInteractionEnabled = true
        
        visitorImgView.image = UIImage(systemName: "hand.thumbsup.fill")
        
        actionType = "good"
        
        let checkApproaches = checkApproaches(user: user)
        if checkApproaches {
            visitorBtn.setTitle("いいね！送信済み", for: .normal)
            visitorBtn.backgroundColor = .gray
            visitorBtn.isUserInteractionEnabled = false
            
            actionType = nil
        }
        
        let checkApproacheds = checkApproacheds(user: user)
        if checkApproacheds {
            visitorBtn.setTitle("いいね！ありがとう", for: .normal)
            visitorBtn.backgroundColor = .accentColor
            visitorBtn.isUserInteractionEnabled = true
            
            actionType = "match"
        }
        
        let determineUserIsPartner = determineUserIsPartner(user: user)
        if determineUserIsPartner {
            visitorBtn.setTitle("メッセージを送信", for: .normal)
            visitorBtn.backgroundColor = .accentColor
            visitorBtn.isUserInteractionEnabled = true
            visitorImgView.image = UIImage(systemName: "message.fill")
            
            actionType = "message"
        }
        
        let checkNotActive = checkNotActive(user: user)
        if checkNotActive {
            visitorBtn.setTitle("退会済みのユーザです", for: .normal)
            visitorBtn.backgroundColor = .gray
            visitorBtn.isUserInteractionEnabled = false
            
            actionType = nil
        }
    }
}
