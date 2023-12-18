//
//  LoginPageViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/02.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices

class LoginPageViewController: UIPageViewController {
    
    var controllers: [UIViewController] = []
    let progressBar = UIProgressView(progressViewStyle: .bar)
    //ユーザー情報
    var birth: String?
    var address: String?
    var address2: String?
    var email: String?
    var introduction: String?
    var hobbies: [String]?
    //特殊ログイン時に名前とメールアドレスを自動入力
    var name: String? {
        didSet {
            let namePage = self.children.first as! LoginNameViewController
            namePage.nameTextField.text = name
            namePage.nextButton.isUserInteractionEnabled = true
            namePage.nextButton.backgroundColor = UIColor(named: "AccentColor")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //表示するページを登録
        guard let loginNameView = storyboard?.instantiateViewController(withIdentifier: "LoginNameView") else { return }
        guard let loginBirthView = storyboard?.instantiateViewController(withIdentifier: "LoginBirthView") else { return }
        guard let loginAddressView = storyboard?.instantiateViewController(withIdentifier: "LoginAddressView") else { return }
        guard let loginEmailView = storyboard?.instantiateViewController(withIdentifier: "LoginEmailView") else { return }
        guard let loginImageView = storyboard?.instantiateViewController(withIdentifier: "LoginImageView") else { return }
        guard let loginIntroductionView = storyboard?.instantiateViewController(withIdentifier: "LoginIntroductionView") else { return }
        guard let loginTagView = storyboard?.instantiateViewController(withIdentifier: "LoginTagView") else { return }
        controllers = [loginNameView, loginBirthView, loginAddressView, loginEmailView, loginImageView, loginIntroductionView, loginTagView]
        setViewControllers([controllers[0]], direction: .forward, animated: true)
        navigationController?.isNavigationBarHidden = true
        //ProgressBarを表示
        view.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        progressBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        progressBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        progressBar.setProgress(1/7, animated: true)
        progressBar.tintColor = UIColor(named: "AccentColor")
        //facebookログインユーザーのデータ自動入力
        if let _ = AccessToken.current {
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"email, name"])
            graphRequest.start { [weak self] connection, result, error in
                guard let weakSelf = self else { return }
                guard let json = result as? NSDictionary else { return }
                if let email = json["email"] as? String, let name = json["name"] as? String {
                    weakSelf.email = email
                    weakSelf.name = name
                }
            }
        }
        //appleログインユーザーのデータ自動入力
        if UserDefaults.standard.string(forKey: "LOGIN_TYPE") == "apple" {
            if let name = UserDefaults.standard.string(forKey: "APPLE_NAME"), let email = UserDefaults.standard.string(forKey: "APPLE_EMAIL") {
                self.email = email
                self.name = name
            }
        }
        //googleログインユーザーのデータ自動入力
        if UserDefaults.standard.string(forKey: "LOGIN_TYPE") == "google" {
            if let user = Auth.auth().currentUser {
                self.email = user.email
                self.name = user.displayName
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }
    //ページ数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }
}
