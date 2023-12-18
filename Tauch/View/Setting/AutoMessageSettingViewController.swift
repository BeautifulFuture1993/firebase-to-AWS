//
//  MatchToRoomSettingViewController.swift
//  Tauch
//
//  Created by Apple on 2023/05/19.
//

import UIKit
import FirebaseFirestore

class AutoMessageSettingViewController: UIBaseViewController {

    @IBOutlet weak var toggleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationWithBackBtnSetUp(navigationTitle: "自動メッセージ送信設定", color: .systemGray6)
        
        toggleSwitch.isOn = GlobalVar.shared.loginUser?.is_auto_message ?? true
    }
    
    @IBAction func didTapSwitch(_ sender: UISwitch) {
        autoMessageSettingUpdate(status: sender.isOn)
    }
    
    private func autoMessageSettingUpdate(status: Bool) {
        
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        
        GlobalVar.shared.loginUser?.is_auto_message = status
        // プッシュ通知カテゴリと状態を指定して更新
        let updateTime = Timestamp()
        let updateData = [
            "is_auto_message": status,
            "updated_at": updateTime
        ] as [String : Any]
        db.collection("users").document(uid).updateData(updateData)
    }
}
