//
//  LoginEmailViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/02.
//

import UIKit

class LoginEmailViewController: UIBaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var parentVC: LoginPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //親VCの取得
        parentVC = self.parent as? LoginPageViewController
        //UI調整
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        emailTextField.leftView = leftPadding
        emailTextField.leftViewMode = .always
        emailTextField.layer.cornerRadius = 10
        nextButton.layer.cornerRadius = 35
        nextButton.setShadow()
        emailTextField.becomeFirstResponder()
        //delegate
        emailTextField.delegate = self
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        //ボタン無効化
        nextButton.isUserInteractionEnabled = false
        //apple・facebookログインの場合は名前を自動入力
        self.emailTextField.text = self.parentVC?.email
        guard let emailText = self.emailTextField.text else { return }
        if emailText.isEmpty == false {
            self.nextButton.isUserInteractionEnabled = true
            self.nextButton.backgroundColor = UIColor(named: "AccentColor")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //apple・facebookログインの場合はemailを自動入力
        emailTextField.text = parentVC?.email
        //自動フォーカス
        DispatchQueue.main.async {
            self.emailTextField.becomeFirstResponder()
        }
    }
    //textfieldのreturn時にキーボードを閉じる
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //textField更新時
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let emailText = emailTextField.text else { return }
        let isEmailValid = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}").evaluate(with: emailTextField.text)
        //正しい内容が入力されたらボタン有効化
        if emailText.isEmpty || isEmailValid == false {
            nextButton.isUserInteractionEnabled = false
            nextButton.backgroundColor = .lightGray
        } else {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = UIColor(named: "AccentColor")
        }
    }
    //次に進む
    @IBAction func nextAction(_ sender: UIButton) {
        guard let nextPage = parentVC?.controllers[4] else { return }
        parentVC?.email = emailTextField.text ?? ""
        parentVC?.setViewControllers([nextPage], direction: .forward, animated: true)
        parentVC?.progressBar.setProgress(5/7, animated: true)
    }
    //前に戻る
    @IBAction func backAction(_ sender: UIButton) {
        guard let backPage = parentVC?.controllers[2] else { return }
        parentVC?.setViewControllers([backPage], direction: .reverse, animated: true)
        parentVC?.progressBar.setProgress(3/7, animated: true)
    }
}
