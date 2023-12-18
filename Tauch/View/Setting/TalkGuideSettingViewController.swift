//
//  TalkGuideSettingViewController.swift
//  Tauch
//
//  Created by adachitakehiro2 on 2023/04/30.
//

import UIKit
import FirebaseFirestore

class TalkGuideSettingViewController: UIBaseViewController {
    //トークガイドの通知を受け取るかどうかのSwitch
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationWithBackBtnSetUp(navigationTitle: "おはなしガイド設定", color: .systemGray6)
        
        toggleSwitch.isOn = GlobalVar.shared.loginUser?.is_talkguide ?? true
    }
    
    @IBAction func didTapSwitch(_ sender: UISwitch) {
        talkGuideSettingUpdate(status: sender.isOn)
    }
    
    func talkGuideSettingUpdate(status: Bool) {
        
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        
        GlobalVar.shared.loginUser?.is_talkguide = status
        // プッシュ通知カテゴリと状態を指定して更新
        let updateTime = Timestamp()
        let updateData = [
            "is_talkguide": status,
            "updated_at": updateTime
        ] as [String : Any]
        db.collection("users").document(uid).updateData(updateData)
    }

}
