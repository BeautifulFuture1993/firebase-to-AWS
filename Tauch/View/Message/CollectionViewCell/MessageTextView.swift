//
//  MessageTextView.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/09/06.
//

import UIKit

final class MessageTextView: UITextView {

    override var isFocused: Bool {
        false
    }

    override var canBecomeFirstResponder: Bool {
        false
    }

    override var canBecomeFocused: Bool {
        false
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }
}
