//
//  LoginConfirmViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/12.
//

import UIKit
import FirebaseAuth

class LoginConfirmViewController: UIBaseViewController, AEOTPTextFieldDelegate {
    
    @IBOutlet weak var otpTextField: AEOTPTextField!
    
    // 入力された電話番号を受け取る
    var phoneNumber = ""
    // SMS認証コードを全画面から受け取る
    var authVerificationID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションセットアップ
        navigationWithBackBtnSetUp(navigationTitle: "電話番号の認証")
        // otpTextFieldの設定
        otpTextField.otpDelegate = self
        otpTextField.configure(with: 6)
        otpTextField.otpCornerRaduis = 15
        otpTextField.otpDefaultBorderWidth = 1
        otpTextField.otpDefaultBorderColor = UIColor().setColor(colorType: "accentColor", alpha: 1.0)
        otpTextField.otpTextColor = UIColor().setColor(colorType: "accentColor", alpha: 1.0)
        otpTextField.otpBackgroundColor = .white
        otpTextField.otpFilledBorderWidth = 1
        otpTextField.otpFilledBorderColor = UIColor().setColor(colorType: "accentColor", alpha: 1.0)
        otpTextField.otpFilledBackgroundColor = .white
        otpTextField.becomeFirstResponder()
        // 認証コードID
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        // 画面に渡された認証コードIDとアプリに保存された認証コードIDが一致した場合
        if authVerificationID == verificationID {
            alert(title: "認証コードを送信しました", message: "入力された電話番号のSMSに6桁の認証コードを送信しました。\n確認の上、画面に入力してください", actiontitle: "OK")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func resendSMSCode(_ sender: Any) {
        // ローディング画面を表示させる
        showLoadingView(loadingView)
        // SMSコードを再送信
        firebaseController.sendSMSCode(phoneNumber: phoneNumber, type: "resend", completion: { [weak self] result in
            guard let weakSelf = self else { return }
            // ローディング画面を外す
            weakSelf.loadingView.removeFromSuperview()
            if let _result = result {
                // SMS認証IDの更新
                let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                weakSelf.authVerificationID = _result
                // 認証コードIDとアプリに保存された認証コードIDが一致した場合
                if weakSelf.authVerificationID == verificationID {
                    weakSelf.alert(title: "認証コードを再送信しました", message: "入力された電話番号のSMSに6桁の認証コードを送信しました。\n確認の上、画面に入力してください", actiontitle: "OK")
                }
            } else {
                weakSelf.alert(title: "認証コードの再送信に失敗しました", message: "システムに問題が起きている可能性があるため、不具合の報告にて報告してください。", actiontitle: "OK")
            }
        })
    }
    
    private func confirmSMSCode(code: String) {
        // ローディング画面を表示させる
        showLoadingView(loadingView)
        // SMS認証を実施する
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: authVerificationID,
            verificationCode: code
        )
        // ログイン
        login(credential: credential, loadingView: loadingView)
    }
    
    func login(credential: AuthCredential, loadingView: UIView) {
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let weakSelf = self else { return }
            // ローディング画面を外す
            loadingView.removeFromSuperview()
            if let error = error {
                weakSelf.alert(title: "認証エラー", message: "入力された6桁のコードが間違っているため認証できませんでした。再度コードを確認し、入力してください。", actiontitle: "OK")
                print(error.localizedDescription)
                return
            }
            Log.event(name: "login", logEventData: ["login_type": "phone"])
            UserDefaults.standard.set("phone", forKey: "LOGIN_TYPE")
        }
    }
    //otpTextFieldの必須メソッド
    func didUserFinishEnter(the code: String) {
        confirmSMSCode(code: code)
    }
}
