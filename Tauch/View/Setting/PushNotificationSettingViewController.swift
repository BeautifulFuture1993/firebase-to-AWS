//
//  PushNotificationSettingViewController.swift
//  Tauch
//
//  Created by Apple on 2022/05/16.
//

import UIKit
import FirebaseFirestore

enum NotificationCategory: String {
    case approachNotification = "is_approached_notification"
    case matchNotification = "is_matching_notification"
    case messageNotification = "is_message_notification"
    case invitationApplyNotification = "is_invitationed_notification"
    case invitationMatchNotification = "is_dating_notification"
    case visitorNotification = "is_visitor_notification"
    case approachMail = "is_approached_mail"
    case matchMail = "is_matching_mail"
    case messageMail = "is_message_mail"
    case invitationApplyMail = "is_invitationed_mail"
    case invitationMatchMail = "is_dating_mail"
    case visitorMail = "is_visitor_mail"
}

class PushNotificationSettingViewController: UIBaseTableViewController {
    
    @IBOutlet weak var notificationIcon: UIView!
    @IBOutlet weak var exclamationIcon: UIImageView!
    @IBOutlet var toggleSwitches: [UISwitch]!
    
    var pushNotificationHidden = false
    let pushNotificationSection = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationIcon.layer.cornerRadius = 15
        exclamationIcon.rounded()
        // 通知状態の確認
        configNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationWithBackBtnSetUp(navigationTitle: "通知設定", color: .systemGray6)
        
