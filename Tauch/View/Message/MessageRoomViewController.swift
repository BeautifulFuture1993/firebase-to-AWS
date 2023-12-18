//
//  MessageRoomViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/10/21.
//

import UIKit
import Nuke
import SDWebImage
import MessageKit
import FBSDKLoginKit
import SafariServices
import InputBarAccessoryView
import FirebaseFirestore

public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}

class MessageRoomViewController: MessagesViewController {
    
    @IBOutlet weak var talkView: UIStackView!
    @IBOutlet weak var talkCellsStackView: UIStackView!
    @IBOutlet weak var talkScrollView: UIScrollView!
    @IBOutlet weak var talkToogleButton: UIButton!
    @IBOutlet weak var talkCellFirst: UIView!
    @IBOutlet weak var talkCellSecond: UIView!
    @IBOutlet weak var talkCellThird: UIView!
    @IBOutlet weak var talkCellFourth: UIView!
    @IBOutlet weak var talkCellFifth: UIView!
    @IBOutlet weak var talkCellSixth: UIView!
    @IBOutlet weak var talkLabelFirst: UILabel!
    @IBOutlet weak var talkLabelSecond: UILabel!
    @IBOutlet weak var talkLabelThird: UILabel!
    @IBOutlet weak var talkLabelFourth: UILabel!
    @IBOutlet weak var talkLabelFifth: UILabel!
    @IBOutlet weak var talkLabelSixth: UILabel!
    @IBOutlet weak var talkSkipButton: UIButton!
    @IBOutlet weak var talkBottomView: UIStackView!
    @IBOutlet weak var talkBottomSpacerView: UIView!
    @IBOutlet weak var talkTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var talkImageView: UIImageView!
    @IBOutlet weak var talkTitleLabel: UILabel!
    
