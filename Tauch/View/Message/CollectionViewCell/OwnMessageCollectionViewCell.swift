//
//  OwnMessageCollectionViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/07/26.
//

import UIKit

final class OwnMessageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reactionLabel: UILabel!
    
    //MARK: NSConstraints
    // リアクションなし
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabelBottomConstraint: NSLayoutConstraint!
    // リアクションあり
    @IBOutlet weak var textViewBottomConstraintWithReaction: NSLayoutConstraint!
    @IBOutlet weak var dateLabelBottomConstraintWithReaction: NSLayoutConstraint!
    @IBOutlet weak var reactionBottomConstraint: NSLayoutConstraint!
    
    static let nibName = "OwnMessageCollectionViewCell"
    static let cellIdentifier = "OwnMessageCollectionViewCell"
    
    private var balloonView = OwnBalloonView()
    private let BALLOON_SIZE = 30.0
    private let RIGHT_MARGIN = 5.0
    
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
        setUpBalloonView()
        setUpContextMenu()
    }
    
    private func setUpBalloonView() {
        let screenSize = UIScreen.main.bounds.size
        balloonView.frame = CGRect(
            x: (screenSize.width - RIGHT_MARGIN) - (BALLOON_SIZE - (RIGHT_MARGIN * 2)),
            y: 0,
            width: BALLOON_SIZE,
            height: BALLOON_SIZE
        )
        addSubview(balloonView)
    }
    
    private func setAttributedText(_ text: String) -> NSAttributedString {
        let attributedText = NSAttributedString(string: text, attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white,
        ])
        
        return attributedText
    }
    
    func configure(_ user: User, message: Message) {
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
        
        if message.read {
            readLabel.isHidden = false
        } else {
            readLabel.isHidden = true
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
}

extension OwnMessageCollectionViewCell: UIContextMenuInteractionDelegate {
 
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
