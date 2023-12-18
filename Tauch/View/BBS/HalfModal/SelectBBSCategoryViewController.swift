//
//  SelectBBSCategoryViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/12.
//

import UIKit

class SelectBBSCategoryViewController: UIBaseViewController {
    
    static let storyboard_name_id = "SelectBBSCategoryViewController"
    
    @IBOutlet weak var firstCategoryView: UIView!
    @IBOutlet weak var firstTagView: BBSCategoryTagView!
    @IBOutlet weak var firstTagLabel: UILabel!
    @IBOutlet weak var firstCheckmark: UIImageView!
    @IBOutlet weak var secondCategoryView: UIView!
    @IBOutlet weak var secondTagView: BBSCategoryTagView!
    @IBOutlet weak var secondTagLabel: UILabel!
    @IBOutlet weak var secondCheckmark: UIImageView!
    @IBOutlet weak var thirdCategoryView: UIView!
    @IBOutlet weak var thirdTagView: BBSCategoryTagView!
    @IBOutlet weak var thirdTagLabel: UILabel!
    @IBOutlet weak var thirdCheckmark: UIImageView!
    @IBOutlet weak var fourthCategoryView: UIView!
    @IBOutlet weak var fourthTagView: BBSCategoryTagView!
    @IBOutlet weak var fourthTagLabel: UILabel!
    @IBOutlet weak var fourthCheckmark: UIImageView!
    
    var closure: ((String) -> Void)?
    var category: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}


//MARK: - Appearance

extension SelectBBSCategoryViewController {
    
    private func configure() {
        
        firstCategoryView.tag = 1
        firstTagView.backgroundColor = .categoryFriendColor
        firstTagLabel.text = .categoryFriend
        firstTagLabel.textColor = .categoryFriendColor
        firstCheckmark.clipsToBounds = true
        firstCheckmark.layer.cornerRadius = firstCheckmark.frame.height / 2
        firstCheckmark.layer.borderWidth = 1.0
        firstCheckmark.layer.borderColor = UIColor.white.cgColor
        
        secondCategoryView.tag = 2
        secondTagView.backgroundColor = .categoryWorriesColor
        secondTagLabel.text = .categoryWorries
        secondTagLabel.textColor = .categoryWorriesColor
        secondCheckmark.clipsToBounds = true
        secondCheckmark.layer.cornerRadius = firstCheckmark.frame.height / 2
        secondCheckmark.layer.borderWidth = 1.0
        secondCheckmark.layer.borderColor = UIColor.white.cgColor
        
        thirdCategoryView.tag = 3
        thirdTagView.backgroundColor = .categoryTeaserColor
        thirdTagLabel.text = .categoryTeaser
        thirdTagLabel.textColor = .categoryTeaserColor
        thirdCheckmark.clipsToBounds = true
        thirdCheckmark.layer.cornerRadius = firstCheckmark.frame.height / 2
        thirdCheckmark.layer.borderWidth = 1.0
        thirdCheckmark.layer.borderColor = UIColor.white.cgColor
        
        fourthCategoryView.tag = 4
        fourthTagView.backgroundColor = .categoryTweetColor
        fourthTagLabel.text = .categoryTweet
        fourthTagLabel.textColor = .categoryTweetColor
        fourthCheckmark.clipsToBounds = true
        fourthCheckmark.layer.cornerRadius = fourthCheckmark.frame.height / 2
        fourthCheckmark.layer.borderWidth = 1.0
        fourthCheckmark.layer.borderColor = UIColor.white.cgColor
        
        let categoryFriendGesture = UITapGestureRecognizer(target: self, action: #selector(didTapcategoryFriend))
        let secondCategoryGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSecondCategory))
        let thirdCategoryGesture = UITapGestureRecognizer(target: self, action: #selector(didTapThirdCategory))
        let fourthCategoryGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFourthCategory))
        firstCategoryView.addGestureRecognizer(categoryFriendGesture)
        secondCategoryView.addGestureRecognizer(secondCategoryGesture)
        thirdCategoryView.addGestureRecognizer(thirdCategoryGesture)
        fourthCategoryView.addGestureRecognizer(fourthCategoryGesture)
        
        if let category = category { switchCategory(category: category, set: true) }
        else { switchCategory(category: .categoryFriend) }
    }
}

extension SelectBBSCategoryViewController {
    
    @objc private func didTapcategoryFriend() { switchCategory(category: .categoryFriend) }
    
    @objc private func didTapSecondCategory() { switchCategory(category: .categoryWorries) }
    
    @objc private func didTapThirdCategory() { switchCategory(category: .categoryTeaser) }
    
    @objc private func didTapFourthCategory() { switchCategory(category: .categoryTweet) }
    
    private func switchCategory(category: String, set: Bool = false) {
        
        firstCheckmark.isHidden  = (category == .categoryFriend  ? false : true)
        secondCheckmark.isHidden = (category == .categoryWorries ? false : true)
        thirdCheckmark.isHidden  = (category == .categoryTeaser  ? false : true)
        fourthCheckmark.isHidden  = (category == .categoryTweet  ? false : true)
        
        if set == false { closure?(category); dismiss(animated: true) }
    }
}