    let statusBarBackground = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Window.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0))
    let firebaseController = FirebaseController()
    let db = Firestore.firestore()
    var room: Room!
    var roomAvatar: Avatar! {
        didSet {
            GlobalVar.shared.messagesCollectionView.reloadData()
        }
    }
    let loadingView = UIView(frame: UIScreen.main.bounds)
    var isTalkShowing = true
    var isCallAction = false
    let isTheme = false
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter
    }()
    
    let blockButton = UIButton(type: .custom)
    let stopButton = UIButton(type: .custom)
    let reportButton = UIButton(type: .custom)
    // let callButton = UIButton(type: .custom)
    
    deinit {
    }

    override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.register(CustomTalkCell.self)
        
        super.viewDidLoad()
        // ナビゲーションセットアップ
        navigationWithBackSetUp()
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        configureTalkView()
        configureMessageInputBar()
        configureMessageCollectionView()
        
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
        
        roomOpenedToggle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // メッセージを既読にする
        messageRead()
        // 特定のルーム情報
        GlobalVar.shared.specificRoom = room
        GlobalVar.shared.messageInputBar = messageInputBar
        GlobalVar.shared.messagesCollectionView = messagesCollectionView
        GlobalVar.shared.talkView = talkView
        GlobalVar.shared.roomMessages = [CustomMessage]()
        // ルーム未送信メッセージをセット
        if let sendMessage = room.send_message {
            messageInputBar.inputTextView.text = sendMessage
        }
        // navigationBarの上の隙間を埋める
        guard let windowFirst = Window.first else { return }
        statusBarBackground.backgroundColor = .white
        windowFirst.addSubview(statusBarBackground)
        // リスナーデタッチ
        removeMessageRoomListener()
        // メッセージを監視
        fetchMessageRoomInfoFromFirestore()
        // ブロック、違反報告、一発停止が実行された場合 (ナビゲーションバーとメッセージ入力バーをカスタマイズする)
        messageRoomCustom(room: room)
        // ユーザアイコンの設定
        setMessageRoomAvator()
        // メッセージルーム オンライン状態のみ更新
        messageRoomStatusUpdate(statusFlg: true)
        // メッセージ通知タブの更新
        resetMessageRoomTabBarBadge()
        // 通話画面の表示判定
        // checkShowCallView()
    }
    
    private func setMessageRoomAvator() {
        guard let thisRoom = room else { return }
        guard let partnerUser = thisRoom.partnerUser else { return }
        let partnerUID = partnerUser.uid
        let partnerUserProfileIconImg = partnerUser.profile_icon_img
        if let url = URL(string: partnerUserProfileIconImg) {
            let iconImage = UIImageView()
            iconImage.setImage(withURL: url)
            setRoomAvator(iconImageView: iconImage, partnerUID: partnerUID)
        }
    }
    
    private func setRoomAvator(iconImageView: UIImageView, partnerUID: String) {
        let iconImage = iconImageView.image
        if iconImage == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.setRoomAvator(iconImageView: iconImageView, partnerUID: partnerUID)
            }
        } else {
            roomAvatar = Avatar(image: iconImage, initials: partnerUID)
        }
    }
    
    private func resetMessageRoomTabBarBadge() {
        guard let rooms = GlobalVar.shared.loginUser?.rooms else { return }
        if let roomIndex = rooms.firstIndex(where: { $0.document_id == room.document_id }), let _ = GlobalVar.shared.loginUser?.rooms[safe: roomIndex] {
            GlobalVar.shared.loginUser?.rooms[roomIndex].unreadCount = 0
            setMessageTabBadges()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setClass(className: className)
        // ルーム30回起動毎に通報お願いアラート表示
        displayShowReportAlert()
    }
    
    // messageKitのナビゲーションバーを設定
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 「話しかけてみましょう」を表示
        view.bringSubviewToFront(talkView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.set("", forKey: "specificRoomID")
        UserDefaults.standard.synchronize()
        
        GlobalVar.shared.messageListTableView.reloadData()
        GlobalVar.shared.recomMsgCollectionView.reloadData()
        
        removeMessageRoomListener()
        statusBarBackground.removeFromSuperview()
        let sendOwnMessage = messageInputBar.inputTextView.text ?? ""
        setMessageStorage(text: sendOwnMessage)
        messageRoomStatusUpdate(statusFlg: false, saveTextFlg: true, saveText: sendOwnMessage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        if isSectionReservedForTypingIndicator(indexPath.section){
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomTalkCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }

    private func displayShowReportAlert() {
        if let launchedTimes = UserDefaults.standard.object(forKey: "roomLaunchedTimes") as? Int {
            launchedTimes > 30 ? showReportAlert() : UserDefaults.standard.set(launchedTimes + 1, forKey: "roomLaunchedTimes")
        } else {
            showReportAlert()
        }
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.maxTextViewHeight = 180

        let isSetMessageInputBar = setMessageInputBar(room: room, messageInputBar: messageInputBar)
        if isSetMessageInputBar == false { return }
        
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        messageInputBar.sendButton.tintColor = .darkGray
        messageInputBar.sendButton.setSize(CGSize(width: 25, height: 25), animated: true)
        messageInputBar.sendButton.imageView?.contentMode = .scaleAspectFit
        messageInputBar.sendButton.contentHorizontalAlignment = .fill
        messageInputBar.sendButton.contentVerticalAlignment = .fill
        
        let camera = makeButton(image: "camera.fill")
        messageInputBar.inputTextView.backgroundColor = .systemGray6
        messageInputBar.inputTextView.tintColor = .darkGray
        messageInputBar.inputTextView.layer.cornerRadius = 10
        messageInputBar.inputTextView.clipsToBounds = true
        
        messageInputBar.setStackViewItems([camera], forStack: .left, animated: true)
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 10)
        messageInputBar.rightStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.rightStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: true)
        messageInputBar.setRightStackViewWidthConstant(to: 30, animated: true)
        messageInputBar.leftStackView.distribution = .fill
        messageInputBar.rightStackView.distribution = .fill
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.leftStackView.spacing = 0
        messageInputBar.rightStackView.spacing = 0
    }
    
    private func makeButton(image: String) -> InputBarButtonItem {
        return InputBarButtonItem().configure {
            $0.image = UIImage(systemName: image)?.withRenderingMode(.alwaysTemplate)
            $0.setSize(CGSize(width: 25, height: 25), animated: true)
            $0.tintColor = .darkGray
            $0.imageView?.contentMode = .scaleAspectFit
            $0.contentHorizontalAlignment = .fill
            $0.contentVerticalAlignment = .fill
        }.onTouchUpInside { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.showImagePickerControllerActionSheet()
        }
    }
    
    private func showReportAlert() {
        let alert = UIAlertController(title: "勧誘ユーザー通報のお願い", message: "Touchは友達作りを目的にしているアプリです。勧誘やその他の目的を持っているユーザーを発見した場合「通報」をお願いします。運営にて厳しい処理を行います。", preferredStyle: .alert)
        alert.view.addConstraint(NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 460))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 115, width: 250, height: 290))
        imageView.image = UIImage(named: "BlockImage")
        alert.view.addSubview(imageView)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
        
        if let launchedTimes = UserDefaults.standard.object(forKey: "roomLaunchedTimes") as? Int, let roomID = room.document_id {
            let logEventData = [
                "roomID": roomID,
                "roomLaunchedTimes": launchedTimes
            ] as [String : Any]
            logEvent(name: "showMessageRoomReportAlert", logEventData: logEventData)
        }
        
        UserDefaults.standard.set(0, forKey: "roomLaunchedTimes")
    }
    
    func showAvatarProfile() {
        guard let roomID = room.document_id else { return }
        guard let partner = room.partnerUser else { return }
        let partnerUID = partner.uid
        let logEventData = [
            "roomID": roomID,
            "target": partnerUID
        ] as [String : Any]
        logEvent(name: "showAvatarProfile", logEventData: logEventData)
        
        if partner.is_deleted == true { return }
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let storyBoard = UIStoryboard.init(name: "ProfileDetailView", bundle: nil)
        let modalVC = storyBoard.instantiateViewController(withIdentifier: "ProfileDetailView") as! ProfileDetailViewController
        modalVC.user = partner
        modalVC.isViolation = false
        modalVC.modalPresentationStyle = .popover
        modalVC.transitioningDelegate = self
        modalVC.presentationController?.delegate = self
        present(modalVC, animated: true, completion: nil)
    }
    
    @IBAction func talkToogleAction(_ sender: UIButton) {
        if talkScrollView.isHidden {
            talkToogleButton.transform = talkToogleButton.transform.rotated(by: .pi / 2)
            talkScrollView.isHidden = false
            
            if isTheme {
                talkBottomView.isHidden = false
            }
        } else {
            talkToogleButton.transform = talkToogleButton.transform.rotated(by: .pi * 3/2)
            talkScrollView.isHidden = true
            
            if isTheme {
                talkBottomView.isHidden = true
            }
        }
    }
    
    @IBAction func talkSkipAction(_ sender: UIButton) {
        talkView.isHidden = true
    }
    
    private func configureTalkView() {
        if isTheme {
            talkTitleHeight.constant = 60
            talkBottomView.isHidden = false
            talkBottomSpacerView.isHidden = true
            talkImageView.image = UIImage(named: "Talk")
            talkTitleLabel.text = "本日のテーマ：\n〇〇〇〇〇〇〇〇〇〇〇〇"
        } else {
            talkTitleHeight.constant = 40
            talkBottomView.isHidden = true
            talkBottomSpacerView.isHidden = false
            talkImageView.image = UIImage(systemName: "message.fill")
            talkTitleLabel.text = "話しかけてみましょう！"
        }
        
        talkScrollView.layer.zPosition = -1
        talkView.setShadow()
        
        setuptalkCell(talkCellFirst, tag: 1)
        setuptalkCell(talkCellSecond, tag: 2)
        setuptalkCell(talkCellThird, tag: 3)
        setuptalkCell(talkCellFourth, tag: 4)
        setuptalkCell(talkCellFifth, tag: 5)
        setuptalkCell(talkCellSixth, tag: 6)
    }
    
    private func setuptalkCell(_ cell: UIView, tag: Int) {
        cell.tag = tag
        cell.layer.cornerRadius = 15
        cell.setShadow(opacity: 0.1)
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTaptalkViewCell)))
    }
    
    @objc func didTaptalkViewCell(_ sender: UITapGestureRecognizer) {
        var text = ""
        switch sender.view?.tag {
        case 1:
            text = talkLabelFirst.text ?? ""
        case 2:
            text = talkLabelSecond.text ?? ""
        case 3:
            text = talkLabelThird.text ?? ""
        case 4:
            text = talkLabelFourth.text ?? ""
        case 5:
            text = talkLabelFifth.text ?? ""
        case 6:
            text = talkLabelSixth.text ?? ""
        default:
            print("想定していないViewのタップを検知しました。(システムエラー)")
        }
        
        sendMessageToFirestore(text: text, type: isTheme ? .talk : .text, input: "talkView")
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        let layout = messagesCollectionView.collectionViewLayout as? CustomMessagesFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        // 相手のメッセージ吹き出し場所をカスタム
        layout?.setMessageIncomingAvatarPosition(.init(vertical: .messageTop))
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)))
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        // 自分のメッセージ吹き出し場所をカスタム
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingCellBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        // AccessoryView
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewPosition(.messageBottom)
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 50, height: 26))
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 50, height: 26))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
    }
    // Backボタン付きのナビゲーション
    private func navigationWithBackSetUp() {
        guard let thisRoom = room else { return }
        guard let partnerUser = thisRoom.partnerUser else { return }
        // フッターを削除
        tabBarController?.tabBar.isHidden = true
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
        // ナビゲーションの戻るボタンを消す
        navigationItem.setHidesBackButton(true, animated: true)
        // ナビゲーションバーの透過させない
        navigationController?.navigationBar.isTranslucent = false
        // ナビゲーションアイテムのタイトルを設定
        navigationItem.title = partnerUser.nick_name
        navigationItem.titleView?.tintColor = UIColor(named: "FontColor")
        // ナビゲーションバー左ボタンを設定
        let backImage = UIImage(systemName: "chevron.backward")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action:#selector(messageListBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "FontColor")
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let isNotActivatedForPartner = (partnerUser.is_activated == false)
        let isDeletedForPartner = (partnerUser.is_deleted == true)
        let isNotUseful = (isNotActivatedForPartner || isDeletedForPartner)
        if isNotUseful { return }
        //ナビゲーションバー右のボタンを設定
        // callButton.addTarget(self, action: #selector(callAction), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockAction), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopAction), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportAction), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [
            // callButton.changeIntoBarItem(systemImage: "phone.fill"),
            stopButton.changeIntoBarItem(systemImage: "megaphone.fill"),
            reportButton.changeIntoBarItem(systemImage: "megaphone"),
            blockButton.changeIntoBarItem(systemImage: "nosign")
        ]
    }
    // メッセージリスト画面に戻る
    @objc func messageListBack() {
        navigationController?.popViewController(animated: true)
    }
