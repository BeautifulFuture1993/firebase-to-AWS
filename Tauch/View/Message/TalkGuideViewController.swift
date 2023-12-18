//
//  TalkGuideViewController.swift
//  Tauch
//
//  Created by adachitakehiro2 on 2023/04/29.
//

import UIKit
import TagListView
import FirebaseFirestore

class TalkGuideViewController: UIBaseViewController {
    
    @IBOutlet weak var commonTagListView1: TagListView!
    @IBOutlet weak var commonTagListView2: TagListView!
    @IBOutlet weak var displayadviceLabel: UILabel!
    @IBOutlet weak var firstLetterLabel: UILabel!
    @IBOutlet weak var partnerName: UILabel!
    // 条件に応じて表示
    @IBOutlet weak var topicAdviceStackView: UIStackView!
    @IBOutlet weak var messageRecommendAdviceStackView: UIStackView!
    @IBOutlet weak var displayAdviceStackView: UIStackView!
    // 常に表示
    @IBOutlet weak var firstLetterAdviceStackView: UIStackView!
    @IBOutlet weak var topicAdviceStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageRecommendAdviceStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var talkGuideStackVIewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var firstLetterAdviceStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var displayAdviceStackViewHeight: NSLayoutConstraint!
    
    private var commonTags:[String] = []
    private let talkGuideCategory = GlobalVar.shared.talkGuideCategory
    
    deinit {
        // お話ガイドを非表示にする
        GlobalVar.shared.showTalkGuide = false
        GlobalVar.shared.talkGuideCategory = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displaySpecificPage(category: talkGuideCategory)
        getCommonTag()
        displayAdviceLabelCustom()
        firstLetterLabelCustom()
        
        guard let specificRoom = GlobalVar.shared.specificRoom else { return }
        readTalkGuide(room: specificRoom)
        
        guard let specificRoomPartnerUser = specificRoom.partnerUser else { return }
        partnerName.text = specificRoomPartnerUser.nick_name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationWithModalBackBtnSetUp(navigationTitle: "おはなしガイド")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GlobalVar.shared.tabBarVC?.tabBar.isHidden = true
    }
    
    @IBAction func guideSettingButtonTapped(_ sender: UIButton) { settingAction() }
    //トークガイド
    @objc func settingAction() {
        //トークガイド画面に遷移
        let storyboard = UIStoryboard.init(name: "TalkGuideSettingView", bundle: nil)
        let settingVC = storyboard.instantiateViewController(withIdentifier: "TalkGuideSettingView") as! TalkGuideSettingViewController
        present(settingVC, animated: true, completion: nil)
    }
    
    private func readTalkGuide(room: Room) {
        
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let roomID = room.document_id else { return }
        var updateRoomData:[String:Any] = [:]
        
        let topicReplyReceived = room.topic_reply_received
        let isTopicReplyReceived = (topicReplyReceived.contains(loginUID) == true)
        
        if isTopicReplyReceived {
            updateRoomData["topic_reply_received_read"] = FieldValue.arrayUnion([loginUID])
        }
        
        let leaveMessageReceived = room.leave_message_received
        let isLeaveMessageReceived = (leaveMessageReceived.contains(loginUID) == true)
        
        if isLeaveMessageReceived {
            updateRoomData["leave_message_received_read"] = FieldValue.arrayUnion([loginUID])
        }
        
        let isUpdateTalkGuide = (talkGuideStatus() == true)
        if isUpdateTalkGuide {
            
            if isTopicReplyReceived {
                GlobalVar.shared.specificRoom?.topic_reply_received_read.append(loginUID)
            }
            if isLeaveMessageReceived {
                GlobalVar.shared.specificRoom?.leave_message_received_read.append(loginUID)
            }
            
            db.collection("rooms").document(roomID).updateData(updateRoomData)
            
            GlobalVar.shared.messageCollectionView?.reloadData() // フルリプレイスのCollectionView
        }
    }

