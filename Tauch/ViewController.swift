//
//  ViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/11.
//

import UIKit
import CryptoKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import SafariServices
import UserNotifications
import AuthenticationServices

class ViewController: UIBaseViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var precautionView: UITextView!
    
    // Unhashed nonce
    fileprivate var currentNonce: String?

    let links = GlobalVar.shared.links
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションの戻るボタンを消す
        self.navigationItem.setHidesBackButton(true, animated: true)
        loginBtn.rounded()
        facebookBtn.rounded()
        googleBtn.rounded()
        loginBtn.setShadow()
        facebookBtn.setShadow()
        appleBtn.setShadow()
        googleBtn.setShadow()
        // IOS13以降のみAppleログインが使えるので制限
        if #available(iOS 13.0, *) {
            // appleLoginButtonをセット
            setAppleLoginButton()
        }
        // ログイン状態の検知
        authState()
        //文章の一部をリンク化
        precautionView.delegate = self
        let termsOfService = links["termsOfService"] ?? ""
        let privacyPolicy = links["privacyPolicy"] ?? ""
        let baseString = "アカウントを作成するか、ログインすると、あなたはTouchの利用規約・プライバシーポリシーに同意することになります。\n※ アカウント作成するためにも、まずログインが必要になります。"
        let attributedString = NSMutableAttributedString(string: baseString)
        attributedString.addAttribute(.link, value: termsOfService, range: NSString(string: baseString).range(of: "利用規約"))
        attributedString.addAttribute(.link, value: privacyPolicy, range: NSString(string: baseString).range(of: "プライバシーポリシー"))
        precautionView.attributedText = attributedString
        // isSelectableをtrue、isEditableをfalseにする必要がある（isSelectableはデフォルトtrueだが説明のため記述）
        precautionView.isSelectable = true
        precautionView.isEditable = false
        // アプリレビュー
        // appStoreReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ナビゲーションバーを消す
        navigationController?.isNavigationBarHidden = true
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }

    // ログインページに遷移
    @IBAction func login(_ sender: Any) {
        
        if let currentUID = GlobalVar.shared.currentUID {
            // ユーザがログインしている場合
            userExistCheckPageMove(uid: currentUID, loadingView: loadingView)
        } else {
            // ユーザがログアウトしている場合
            screenTransition(storyboardName: "LoginView", storyboardID: "LoginView")
        }
    }
    //facebookログイン
    @IBAction func facebookAction(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
            guard let _ = self else { return }
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                print("Logged In")
                if let token = AccessToken.current, !token.isExpired, let tokenString = AccessToken.current?.tokenString {
                    let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                    Auth.auth().signIn(with: credential) { [weak self] (authResult, err) in
                        guard let weakSelf = self else { return }
                        if let err = err {
                            print(err)
                            weakSelf.alert(title: "facebookログインエラー", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
                            return
                        }
                        if let authResult = authResult {
                            print(authResult)
                            print("facebook ログイン完了")
                            UserDefaults.standard.set("facebook", forKey: "LOGIN_TYPE")
                            Log.event(name: "login", logEventData: ["login_type": "facebook"])
                        }
                    }
                }
            }
        }
    }
    //Googleログイン
    @IBAction func googleAction(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: self, hint: clientID) { [weak self] (result, error) in
            guard let _ = self else { return }
            if let error = error {
                print("GIDSignInError: \(error.localizedDescription)")
                return
            }
            guard let authUser = result?.user, let idToken = authUser.idToken?.tokenString else { return }
            let accessToken = authUser.accessToken.tokenString
            Auth.auth().signIn(with: GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)) { [weak self] (authResult, err) in
                   guard let weakSelf = self else { return }
                   if let err = err {
                       print(err)
                       weakSelf.alert(title: "googleログインエラー", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
                       return
                   }
                   if let authResult = authResult {
                       print(authResult)
                       print("google ログイン完了")
                       UserDefaults.standard.set("google", forKey: "LOGIN_TYPE")
                       Log.event(name: "login", logEventData: ["login_type": "google"])
                   }
            }
        }
    }
    // 不具合の報告ページに遷移
    @IBAction func showContactForm(_ sender: Any) {
        let contactFormURL = "https://docs.google.com/forms/d/e/1FAIpQLSfCILvbJZOWAkCkrcMBFg99IMS9Nd7EFPU0ySg9FVgVgu52zQ/viewform"
        guard let url = URL(string: contactFormURL) else { return }
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
    }
    
    // ログイン状態の検知
    func authState() {
        // ログイン検知
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let weakSelf = self else { return }
            if let user = user {
                // weakSelf.logoutAction()
                // ロード画面を表示
                weakSelf.showLoadingView(weakSelf.loadingView)
                // グローバル変数にログインUIDを格納
                let currentUID = user.uid
                print("ユーザID : \(currentUID)")
                GlobalVar.shared.currentUID = currentUID
                weakSelf.userExistCheckPageMove(uid: currentUID, loadingView: weakSelf.loadingView)
                
            } else {
                // ログアウト後のデータの初期化
                UserDefaults.standard.set("", forKey: "LOGIN_TYPE")
                UserDefaults.standard.set(false, forKey: "isShowedApproachTutorial")
                UserDefaults.standard.set(false, forKey: "isShowedApproachedTutorial")
                UserDefaults.standard.set(false, forKey: "isShowedMessageTutorial")
                UserDefaults.standard.set(false, forKey: "isShowedInvitationTutorial")
                UserDefaults.standard.set(false, forKey: "isShowedBoardTutorial")
                UserDefaults.standard.set(false, forKey: "isShowedPhoneTutorial")
                UserDefaults.standard.set(0, forKey: "display_auto_message_num")
                
                GlobalVar.shared.currentUID = nil
                GlobalVar.shared.loginUser = nil
                weakSelf.removeListener()
            }
        }
    }
}

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // appleログインボタンをセット
    func setAppleLoginButton() {
        // ボタン押した時にhandleTappedAppleLoginButtonの関数を呼ぶようにセット
        appleBtn.addTarget(
            self,
            action: #selector(handleTappedAppleLoginButton(_:)),
            for: .touchUpInside
        )
        // ボタンデザイン加工
        appleBtn.rounded()
        appleBtn.layer.borderColor = UIColor().setColor(colorType: "fontColor", alpha: 1.0).cgColor
        appleBtn.layer.borderWidth = 1
    }
    // appleLoginButtonを押した時の挙動を設定
    @available(iOS 13.0, *)
    @objc func handleTappedAppleLoginButton(_ sender: ASAuthorizationAppleIDButton) {
        // ランダムの文字列を生成
        let nonce = randomNonceString()
        // delegateで使用するため代入
        currentNonce = nonce
        // requestを作成
        let request = ASAuthorizationAppleIDProvider().createRequest()
        // リクエストで取得する項目 (名前、メールアドレス)
        request.requestedScopes = [.fullName, .email]
        // sha256で変換したnonceをrequestのnonceにセット
        request.nonce = sha256(nonce)
        // controllerをインスタンス化する(delegateで使用するcontroller)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
       
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
           
            randoms.forEach { random in
                if length == 0 {
                    return
                }
               
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    // SHA256を使用してハッシュ変換する関数を用意
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    // 認証が成功した時に呼ばれる関数
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // credentialが存在するかチェック
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        // nonceがセットされているかチェック
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        // credentialからtokenが取得できるかチェック
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        // tokenのエンコードを失敗
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
             print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        // 認証に必要なcredentialをセット
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        // Firebaseへのログインを実行
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let weakSelf = self else { return }
            if let error = error {
                print(error)
                weakSelf.alert(title: "Appleログインエラー", message: "アプリを再起動して再度実行してください。\n\(error)", actiontitle: "OK")
                return
            }
            if let _ = authResult {
                
                Log.event(name: "login", logEventData: ["login_type": "apple"])
                
                let name = appleIDCredential.fullName?.givenName
                let email = appleIDCredential.email
                UserDefaults.standard.set("apple", forKey: "LOGIN_TYPE")
                UserDefaults.standard.set(name, forKey: "APPLE_NAME")
                UserDefaults.standard.set(email, forKey: "APPLE_EMAIL")
            }
        }
    }
    // delegateのプロトコルに設定されているため、書いておく
   func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
       guard let window = view.window else { return UIWindow() }
       return window
   }
   // Appleのログイン側でエラーがあった時に呼ばれる
   func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
       // Handle error.
       print("Sign in with Apple errored: \(error)")
   }
}

extension ViewController {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            
            UIApplication.shared.open(URL)
        }
        return false
    }
}