//    // 通話
//    @objc func callAction() {
//        // チュートリアル
//        let key = "isShowedPhoneTutorial"
//        playTutorial(key: key, type: "phone")
//
//        let isPhoneTutorial = (UserDefaults.standard.bool(forKey: key) == true)
//        if isPhoneTutorial {
//            if isCallAction {
//                let partnerNickName = room.partnerUser?.nick_name ?? ""
//                let title = "本当に\(partnerNickName)さんに通話をかけますか？"
//                let subTitle = ""
//                let confirmTitle = "通話"
//                dialog(title: title, subTitle: subTitle, confirmTitle: confirmTitle, completion: { [weak self] result in
//                    // 通話をかける
//                    if result { self?.call() }
//                })
//            } else {
//                alert(title: "通話ができません", message: "メッセージを「2往復」以上やりとりすると通話ができます。", actiontitle: "OK")
//            }
//        }
//    }
//    private func call() {
//
//        messageInputBar.inputTextView.resignFirstResponder()
//
//        let partnerUID = room.partnerUser?.uid ?? ""
//        db.collection("users").document(partnerUID).getDocument { [weak self] (document, error) in
//            if let document = document, document.exists {
//                let user = User(document: document)
//                self?.startCall(user: user)
//            }
//        }
//    }
    // ブロック
    @objc func blockAction() {
        guard let currentUID = GlobalVar.shared.loginUser?.uid else { return }
        let alert = UIAlertController(title: "\(room.partnerUser?.nick_name ?? "")さんをブロックしますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "ブロック", style: .destructive, handler: { [self] _ in
            self.showLoadingView(loadingView: loadingView)
            guard let partnerID = room.partnerUser?.uid else { return }
            firebaseController.block(loginUID: currentUID, targetUID: partnerID, completion: { [weak self] result in
                guard let weakSelf = self else { return }
                weakSelf.loadingView.removeFromSuperview()
                if result {
                    weakSelf.screenTransition(storyboardName: "MessageListViewController", storyboardID: "MessageListViewController")
                } else {
                    weakSelf.alert(title: "ブロックに失敗しました", message: "不具合を運営に報告してください。", actiontitle: "OK")
                }
            })
        }))
        present(alert, animated: true)
    }
    // 報告
    @objc func reportAction() {
        // 違反報告画面に遷移
        let storyBoard = UIStoryboard.init(name: "ViolationView", bundle: nil)
        let violationVC = storyBoard.instantiateViewController(withIdentifier: "ViolationView") as! ViolationViewController
        violationVC.targetUser = room.partnerUser
        violationVC.modalPresentationStyle = .popover
        violationVC.transitioningDelegate = self
        violationVC.presentationController?.delegate = self
        violationVC.closure = { [weak self] (flag: Bool) -> Void in
            guard let weakSelf = self else { return }
            if flag { weakSelf.screenTransition(storyboardName: "MessageListViewController", storyboardID: "MessageListViewController") }
        }
        present(violationVC, animated: true, completion: nil)
    }
    // 一発停止
    @objc func stopAction() {
        // アカウント一発停止画面に遷移
        let storyBoard = UIStoryboard.init(name: "StopView", bundle: nil)
        let stopVC = storyBoard.instantiateViewController(withIdentifier: "StopView") as! StopViewController
        stopVC.targetUser = room.partnerUser
        stopVC.modalPresentationStyle = .popover
        stopVC.transitioningDelegate = self
        stopVC.presentationController?.delegate = self
        stopVC.closure = { [weak self] (flag: Bool) -> Void in
            guard let weakSelf = self else { return }
            if flag { weakSelf.screenTransition(storyboardName: "MessageListViewController", storyboardID: "MessageListViewController") }
        }
        present(stopVC, animated: true, completion: nil)
    }
    private func messageRead() {
        
        guard let roomID = room.document_id else { return }
        guard let partnerUser = room.partnerUser else { return }
        let partnerUID = partnerUser.uid
        
        db.collection("rooms").document(roomID).collection("messages").whereField("creator", isEqualTo: partnerUID).whereField("read", isEqualTo: false).getDocuments { [weak self] (messageSnapshots, err) in
            guard let weakSelf = self else { return }
            if let err = err { print("メッセージ情報の取得失敗: \(err)"); return }
            guard let messageDocuments = messageSnapshots?.documents else { return }
            messageDocuments.forEach { messageDocument in
                let messageID = messageDocument.documentID
                weakSelf.db.collection("rooms").document(roomID).collection("messages").document(messageID).updateData(["read": true])
            }
        }
    }
    // Firestoreにメッセージを送信
    private func sendMessageToFirestore(text: String, imageURLs: [String] = [], type: CustomMessageType = .text, input: String, sourceType: UIImagePickerController.SourceType = .camera) {
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        guard let roomID = room.document_id else { return }
        guard let partnerID = room.partnerUser?.uid else { return }
        
        let messageId = UUID().uuidString
        
        addMessageForLocal(messageID: messageId, text: text, imageURLs: imageURLs, type: type, currentUID: uid)

        let members = [uid, partnerID]
        let sendTime = Timestamp()
        let messageData = [
            "room_id": roomID,
            "message_id": messageId,
            "text": text,
            "photos": imageURLs,
            "read": false,
            "members": members,
            "creator": uid,
            "type": type.rawValue,
            "unread_flg": true,
            "calc_unread_flg": true,
            "created_at": sendTime,
            "updated_at": sendTime
        ] as [String : Any]
        
        db.collection("rooms").document(roomID).collection("messages").document(messageId).setData(messageData)
        
        let removedUser = [String]()
        let latestMessageData = [
            "latest_message_id": messageId,
            "latest_message": text,
            "latest_sender": uid,
            "removed_user": removedUser,
            "unread_\(uid)": 0,
            "unread_\(partnerID)": FieldValue.increment(Int64(1)),
            "is_room_opened_\(partnerID)": true,
            "creator": uid,
            "updated_at": sendTime
        ] as [String : Any]
        
        db.collection("rooms").document(roomID).updateData(latestMessageData)
        
        registNotificationEachUser(creator: uid, members: members, roomID: roomID, messageID: messageId)
        
        let logEventData = [
            "room_id": roomID,
            "message_id": messageId,
            "text": text,
            "target": partnerID
        ] as [String : Any]
        
        switch input {
        case "talkView":
            logEvent(name: "sendMessageFromTalkView", logEventData: logEventData)
            break
        case "cameraInput":
            if sourceType == .photoLibrary {
                logEvent(name: "sendMessageFromPhotoLibraryInput", logEventData: logEventData)
            } else if sourceType == .camera {
                logEvent(name: "sendMessageFromCameraInput", logEventData: logEventData)
            }
            break
        case "messageInput":
            logEvent(name: "sendMessageFromMessageInput", logEventData: logEventData)
            break
        default:
            break
        }
    }
    //メッセージを送信した時、パートナーのis_room_openedをtrueに変更
    private func roomOpenedToggle() {
        
        guard let roomID = room.document_id else { return }
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        
        let roomData = ["is_room_opened_\(loginUID)": true]
        
        if room.is_room_opened == false { db.collection("rooms").document(roomID).updateData(roomData) }
    }
    
    private func addMessageForLocal(messageID: String, text: String, imageURLs: [String] = [], type: CustomMessageType = .text, currentUID: String) {
        
        if GlobalVar.shared.roomMessages.firstIndex(where: { $0.messageId == messageID }) != nil { return }
        
        let rooms = GlobalVar.shared.loginUser?.rooms ?? [Room]()
        
        let sender = Sender(
            senderId: currentUID,
            displayName: ""
        )
        
        let addTimeStamp = Timestamp()
        let addDate = addTimeStamp.dateValue()
        var customMessage: CustomMessage?
        
        if imageURLs.isEmpty == false {
            if let photo = imageURLs.first, let photoURL = URL(string: photo) {
                customMessage = CustomMessage(
                    imageURL: photoURL,
                    sender: sender,
                    messageId: messageID,
                    date: addDate,
                    readFlg: false,
                    accessoryFlg: true
                )
            }
            
        } else {
            switch type {
            case .text:
                customMessage = CustomMessage(
                    text: text,
                    sender: sender,
                    messageId: messageID,
                    date: addDate,
                    readFlg: false,
                    accessoryFlg: false
                )
                break
            default: break
            }
        }
        
        guard let addMessage = customMessage else { return }
        GlobalVar.shared.roomMessages.append(addMessage)
        
        talkView.isHidden = true
        
        for (index, _room) in rooms.enumerated() {
            if _room.document_id == room.document_id {
                GlobalVar.shared.loginUser?.rooms[index].latest_message = text
                GlobalVar.shared.loginUser?.rooms[index].latest_sender = currentUID
                GlobalVar.shared.loginUser?.rooms[index].unreadCount = 0
                GlobalVar.shared.loginUser?.rooms[index].removed_user = []
                GlobalVar.shared.loginUser?.rooms[index].updated_at = addTimeStamp
            }
        }
        
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    private func setMessageStorage(text: String) {
        
        GlobalVar.shared.specificRoom?.send_message = text
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        let rooms = loginUser.rooms
        let sendMessage = room.send_message ?? ""
        
        if let roomIndex = rooms.firstIndex(where: { $0.document_id == room.document_id }) {
            GlobalVar.shared.loginUser?.rooms[roomIndex].send_message = sendMessage
        }
    }
    
    public func presentationController(_ presentationController: UIPresentationController, prepare adaptivePresentationController: UIPresentationController) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
}

