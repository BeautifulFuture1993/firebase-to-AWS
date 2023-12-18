//
//  StoppedViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/05/12.
//

import UIKit
import SafariServices
import FirebaseFirestore

class StoppedViewController: UIBaseViewController {
    
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var withdrawalBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactBtn.rounded()
        contactBtn.setShadow()
        withdrawalBtn.rounded()
        withdrawalBtn.setShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ナビゲーションバーを消す
        navigationController?.navigationBar.isHidden = true
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
        
        hideNavigationBarBorderAndShowTabBarBorder()
        
        let isUserDeleted = GlobalVar.shared.loginUser?.is_deleted ?? false
        let isNotDeleted = (isUserDeleted == false)
        customWithdrawal(enableFlg: isNotDeleted)
    }
    
    @IBAction func contact(_ sender: Any) {
        let contactFormURL = "https://docs.google.com/forms/d/e/1FAIpQLSfCILvbJZOWAkCkrcMBFg99IMS9Nd7EFPU0ySg9FVgVgu52zQ/viewform"
        openURLForSafari(url: contactFormURL, category: "opinionsAndRequests")
    }
    
    @IBAction func withdraw(_ sender: Any) {
        let user = GlobalVar.shared.loginUser
        let loginUID = user?.uid ?? ""
        let nickName = user?.nick_name ?? ""
        let email = user?.email ?? ""
        let address = user?.address ?? ""
        let address2 = user?.address2 ?? ""
        let birthDate = user?.birth_date ?? ""
        let registedAt = user?.created_at ?? Timestamp()
        let content = "アカウント停止されたユーザの退会処理 (管理画面からの削除と同様の処理)"
        dialog(title: "本当に退会しますか？", subTitle: "退会するとユーザ情報が全て削除されます。事前にご了承ください", confirmTitle: "OK", completion: { [weak self] result in
            guard let weakSelf = self else { return }
            if result {
                weakSelf.showLoadingView(weakSelf.loadingView)
                weakSelf.firebaseController.withdraw(loginUID: loginUID, nickName: nickName, email: email, address: address, address2: address2, birthDate: birthDate, registedAt: registedAt, content: content, completion: { [weak self] result in
                    guard let weakSelf = self else { return }
                    //ロード画面削除
                    weakSelf.loadingView.removeFromSuperview()
                    // 退会の登録完了
                    if result {
                        weakSelf.db.collection("users").document(loginUID).updateData(["is_deleted": true])
                        weakSelf.logoutAction()
                        weakSelf.customWithdrawal(enableFlg: false)
                        return
                    }
                    weakSelf.alert(title: "退会に失敗しました..", message: "不具合を運営に報告してください。", actiontitle: "OK")
                })
            }
        })
    }

    private func customWithdrawal(enableFlg: Bool) {
        if enableFlg {
            withdrawalBtn.isEnabled = true
            withdrawalBtn.backgroundColor = .red
        } else {
            withdrawalBtn.isEnabled = false
            withdrawalBtn.backgroundColor = .lightGray
        }
    }
}