    func displaySpecificPage(category: String) {
        switch category {
        case "topic_reply":
            // 4ラリー以内に24時間返信が無いと表示
            //「こんな話題で返信してみませんか」
            topicAdviceStackView.isHidden = false
            messageRecommendAdviceStackView.isHidden = true
        case "leave_message":
            // マッチングから6時間が経過した
            //「早急にメッセージを送りましょう」
            topicAdviceStackView.isHidden = true
            messageRecommendAdviceStackView.isHidden = false
        default:
            // 常に表示の部分
            // 「トークを始める前に知っておきたいこと」
            // 「１通目の送信をはやめましょう」
            topicAdviceStackView.isHidden = true
            messageRecommendAdviceStackView.isHidden = true
            // 常に表示しない部分の表示条件
            showTalkGuide()
        }
    }
    
    private func showTalkGuide() {
        
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let room = GlobalVar.shared.specificRoom else { return }
        
        let topicReplyReceived = room.topic_reply_received
        let isTopicReplyReceived = (topicReplyReceived.contains(loginUID) == true)
        
        let leaveMessageReceived = room.leave_message_received
        let isLeaveMessageReceived = (leaveMessageReceived.contains(loginUID) == true)
        
        topicAdviceStackView.isHidden = (isTopicReplyReceived ? false : true)
        messageRecommendAdviceStackView.isHidden = (isLeaveMessageReceived ? false : true)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}


//MARK: - Setting

extension TalkGuideViewController {
    
    func getCommonTag() {
        let userHobbies = GlobalVar.shared.loginUser?.hobbies
        let partnerHobbies = GlobalVar.shared.specificRoom?.partnerUser?.hobbies
        
        for i in 0..<(userHobbies?.count ?? 0) {
            for j in 0..<(partnerHobbies?.count ?? 0) {
                if userHobbies?[i] == partnerHobbies?[j] {
                    commonTags.append(userHobbies?[i] ?? "")
                }
            }
        }
        setTags(selectedTags: commonTags)
    }
    
    func setTags(selectedTags: [String]) {
        commonTagListView1.removeAllTags()
        commonTagListView2.removeAllTags()
        commonTagListView1.addTags(selectedTags)
        commonTagListView2.addTags(selectedTags)
        tagListViewCustom(selectedTags: selectedTags)
    }
    
    private func tagListViewCustom(selectedTags: [String]) {
        
        // 趣味カード分のスペースを空ける
        let hobbyListCount = selectedTags.count
        var hobbyListTotalString = 0
        selectedTags.forEach { hobby in hobbyListTotalString += hobby.count }
        
        commonTagListView1.textFont = UIFont.boldSystemFont(ofSize: 14)
        commonTagListView2.textFont = UIFont.boldSystemFont(ofSize: 14)
        
        var hobbyListViewWidth: CGFloat = 0
        
        if hobbyListCount*40 + hobbyListTotalString*14 < Int(UIScreen.main.bounds.width - 40) {
            hobbyListViewWidth = UIScreen.main.bounds.width - 40
            commonTagListView1.heightAnchor.constraint(equalToConstant: 60).isActive = true
            commonTagListView2.heightAnchor.constraint(equalToConstant: 60).isActive = true
        } else {
            hobbyListViewWidth = CGFloat(hobbyListCount*20 + hobbyListTotalString*7)
        }
        
        commonTagListView1.widthAnchor.constraint(equalToConstant: hobbyListViewWidth).isActive = true
        commonTagListView2.widthAnchor.constraint(equalToConstant: hobbyListViewWidth).isActive = true
    }
    
    func displayAdviceLabelCustom() {
        guard let displayAdviceLabelText = displayadviceLabel.text else { return }
        let attrDisplayAdviceLabelText = NSMutableAttributedString(string: displayAdviceLabelText)

        attrDisplayAdviceLabelText.addAttributes([
            .foregroundColor: UIColor(named: "defaultColor"),
            .font: UIFont.boldSystemFont(ofSize: 14)
        ], range: NSMakeRange(44, 17))

        displayadviceLabel.attributedText = attrDisplayAdviceLabelText
    }
    
    func firstLetterLabelCustom() {
        guard let firstLetterLabelText = firstLetterLabel.text else { return }
        let attrFirstLetterLabelText = NSMutableAttributedString(string: firstLetterLabelText)

        attrFirstLetterLabelText.addAttributes([
            .foregroundColor: UIColor(named: "defaultColor"),
            .font: UIFont.boldSystemFont(ofSize: 14)
        ], range: NSMakeRange(18, 20))

        firstLetterLabel.attributedText = attrFirstLetterLabelText
    }
}