extension MessageRoomViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    private func showImagePickerControllerActionSheet()  {
        let photoLibraryAction = UIAlertAction(title: "ライブラリから写真を選ぶ", style: .default) { [weak self] action in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "カメラで写真を撮る", style: .default) { [weak self] action in
            self?.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default , handler: nil)
        showAlert(style: .actionSheet, title: "送信する画像を選択してください", message: nil, actions: [photoLibraryAction, cameraAction , cancelAction], completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = sourceType
        // imgPicker.allowsEditing = true
        imgPicker.presentationController?.delegate = self
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let roomID = room.document_id else { return }
        
        let sourceType = picker.sourceType
        
        let loadingView = UIView(frame: UIScreen.main.bounds)
        showLoadingView(loadingView: loadingView)
        
        var images = [UIImage]()
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            messageInputBar.inputPlugins.forEach { _ = $0.handleInput(of: image)}
            if let resizedImage = image.resized(size: CGSize(width: 400, height: 400)) {
                images.append(resizedImage)
            } else {
                images.append(image)
            }
        }
        uploadMessageImgStrage(roomID: roomID, images: images, completion: { [weak self] imageURLs in
            guard let weakSelf = self else { return }
            let text = "画像が送信されました"
            weakSelf.sendMessageToFirestore(text: text, imageURLs: imageURLs, type: .image, input: "cameraInput", sourceType: sourceType)
            loadingView.removeFromSuperview()
        })
        messageInputBar.inputTextView.text = ""
        setMessageStorage(text: "")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // ローディング画面を表示
    func showLoadingView(loadingView: UIView) {
        loadingView.backgroundColor = .white.withAlphaComponent(0.5)
        let indicator = UIActivityIndicatorView()
        indicator.center = loadingView.center
        indicator.style = .large
        indicator.color = UIColor(named: "AccentColor")
        indicator.startAnimating()
        loadingView.addSubview(indicator)
        guard let windowFirst = Window.first else { return }
        windowFirst.addSubview(loadingView)
    }
}

