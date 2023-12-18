//
//  EmailEditViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/05/11.
//

import UIKit
import FirebaseFirestore
import FirebaseFunctions

class EmailEditViewController: UIBaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var receiveMailButton: UIButton!
    
    var progress: Bool = false
    var progressType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        emailTextField.leftView = leftPadding
        emailTextField.leftViewMode = .always
        emailTextField.layer.cornerRadius = 10
        
        let notificationEmail = GlobalVar.shared.loginUser?.notification_email ?? ""
        emailTextField.text = notificationEmail
        emailTextField.becomeFirstResponder()
        
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        saveButton.setShadow()
        saveButton.disable()
        
        receiveMailButton.layer.cornerRadius = receiveMailButton.frame.height / 2
        receiveMailButton.setShadow()
        receiveMailButton.disable()
        
        tabBarController?.tabBar.backgroundColor = .white
        navigationWithBackBtnSetUp(navigationTitle: "通知用メールアドレス")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func editNotificationEmail(_ sender: Any) {
        
        showLoadingView(loadingView)
        
        progress = true
        progressType = "editMail"
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(cancelUpdate), userInfo: nil, repeats: false)
        
        guard let loginUser = GlobalVar.shared.loginUser else { customAlert(status: "save-error"); return }
        guard let email = emailTextField.text else { customAlert(status: "save-error"); return }
        
        let checkNotificationEmail = checkNotificationEmail()
        if checkNotificationEmail == false { customAlert(status: "save-same"); return }
        
        let updatedAt = Timestamp()
        let userData = [
            "notification_email": email,
            "updated_at": updatedAt
        ] as [String : Any]
        
        let loginUID = loginUser.uid
        db.collection("users").document(loginUID).updateData(userData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let _ = err { weakSelf.customAlert(status: "save-error"); return }
            GlobalVar.shared.loginUser?.notification_email = email
            weakSelf.saveButton.disable()
            weakSelf.customAlert(status: "save-success")
        }
    }
    
    @IBAction func receiveNotificationMail(_ sender: Any) {
        
        let email = emailTextField.text ?? ""
        let userData = ["to": email, "category": "test"]
        
        lazy var functions = Functions.functions()
        
        showLoadingView(loadingView)

        progress = true
        progressType = "receiveMail"
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(cancelUpdate), userInfo: nil, repeats: false)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userData, options: [])
            if let jsonStr = String(bytes: jsonData, encoding: .utf8) {
                functions.httpsCallable("receiveMail").call(jsonStr) { [weak self] result, error in
                    if let error = error as NSError? {
                        if error.domain == FunctionsErrorDomain {
                            let code = FunctionsErrorCode(rawValue: error.code)
                            let message = error.localizedDescription
                            let details = error.userInfo[FunctionsErrorDetailsKey]
                            print("code : \(String(describing: code)), message : \(message), details : \(String(describing: details))")
                        }
                    }
                    if let res = result?.data as? String { print(res); self?.customAlert(status: "receive-success"); return }
                    self?.customAlert(status: "receive-failure")
                }
            } else {
                customAlert(status: "receive-error")
            }
            
        } catch let error {
            print(error)
            customAlert(status: "receive-error")
        }
    }
    //returnでキーボードを閉じる
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    //メールアドレスが正しい時にボタン有効化
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let email = emailTextField.text ?? ""
        if validateEmail(emailText: email) { saveButton.enable(); receiveMailButton.enable(bgColor: .red); return }
        saveButton.disable()
        receiveMailButton.disable()
    }
    
    private func checkNotificationEmail() -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        guard let email = emailTextField.text else { return false }
        
        let notificationEmail = loginUser.notification_email
        if notificationEmail == email { return false }
        
        return true
    }
    
    @objc private func cancelUpdate() {
        if progress && progressType == "editMail" { customAlert(status: "save-progress-over") }
        if progress && progressType == "receiveMail" { customAlert(status: "receive-progress-over") }
    }
    
    private func customAlert(status: String) {
        
        progress = false
        progressType = ""
        
        loadingView.removeFromSuperview()
        
        switch status {
        case "save-success":
            let title = "保存しました"
            let message = "通知用のメールアドレスが変更されました"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "save-error":
            let title = "更新エラー"
            let message = "正常にメールアドレスが更新されませんでした。\n不具合の報告から運営に報告してください"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "save-same":
            let title = "更新エラー"
            let message = "前回と同じメールアドレスを設定されているので更新できませんでした"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "save-progress-over":
            let title = "更新エラー"
            let message = "メールアドレスの更新に時間がかかり過ぎているため\n正常にメールアドレスが登録されていない可能性があります。\nアプリを再起動して再度更新を試してください"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "receive-success":
            let title = "メールが送信されました"
            let message = "通知用のメールアドレスにメールを送信されました。\nメールが来ているかどうか確認してください"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "receive-failure":
            let title = "メール送信エラー"
            let message = "正常にメールアドレスが送信されませんでした。\nメールアドレスを確認してください"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "receive-error":
            let title = "メール送信エラー"
            let message = "正常にメールアドレスが送信されませんでした。\n不具合の報告から運営に報告してください"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "receive-progress-over":
            let title = "メール送信エラー"
            let message = "メールアドレスの送信に時間がかかり過ぎているため\n正常にメールアドレスが送信されていない可能性があります。\nアプリを再起動して再度送信を試してください"
            alert(title: title, message: message, actiontitle: "OK")
            break
        default:
            break
        }
    }
}
