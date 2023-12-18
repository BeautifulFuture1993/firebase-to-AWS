//
//  CustomTextField.swift
//  Tauch
//
//  Created by Apple on 2022/09/18.
//

import UIKit
import Foundation

final class CustomTextField: UITextField {
    
    /* 入力キャレット非表示 */
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    /* 範囲選択カーソル非表示 */
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    /* コピー・ペースト・選択等のメニュー非表示 */
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
