//
//  AccountSettingTableViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/09/15.
//

import UIKit

class AccountSettingTableViewController: UIBaseTableViewController {
    
    @IBOutlet var iconBackground: [UIView]!
    @IBOutlet weak var exclamationImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconBackground.forEach { $0.layer.cornerRadius = 10 }
        exclamationImageView.rounded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationWithBackBtnSetUp(navigationTitle: "アカウント設定", color: .systemGray6)
        
        guard let user = GlobalVar.shared.loginUser else { return }
        
        let isNotificationOptionsAllDisabled: Bool =
        !user.is_approached_notification &&
        !user.is_matching_notification &&
        !user.is_message_notification &&
        !user.is_visitor_notification &&
        !user.is_invitationed_notification &&
        !user.is_dating_notification
        
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationSettings() { setting in
            DispatchQueue.main.async { [self] in
                exclamationImageView.isHidden = setting.authorizationStatus == .authorized && !isNotificationOptionsAllDisabled
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // 通知設定
            pushNotificationScreenTransition()
        case 1: // 通知メールアドレス設定
            screenTransition(storyboardName: "EmailEditView", storyboardID: "EmailEditView")
        case 2: // トークアドバイス設定
            screenTransition(storyboardName: "TalkGuideSettingView", storyboardID: "TalkGuideSettingView")
        case 3: // 自動メッセージ送信設定
            screenTransition(storyboardName: "AutoMessageSettingView", storyboardID: "AutoMessageSettingView")
        case 4: // フレンド絵文字設定
            screenTransition(storyboardName: "FriendEmojiSettingView", storyboardID: "FriendEmojiSettingView")
        case 5: // ログアウト
            logout()
        case 6: // 退会処理
            screenTransition(storyboardName: "RestView", storyboardID: "RestView")
        default: return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // ログアウト
    private func logout() {
        let alert = UIAlertController(title: "本当にログアウトしますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default))
        alert.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.logoutAction()
        }))
        present(alert, animated: true)
    }
}
