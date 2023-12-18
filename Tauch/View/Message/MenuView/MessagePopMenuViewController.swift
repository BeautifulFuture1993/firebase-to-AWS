//
//  MessagePopMenuViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/08/11.
//

import UIKit

protocol MessagePopMenuViewControllerDelegate: AnyObject {
    
    func replyButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController)
    func copyButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController)
    func showImageButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController)
    func unsendButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController)
    func reactionButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController, didSelectedReaction: String)
}

final class MessagePopMenuViewController: UIViewController {
    
    static let storyboardName = "MessagePopMenuViewController"
    static let storybaordId = "MessagePopMenuViewController"
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var showImageButton: UIButton!
    @IBOutlet weak var unsendButton: UIButton!
    @IBOutlet weak var menuSpaceView: UIView!
    @IBOutlet weak var topReactionStackView: UIStackView!
    @IBOutlet weak var bottomReactionStackView: UIStackView!
    @IBOutlet var reactionButtons: [UIButton]!
    
    private let isLoginUser: Bool
    private let isUpper: Bool
    private let type: CustomMessageType
    
    weak var delegate: MessagePopMenuViewControllerDelegate?
    private let reactionArray = ["❤️", "😆", "😥", "😊", "👍"]
    
    init?(coder: NSCoder, isLoginUser: Bool, isUpper: Bool, type: CustomMessageType) {
        self.isLoginUser = isLoginUser
        self.isUpper = isUpper
        self.type = type
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("MessagePopMenuViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reactionButtons.forEach({ $0.backgroundColor = .clear })
        topReactionStackView.backgroundColor = .clear
        bottomReactionStackView.backgroundColor = .clear
        
        switch (isLoginUser, isUpper, type) {
        case (true, true, .text), (true, true, .image), (true, true, .reply):
            topReactionStackView.isHidden = true
            menuSpaceView.isHidden = true
            showImageButton.isHidden = true
            self.preferredContentSize = CGSize(width: 280, height: 130)
            replyButton.clipsToBounds = true
            replyButton.layer.cornerRadius = 8.0
            replyButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            unsendButton.clipsToBounds = true
            unsendButton.layer.cornerRadius = 8.0
            unsendButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
        case (true, false, .text), (true, false, .image), (true, false, .reply):
            bottomReactionStackView.isHidden = true
            menuSpaceView.isHidden = true
            showImageButton.isHidden = true
            self.preferredContentSize = CGSize(width: 280, height: 130)
            replyButton.clipsToBounds = true
            replyButton.layer.cornerRadius = 8.0
            replyButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            unsendButton.clipsToBounds = true
            unsendButton.layer.cornerRadius = 8.0
            unsendButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
        case (false, true, .text), (false, true, .image), (false, true, .reply):
            topReactionStackView.isHidden = true
            unsendButton.isHidden = true
            showImageButton.isHidden = true
            self.preferredContentSize = CGSize(width: 260, height: 130)
            replyButton.clipsToBounds = true
            replyButton.layer.cornerRadius = 8.0
            replyButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            menuSpaceView.clipsToBounds = true
            menuSpaceView.layer.cornerRadius = 8.0
            menuSpaceView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
        case (false, false, .text), (false, false, .image), (false, false, .reply):
            bottomReactionStackView.isHidden = true
            unsendButton.isHidden = true
            showImageButton.isHidden = true
            self.preferredContentSize = CGSize(width: 260, height: 130)
            replyButton.clipsToBounds = true
            replyButton.layer.cornerRadius = 8.0
            replyButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            menuSpaceView.clipsToBounds = true
            menuSpaceView.layer.cornerRadius = 8.0
            menuSpaceView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
        default:
            fatalError("MessagePopMenuViewController - 想定外の入力を受け取った")
        }
    }
    
    @IBAction func replyButtonPressed(_ sender: UIButton) {
        delegate?.replyButtonPressed(self)
    }
    
    @IBAction func copyButtonPressed(_ sender: UIButton) {
        delegate?.copyButtonPressed(self)
    }
    
    @IBAction func showImageButtonPressed(_ sender: UIButton) {
        delegate?.showImageButtonPressed(self)
    }
    
    @IBAction func unsendButtonPressed(_ sender: UIButton) {
        delegate?.unsendButtonPressed(self)
    }
    
    @IBAction func reactionButtonPressed(_ sender: UIButton) {
        let selectedReaction = reactionArray[sender.tag]
        delegate?.reactionButtonPressed(self, didSelectedReaction: selectedReaction)
    }
}
