//
//  CardSideView.swift
//  Tauch
//
//  Created by Apple on 2022/05/17.
//

import UIKit
import SwiftUI

final class CardSideView: UIView {

    let leftSideView: UIView = {
       let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: 150, height: 70)
        v.contentMode = .scaleToFill
        v.backgroundColor = .darkGray
        v.layer.cornerRadius = 10
        return v
    }()
    
    let leftSideImageView: UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        iv.image = UIImage(systemName: "hand.thumbsdown.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0.2
        return iv
    }()
    
    let leftSideLabel: UILabel = {
        let il = UILabel()
        il.frame = CGRect(x: 0, y: 0, width: 40, height: 25)
        il.textColor = .white
        il.font = UIFont(name: "HelveticaNeue", size: 14)
        il.text = "Skip"
        il.lineBreakMode = .byCharWrapping
        return il
    }()
    
    let rightSideView: UIView = {
       let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: 150, height: 70)
        v.contentMode = .scaleToFill
        v.backgroundColor = UIColor(named: "AccentColor")
        v.layer.cornerRadius = 10
        return v
    }()
    
    let rightSideImageView: UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        iv.image = UIImage(systemName: "hand.thumbsup.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0.2
        return iv
    }()
    
    let rightSideLabel: UILabel = {
        let il = UILabel()
        il.frame = CGRect(x: 0, y: 0, width: 40, height: 25)
        il.textColor = .white
        il.font = UIFont(name: "HelveticaNeue", size: 14)
        il.text = "Good"
        il.lineBreakMode = .byCharWrapping
        return il
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.isHidden = true
    }
    
    init(type: String) {
        self.init()
        
        if type == "left" {
            configureLeftUI()
        }
        if type == "right" {
            configureRightUI()
        }
    }
    
    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Helper functions
    
    // 左側のコンポーネントと制約を追加
    private func configureLeftUI() {
        leftSideView.removeFromSuperview()
        addSubview(leftSideView)
        leftSideView.addSubview(leftSideImageView)
        leftSideView.addSubview(leftSideLabel)
        // AutoLayout制約を追加
        leftSideViewConstraint(view: leftSideView)
        leftSideImageViewConstraint(view: leftSideView, imageView: leftSideImageView)
        leftSideLabelConstraint(view: leftSideView, label: leftSideLabel)
    }

    private func leftSideViewConstraint(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        view.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
    }
    
    private func leftSideImageViewConstraint(view: UIView, imageView: UIImageView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 55.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 55.0).isActive = true
    }
    
    private func leftSideLabelConstraint(view: UIView, label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
    }
    
    // 右側のコンポーネントと制約を追加
    private func configureRightUI() {
        addSubview(rightSideView)
        rightSideView.addSubview(rightSideImageView)
        rightSideView.addSubview(rightSideLabel)
        // AutoLayout制約を追加
        rightSideViewConstraint(view: rightSideView)
        rightSideImageViewConstraint(view: rightSideView, imageView: rightSideImageView)
        rightSideLabelConstraint(view: rightSideView, label: rightSideLabel)
    }
    
    private func rightSideViewConstraint(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        view.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
    }
    
    private func rightSideImageViewConstraint(view: UIView, imageView: UIImageView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 55.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 55.0).isActive = true
    }
    
    private func rightSideLabelConstraint(view: UIView, label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
    }
}
