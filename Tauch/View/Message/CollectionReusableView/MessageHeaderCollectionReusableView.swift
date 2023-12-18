//
//  MessageHeaderCollectionReusableView.swift
//  Tauch
//
//  Created by Apple on 2023/07/26.
//

import UIKit

final class MessageHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var headerSecionTitle: UILabel!
    
    static let nibName = "MessageHeaderCollectionReusableView"
    static let cellIdentifier = "MessageHeaderCollectionReusableView"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(text: String) {
        headerSecionTitle.text = text
    }
}
