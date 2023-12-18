//
//  LoginViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/12.
//

import UIKit

class LoginViewController: UIBaseViewController {
    
    @IBOutlet weak var inputTelField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 電話番号入力デリゲート
        inputTelField.delegate = self
        inputTelField.layer.cornerRadius = 10
        inputTelField.becomeFirstResponder()
        sendButton.layer.cornerRadius = 35
        sendButton.setShadow()
    }
    //NavigationBarの設定
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ナビゲーションバーをカスタマイズ
        navigationWithBackBtnSetUp(navigationTitle: "電話番号を入力")
        // ナビゲーションバーを表示
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.backgroundColor = .white
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func callSMSAuth(_ sender: Any) {
        // ローディング画面を表示させる
        showLoadingView(loadingView)
        // 日本の電話番号のみ入力許可する
        let phoneNumber = "+81" + (inputTelField.text ?? "")
        // SMSコードを送信
        firebaseController.sendSMSCode(phoneNumber: phoneNumber, type: "send", completion: { [weak self] result in
            guard let weakSelf = self else { return }
            // ローディング画面を外す
            weakSelf.loadingView.removeFromSuperview()
            if let _result = result {
                let storyboard = UIStoryboard(name: "LoginConfirmView", bundle: nil)
                let loginConfirmVC = storyboard.instantiateViewController(withIdentifier: "LoginConfirmView") as! LoginConfirmViewController
                loginConfirmVC.authVerificationID = _result
                loginConfirmVC.phoneNumber = phoneNumber
                weakSelf.navigationController?.show(loginConfirmVC, sender: nil)
                
            } else {
                weakSelf.alert(title: "認証コードの送信に失敗しました", message: "入力された電話番号では認証できない(日本の電話番号のみ利用可能です)。また、選んだ画像が間違っていたため確認コードが送信できませんでした。", actiontitle: "OK")
            }
        })
    }
    //入力された電話番号が有効な場合ボタンを有効化
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if validateTel(telText: inputTelField.text ?? "") {
            sendButton.enable()
        } else {
            sendButton.disable()
        }
    }
    
}
