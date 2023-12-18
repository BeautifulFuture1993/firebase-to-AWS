//
//  FriendEmojiSettingViewController.swift
//  Tauch
//
//  Created by Apple on 2023/07/12.
//

import UIKit
import FirebaseFirestore

class FriendEmojiSettingViewController: UIBaseViewController {
    // フレンド絵文字のON/OFF Switch
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationWithBackBtnSetUp(navigationTitle: "フレンド絵文字設定", color: .systemGray6)
        
        toggleSwitch.isOn = GlobalVar.shared.loginUser?.is_friend_emoji ?? true
    }
    
    @IBAction func didTapSwitch(_ sender: UISwitch) {
        friendEmojiSettingUpdate(status: sender.isOn)
    }
    
    func friendEmojiSettingUpdate(status: Bool) {
        
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        
        GlobalVar.shared.loginUser?.is_friend_emoji = status
        // フレンド絵文字を指定して更新
        let updateTime = Timestamp()
        let updateData = [
            "is_friend_emoji": status,
            "updated_at": updateTime
        ] as [String : Any]
        db.collection("users").document(uid).updateData(updateData)
    }

}