extension MessageRoomViewController: CameraInputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text.isEmpty { return }
        sendMessageToFirestore(text: text, input: "messageInput")
        messageInputBar.inputTextView.text = ""
        setMessageStorage(text: "")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        setMessageStorage(text: text)
    }
    
    // FireStoreにメッセージ画像をアップロード
    private func uploadMessageImgStrage(roomID: String, images: [UIImage], completion: @escaping ([String]) -> Void) {
        let refName = "rooms/\(roomID)"
        let folderName = "messages"
        let fileID = UUID().uuidString
        let fileName = "img_\(fileID).jpg"
        
        var imageURLs = [String]()
        let imageNum = images.count
        if images.count == 0 { completion(imageURLs) }
        for (index, _image) in images.enumerated() {
            firebaseController.uploadImageToFireStorage(image: _image, referenceName: refName, folderName: folderName, fileName: fileName, completion: { [weak self] result in
                guard let _ = self else { return }
                if result.count != 0 {
                    imageURLs.append(result)
                }
                if index == imageNum - 1 {
                    completion(imageURLs)
                }
            })
        }
    }
}

extension MessageRoomViewController: MessagesDataSource {
    
    func isFromCurrentSender(message: MessageType) -> Bool {
        return message.sender.senderId == currentSender().senderId
    }
    
