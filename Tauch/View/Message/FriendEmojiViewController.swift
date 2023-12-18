//
//  FriendEmojiViewController.swift
//  Tauch
//
//  Created by Apple on 2023/07/13.
//

import UIKit

class FriendEmojiViewController: UIBaseViewController {

    @IBOutlet weak var friendEmojiSettingBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendEmojiSettingBtn.addTarget(self, action: #selector(moveFriendEmojiSetting), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationWithModalBackBtnSetUp(navigationTitle: "フレンド絵文字ガイド")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideNavigationBarBorderAndShowTabBarBorder()
        GlobalVar.shared.messageListTableView.reloadData()
    }
}
