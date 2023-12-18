//
//  BBSTableViewCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/10.
//

import UIKit

protocol BBSTableViewCellDelegate: AnyObject {
    func didTapMenuAction(cell: BBSTableViewCell)
    func didTapVisitorAction(cell: BBSTableViewCell)
    func didTapMessageAction(cell: BBSTableViewCell)
    func didTapGoDetail(cell: BBSTableViewCell)
    func didTapMessageImage(cell: BBSTableViewCell)
}

class BBSTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "BBSTableViewCell", bundle: nil)
    static let cellIdentifier = "BBSTableViewCell"
    
    static let height: CGFloat = 150
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var categoryTagView: BBSCategoryTagView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var visitorButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var board: Board?
    weak var delegate: BBSTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureAppearance()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        delegate?.didTapMenuAction(cell: self)
    }
    
    @IBAction func visitorButtonPressed(_ sender: UIButton) {
        delegate?.didTapVisitorAction(cell: self)
    }
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        delegate?.didTapMessageAction(cell: self)
    }
    
    @objc func iconImageTapped(_ sender : UITapGestureRecognizer) {
        delegate?.didTapGoDetail(cell: self)
    }
    
    @objc func messageImageTapped(_ sender : UITapGestureRecognizer) {
        delegate?.didTapMessageImage(cell: self)
    }
}

//MARK: - Appearance

extension BBSTableViewCell {
    
    private func configureAppearance() {
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.isUserInteractionEnabled = true
        
        let iconImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(iconImageTapped(_:)))
        iconImageView.addGestureRecognizer(iconImageTapGesture)
        
        nameLabel.font = .systemFont(ofSize: 14.0, weight: .bold)
        nameLabel.textColor = .fontColor
        
        addressLabel.font = .systemFont(ofSize: 12.0, weight: .bold)
        addressLabel.textColor = .fontColor
        
        timeLabel.font = .systemFont(ofSize: 14.0)
        timeLabel.textColor = .lightGray
        
        categoryLabel.font = .systemFont(ofSize: 11.0, weight: .medium)
        categoryLabel.textColor = .white
        
        messageTextView.font = .systemFont(ofSize: 14.0)
        messageTextView.isScrollEnabled = false
        
        messageImageView.clipsToBounds = true
        messageImageView.layer.cornerRadius = 20.0
        messageImageView.isUserInteractionEnabled = true
        let messageImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(messageImageTapped(_:)))
        messageImageView.addGestureRecognizer(messageImageTapGesture)
    }
}


//MARK: - Set BBS Info

extension BBSTableViewCell {
    
    func configure(board: Board) {
        
        self.board = board
        
        let boardTime = board.created_at.dateValue()
        let boardCategory = board.category
        let boardText = board.text
        let boardPhotos = board.photos
        let boardVisitors = board.visitors
        let boardMessangers = board.messangers
        let boardCreator = board.creator
        let boardAdmin = board.is_admin
        
        let loginUID = GlobalVar.shared.loginUser?.uid ?? ""
        
        let isAdmin = (boardAdmin == true)
        let isLogin = (loginUID == boardCreator)
        let isAdminOrLogin = (isAdmin || isLogin)
        
        timeLabel.isHidden = (isAdmin ? true : false)
        timeLabel.text = ElapsedTime.elapsedTime(from: boardTime)
        
        categoryLabel.isHidden = (isAdmin ? true : false)
        categoryLabel.text = boardCategory
        
        categoryTagView.isHidden = (isAdmin ? true : false)
        categoryTagView.backgroundColor = (boardCategory == .categoryFriend  ? .categoryFriendColor  : categoryTagView.backgroundColor)
        categoryTagView.backgroundColor = (boardCategory == .categoryWorries ? .categoryWorriesColor : categoryTagView.backgroundColor)
        categoryTagView.backgroundColor = (boardCategory == .categoryTeaser  ? .categoryTeaserColor  : categoryTagView.backgroundColor)
        categoryTagView.backgroundColor = (boardCategory == .categoryTweet  ? .categoryTweetColor  : categoryTagView.backgroundColor)
        
        menuButton.isHidden = (isAdmin ? true : false)
        
        messageTextView.text = boardText
        messageTextView.isHidden = (boardText.isEmpty ? true : false)
        
        if let boardPhoto = boardPhotos[safe: 0] {
            messageImageView.isHidden = false
            messageImageView.setImage(withURLString: boardPhoto)
        } else {
            messageImageView.isHidden = true
        }
        
        visitorButton.isHidden = (isAdminOrLogin ? true : false)
        visitorButton.tintColor = (boardVisitors.contains(loginUID) ? .accentColor : .lightGray)
        
        if let visitorButtonImage = (
            boardVisitors.contains(loginUID) ? UIImage(systemName: "pawprint.fill") : UIImage(systemName: "pawprint")
        ) {
            visitorButton.setImage(visitorButtonImage, for: .normal)
        }
        
        messageButton.isHidden = (isLogin ? true : false)
        messageButton.tintColor = (boardMessangers.contains(loginUID) ? .accentColor : .lightGray)
        
        if let messageButtonImage = (
            boardMessangers.contains(loginUID) ? UIImage(systemName: "message.fill") : UIImage(systemName: "message")
        ) {
            messageButton.setImage(messageButtonImage, for: .normal)
        }
        
        if let user = board.userInfo {
            
            let nickName = user.nick_name
            let address = user.address
            let profileIconImg = user.profile_icon_img
            
            iconImageView.setImage(withURLString: profileIconImg)
            nameLabel.text = nickName
            addressLabel.text = address
        }
    }
}