    func currentSender() -> SenderType {
        let uid = GlobalVar.shared.loginUser?.uid ?? ""
        
        return Sender(
            senderId: uid,
            displayName: ""
        )
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return GlobalVar.shared.roomMessages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return GlobalVar.shared.roomMessages[indexPath.section]
    }
    // セルの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
}
// メッセージのdelegate
extension MessageRoomViewController: MessagesDisplayDelegate {
    // メッセージの色
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    // メッセージの背景色
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let myMessageBackGroundColor = UIColor().setColor(colorType: "accentColor", alpha: 1.0)
        let otherMessageBackGroundColor = UIColor.systemGray6
        return isFromCurrentSender(message: message) ? myMessageBackGroundColor : otherMessageBackGroundColor
    }
    // メッセージの枠
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .topRight : .topLeft
        return .bubbleTail(tail, .pointedEdge)
    }
    // アイコン
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if isFromCurrentSender(message: message) {
            // 自分が送信者の場合、アイコン非表示
            avatarView.isHidden = true
        } else {
            // 自分以外が送信者の場合、アイコン表示
            avatarView.isHidden = false
            if let _ = roomAvatar.image { avatarView.set(avatar: roomAvatar) }
        }
    }
    // 画像
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.setImage(withURL: imageURL, isFade: false)
        }
    }
    // リンクの検知 アクティブ化 (テキスト色を青色に変更)
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .url:
            return [
                .foregroundColor: UIColor.systemBlue,
                .underlineColor: UIColor.systemBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    // リンクを検知しアクティブ化
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    // メッセージの横の表示
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
        guard let currentUID = GlobalVar.shared.loginUser?.uid else { return }
        removeAllSubviews(parentView: accessoryView)
        // 既読
        let readLabel = UILabel(frame: CGRect(x: 0, y: isFromCurrentSender(message: message) ? 4 : 0, width: 50, height: 10))
        readLabel.font = UIFont.boldSystemFont(ofSize: 10)
        readLabel.textColor = .darkGray
        readLabel.textAlignment = isFromCurrentSender(message: message) ? .right : .left
        let customMessage = message as! CustomMessage
        let isReadFlg = customMessage.readFlg
        let isOwnSend = (customMessage.sender.senderId == currentUID)
        if isReadFlg && isOwnSend { readLabel.text = "既読" }
        accessoryView.addSubview(readLabel)
        // 送信時間
        let timeLabel = UILabel(frame: CGRect(x: 0, y: isFromCurrentSender(message: message) ? 16 : 12, width: 50, height: 10))
        timeLabel.text = ElapsedTime.format(from: message.sentDate)
        timeLabel.font = UIFont.boldSystemFont(ofSize: 10)
        timeLabel.textColor = .darkGray
        timeLabel.textAlignment = isFromCurrentSender(message: message) ? .right : .left
        accessoryView.addSubview(timeLabel)
    }
}

