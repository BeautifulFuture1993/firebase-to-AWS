//
//  OwnMessageTableViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/07/22.
//

import UIKit

class OwnMessageTableViewCell: UITableViewCell {

    static let nibName = "OwnMessageTableViewCell"
    static let cellIdentifier = "OwnMessageTableViewCell"
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
    
    @IBOutlet weak var messageContentView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        messageContentView.backgroundColor = .accentColor
        messageContentView.allMaskedCorners()

        messageTextLabel.textColor = .white
    }
    
    func configure(user: User, message: Message) {
        
        let text = message.text
        let photos = message.photos
        let read = message.read
        let date = message.updated_at.dateValue()
        
//        messageTextLabel.isHidden = (text.isEmpty ? true : false)
//        messageTextLabel.text = text
//
//        messageImageView.isHidden = (photos.isEmpty ? true : false)
//        photos.forEach({ messageImageView.setImage(withURLString: $0) })
//
//        readLabel.isHidden = (read ? true : false)
//        dateLabel.text = elaspedTime.string(from: date)
    }
}
