//
//  OtherMessageCollectionViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/07/26.
//

import UIKit

protocol OtherMessageCollectionViewCellDelegate: AnyObject {
    func onProfileIconTapped(cell: OtherMessageCollectionViewCell, user: User)
}

final class OtherMessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reactionLabel: UILabel!
    // リアクションなし
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabelBottomConstraint: NSLayoutConstraint!
    // リアクションあり
    @IBOutlet weak var textViewBottomConstraintWithReaction: NSLayoutConstraint!
    @IBOutlet weak var dateLabelBottomConstraintWithReaction: NSLayoutConstraint!
    @IBOutlet weak var reactionBottomConstraint: NSLayoutConstraint!
    
    static let nibName = "OtherMessageCollectionViewCell"
    static let cellIdentifier = "OtherMessageCollectionViewCell"
    
    weak var delegate: OtherMessageCollectionViewCellDelegate?
    
    var user: User?
    
    private var balloonView = OtherBalloonView()
    private let BALLOON_SIZE = 30.0
    
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

        setUpTapGesture()
        setUpBalloonView()
        setUpImageView()
        setUpContextMenu()
    }
    
    private func setUpTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(onIconImageViewTapped(_:))
        )
        iconImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setUpBalloonView() {
        balloonView.frame = CGRect(
            x: textView.frame.minX - (BALLOON_SIZE / 3) + 5,
            y: textView.frame.minY - 7.0,
            width: BALLOON_SIZE,
            height: BALLOON_SIZE
        )
        addSubview(balloonView)
    }

    private func setAttributedText(_ text: String) -> NSAttributedString {
        let attributedText = NSAttributedString(string: text, attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1),
        ])
        
        return attributedText
    }
    
    private func setUpImageView() {
        iconImageView.clipsToBounds = true
        iconImageView.rounded()
        let iconImageViewTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(onIconImageViewTapped(_:))
        )
        iconImageView.addGestureRecognizer(iconImageViewTapGesture)
    }
    
    func configure(_ user: User, message: Message) {
        
        self.user = user
        
        let iconImg = user.profile_icon_img
        iconImageView.setImage(withURLString: iconImg)
        
        if message.text.isEmpty {
            textView.isHidden = true
            balloonView.isHidden = true
        } else {
            textView.isHidden = false
            balloonView.isHidden = false
            textView.textContainer.lineFragmentPadding = 10
            textView.attributedText = setAttributedText(message.text)
        }
        
        if textView.dataDetectorTypes == .link {
            textView.tintColor = .link
        }
        
        let date = message.updated_at.dateValue()
        if Calendar.current.isDateInToday(date) {
            dateLabel.text = elaspedTime.string(from: message.updated_at.dateValue())
        } else if Calendar.current.isDateInYesterday(date) {
            dateLabel.text = "昨日 " + elaspedTime.string(from: message.updated_at.dateValue())
        } else {
            dateLabel.text = pastTime.string(from: message.updated_at.dateValue())
        }
        
        if message.reactionEmoji.isEmpty {
            reactionLabel.isHidden = true
            dateLabelBottomConstraint.isActive = true
            dateLabelBottomConstraintWithReaction.isActive = false
            textViewBottomConstraint.isActive = true
            textViewBottomConstraintWithReaction.isActive = false
        } else {
            reactionLabel.isHidden = false
            reactionLabel.text = message.reactionEmoji
            dateLabelBottomConstraint.isActive = false
            dateLabelBottomConstraintWithReaction.isActive = true
            textViewBottomConstraint.isActive = false
            textViewBottomConstraintWithReaction.isActive = true
        }
    }
    
    func animateReactionLabel(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.reactionBottomConstraint.constant += 50
            self?.layoutIfNeeded()
            self?.reactionLabel.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.5, animations: {
                self?.reactionBottomConstraint.constant = 0
                self?.layoutIfNeeded()
                self?.reactionLabel.transform = .identity
            }, completion: completion)
        }
    }
    
    @objc private func onIconImageViewTapped(_ sender: UITapGestureRecognizer) {
        if let user = user {
            delegate?.onProfileIconTapped(cell: self, user: user)
        }
    }
}

extension OtherMessageCollectionViewCell: UIContextMenuInteractionDelegate {
 
    private func setUpContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        textView.addInteraction(interaction)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let action = UIAction(title: "コピー") { _ in
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.textView.text
        }
        let menu = UIMenu(title: "", children: [action])
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return menu
        }
    }
}
