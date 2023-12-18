//
//  MessageInputView.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/09/02.
//

import UIKit

protocol MessageInputViewStickerDelegate: AnyObject {
    func closeStickerPreview()
    func sendMessageSticker()
}

final class MessageInputView: UIView {

    var messageStickerPreview: UIView
    let stickerPreviewImageView = UIImageView()
    let stickerPreviewCloseButton = UIButton(type: .close)
    
    weak var stickerDelegate: MessageInputViewStickerDelegate?
    
    init() {
        messageStickerPreview = UIView()
        super.init(frame: .zero)
    }
    
    init(frame: CGRect, stickerPreviewFrame: CGRect) {
        messageStickerPreview = UIView(frame: stickerPreviewFrame)
        
        super.init(frame: frame)
        
        configureMessageStickerPreview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let previewIsShown = messageStickerPreview.isHidden == false
        
        if stickerPreviewCloseButton.bounds.contains(stickerPreviewCloseButton.convert(point, from: self)) && previewIsShown {
            return stickerPreviewCloseButton
        } else if stickerPreviewImageView.bounds.contains(stickerPreviewImageView.convert(point, from: self)) && previewIsShown {
            return stickerPreviewImageView
        } else if messageStickerPreview.bounds.contains(messageStickerPreview.convert(point, from: self)) && previewIsShown {
            return messageStickerPreview
        }
        return super.hitTest(point, with: event)
    }
    
    // MARK: StickerPreview
    private func configureMessageStickerPreview() {
        let screenHeight = UIScreen.main.bounds.size.height
        
        self.addSubview(messageStickerPreview)
        messageStickerPreview.backgroundColor = .systemGray6.withAlphaComponent(0.8)
        messageStickerPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePreview)))
        
        stickerPreviewImageView.contentMode = .scaleAspectFit
        stickerPreviewImageView.isUserInteractionEnabled = true
        stickerPreviewImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendMessageSticker)))
        messageStickerPreview.addSubview(stickerPreviewImageView)
        stickerPreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        stickerPreviewImageView.widthAnchor.constraint(equalToConstant: screenHeight * 0.15).isActive = true
        stickerPreviewImageView.heightAnchor.constraint(equalToConstant: screenHeight * 0.15).isActive = true
        stickerPreviewImageView.centerXAnchor.constraint(equalTo: messageStickerPreview.centerXAnchor).isActive = true
        stickerPreviewImageView.centerYAnchor.constraint(equalTo: messageStickerPreview.centerYAnchor).isActive = true
        
        stickerPreviewCloseButton.addTarget(self, action: #selector(closePreview), for: .touchUpInside)
        stickerPreviewCloseButton.setTitle("", for: .normal)
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .fontColor
        stickerPreviewCloseButton.configuration = configuration
        messageStickerPreview.addSubview(stickerPreviewCloseButton)
        stickerPreviewCloseButton.translatesAutoresizingMaskIntoConstraints = false
        stickerPreviewCloseButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        stickerPreviewCloseButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        stickerPreviewCloseButton.topAnchor.constraint(equalTo: messageStickerPreview.topAnchor, constant: 20.0).isActive = true
        stickerPreviewCloseButton.trailingAnchor.constraint(equalTo: messageStickerPreview.trailingAnchor, constant: -20.0).isActive = true
    }
    
    /// messageStickerPreviewの表示・非表示を行う
    func setStickerPreview(active: Bool) {
        if active {
            messageStickerPreview.isHidden = false
        } else {
            messageStickerPreview.isHidden = true
        }
    }
    
    @objc private func closePreview() {
        stickerDelegate?.closeStickerPreview()
    }
    
    @objc private func sendMessageSticker() {
        stickerDelegate?.sendMessageSticker()
    }
}
