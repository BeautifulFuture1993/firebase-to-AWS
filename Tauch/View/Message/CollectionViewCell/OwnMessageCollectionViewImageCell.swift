//
//  OwnMessageCollectionViewImageCell.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/08/10.
//

import UIKit

protocol OwnMessageCollectionViewImageCellDelegate: AnyObject {
    func onOwnImageViewTapped(cell: OwnMessageCollectionViewImageCell, imageUrl: String)
}

final class OwnMessageCollectionViewImageCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reactionLabel: UILabel!
    
    @IBOutlet var subStackViews: [UIStackView]!
    @IBOutlet var subStackImageViews: [UIImageView]!
    
    //MARK: NSConstraints
    // リアクションなし
    @IBOutlet weak var dateLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    // リアクションあり
    @IBOutlet weak var dateLabelBottomConstraintWithReaction: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraintWithReaction: NSLayoutConstraint!
    @IBOutlet weak var reactionBottomConstraint: NSLayoutConstraint!
    
    static let nibName = "OwnMessageCollectionViewImageCell"
    static let cellIdentifier = "OwnMessageCollectionViewImageCell"
    
    weak var delegate: OwnMessageCollectionViewImageCellDelegate?
    
    private var message: Message?
    
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
        setUpTapGesture()
        setUpImageViews()
    }
    
    private func setUpStackView() {
        stackView.clipsToBounds = true
        stackView.allMaskedCorners()
    }
    
    private func setUpTapGesture() {
        subStackImageViews.forEach({
            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(onOwnImageViewTapped(_:))
            )
            $0.addGestureRecognizer(tapGesture)
        })
    }
    
    private func setUpImageViews() {
        subStackImageViews.forEach {
            $0.backgroundColor = .systemGray6
        }
    }
    
    func configure(_ message: Message) {
        
        self.message = message
        
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
        
        let mediaURLs = message.photos
        // stackViewに表示するimageViewを判定
        subStackImageViews.forEach({
            if let mediaURL = mediaURLs[safe: $0.tag] {
                $0.isHidden = false
                $0.setImage(withURLString: mediaURL)
            } else {
                $0.isHidden = true
            }
        })
        // stackViewに表示を判定
        subStackViews.forEach({
            $0.isHidden = (mediaURLs[safe: $0.tag * 2] == nil ? true : false)
        })
        
        if message.reactionEmoji.isEmpty {
            reactionLabel.isHidden = true
            dateLabelBottomConstraint.isActive = true
            dateLabelBottomConstraintWithReaction.isActive = false
            stackViewBottomConstraint.isActive = true
            stackViewBottomConstraintWithReaction.isActive = false
        } else {
            reactionLabel.isHidden = false
            reactionLabel.text = message.reactionEmoji
            dateLabelBottomConstraint.isActive = false
            dateLabelBottomConstraintWithReaction.isActive = true
            stackViewBottomConstraint.isActive = false
            stackViewBottomConstraintWithReaction.isActive = true
        }
    }
    
    @objc private func onOwnImageViewTapped(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag, let imageUrl = message?.photos[tag] {
            delegate?.onOwnImageViewTapped(cell: self, imageUrl: imageUrl)
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
