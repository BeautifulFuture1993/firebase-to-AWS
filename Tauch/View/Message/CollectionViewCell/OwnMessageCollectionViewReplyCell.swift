//
//  OwnMessageCollectionViewReplyCell.swift
//  Tauch
//
//  Created by Apple on 2023/08/23.
//

import UIKit

class OwnMessageCollectionViewReplyCell: UICollectionViewCell {

    @IBOutlet weak var messageStackView: UIStackView!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyMessageTextLabel: UILabel!
    
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reactionLabel: UILabel!
    
    static let nibName = "OwnMessageCollectionViewReplyCell"
    static let cellIdentifier = "OwnMessageCollectionViewReplyCell"
    
    var elaspedTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var pastTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy/MM/dd/ HH:mm"
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpStackView()
    }
    
    private func setUpStackView() {
        messageStackView.clipsToBounds = true
        messageStackView.allMaskedCorners()
    }
    
    func configure(_ message: Message, messages: [Message]) {
        
        let messageText = message.text
        let messageRead = message.read
        let messageSender = message.creator
        
        let loginUser = GlobalVar.shared.loginUser
        let loginUID = loginUser?.uid ?? ""
        let isOwnMessage = (messageSender == loginUID)
        
        messageStackView.backgroundColor = (isOwnMessage ? .accentColor : .systemGray6)
        messageView.backgroundColor = (isOwnMessage ? .accentColor : .systemGray6)
        replyView.backgroundColor = (isOwnMessage ? .accentColor : .systemGray6)
        
        let messageReplyID = message.reply_message_id
        
        if let replyMessage = messages.first(where: { $0.document_id == messageReplyID }) {
            
            let replyMessageText = replyMessage.text
            let replyMessageSender = replyMessage.creator
            
            let loginNickName = loginUser?.nick_name ?? ""
            let loginProfileIconImg = loginUser?.profile_icon_img ?? ""
            
            var replyMessageProfileIconImg = ""
            var replyMessageNickName = ""
            
            let isLoginUser = (replyMessageSender == loginUID)
            if isLoginUser {
                
                replyMessageProfileIconImg = loginProfileIconImg
                replyMessageNickName = loginNickName
                
            } else {
                
                let room = loginUser?.rooms.first(where: { $0.members.contains(replyMessageSender) })
                let partnerUser = room?.partnerUser
                let partnerNickName = partnerUser?.nick_name ?? ""
                let partnerProfileIconImg = partnerUser?.profile_icon_img ?? ""
                
                replyMessageProfileIconImg = partnerProfileIconImg
                replyMessageNickName = partnerNickName
            }
            
            iconImageView.clipsToBounds = true
            iconImageView.rounded()
            iconImageView.setBorder()
            iconImageView.setImage(withURLString: replyMessageProfileIconImg)
            
            nickNameLabel.text = replyMessageNickName
            nickNameLabel.textColor = (isOwnMessage ? .white : .fontColor)
            nickNameLabel.font = .boldSystemFont(ofSize: 12)
            nickNameLabel.numberOfLines = 1
            nickNameLabel.lineBreakMode = .byTruncatingTail
            
            messageTextLabel.text = replyMessageText
            messageTextLabel.textColor = (isOwnMessage ? .white : .fontColor)
            messageTextLabel.font = .systemFont(ofSize: 12)
            messageTextLabel.numberOfLines = 2
            messageTextLabel.lineBreakMode = .byTruncatingTail
        }
        
        replyMessageTextLabel.text = messageText
        replyMessageTextLabel.textColor = (isOwnMessage ? .white : .fontColor)
        replyMessageTextLabel.font = .systemFont(ofSize: 15)
        replyMessageTextLabel.numberOfLines = 0
        
        readLabel.isHidden = (messageRead ? false : true)
        
        let date = message.updated_at.dateValue()
        if Calendar.current.isDateInToday(date) {
            dateLabel.text = elaspedTime.string(from: message.updated_at.dateValue())
        } else if Calendar.current.isDateInYesterday(date) {
            dateLabel.text = "昨日 " + elaspedTime.string(from: message.updated_at.dateValue())
        } else {
            dateLabel.text = pastTime.string(from: message.updated_at.dateValue())
        }
        
        reactionLabel.isHidden = (message.reactionEmoji.isEmpty ? true : false)
        reactionLabel.text = message.reactionEmoji
    }
}