// 各ラベルの高さを設定（デフォルト0なので必須）
extension MessageRoomViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard let partner = room.partnerUser else { return 0 }
        let partnerUID = partner.uid
        // メッセージやりとりしているユーザがブロック・違反報告・一発停止・退会済みされている場合
        let loginUser = GlobalVar.shared.loginUser
        let isBlockUser = (loginUser?.blocks.firstIndex(of: partnerUID) != nil)
        let isViolationUser = (loginUser?.violations.firstIndex(of: partnerUID) != nil)
        let isStopUser = (loginUser?.stops.firstIndex(of: partnerUID) != nil)
        let isDeleteUser = (loginUser?.deleteUsers.firstIndex(of: partnerUID) != nil)
        let isExistRoomMessages = (GlobalVar.shared.roomMessages.count != 0)
        if isBlockUser || isViolationUser || isStopUser || isDeleteUser || isExistRoomMessages {
            return 0
        } else {
            if indexPath.section == 0 { return 60 }
        }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 2
    }
    
    func customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
        let cell = messagesCollectionView.dequeueReusableCell(CustomTalkCell.self, for: indexPath)
        cell.configure(with: message, at: indexPath, and: messagesCollectionView)
        return cell
    }
}
// 各要素タップ時の挙動を定義
extension MessageRoomViewController: MessageCellDelegate {
    // アイコンタップした場合
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        showAvatarProfile()
    }
    // バックグラウンドタップした場合
    func didTapBackground(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else { return }
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            SDWebImageDownloader.shared.downloadImage(with: imageURL, options: [], progress: nil) { [self] image,_,_,_ in
                if let image = image {
                    moveImageDetail(image: image)
                }
            }
        }
    }
    
    private func moveImageDetail(image: UIImage) {
        let storyBoard = UIStoryboard.init(name: "ImageDetailView", bundle: nil)
        let imageVC = storyBoard.instantiateViewController(withIdentifier: "ImageDetailView") as! ImageDetailViewController
        imageVC.pickedImage = image
        loadingView.removeFromSuperview()
        present(imageVC, animated: true)
    }
}

extension MessageRoomViewController: MessageLabelDelegate {
    func didSelectURL(_ url: URL) {
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true)
        
        guard let roomID = room.document_id else { return }
        guard let partner = room.partnerUser else { return }
        let partnerUID = partner.uid
        let logEventData = [
            "roomID": roomID,
            "target": partnerUID
        ] as [String : Any]
        logEvent(name: "openMessageLinkURL", logEventData: logEventData)
    }
}

open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    lazy open var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)

    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
}
