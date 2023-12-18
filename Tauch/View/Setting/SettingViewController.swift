//
//  SettingViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/14.
//
import UIKit

class SettingViewController: UIBaseViewController {
    
    @IBOutlet weak var profileEditContentView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var profileEditLabel: UILabel!
    @IBOutlet weak var profileEditIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = 15
        profileEditContentView.layer.cornerRadius = 15
        
        navigationWithSetUp(navigationTitle: "設定", color: .systemGray6)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileEditDidTapped(_:)))
        profileEditContentView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.backgroundColor = .systemGray6
        
        changeProfileAppearanceByRestMode()
        
        guard let user = GlobalVar.shared.loginUser else { return }
        userNameLabel.text = user.nick_name
        userInfoLabel.text = "\(user.address)\(user.address2) \(user.birth_date.calcAge())"
        userImageView.setImage(withURLString: user.profile_icon_img)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func changeProfileAppearanceByRestMode() {
        let isRestMode = GlobalVar.shared.loginUser?.is_rested ?? false
        profileEditContentView.backgroundColor = isRestMode ? .black : .white
        userNameLabel.textColor = isRestMode ? .white : .black
        userInfoLabel.textColor = isRestMode ? .white : .black
        profileEditLabel.textColor = isRestMode ? .white : .black
        profileEditIcon.tintColor = isRestMode ? .white : .black
        profileEditLabel.text = isRestMode ? "休憩モード解除" : "プロフィール編集"
        profileEditIcon.image = isRestMode ? UIImage(systemName: "moon.circle.fill") : UIImage(systemName: "arrow.forward.circle.fill")
    }
    
    @objc private func profileEditDidTapped(_ sender: UITapGestureRecognizer) {
        // プロフィール編集
        guard let userID = GlobalVar.shared.loginUser?.uid else { return }
        let isRestMode = GlobalVar.shared.loginUser?.is_rested ?? false
        if isRestMode {
            let alert = UIAlertController(title: "休憩モードを解除しますか？", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            alert.addAction(UIAlertAction(title: "解除する", style: .default) { [weak self] _ in
                guard let weakSelf = self else { return }
                GlobalVar.shared.loginUser?.is_rested = false
                weakSelf.db.collection("users").document(userID).updateData(["is_rested": false])
                weakSelf.changeProfileAppearanceByRestMode()
                Log.event(name: "restModeCancel")
            })
            present(alert, animated: true)
        } else {
            screenTransition(storyboardName: "ProfileView", storyboardID: "ProfileView")
        }
    }
}

class SettingContainerViewController: UIBaseTableViewController {
    
    @IBOutlet weak var settingsTable: UITableView!
    @IBOutlet var iconBackground: [UIView]!
    
    let links = GlobalVar.shared.links
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconBackground.forEach { $0.layer.cornerRadius = 8 }
        
        navigationWithSetUp(navigationTitle: "設定", color: .systemGray6)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.backgroundColor = .systemGray6
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //セル選択時のアクション
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: //メール通知設定
                pushNotificationScreenTransition(pushNotificationHidden: true)
            default: return
            }
        case 1: //アプリケーション
            switch indexPath.row {
            case 0: //チュートリアル
                screenTransition(storyboardName: "UsageTableView", storyboardID: "UsageTableView")
            case 1: //使い方
                let helpLink = links["help"] ?? ""
                openURLForSafari(url: helpLink, category: "help")
            case 2: //本人確認の提出
                identificationMove()
            default: return
            }
        case 2: //お問い合わせ
            switch indexPath.row {
            case 0: //不具合の報告
                let bugReportLink = links["bugReport"] ?? ""
                openURLForSafari(url: bugReportLink, category: "bugReport")
            case 1: //ご意見・ご要望
                let opinionsAndRequestsLink = links["opinionsAndRequests"] ?? ""
                openURLForSafari(url: opinionsAndRequestsLink, category: "opinionsAndRequests")
            default: return
            }
        case 3: //使用上の注意
            switch indexPath.row {
            case 0: //利用規約
                let termsOfServiceLink = links["termsOfService"] ?? ""
                openURLForSafari(url: termsOfServiceLink, category: "termsOfService")
            case 1: //プライバシーポリシー
                let privacyPolicyLink = links["privacyPolicy"] ?? ""
                openURLForSafari(url: privacyPolicyLink, category: "privacyPolicy")
            case 2: //安心・安全のガイドライン
                let safetyAndSecurityGuidelinesLink = links["safetyAndSecurityGuidelines"] ?? ""
                openURLForSafari(url: safetyAndSecurityGuidelinesLink, category: "safetyAndSecurityGuidelines")
            case 3: //特商法に基づく表記
                let specialCommercialLawLink = links["specialCommercialLaw"] ?? ""
                openURLForSafari(url: specialCommercialLawLink, category: "specialCommercialLaw")
            default: return
            }
        case 4:
            switch indexPath.row {
            case 0: //アカウント設定
                screenTransition(storyboardName: "AccountSettingTableView", storyboardID: "AccountSettingTableView")
            default: return
            }
        default: return
        }
        //セル選択時に背景が黒くなるのを戻す
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //本人確認済みの場合セルを消す
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let applicationSection = 1
        let isIdAdminCheck = (GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status == 1)
        if section == applicationSection && isIdAdminCheck { return 2 }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    private func identificationMove() {
        //本人確認していない場合は確認ページを表示
        guard let adminIDCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status else {
            popUpIdentificationView()
            return
        }
        if adminIDCheckStatus == 0 {
            alert(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", actiontitle: "OK")
        } else if adminIDCheckStatus == 2 {
            dialog(title: "本人確認失敗しました", subTitle: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", confirmTitle: "OK", completion: { [weak self] confirm in
                guard let weakSelf = self else { return }
                if confirm { weakSelf.popUpIdentificationView() }
            })
        }
    }
    
}
