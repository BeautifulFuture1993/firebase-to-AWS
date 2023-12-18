//
//  InputAccessoryView.swift
//  Tauch
//
//  Created by Apple on 2023/07/25.
//

import UIKit
import KMPlaceholderTextView

class InputAccessoryView: UIView {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var messageInputTextView: KMPlaceholderTextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        nibInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        nibInit()
    }
    
    // カスタムビューの初期化
    private func nibInit() {
        
        autoresizingMask = .flexibleHeight
        
        let nib = UINib(nibName: "InputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        
        configure()
    }
    
    // textViewの高さを可変にする(initでautoresizingMaskの設定必要)
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func configure() {
        messageInputTextView.allMaskedCorners()
    }

}