        tabBarController?.tabBar.backgroundColor = .systemGray6
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func didTapSwitch(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            notificationUpdate(category: .approachNotification, status: sender.isOn)
        case 1:
            notificationUpdate(category: .matchNotification, status: sender.isOn)
        case 2:
            notificationUpdate(category: .messageNotification, status: sender.isOn)
        case 3:
            notificationUpdate(category: .invitationApplyNotification, status: sender.isOn)
        case 4:
            notificationUpdate(category: .invitationMatchNotification, status: sender.isOn)
        case 5:
            notificationUpdate(category: .visitorNotification, status: sender.isOn)
        case 6:
            notificationUpdate(category: .approachMail, status: sender.isOn)
        case 7:
            notificationUpdate(category: .matchMail, status: sender.isOn)
        case 8:
            notificationUpdate(category: .messageMail, status: sender.isOn)
        case 9:
            notificationUpdate(category: .invitationApplyMail, status: sender.isOn)
        case 10:
            notificationUpdate(category: .invitationMatchMail, status: sender.isOn)
        case 11:
            notificationUpdate(category: .visitorMail, status: sender.isOn)
        default: break
        }
    }
    
    private func configNotification() {
        // Push通知状態
        let isApproachedNotification   = GlobalVar.shared.loginUser?.is_approached_notification ?? true
        let isMatchingNotification     = GlobalVar.shared.loginUser?.is_matching_notification ?? true
        let isMessageNotification      = GlobalVar.shared.loginUser?.is_message_notification ?? true
        let isInvitationedNotification = GlobalVar.shared.loginUser?.is_invitationed_notification ?? true
        let isDatingNotification       = GlobalVar.shared.loginUser?.is_dating_notification ?? true
        let isVisitorNotification      = GlobalVar.shared.loginUser?.is_visitor_notification ?? true
        // メール通知状態
        let isApproachedMail   = GlobalVar.shared.loginUser?.is_approached_mail ?? true
        let isMatchingMail     = GlobalVar.shared.loginUser?.is_matching_mail ?? true
        let isMessageMail      = GlobalVar.shared.loginUser?.is_message_mail ?? true
        let isInvitationedMail = GlobalVar.shared.loginUser?.is_invitationed_mail ?? true
        let isDatingMail       = GlobalVar.shared.loginUser?.is_dating_mail ?? true
        let isVisitorMail      = GlobalVar.shared.loginUser?.is_visitor_mail ?? true
        
        toggleSwitches.forEach {
            switch $0.tag {
            case 0:
                $0.isOn = isApproachedNotification
            case 1:
                $0.isOn = isMatchingNotification
            case 2:
                $0.isOn = isMessageNotification
            case 3:
                $0.isOn = isInvitationedNotification
            case 4:
                $0.isOn = isDatingNotification
            case 5:
                $0.isOn = isVisitorNotification
            case 6:
                $0.isOn = isApproachedMail
            case 7:
                $0.isOn = isMatchingMail
            case 8:
                $0.isOn = isMessageMail
            case 9:
                $0.isOn = isInvitationedMail
            case 10:
                $0.isOn = isDatingMail
            case 11:
                $0.isOn = isVisitorMail
            default: break
            }
        }
        
        GlobalVar.shared.pushNotificationToggleSwitches = toggleSwitches
        GlobalVar.shared.pushNotificationSettingTableView = tableView
    }
    
    // プッシュ通知の状態更新
    private func notificationUpdate(category: NotificationCategory, status: Bool) {
        // ログインUIDを取得
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        // プッシュ通知カテゴリと状態を指定して更新
        let updateTime = Timestamp()
        let updateData = [
            category.rawValue: status,
            "updated_at": updateTime
        ] as [String : Any]
        // プロフィールデータ更新
        db.collection("users").document(uid).updateData(updateData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                print("プッシュ通知の状態の更新に失敗しました: \(err)")
                return
            }
            switch category {
            case .approachNotification:
                GlobalVar.shared.loginUser?.is_approached_notification = status
            case .matchNotification:
                GlobalVar.shared.loginUser?.is_matching_notification = status
            case .messageNotification:
                GlobalVar.shared.loginUser?.is_message_notification = status
            case .invitationApplyNotification:
                GlobalVar.shared.loginUser?.is_invitationed_notification = status
            case .invitationMatchNotification:
                GlobalVar.shared.loginUser?.is_dating_notification = status
            case .visitorNotification:
                GlobalVar.shared.loginUser?.is_visitor_notification = status
            case .approachMail:
                GlobalVar.shared.loginUser?.is_approached_mail = status
            case .matchMail:
                GlobalVar.shared.loginUser?.is_matching_mail = status
            case .messageMail:
                GlobalVar.shared.loginUser?.is_message_mail = status
            case .invitationApplyMail:
                GlobalVar.shared.loginUser?.is_invitationed_mail = status
            case .invitationMatchMail:
                GlobalVar.shared.loginUser?.is_dating_mail = status
            case .visitorMail:
                GlobalVar.shared.loginUser?.is_visitor_mail = status
            }
            // イベント登録
            let isApproachedNotification   = GlobalVar.shared.loginUser?.is_approached_notification ?? true
            let isMatchingNotification     = GlobalVar.shared.loginUser?.is_matching_notification ?? true
            let isMessageNotification      = GlobalVar.shared.loginUser?.is_message_notification ?? true
            let isInvitationedNotification = GlobalVar.shared.loginUser?.is_invitationed_notification ?? true
            let isDatingNotification       = GlobalVar.shared.loginUser?.is_dating_notification ?? true
            let isVisitorNotification      = GlobalVar.shared.loginUser?.is_visitor_notification ?? true
            
            let isApproachedMail   = GlobalVar.shared.loginUser?.is_approached_mail ?? true
            let isMatchingMail     = GlobalVar.shared.loginUser?.is_matching_mail ?? true
            let isMessageMail      = GlobalVar.shared.loginUser?.is_message_mail ?? true
            let isInvitationedMail = GlobalVar.shared.loginUser?.is_invitationed_mail ?? true
            let isDatingMail       = GlobalVar.shared.loginUser?.is_dating_mail ?? true
            let isVisitorMail      = GlobalVar.shared.loginUser?.is_visitor_mail ?? true
            
            let logEventData = [
                "is_approached_notification": isApproachedNotification,
                "is_matching_notification": isMatchingNotification,
                "is_message_notification": isMessageNotification,
                "is_invitationed_notification": isInvitationedNotification,
                "is_dating_notification": isDatingNotification,
                "is_visitor_notification": isVisitorNotification,
                "is_approached_mail": isApproachedMail,
                "is_matching_mail": isMatchingMail,
                "is_message_mail": isMessageMail,
                "is_invitationed_mail": isInvitationedMail,
                "is_dating_mail": isDatingMail,
                "is_visitor_mail": isVisitorMail
            ] as [String : Any]
            Log.event(name: "changeNotificationSetting", logEventData: logEventData)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            openSettingURL()
        }
        let pushNotificationSettingTableView = GlobalVar.shared.pushNotificationSettingTableView
        pushNotificationSettingTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isPermitted = GlobalVar.shared.iosNotificationIsPermitted
        let pushNotificationSettingTableView = GlobalVar.shared.pushNotificationSettingTableView
        if indexPath.section == 0 && isPermitted {
            return 0
        } else if pushNotificationSectionHidden(section: indexPath.section) {
            return 0
        } else {
            return super.tableView(pushNotificationSettingTableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if pushNotificationSectionHidden(section: section) {
            return nil
        } else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if pushNotificationSectionHidden(section: section) {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    private func pushNotificationSectionHidden(section: Int) -> Bool {
        return pushNotificationHidden == true && section == pushNotificationSection
    }
}
