//
//  WithdrawalViewController.swift
//  Tauch
//
//  Created by Apple on 2022/06/20.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class WithdrawalViewController: UIBaseViewController, UIPickerViewDelegate {

    @IBOutlet weak var withdrawalTextView: UITextView!
    @IBOutlet weak var withdrawalButton: UIButton!
    @IBOutlet weak var withdrawalTextField: UITextField!
    @IBOutlet weak var withdrawalDetailView: UIView!
    @IBOutlet weak var withdrawalCategoryTextField: UITextField!
    @IBOutlet weak var withdrawalDetailLabel: UILabel!
    @IBOutlet weak var withdrawalCountLabel: UILabel!
    
    var user: User?
    var closure: ((Bool) -> Void)?
    var categoriesArray = [
        "アプローチの仕方がわからない", "マッチングの仕方がわからない",
        "メッセージの仕方がわからない", "お誘いの出し方がわからない",
        "お誘いの応募しかたがわからない", "お誘いマッチングの仕方がわからない",
        "その他"
    ]
    let categoriesPickerView = UIPickerView()
    var meansArray = [
        "使い方がわからない", "ユーザー数が少ない",
        "探しているタイプが見つからない", "マッチングしない",
        "返信が来ない", "不具合がある", "その他"
    ]
    let meansPickerView = UIPickerView()
    let minCharacters = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        withdrawalTextView.delegate = self
        withdrawalTextField.delegate = self
        withdrawalCategoryTextField.delegate = self
        meansPickerView.delegate = self
        meansPickerView.dataSource = self
        meansPickerView.tag = 0
        categoriesPickerView.delegate = self
        categoriesPickerView.dataSource = self
        categoriesPickerView.tag = 1
        
        withdrawalTextField.layer.cornerRadius = 10
        withdrawalTextField.setToolbar(action: #selector(done))
        withdrawalTextField.inputView = meansPickerView
        withdrawalTextField.setLeftPadding()
        
        withdrawalCategoryTextField.layer.cornerRadius = 10
        withdrawalCategoryTextField.setToolbar(action: #selector(doneCategory))
        withdrawalCategoryTextField.inputView = categoriesPickerView
        withdrawalCategoryTextField.setLeftPadding()
        
        withdrawalTextView.layer.cornerRadius = 10
        withdrawalTextView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        withdrawalCountLabel.text = "\(minCharacters)"
        
        withdrawalButton.rounded()
        withdrawalButton.setShadow()
        
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        //キーボードの開閉時に通知を取得
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        enableButtonIfFilled()
        let content = withdrawalTextView.text ?? ""
        if content.count >= minCharacters {
            withdrawalCountLabel.isHidden = true
        } else {
            withdrawalCountLabel.isHidden = false
            withdrawalCountLabel.text = "\(minCharacters - content.count)"
        }
    }
    // キーボードが表示された時
    @objc private func keyboardWillShow(sender: NSNotification) {
        if withdrawalTextView.isFirstResponder {
            guard let userInfo = sender.userInfo else { return }
            let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                let transform = CGAffineTransform(translationX: 0, y: -200)
                self.view.transform = transform
            })
        }
    }
    // キーボードが閉じられた時
    @objc private func keyboardWillHide(sender: NSNotification) {
        guard let userInfo = sender.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    @objc private func doneCategory() {
        withdrawalCategoryTextField.text = categoriesArray[categoriesPickerView.selectedRow(inComponent: 0)]
        
        withdrawalCategoryTextField.endEditing(true)
        
        enableButtonIfFilled()
    }
    
    @objc private func done() {
        withdrawalTextField.text = meansArray[meansPickerView.selectedRow(inComponent: 0)]
        withdrawalTextView.text = ""
        
        switch meansPickerView.selectedRow(inComponent: 0) {
        case 0:
            showDetailView(with: "わからない箇所を具体的に教えてください")
        case 5:
            showDetailView(with: "不具合の内容を具体的に教えてください")
        default:
            showDetailView(with: "具体的な理由を教えてください")
        }
        
        withdrawalTextField.endEditing(true)
        
        let withdrawalText = withdrawalTextField.text
        switch withdrawalText {
        case "使い方がわからない":
            withdrawalCategoryTextField.isHidden = false
            break
        default:
            withdrawalCategoryTextField.isHidden = true
            break
        }
        
        withdrawalCountLabel.text = "\(minCharacters)"
        withdrawalCountLabel.isHidden = false
    }
    
    private func showDetailView(with title: String) {
        withdrawalDetailLabel.text = "\(title)（\(minCharacters)文字以上）"
        withdrawalDetailView.isHidden = false
        enableButtonIfFilled()
    }
    
    private func logout() {
        
        let firebaseAuth = Auth.auth()
        //facebookログアウト
        if GlobalVar.shared.loginUser?.phone_number == "facebook" {
            let manager = LoginManager()
            manager.logOut()
        }
        do {
            try firebaseAuth.signOut()
            
            let loginType = UserDefaults.standard.string(forKey: "LOGIN_TYPE") ?? ""
            switch loginType {
            case "apple", "facebook", "google", "phone":
                Log.event(name: "logout", logEventData: ["login_type": loginType])
                break
            default:
                break
            }
            
            closure?(true)
            dismiss(animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    private func enableButtonIfFilled() {
        
        let content = withdrawalTextView.text ?? ""
        let type = withdrawalTextField.text ?? ""
        let category = withdrawalCategoryTextField.text ?? ""
        
        let enoughCharacters = (content.count >= minCharacters)
        
        let isUnknownUsage = (type == "使い方がわからない")
        let isCategoryText = (category != "選択してください")
        let isEnableUnknownUsage = (isUnknownUsage && isCategoryText)
        let isNotUnknownUsage = (type != "使い方がわからない")
        let isEnableCategory = (isEnableUnknownUsage || isNotUnknownUsage)
        let isContent = (enoughCharacters && isEnableCategory)
        
        if isContent {
            withdrawalButton.isUserInteractionEnabled = true
            withdrawalButton.backgroundColor = .red
        } else {
            withdrawalButton.isUserInteractionEnabled = false
            withdrawalButton.backgroundColor = .lightGray
        }
    }
    
    @IBAction func close(_ sender: Any) {
        closure?(false)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func withdrawal(_ sender: Any) {
        
        guard let currentUID = user?.uid else { return }
        guard let nickName = user?.nick_name else { return }
        guard let email = user?.email else { return }
        guard let address = user?.address else { return }
        guard let address2 = user?.address2 else { return }
        guard let birthDate = user?.birth_date else { return }
        guard let registedAt = user?.created_at else { return }
        
        let type = withdrawalTextField.text ?? ""
        let category = withdrawalCategoryTextField.text ?? ""
        let content = withdrawalTextView.text ?? ""
        
        let isUnknownUsage = (type == "使い方がわからない")
        let isDefaultCategoryText = (category == "選択してください")
        
        if isUnknownUsage && isDefaultCategoryText {
            alert(title: "選択されていない項目があります", message: "「使い方がわからない」カテゴリを選択してください。", actiontitle: "OK")
            return
        }
        
        let isEmptyText = (content == "")
        let isTextRequired = (withdrawalTextView.isHidden == false)
        
        if isTextRequired && isEmptyText {
            alert(title: "入力されていない項目があります", message: "退会理由を入力してください。", actiontitle: "OK")
            return
        }
        
        var contentText = "\(type) : \(content)"
        if isUnknownUsage { contentText = "\(type) : \(category) : \(content)" }
        //ロード画面を表示
        showLoadingView(loadingView)
        firebaseController.withdraw(loginUID: currentUID, nickName: nickName, email: email, address: address, address2: address2, birthDate: birthDate, registedAt: registedAt, content: contentText, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            //ロード画面削除
            weakSelf.loadingView.removeFromSuperview()
            // 退会の登録完了
            if result {
                weakSelf.logout()
                weakSelf.db.collection("users").document(currentUID).updateData(["is_deleted": true])
                return
            }
            weakSelf.alert(title: "退会に失敗しました..", message: "不具合を運営に報告してください。", actiontitle: "OK")
            return
        })
    }
}

extension WithdrawalViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var pickerCount = 0
        switch pickerView.tag {
        case 0:
            pickerCount = meansArray.count
            break
        case 1:
            pickerCount = categoriesArray.count
            break
        default:
            break
        }
        return pickerCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var pickerTitle = ""
        switch pickerView.tag {
        case 0:
            pickerTitle = meansArray[row]
            break
        case 1:
            pickerTitle = categoriesArray[row]
            break
        default:
            break
        }
        return pickerTitle
    }
}
