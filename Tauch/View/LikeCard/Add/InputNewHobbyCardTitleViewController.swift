//
//  InputNewLikeCardTitleViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/29.
//

import UIKit

class InputNewHobbyCardTitleViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var inputTitleTextField: UITextField!
    @IBOutlet weak var countCharactersLabel: UILabel!
    @IBOutlet weak var fillOutButton: UIButton!
    
    static let storyboardName = "InputNewHobbyCardTitleView"
    static let storyboardId = "InputNewHobbyCardTitleView"
    
    private let maxTextLength = 20
    private var numberOfCharacter: Int = 0
    public var currentTitle: String = "" {
        didSet {
            inputTitleTextField.text = currentTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationWithBackBtnSetUp(navigationTitle: "趣味カードを作成")
        setNumberOfCharacter()
        configureInputTitleScreenAppearance()
        
        inputTitleTextField.becomeFirstResponder()
        inputTitleTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        let ownSpecificHobbyCard = GlobalVar.shared.ownSpecificHobbyCard
        if let hobbyCardTitle = ownSpecificHobbyCard["hobbyCardTitle"] as? String {
            currentTitle = hobbyCardTitle
        }
    }
    
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    
    /// 画面をタップするとキーボードをフェードアウト
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    /// 入力した値の渡しと、画面遷移
    @IBAction func fillOutButtonPressed(_ sender: UIButton) {
        // GlobalVarに一時的に保存
        GlobalVar.shared.ownSpecificHobbyCard["hobbyCardTitle"] = currentTitle
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - Appearance

extension InputNewHobbyCardTitleViewController {
    
    private func setNumberOfCharacter() {
        guard let savedTitle = GlobalVar.shared.ownSpecificHobbyCard["hobbyCardTitle"] as? String else { return }
        numberOfCharacter = savedTitle.count
    }
    
    private func configureInputTitleScreenAppearance() {
        
        backgroundView.layer.cornerRadius = 17
        backgroundView.layer.borderWidth = 1.0
        backgroundView.layer.borderColor = UIColor.lightGray.cgColor
        
        countCharactersLabel.text = "（あと\(20 - numberOfCharacter)字）\(numberOfCharacter)/20"
        countCharactersLabel.font = UIFont.systemFont(ofSize: 8)
        countCharactersLabel.textColor = .darkGray
        
        inputTitleTextField.textAlignment = .left
        inputTitleTextField.borderStyle = .none
        inputTitleTextField.font = UIFont.systemFont(ofSize: 12)
        inputTitleTextField.attributedPlaceholder = NSAttributedString(string: "カード名を入力（20文字以内）", attributes: [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.lightGray
        ])
        
        fillOutButton.configuration = nil
        fillOutButton.layer.cornerRadius = 23
        fillOutButton.setTitleColor(UIColor.white, for: .normal)
        fillOutButton.setTitle("決定", for: .normal)
        fillOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        fillOutButton.disable()
    }
}

//MARK: - UITextFieldDelegate

extension InputNewHobbyCardTitleViewController: UITextFieldDelegate {
    
    // 最大文字数を20文字に設定, ボタンを切り替え, 入力したテキストの保存
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        // 最大文字数を20文字に設定
        if text.count > maxTextLength {
            inputTitleTextField.text = String(text.prefix(maxTextLength))
        }
        // テキストがあるかないかを判定
        text.isEmpty ? fillOutButton.disable() : fillOutButton.enable()
        // テキストの保存
        currentTitle = text
    }
    
    // Returnを押すと編集が終わる（キーボードが閉じる）
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    // 入力したテキストの一時的な保存、文字数カウント
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 文字数カウント
        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length
        if newLength <= maxTextLength {
            numberOfCharacter = newLength
            countCharactersLabel.text = "（あと\(maxTextLength - numberOfCharacter)字）\(numberOfCharacter)/20"
        }
        return newLength <= maxTextLength
    }

}
