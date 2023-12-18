//
//  CardNoneView.swift
//  Tatibanashi-MVP
//
//  Created by Apple on 2022/05/06.
//

import UIKit
import SwiftUI

final class CardNoneView: UIView {
    
    let commentLabel: UILabel = {
        let il = UILabel()
        il.textColor = .black
        il.font = UIFont.boldSystemFont(ofSize: 20)
        il.textAlignment = .center
        il.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        il.numberOfLines = 0
        return il
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        configureUI()
    }
    
    init(comment: String) {
        self.init()
        // 注意書き
        commentLabel.text = comment
    }
    
    deinit {
        // print("CardNoneViewを解放しました")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Helper functions
    
    // panGestureとimageViewの貼付
    private func configureUI() {
        addSubview(commentLabel)
        // AutoLayout制約を追加
        commentLabelConstraint(label: commentLabel)
    }

    private func commentLabelConstraint(label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 250.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    }

}
