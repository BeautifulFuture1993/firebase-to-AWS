//
//  OtherMessageTableViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/07/22.
//

import UIKit

class OtherMessageTableViewCell: UITableViewCell {

    static let nibName = "OtherMessageTableViewCell"
    static let cellIdentifier = "OtherMessageTableViewCell"
    static let height: CGFloat = 100
    static let width: CGFloat = 80
    
    var elaspedTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageContentView: UIStackView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.rounded()
        
        messageContentView.backgroundColor = .systemGray6
        messageTextLabel.textColor = .fontColor
        
        messageContentView.allMaskedCorners()
    }
    
    func configure(user: User, message: Message) {
        
        let iconImg = user.profile_icon_img
        iconImageView.setImage(withURLString: iconImg)
        
        let text = message.text
        let photos = message.photos
        let date = message.updated_at.dateValue()
        
        messageTextLabel.isHidden = (text.isEmpty ? true : false)
        messageTextLabel.text = text
        messageTextLabel.sizeToFit()
        
        messageImageView.isHidden = (photos.isEmpty ? true : false)
        photos.forEach({ messageImageView.setImage(withURLString: $0) })
        
        dateLabel.text = elaspedTime.string(from: date)
        dateLabel.sizeToFit()
    }
}
