//
//  MessageRoomView.swift
//  Tauch
//
//  Created by Apple on 2023/07/22.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseFunctions

final class MessageRoomView: UIBaseViewController {
    
    @IBOutlet weak var talkView: UIStackView!
    @IBOutlet weak var talkCellsStackView: UIStackView!
    @IBOutlet weak var talkScrollView: UIScrollView!
    @IBOutlet weak var talkImageView: UIImageView!
    @IBOutlet weak var talkTitleLabel: UILabel!
    @IBOutlet weak var talkTitleHeight: NSLayoutConstraint!
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
    @IBOutlet weak var talkBottomView: UIStackView!
    @IBOutlet weak var talkBottomSpacerView: UIView!
    @IBOutlet weak var messageCollectionView: UICollectionView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var room: Room?
    
    private var roomMessages = [Message]()
    private var pastMessages = [Message]()
    private var callViewController: CallViewController?
    private var listener: ListenerRegistration?
    private var skywayToken: String?
    private var selectedIndexPath: IndexPath?
    private var reactionIndexPath: IndexPath?
    private var messageInputView = MessageInputView.init()
    private var disableLabel = UILabel()
    private var textView = UITextView()
    private var placeHolder = UILabel()
    private var cameraButton = UIButton()
    private var stampButton = UIButton()
    private var sendButton = UIButton()
    private var messageInputViewFrame: CGRect?
    private var safeAreaInsets: UIEdgeInsets?
    private var keyboardFrame: CGRect?
    private let LABEL_SIZE: CGFloat = 50
    private let BUTTON_SIZE: CGFloat = 50
    private let INPUT_VIEW_HEIGHT: CGFloat = 50
    private let INPUT_VIEW_MARGIN: CGFloat = 10
    private let TEXT_VIEW_HEIGHT: CGFloat = 36
    private let TEXT_VIEW_MARGIN: CGFloat = 8
    private let INPUT_VIEW_PADDING: CGFloat = 7.5
    private let MIN_TEXT_VIEW_HEIGHT: CGFloat = 36
    private let MAX_TEXT_VIEW_HEIGHT: CGFloat = 200
    private let TEXT_VIEW_FONT_SIZE: CGFloat = 16
    private let REPRY_VIEW_HEIGHT: CGFloat = 70
    private let callButton = UIButton(type: .custom)
    private let guideButton = UIButton(type: .custom)
    private let rightStackButton = UIButton(type: .custom)
    private var lastDocument: DocumentChange?
    private var isConsecutiveCoundUpdate = false
    private var typingIndicatorView: TypingIndicatorView?
    private let sectionCount = 1
    private var isScrollToBottomAfterKeyboardShowed = false
    private var beforeTextViewHeight: CGFloat = 0.0
    private var lastTextViewSelectRange: NSRange?
    private var isFetchPastMessages = true
    private var isAlreadyReloadDataForLocalMessage = false
    private var isBackground = false
    
    // リプライ関連
    private let replyPreview = UIView()
    private let replyPreviewIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.rounded()
        return imageView
    }()
    private let replyPreviewNickNameLabel = UILabel()
    private let replyPreviewMessageTextLabel = UILabel()
    private let replyPreviewMessageImageView = UIImageView()
    private let replyPreviewCloseButton = UIButton(type: .close)
    private var replyIsSelected: Bool = false
    private var replyMessageID: String?
    
    // スタンプ機能
    private var messageStickerIsSelected: Bool = false
    private var selectedSticker: (sticker: UIImage?, identifier: String?)
    private var keyboardIsShown: Bool = false
    
    private enum ReactionTypes {
        case delayedUpdate
    }

    private enum InterfaceActions {
        case changingKeyboardFrame
        case changingContentInsets
        case changingFrameSize
        case sendingMessage
        case scrollingToTop
        case scrollingToBottom
        case showingPreview
        case showingAccessory
        case updatingCollectionInIsolation
    }

    private enum ControllerActions {
        case loadingInitialMessages
        case loadingPreviousMessages
        case updatingCollection
    }
    
    private enum CallAlertType {
        case missingData
        case notFunctionEnabled
    }
    
    private enum SendMessageAlertType {
        case nonDocumentID
        case overFileSize
        case emptyFile
        case notReadFile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigation()
        setConsectiveRallyRecord()
        setUpMessageInputViewContainer()
        fetchSkyWayToken()
        configureTalkView()
        configureMessageCollectionView()
        seUpCollectionViewCell()
        setCollectionViewTapGesture()
        setUpNotification()
        setUpLoadingLabel()
        // observeTypingState() フルリプレイス1stリリースでは不要
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeMessageRoomListener()
        fetchMessagesForFirestore()
        messageRoomStatusUpdate(statusFlg: true)
        messageRead()
        setMessageRoomInfo()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if GlobalVar.shared.showTalkGuide {
            onTalkGuideButtonTapped()
        }
        
        cheackLaunchRoomCount()
        autoMessageAction()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.set("", forKey: "specificRoomID")
        UserDefaults.standard.synchronize()
        
        tabBarController?.tabBar.isHidden = false
        removeMessageRoomListener()
        
        if let sendOwnMessage = textView.text {
            setMessageStorage(sendOwnMessage)
            messageRoomStatusUpdate(statusFlg: false, saveTextFlg: true, saveText: sendOwnMessage)
            lastTextViewSelectRange = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // updateTypingState(isTyping: false) フルリプレイス1stリリースでは不要
    }
    
    private func setUpNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(closedTutorial),
            name: NSNotification.Name(NotificationName.ClosedTutorial.rawValue),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(foreground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(background(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func setUpLoadingLabel() {
        loadingLabel.isHidden = true
        loadingLabel.clipsToBounds = true
        loadingLabel.layer.cornerRadius = 7.5
    }
    
    @objc private func foreground(_ notification: Notification) {
        print("come back foreground.")
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        isBackground = false
        messageRoomStatusUpdate(statusFlg: true)
        messageRead()
        setMessageRoomInfo()
    }
    
    @objc private func background(_ notification: Notification) {
        print("go to background.")
        if let sendOwnMessage = textView.text {
            setMessageStorage(sendOwnMessage)
            messageRoomStatusUpdate(statusFlg: false, saveTextFlg: true, saveText: sendOwnMessage)
            lastTextViewSelectRange = nil
        }
        isBackground = true
    }
    
    private func scrollToBottom() {
        if messageCollectionView.numberOfSections > 0 {
            let section = messageCollectionView.numberOfSections
            let lastSection = section - 1
            let lastItem = messageCollectionView.numberOfItems(inSection: lastSection)
            if lastItem >= 0 {
                let lastIndexPath = IndexPath(item: lastItem - 1, section: lastSection)
                messageCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                
                // 2回呼ぶことで最下部メッセージの全体が表示されない不具合を回避している（0.01で送受信のカクツキを回避）
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    UIView.performWithoutAnimation {
                        let lastIndexPath = IndexPath(item: lastItem - 1, section: lastSection)
                        self.messageCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                    }
                }
            }
        }
    }
    
    func isCollectionViewAtBottom(_ collectionView: UICollectionView) -> Bool {
        let contentHeight = collectionView.contentSize.height
        let offsetY = collectionView.contentOffset.y
        let boundsHeight = collectionView.bounds.height
        
        return contentHeight - offsetY <= boundsHeight
    }
    
    private func setMessageRoomInfo() {
        guard let room = room else {
            return
        }
        let shared = GlobalVar.shared
        let rooms = shared.loginUser?.rooms
        shared.specificRoom = room
        shared.messageCollectionView = messageCollectionView
        shared.talkView = talkView
        
        if let index = rooms?.firstIndex(where: { $0.document_id == room.document_id }) {
            if let sendMessage = rooms?[index].send_message {
                textView.text = sendMessage
            }
        }
    }
    
    private func setCollectionViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCollectionViewTapped(_:)))
        messageCollectionView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onCollectionViewTapped(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let messageInputViewTouch = touch.location(in: messageInputView)
            let stickerPreviewTouch = touch.location(in: messageInputView.messageStickerPreview)
            
            if messageInputView.bounds.contains(messageInputViewTouch) {
                return
            } else if messageInputView.messageStickerPreview.bounds.contains(stickerPreviewTouch) {
                return
            } else {
                textView.resignFirstResponder()
            }
        }
    }
}

// navigation関連
extension MessageRoomView {
    
    private func setUpNavigation() {
        guard let room = room else {
            return
        }
        guard let partnerUser = room.partnerUser else {
            return
        }
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.isUserInteractionEnabled = true
        titleLabel.text = "" // messageRoomCustomが呼ばれたときにチラつくので空文字
        titleLabel.sizeToFit()
        
        navigationItem.titleView = titleLabel
        navigationController?.setNavigationBarHidden(false, animated: true) // ナビゲーションバーを表示する
        navigationItem.setHidesBackButton(true, animated: true) // ナビゲーションの戻るボタンを消す
        navigationController?.navigationBar.isTranslucent = false // ナビゲーションバーの透過させない
        hideNavigationBarBorderAndShowTabBarBorder() // ナビゲーションバーの設定
        navigationItem.titleView?.tintColor = .fontColor
        
        let backImage = UIImage(systemName: "chevron.backward")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action:#selector(messageListBack))
        navigationItem.leftBarButtonItem?.tintColor = .fontColor
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let isNotActivatedForPartner = partnerUser.is_activated == false
        let isDeletedForPartner = partnerUser.is_deleted == true
        let isNotUseful = isNotActivatedForPartner || isDeletedForPartner
        
        if isNotUseful {
            return
        }
        
        rightStackButton.tintColor = .black
        guideButton.tintColor = .black
        callButton.tintColor = .black
      
        rightStackButton.addTarget(self, action: #selector(onEllipsisButtonTapped), for: .touchUpInside)
        guideButton.addTarget(self, action: #selector(onTalkGuideButtonTapped), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(onCallButtonTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [
            rightStackButton.changeIntoBarItem(systemImage: "ellipsis"),
            guideButton.changeIntoBarItem(systemImage: "book.fill"),
            callButton.changeIntoBarItem(systemImage: "phone.fill"),
        ]
    }
    
    @objc private func messageListBack() {
        NotificationCenter.default.post(
            name: Notification.Name(NotificationName.MessageListBack.rawValue),
            object: self
        )
        navigationController?.popViewController(animated: true)
    }
}

// トークアドバイス
extension MessageRoomView {
    
    private func configureTalkView() {
        talkTitleHeight.constant = 40
        talkBottomView.isHidden = true
        talkBottomSpacerView.isHidden = false
        talkImageView.image = UIImage(systemName: "message.fill")
        talkTitleLabel.text = "話しかけてみましょう！"
        
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
    
    @objc private func didTaptalkViewCell(_ sender: UITapGestureRecognizer) {
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
        let model = getSendMessageModel(
            text: text,
            inputType: .talk,
            messageType: .talk,
            sourceType: nil,
            imageUrls: nil,
            messageId: UUID().uuidString
        )
        sendMessageToFirestore(model)
    }
}

// フレンド絵文字関連
extension MessageRoomView {
    
    // ⌛️は連続記録5回以上かつ40~48hやりとりがない場合に表示
    private func limitIconEnabled(_ room: Room, consectiveCount: Int?) -> Bool {
        let lastUpdatedEpochTime = Int(room.updated_at.seconds)
        let currentEpochTime = Int(Date().timeIntervalSince1970)
        let diffEposhTime = currentEpochTime - lastUpdatedEpochTime
        let minPeriodEpochTime = DateConst.hourInSeconds * 40
        let maxPeriodEpochTime = DateConst.hourInSeconds * 48
        guard let consectiveCount = consectiveCount else {
            return false
        }
       
        if consectiveCount >= 5 {
            if diffEposhTime >= minPeriodEpochTime {
                if diffEposhTime <= maxPeriodEpochTime {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // 連続記録に必要なepochtimeと連続カウントを取得更新している
    private func setConsectiveRallyRecord() {
        guard let room = room else { return }
        guard let roomId = room.document_id else { return }
        guard let partnerUserId = room.partnerUser?.uid else { return }
        guard let loginUserId = GlobalVar.shared.loginUser?.uid else { return }
        
        // 連続記録取得までの間に一瞬のラグがありユーザー名がチラつくので先に一度だけ呼んでおく
        messageRoomCustom(
            room: room,
            limitIconEnabled: limitIconEnabled(room, consectiveCount: GlobalVar.shared.consectiveCountDictionary[roomId]),
            consectiveCount: GlobalVar.shared.consectiveCountDictionary[roomId]
        )
        
        Task {
            do {
                let collection = db.collection("rooms")
                let document = try await collection.document(roomId).getDocument()
                let documentData = document.data()
                
                guard let lastCountAt = documentData?["last_consective_count_at"] as? Int else {
                    messageRoomCustom(
                        room: room,
                        limitIconEnabled: limitIconEnabled(room, consectiveCount: GlobalVar.shared.consectiveCountDictionary[roomId]),
                        consectiveCount: nil
                    )
                    GlobalVar.shared.consectiveCountDictionary[roomId] = 0
                    return
                }
                guard let count = documentData?["consective_count"] as? Int else {
                    messageRoomCustom(
                        room: room,
                        limitIconEnabled: limitIconEnabled(room, consectiveCount: GlobalVar.shared.consectiveCountDictionary[roomId]),
                        consectiveCount: nil
                    )
                    GlobalVar.shared.consectiveCountDictionary[roomId] = 0
                    return
                }
                
                let minPeriodEpochTime = lastCountAt + DateConst.dayInSeconds
                let periodEpochTime = DateConst.hourInSeconds * 48
                let limitEposhTime = lastCountAt + periodEpochTime
                let currentEpochTime = Int(Date().timeIntervalSince1970)
                let diffEposhTime = currentEpochTime - periodEpochTime
                
                var updateData: [String: Int] = [:]
                var _createdAtArray: [Int] = []
                var _creators: [String] = []
                
                // 連続記録が0の場合ラリーを検索して初期化
                if count == 0 {
                    roomMessages.forEach { message in
                        if diffEposhTime <= message.created_at.seconds {
                            _createdAtArray.append(Int(message.created_at.seconds))
                            _creators.append(message.creator)
                        }
                    }
                    
                    if _creators.contains(loginUserId) && _creators.contains(partnerUserId) {
                        guard let lastConsectiveCountAt = _createdAtArray.max() else {
                            return
                        }
                        let consectiveCount = 1
                        updateData["last_consective_count_at"] = lastConsectiveCountAt
                        updateData["consective_count"] = consectiveCount
                        try await db.collection("rooms").document(roomId).updateData(updateData)
                        messageRoomCustom(
                            room: room,
                            limitIconEnabled: limitIconEnabled(room, consectiveCount: GlobalVar.shared.consectiveCountDictionary[roomId]),
                            consectiveCount: consectiveCount
                        )
                        GlobalVar.shared.consectiveCountDictionary[roomId] = consectiveCount
                        return
                    }
                }
                
                // 最後のラリーから48h超えていたら連続記録をリセット
                if currentEpochTime >= limitEposhTime {
                    let consectiveCount = 0
                    updateData["last_consective_count_at"] = 0
                    updateData["consective_count"] = consectiveCount
                    try await db.collection("rooms").document(roomId).updateData(updateData)
                    messageRoomCustom(
                        room: room, limitIconEnabled: limitIconEnabled(room, consectiveCount: GlobalVar.shared.consectiveCountDictionary[roomId]),
                        consectiveCount: consectiveCount
                    )
                    GlobalVar.shared.consectiveCountDictionary[roomId] = consectiveCount
                    return
                }
                
                // 24h〜48hの間にラリーしているかを検索
                roomMessages.forEach { message in
                    if minPeriodEpochTime <= message.created_at.seconds && limitEposhTime >= message.created_at.seconds {
                        _createdAtArray.append(Int(message.created_at.seconds))
                        _creators.append(message.creator)
                    }
                }
                
                // 24h〜48hの間にラリーされていたら連続記録を更新
                if _creators.contains(loginUserId) && _creators.contains(partnerUserId) {
                    guard let lastConsectiveCountAt = _createdAtArray.max() else {
                        return
                    }
                    let consectiveCount = count + 1
                    updateData["last_consective_count_at"] = lastConsectiveCountAt
                    updateData["consective_count"] = consectiveCount
                    try await db.collection("rooms").document(roomId).updateData(updateData)
                    messageRoomCustom(
                        room: room,
                        limitIconEnabled: limitIconEnabled(room, consectiveCount: GlobalVar.shared.consectiveCountDictionary[roomId]),
                        consectiveCount: consectiveCount
                    )
                    GlobalVar.shared.consectiveCountDictionary[roomId] = consectiveCount
                    return
                }
                
                messageRoomCustom(
                    room: room,
                    limitIconEnabled: limitIconEnabled(room, consectiveCount: GlobalVar.shared.consectiveCountDictionary[roomId]),
                    consectiveCount: count
                )
            } catch {
                print("🔥アイコン表示データ取得に失敗")
            }
        }
    }
}

// 通話関連
extension MessageRoomView: CallViewControllerDelegate {
    
    @objc private func onCallButtonTapped() {
        if let callData = createCallData() {
            Task {
                do {
                    let enabled = try await callFunctionEnabled(callData.loginUser, partnerUser: callData.partnerUser, rallyNum: 5)
                    if !enabled {
                        showCallFunctionAlert(.notFunctionEnabled)
                        return
                    }
                    
                    let key = "isShowedPhoneTutorial"
                    let isShowedTutorial = UserDefaults.standard.bool(forKey: key) == true
                    if !isShowedTutorial {
                        textView.resignFirstResponder()
                        playTutorial(key: key, type: "phone")
                        return
                    }
                    
                    let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
                    let audioEnabled = audioStatus == .authorized
                    if !audioEnabled {
                        checkPermissionAudio()
                        return
                    }
                    
                    print("callData", callData.partnerName)
                    print("callData", callData.roomName)
                    print("callData", callData.skywayToken)
                    
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(endCall),
                        name: NSNotification.Name(NotificationName.EndCall.rawValue),
                        object: nil
                    )
                    showCallViewController(
                        callData.partnerName,
                        partnerIcon: callData.partnerIcon,
                        roomName: callData.roomName,
                        skywayToken: callData.skywayToken
                    )
                } catch {
                    showCallFunctionAlert(.missingData)
                }
            }
        }
    }
    
    private func createCallData() -> CallData? {
        guard let loginUser = GlobalVar.shared.loginUser else {
            showCallFunctionAlert(.missingData)
            return nil
        }
        guard let room = room else {
            showCallFunctionAlert(.missingData)
            return nil
        }
        guard let partnerUser = room.partnerUser else {
            showCallFunctionAlert(.missingData)
            return nil
        }
        guard let partnerIconUrl = URL(string: partnerUser.profile_icon_img) else {
            showCallFunctionAlert(.missingData)
            return nil
        }
        guard let roomName = room.document_id else {
            showCallFunctionAlert(.missingData)
            return nil
        }
        guard let skywayToken = skywayToken else {
            showCallFunctionAlert(.missingData)
            return nil
        }
        let imageView = UIImageView()
        imageView.setImage(withURL: partnerIconUrl)
        
        
        let data = CallData(
            loginUser: loginUser,
            partnerUser: partnerUser,
            partnerName: partnerUser.nick_name,
            partnerIcon: imageView,
            roomName: roomName,
            skywayToken: skywayToken
        )
        
        return data
    }
    
    private func callFunctionEnabled(_ loginUser: User, partnerUser: User, rallyNum: Int) async throws -> Bool {
        guard let roomId = room?.document_id else {
            throw NSError()
        }
        
        do {
            let collection = db.collection("rooms").document(roomId).collection("messages")
            let documents = try await collection.getDocuments(source: .default).documents
            var messages = [Message]()
            
            documents.forEach { document in
                let message = Message(document: document)
                messages.append(message)
            }
            
            let ownMessages = messages.filter({
                $0.creator == loginUser.uid
            })
            let otherMessages = messages.filter({
                $0.creator != loginUser.uid
            })
            let result = ownMessages.count >= rallyNum && otherMessages.count >= rallyNum
            
            return result
        } catch {
            throw error
        }
    }
    
    private func fetchSkyWayToken() {
        callButton.isEnabled = false
        let functions = Functions.functions()
        let currentEpochTime = Int(Date().timeIntervalSince1970)
        let dayInSeconds = 86400
        var updateData: [String: Any] = [:]
        guard let room = room else {
            return
        }
        
        // print("last_updated_at_for_skyway_token:", room.lastUpdatedAtForSkyWayToken)
        // print("next_update_at_for_skyway_token:", room.lastUpdatedAtForSkyWayToken + dayInSeconds)
        
        if (room.lastUpdatedAtForSkyWayToken + dayInSeconds) <= currentEpochTime {
            functions.httpsCallable("generateSkyWayAuthToken").call { result, error in
                if let error = error {
                    print("Fail fetchSkyWayToken.")
                    print(error)
                    print(error.localizedDescription)
                } else {
                    guard let token = result?.data as? String else {
                        return
                    }
                    guard let roomID = self.room?.document_id else {
                        return
                    }
                    let lastUpdatedAtForSkyWayToken = currentEpochTime
                    
                    updateData["skyway_token"] = token
                    updateData["last_updated_at_for_skyway_token"] = lastUpdatedAtForSkyWayToken
                    
                    self.skywayToken = token
                    self.room?.skywayToken = token
                    self.room?.lastUpdatedAtForSkyWayToken = lastUpdatedAtForSkyWayToken
                    self.db.collection("rooms").document(roomID).updateData(updateData)
                    self.callButton.isEnabled = true
                }
            }
        } else {
            skywayToken = room.skywayToken
            callButton.isEnabled = true
        }
    }
    
    private func showCallViewController(_ partnerName: String, partnerIcon: UIImageView, roomName: String, skywayToken: String) {
        callViewController = CallViewController()
        guard let callViewController = callViewController else {
            return
        }
        callViewController.delegate = self
        callViewController.iconImage = partnerIcon.image
        callViewController.partnerName = partnerName
        callViewController.skywayToken = skywayToken
        callViewController.roomName = roomName
        callViewController.modalPresentationStyle = .fullScreen
        
        present(callViewController, animated: true) {
            self.resetMessageAndCollectionView()
        }
    }
    
    private func showCallFunctionAlert(_ type: CallAlertType) {
        switch type {
        case .missingData:
            let alert = UIAlertController(title: "確認", message: "通話情報の取得に失敗しました。\n時間をおいて再度やり直してください。", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        case .notFunctionEnabled:
            let alert = UIAlertController(title: "確認", message: "通話機能はトークを5往復以上おこなってから利用することができます。", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        }
    }
    
    @objc private func endCall() {
        messageCollectionView.reloadData()
        
        callViewController?.dismiss(animated: true) {
            self.callViewController = nil
            self.messageInputView.isHidden = false
            self.scrollToBottom()
        }
    }
    
    @objc private func closedTutorial() {
        textView.resignFirstResponder()
    }
    
    func sendEndCallMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.messageInputView.isHidden = false
            let model = self.getSendMessageModel(
                text: "通話しました📞",
                inputType: .message,
                messageType: .text,
                sourceType: nil,
                imageUrls: nil,
                messageId: UUID().uuidString
            )
            self.sendMessageToFirestore(model)
        }
    }
}

// 自動メッセージ関連
extension MessageRoomView {
    // 自動メッセージ送信
    @objc private func autoMessageAction() {
        
        let autoMessage = (GlobalVar.shared.loginUser?.is_auto_message == true)
        let displayAutoMessage = (GlobalVar.shared.displayAutoMessage == true)
        let displayAutoMessageNum = UserDefaults.standard.integer(forKey: "display_auto_message_num")
        let displayAutoMessageRange = (displayAutoMessageNum < 2)
        let showAutoMessage = (autoMessage && displayAutoMessage && displayAutoMessageRange)
        if showAutoMessage {
            GlobalVar.shared.displayAutoMessage = false
            
            let displayAutoMessageNum = UserDefaults.standard.integer(forKey: "display_auto_message_num")
            
            UserDefaults.standard.set(displayAutoMessageNum + 1, forKey: "display_auto_message_num")
            UserDefaults.standard.synchronize()
            
            autoMessageMove()
        }
    }
}

// お話ガイド関連
extension MessageRoomView {
    
    private func customTalkGuideBtn() {
        guideButton.tintColor = (talkGuideStatus() ? .accentColor : .black)
    }
    
    @objc private func onTalkGuideButtonTapped() {
        talkGuideMove()
    }
}

// 違反勧誘関連
extension MessageRoomView {
    
    @objc private func onEllipsisButtonTapped() {
        showAlertList()
    }
    
    private func showAlertList() {
        var block = UIAlertAction(title: "ブロック", style: .default) { action in
            self.block()
        }
        var report = UIAlertAction(title: "違反報告", style: .default) { action in
            self.report()
        }
        var stop = UIAlertAction(title: "勧誘専用の報告", style: .default) { action in
            self.stop()
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
        
        block = customAlertAction(block, image: "nosign", color: .black)
        report = customAlertAction(report, image: "megaphone", color: .black)
        stop = customAlertAction(stop, image: "megaphone.fill", color: .red)
        
        let actions = [block, report, stop, cancel]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actions.forEach { action in
            alert.addAction(action)
        }
        
        present(alert, animated: true)
    }
    
    private func customAlertAction(_ action: UIAlertAction, image: String, color: UIColor) -> UIAlertAction {
        action.setValue(UIImage(systemName: image), forKey: "image")
        action.setValue(color, forKey: "imageTintColor")
        action.setValue(color, forKey: "titleTextColor")
        
        return action
    }
    
    private func block() {
        guard let currentUid = GlobalVar.shared.loginUser?.uid else { return }
        guard let partnerUser = room?.partnerUser else { return }
        let partnerId = partnerUser.uid
        let partnerName = partnerUser.nick_name
        
        let alert = UIAlertController(title: partnerName + "さんをブロックしますか？", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
        let block = UIAlertAction(title: "ブロック", style: .destructive, handler: { _ in
            self.showLoadingView(self.loadingView)
            self.firebaseController.block(loginUID: currentUid, targetUID: partnerId) { result in
                self.loadingView.removeFromSuperview()
                if result {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.alert(title: "ブロックに失敗しました", message: "不具合を運営に報告してください。", actiontitle: "OK")
                }
            }
        })
        
        alert.addAction(cancel)
        alert.addAction(block)
        
        present(alert, animated: true)
    }
    
    private func report() {
        guard let room = room else { return }
        let storyBoard = UIStoryboard.init(name: "ViolationView", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViolationView") as! ViolationViewController
        viewController.targetUser = room.partnerUser
        viewController.category = "room"
        viewController.violationedID = room.document_id ?? ""
        viewController.closure = { (flag: Bool) -> Void in
            if flag {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        present(viewController, animated: true) {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    private func stop() {
        guard let room = room else { return }
        let storyBoard = UIStoryboard.init(name: "StopView", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "StopView") as! StopViewController
        viewController.targetUser = room.partnerUser
        viewController.closure = { (flag: Bool) -> Void in
            if flag {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        present(viewController, animated: true) {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    private func cheackLaunchRoomCount() {
        guard let count = UserDefaults.standard.object(forKey: "roomLaunchedTimes") as? Int else {
            return
        }
        if count > 30 {
            presentReportAlert()
        } else {
            UserDefaults.standard.set(count + 1, forKey: "roomLaunchedTimes")
        }
    }

    private func presentReportAlert() {
        let alert = UIAlertController(
            title: "勧誘ユーザー通報のお願い",
            message: "Touchは友達作りを目的にしているアプリです。勧誘やその他の目的を持っているユーザーを発見した場合「通報」をお願いします。運営にて厳しい処理を行います。",
            preferredStyle: .alert
        )
        let ok = UIAlertAction(title: "OK", style: .default)

        let frame = CGRect(x: 10, y: 115, width: 250, height: 290)
        let imageView = UIImageView()
        imageView.frame = frame
        imageView.image = UIImage(named: "BlockImage")

        alert.view.addConstraint(
            NSLayoutConstraint(
                item: alert.view as Any,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 460
            )
        )
        alert.view.addSubview(imageView)
        alert.addAction(ok)

        present(alert, animated: true) {
            guard let roomId = self.room?.document_id else {
                return
            }
            guard let count = UserDefaults.standard.object(forKey: "roomLaunchedTimes") as? Int else {
                return
            }
            let logEventData: [String: Any] = ["roomID": roomId, "roomLaunchedTimes": count]
            Log.event(name: "showMessageRoomReportAlert", logEventData: logEventData)
            UserDefaults.standard.set(0, forKey: "roomLaunchedTimes")
        }
    }
}

// CollectionView関連
extension MessageRoomView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
                           OwnMessageCollectionViewImageCellDelegate,  OtherMessageCollectionViewCellDelegate,
                           OtherMessageCollectionViewImageCellDelegate, OtherMessageCollectionViewReplyCellDelegate,
                           OwnMessageCollectionViewStickerCellDelegate, OtherMessageCollectionViewStickerCellDelegate {
    
    private func seUpCollectionViewCell() {
        registerCustomCell(nibName: OwnMessageCollectionViewCell.nibName, cellIdentifier: OwnMessageCollectionViewCell.cellIdentifier)
        registerCustomCell(nibName: OwnMessageCollectionViewImageCell.nibName, cellIdentifier: OwnMessageCollectionViewImageCell.cellIdentifier)
        registerCustomCell(nibName: OwnMessageCollectionViewReplyCell.nibName, cellIdentifier: OwnMessageCollectionViewReplyCell.cellIdentifier)
        registerCustomCell(nibName: OwnMessageCollectionViewStickerCell.nibName, cellIdentifier: OwnMessageCollectionViewStickerCell.cellIdentifier)
        registerCustomCell(nibName: OtherMessageCollectionViewCell.nibName, cellIdentifier: OtherMessageCollectionViewCell.cellIdentifier)
        registerCustomCell(nibName: OtherMessageCollectionViewImageCell.nibName, cellIdentifier: OtherMessageCollectionViewImageCell.cellIdentifier)
        registerCustomCell(nibName: OtherMessageCollectionViewReplyCell.nibName, cellIdentifier: OtherMessageCollectionViewReplyCell.cellIdentifier)
        registerCustomCell(nibName: OtherMessageCollectionViewStickerCell.nibName, cellIdentifier: OtherMessageCollectionViewStickerCell.cellIdentifier)
        registerCustomCell(nibName: UnsendMessageCollectionViewCell.nibName, cellIdentifier: UnsendMessageCollectionViewCell.cellIdentifier)
    }
    
    private func registerCustomCell(nibName: String, cellIdentifier: String) {
        messageCollectionView.register(
            UINib(nibName: nibName, bundle: nil),
            forCellWithReuseIdentifier: cellIdentifier
        )
    }
    
    private func configureMessageCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.separatorConfiguration.color = .systemBackground
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let safeArea = windowScene?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets else {
            return
        }
        
        messageCollectionView.collectionViewLayout = layout
        messageCollectionView.delegate = self
        messageCollectionView.dataSource = self
        messageCollectionView.alwaysBounceVertical = true
        messageCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (safeArea.bottom + INPUT_VIEW_HEIGHT))
        
        // フルリプレイス1stリリースでは不要
        //let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        // longPressGesture.minimumPressDuration = 0.3
        // longPressGesture.delegate = self
        // messageCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    private func resetMessageAndCollectionView() {
        roomMessages = []
        messageCollectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge >= scrollView.contentSize.height - 50 {
            isScrollToBottomAfterKeyboardShowed = true
        } else {
            isScrollToBottomAfterKeyboardShowed = false
        }
        
        // 現在表示している最過去メッセージが表示されたら自動でさらに過去メッセージを取得する
        if scrollView.contentOffset.y == 0 {
            if isFetchPastMessages {
                isFetchPastMessages = false
                messageCollectionView.isScrollEnabled = false
                fetchPastMessageForFirestore()
                Log.event(name: "reloadMessageList")
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        customTalkGuideBtn()
        return sectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        guard let loginUser = GlobalVar.shared.loginUser else {
            return cell
        }
        guard let partnerUser = room?.partnerUser else {
            return cell
        }
        guard let message = roomMessages[safe:indexPath.row] else {
            return cell
        }
        
        if message.is_deleted {
            let id = UnsendMessageCollectionViewCell.cellIdentifier
            let unsendCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! UnsendMessageCollectionViewCell
            unsendCell.configure(room: room, message: message)
            
            return unsendCell
        }
        
        if loginUser.uid == message.creator {
            if message.type == .reply {
                let id = OwnMessageCollectionViewReplyCell.identifier
                let messageReplyCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! OwnMessageCollectionViewReplyCell
                messageReplyCell.configure(message, messages: roomMessages)
                
                return messageReplyCell
            } else if message.type == .sticker {
                let id = OwnMessageCollectionViewStickerCell.identifier
                let stickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! OwnMessageCollectionViewStickerCell
                stickerCell.configure(loginUser, message: message, delegate: self)
                
                return stickerCell
            }
            if message.photos.count != 0  {
                let id = OwnMessageCollectionViewImageCell.identifier
                let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! OwnMessageCollectionViewImageCell
                imageCell.delegate = self
                imageCell.configure(message)
                
                return imageCell
            } else {
                let id = OwnMessageCollectionViewCell.identifier
                let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! OwnMessageCollectionViewCell
                messageCell.configure(loginUser, message: message)
                
                return messageCell
            }
        } else {
            if message.type == .reply {
                let id = OtherMessageCollectionViewReplyCell.identifier
                let messageReplyCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! OtherMessageCollectionViewReplyCell
                messageReplyCell.delegate = self
                messageReplyCell.configure(message, messages: roomMessages, partnerUser: partnerUser)
                
                return messageReplyCell
            } else if message.type == .sticker {
                let id = OtherMessageCollectionViewStickerCell.cellIdentifier
                let stickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! OtherMessageCollectionViewStickerCell
                stickerCell.configure(partnerUser, message: message, delegate: self)
                
                return stickerCell
            }
            if message.photos.count != 0  {
                let id = OtherMessageCollectionViewImageCell.cellIdentifier
                let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! OtherMessageCollectionViewImageCell
                imageCell.delegate = self
                imageCell.configure(partnerUser, message: message)
                
                return imageCell
            } else {
                let id = OtherMessageCollectionViewCell.cellIdentifier
                let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! OtherMessageCollectionViewCell
                messageCell.delegate = self
                messageCell.configure(partnerUser, message: message)
                
                return messageCell
            }
        }
    }
    
    private func moveImageDetail(image: UIImage) {
        let storyBoard = UIStoryboard.init(name: "ImageDetailView", bundle: nil)
        let imageVC = storyBoard.instantiateViewController(withIdentifier: "ImageDetailView") as! ImageDetailViewController
        imageVC.pickedImage = image
        
        present(imageVC, animated: true) {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @objc private func showProfilePage() {
        guard let roomId = room?.document_id else {
            return
        }
        guard let partner = room?.partnerUser else {
            return
        }
        
        if partner.is_deleted {
            return
        }
        
        let logEventData: [String: Any] = ["roomID": roomId, "target": partner.uid]
        Log.event(name: "showAvatarProfile", logEventData: logEventData)
        
        textView.resignFirstResponder()
        
        let storyBoard = UIStoryboard.init(name: "ProfileDetailView", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ProfileDetailView") as! ProfileDetailViewController
        viewController.user = partner
        viewController.isViolation = false
        
        present(viewController, animated: true) {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func onOwnImageViewTapped(cell: OwnMessageCollectionViewImageCell, imageUrl: String) {
        if let url = URL(string: imageUrl) {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    moveImageDetail(image: image)
                } else {
                    self.alert(title: "画像の読み込みに失敗しました。", message: "", actiontitle: "OK")
                }
            } catch let error {
                print(error.localizedDescription)
                self.alert(title: "画像の読み込みに失敗しました。", message: "", actiontitle: "OK")
            }
        } else {
            self.alert(title: "画像の読み込みに失敗しました。", message: "", actiontitle: "OK")
        }
    }
    
    func onProfileIconTapped(cell: OtherMessageCollectionViewCell, user: User) {
        showProfilePage()
    }
    
    func onOtherImageViewTapped(cell: OtherMessageCollectionViewImageCell, imageUrl: String) {
        if let url = URL(string: imageUrl) {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    moveImageDetail(image: image)
                } else {
                    self.alert(title: "画像の読み込みに失敗しました。", message: "", actiontitle: "OK")
                }
            } catch let error {
                print(error.localizedDescription)
                self.alert(title: "画像の読み込みに失敗しました。", message: "", actiontitle: "OK")
            }
        } else {
            self.alert(title: "画像の読み込みに失敗しました。", message: "", actiontitle: "OK")
        }
    }
    
    func onProfileIconTapped(cell: OtherMessageCollectionViewImageCell, user: User) {
        showProfilePage()
    }
    
    func onProfileIconTapped(cell: OtherMessageCollectionViewReplyCell, user: User) {
        showProfilePage()
    }
    
    func onOwnStickerTapped(cell: OwnMessageCollectionViewStickerCell, stickerUrl: String) {
        showStickerInputView()
    }
    
    func onOtherStickerTapped(cell: OtherMessageCollectionViewStickerCell, stickerUrl: String) {
        showStickerInputView()
    }
    
    func onProfileIconTapped(cell: OtherMessageCollectionViewStickerCell, user: User) {
        showProfilePage()
    }

}

// メッセージ投稿UI関連
extension MessageRoomView {
    
    private func setUpMessageInputViewContainer() {
        setUpMessageInputView()
        
        if checkRoomActive(room: room) == false {
            setUpDisableLabel()
            return
        }
        
        setUpTextView()
        setUpCameraButton()
        setUpStampButton()
        setUpPlaceHolder()
        setUpSendButton()
        setUpTypingIndicator()
        // setUpReplyPreview() フルリプレイ1stリリースでは不要
        setUpStickerPreview()
    }
    
    private func setUpMessageInputView() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let safeArea = windowScene?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets else {
            return
        }
        safeAreaInsets = safeArea
        
        if let navigationBar = navigationController?.navigationBar {
            let frame = CGRect(
                x: 0,
                y: view.frame.height - navigationBar.frame.height - (safeArea.top + safeArea.bottom) - INPUT_VIEW_HEIGHT,
                width: view.frame.width,
                height: INPUT_VIEW_HEIGHT
            )
            let screenHeight = UIScreen.main.bounds.size.height
            let stickerPreviewFrame = CGRect(
                x: 0,
                y: -screenHeight * 0.2,
                width: view.frame.width,
                height: screenHeight * 0.2
            )
            messageInputView = MessageInputView(frame: frame, stickerPreviewFrame: stickerPreviewFrame)
            messageInputView.backgroundColor = .systemBackground
            view.addSubview(messageInputView)
            
            messageInputViewFrame = messageInputView.frame
            
            GlobalVar.shared.messageInputView = messageInputView
        }
    }

    private func setUpDisableLabel() {
        messageInputView.removeAllSubviews()
        let frame = CGRect(
            x: 0,
            y: 0,
            width: messageInputView.frame.width,
            height: messageInputView.frame.height
        )
        disableLabel.text = "退会済み"
        disableLabel.frame = frame
        disableLabel.tintColor = .fontColor
        disableLabel.textAlignment = .center
        disableLabel.backgroundColor = .clear
        disableLabel.font = UIFont.systemFont(ofSize: 16)
        messageInputView.addSubview(disableLabel)
    }
    
    private func setUpTextView() {
        let frame = CGRect(
            x: ((BUTTON_SIZE / 1.5) * 2) + (INPUT_VIEW_PADDING * 3),
            y: TEXT_VIEW_MARGIN,
            width: view.frame.width - ((BUTTON_SIZE / 1.5) * 3) - (INPUT_VIEW_PADDING * 5),
            height: TEXT_VIEW_HEIGHT
        )
        textView.frame = frame
        textView.font = UIFont.systemFont(ofSize: TEXT_VIEW_FONT_SIZE)
        textView.layer.cornerRadius = 10
        textView.delegate = self
        textView.backgroundColor = .textViewColor
        messageInputView.addSubview(textView)
        
        let user = GlobalVar.shared.loginUser
        let rooms = user?.rooms
        if let index = rooms?.firstIndex(where: { $0.document_id == room?.document_id }) {
            textView.text = GlobalVar.shared.loginUser?.rooms[index].send_message
        }
    }
    
    private func setUpPlaceHolder() {
        let frame = CGRect(
            x: 5,
            y: 0,
            width: 20,
            height: TEXT_VIEW_HEIGHT
        )
        placeHolder.frame = frame
        placeHolder.text = "Aa"
        placeHolder.textColor = .gray
        placeHolder.font = UIFont.systemFont(ofSize: TEXT_VIEW_FONT_SIZE)
        textView.addSubview(placeHolder)
    }
    
    private func setUpCameraButton() {
        let frame = CGRect(
            x: INPUT_VIEW_PADDING,
            y: textView.frame.maxY - (BUTTON_SIZE / 2) - INPUT_VIEW_PADDING,
            width: BUTTON_SIZE / 1.5,
            height: BUTTON_SIZE / 2
        )
        cameraButton.frame = frame
        cameraButton.tintColor = .darkGray
        cameraButton.backgroundColor = .clear
        cameraButton.contentMode = .scaleAspectFit
        cameraButton.contentHorizontalAlignment = .fill
        cameraButton.contentVerticalAlignment = .fill
        cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        cameraButton.addTarget(self, action: #selector(onCameraButtonTapped(_:)), for: .touchUpInside)
        messageInputView.addSubview(cameraButton)
    }
    
    private func setUpStampButton() {
        let frame = CGRect(
            x: cameraButton.frame.maxX + INPUT_VIEW_PADDING,
            y: textView.frame.maxY - (BUTTON_SIZE / 2) - INPUT_VIEW_PADDING,
            width: BUTTON_SIZE / 1.5,
            height: BUTTON_SIZE / 2
        )
        stampButton.frame = frame
        stampButton.setImage(UIImage(systemName: "face.smiling")?.withRenderingMode(.alwaysTemplate), for: .normal)
        stampButton.setImage(UIImage(systemName: "keyboard")?.withRenderingMode(.alwaysTemplate), for: .selected)
        stampButton.tintColor = .darkGray
        stampButton.backgroundColor = .clear
        stampButton.imageView?.contentMode = .scaleAspectFit
        stampButton.contentHorizontalAlignment = .fill
        stampButton.contentVerticalAlignment = .fill
        stampButton.addTarget(self, action: #selector(onStampButtonTapped(_:)), for: .touchUpInside)
        messageInputView.addSubview(stampButton)
        stampButton.isSelected = false
    }
    
    private func setUpSendButton() {
        let frame = CGRect(
            x: messageInputView.frame.width - (BUTTON_SIZE / 1.5) - INPUT_VIEW_PADDING,
            y: textView.frame.maxY - (BUTTON_SIZE / 2) - INPUT_VIEW_PADDING,
            width: BUTTON_SIZE / 1.5,
            height: BUTTON_SIZE / 2
        )
        sendButton.frame = frame
        sendButton.tintColor = .darkGray
        sendButton.backgroundColor = .clear
        stampButton.contentMode = .scaleAspectFit
        stampButton.contentHorizontalAlignment = .fill
        stampButton.contentVerticalAlignment = .fill
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.addTarget(self, action: #selector(onSendButtonTapped(_:)), for: .touchUpInside)
        
        if textView.text == "" {
            sendButton.isEnabled = false
            placeHolder.isHidden = false
        } else {
            sendButton.isEnabled = true
            placeHolder.isHidden = true
        }
        
        messageInputView.addSubview(sendButton)
    }
    
    private func setUpTypingIndicator() {
        if let _room = self.room {
            typingIndicatorView = TypingIndicatorView(frame: CGRect(x: 0, y: -25, width: view.bounds.width, height: 25), room: _room)
            if let _typingIndicatorView = typingIndicatorView {
                messageInputView.addSubview(_typingIndicatorView)
            }
        }
        typingIndicatorView?.indicatorView.stopAnimating()
        typingIndicatorView?.isHidden = true
    }
    
    private func setUpStickerPreview() {
        messageInputView.stickerDelegate = self
        messageInputView.setStickerPreview(active: false)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        keyboardFrame = keyboardInfo.cgRectValue
        drawMessageInputView()
        messageCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: messageInputView.frame.minY)
        
        if let lastRange = lastTextViewSelectRange {
            textView.selectedRange = lastRange
        }
        
        if isScrollToBottomAfterKeyboardShowed {
            scrollToBottom()
        }
        keyboardIsShown = true
    }
    
    @objc private func keyboardWillHide(_ notification: Notification?) {
        guard let messageInputViewFrame = messageInputViewFrame else {
            return
        }
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let safeArea = windowScene?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets else {
            return
        }
        
        messageInputView.frame = CGRect(
            x: messageInputViewFrame.origin.x,
            y: messageInputViewFrame.origin.y,
            width: messageInputView.frame.width,
            height: messageInputView.frame.height
        )
        messageCollectionView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height - (safeArea.bottom + INPUT_VIEW_HEIGHT)
        )
        textView.frame = CGRect(
            x: textView.frame.origin.x,
            y: textView.frame.origin.y,
            width: textView.frame.width,
            height: TEXT_VIEW_HEIGHT
        )
        initInputViewButtonFrame()
        
        if isCollectionViewAtBottom(messageCollectionView) {
            scrollToBottom()
        }
        
        keyboardIsShown = false
    }
    
    private func drawMessageInputView() {
        var height = textView.contentSize.height
        
        if height < MIN_TEXT_VIEW_HEIGHT {
            height = MIN_TEXT_VIEW_HEIGHT
        } else if MAX_TEXT_VIEW_HEIGHT < height {
            height = MAX_TEXT_VIEW_HEIGHT
        }
        
        if let keyboardFrame = keyboardFrame {
            textView.frame = CGRect(
                x: textView.frame.origin.x,
                y: textView.frame.origin.y,
                width: textView.frame.width,
                height: height
            )
            messageInputView.frame = CGRect(
                x: messageInputView.frame.origin.x,
                y: view.frame.height - keyboardFrame.size.height - (textView.frame.height + (TEXT_VIEW_MARGIN * 2)),
                width: view.frame.width,
                height: height + (TEXT_VIEW_MARGIN * 2)
            )
            messageCollectionView.frame = CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: messageInputView.frame.minY
            )
            initInputViewButtonFrame()
        }
    }
    
    private func initTextView() {
        placeHolder.isHidden = false
        sendButton.isEnabled = false
        textView.text = ""
        setMessageStorage(textView.text)
        textViewDidChange(textView)
    }
    
    private func initInputViewButtonFrame() {
        cameraButton.frame = CGRect(
            x: INPUT_VIEW_PADDING,
            y: textView.frame.maxY - (BUTTON_SIZE / 2) - INPUT_VIEW_PADDING,
            width: BUTTON_SIZE / 1.5,
            height: BUTTON_SIZE / 2
        )
        stampButton.frame = CGRect(
            x: cameraButton.frame.maxX + INPUT_VIEW_PADDING,
            y: textView.frame.maxY - (BUTTON_SIZE / 2) - INPUT_VIEW_PADDING,
            width: BUTTON_SIZE / 1.5,
            height: BUTTON_SIZE / 2
        )
        sendButton.frame = CGRect(
            x: messageInputView.frame.width - (BUTTON_SIZE / 1.5) - INPUT_VIEW_PADDING,
            y: textView.frame.maxY - (BUTTON_SIZE / 2) - INPUT_VIEW_PADDING,
            width: BUTTON_SIZE / 1.5,
            height: BUTTON_SIZE / 2
        )
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            sendButton.isEnabled = false
            placeHolder.isHidden = false
        } else {
            sendButton.isEnabled = true
            placeHolder.isHidden = true
        }
        lastTextViewSelectRange = textView.selectedRange
        drawMessageInputView()
        
        if isCollectionViewAtBottom(messageCollectionView) {
            scrollToBottom()
            return
        }
        
        // textViewの行数減少に合わせてcollectionViewも追従させる
        if textView.frame.height >= MAX_TEXT_VIEW_HEIGHT {
            messageCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: messageInputView.frame.minY)
        } else if textView.frame.height < beforeTextViewHeight {
            let currentOffset = messageCollectionView.contentOffset
            let point = CGPoint(x: currentOffset.x, y: currentOffset.y - 19)
            messageCollectionView.setContentOffset(point, animated: false)
            messageCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: messageInputView.frame.minY)
        }
        
        beforeTextViewHeight = textView.frame.height
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // textViewの改行に合わせてcollectionViewも追従させる
        if text == "\n" {
            let currentOffset = messageCollectionView.contentOffset
            let point = CGPoint(x: currentOffset.x, y: currentOffset.y + 19)
            
            if textView.frame.height < MAX_TEXT_VIEW_HEIGHT {
                messageCollectionView.setContentOffset(point, animated: false)
                messageCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: messageInputView.frame.minY)
            }
        }
        
        return true
    }
    
    @objc private func onCameraButtonTapped(_ sender: UIButton) {
        textView.resignFirstResponder()
        
        let selectAction = UIAlertAction(title: "ライブラリから写真を選ぶ", style: .default) { action in
            self.presentPicker()
        }
        let cameraAction = UIAlertAction(title: "カメラで写真を撮る", style: .default) { action in
            self.presentCamera()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default)
        
        let alert = UIAlertController(title: "送信する画像を選択してください", message: nil, preferredStyle: .actionSheet)
        alert.addAction(selectAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func onStampButtonTapped(_ sender: UIButton) {
        // deactivateTypingState() // フルリプレイス1stリリースでは不要
        switchSelectedStateAction()
    }
    
    @objc private func onSendButtonTapped(_ sender: UIButton) {
        // フルリプレイス1stリリースでは不要
        //        deactivateTypingState() // タイピング状態をOFF
        /* 1. 本人確認しているかをチェック */
        if adminCheckStatus() == false {
            return
        }
        //
        //        if replyIsSelected, let replyMessageID = replyMessageID {
        //            print("リプライ送信 ID:", replyMessageID)
        //
        //            let model = getSendMessageModel(
        //                text: textView.text,
        //                inputType: .replay,
        //                messageType: .reply,
        //                sourceType: nil,
        //                imageUrls: nil,
        //                messageId: replyMessageID
        //            )
        //            sendMessageToFirestore(model)
        //        } else {
        //            let model = getSendMessageModel(
        //                text: textView.text,
        //                inputType: .message,
        //                messageType: .text,
        //                sourceType: nil,
        //                imageUrls: nil,
        //                messageId: UUID().uuidString
        //            )
        //            sendMessageToFirestore(model)
        //        }
        
        /* 2. スタンプ送信かテキストメッセージ送信かを判定 */
        if messageStickerIsSelected {
            /* 3.a. スタンプ送信  */
            sendMessageSticker()
            
        } else {
            scrollToBottom()
            /* 3.b. テキストメッセージ送信  */
            let model = getSendMessageModel(
                text: textView.text,
                inputType: .message,
                messageType: .text,
                sourceType: nil,
                imageUrls: nil,
                messageId: UUID().uuidString
            )
            sendMessageToFirestore(model)
            // closeReplyPreview() フルリプレイス1stリリースでは不要
            initTextView()
            // 長文送信時にcollectionViewの最上部までスクロールする不具合を解消するための非同期（少し強引）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.scrollToBottom()
            }
        }
    }
}


//MARK: - Message Sticker

extension MessageRoomView: StickerKeyboardViewDelegate, MessageInputViewStickerDelegate {
    
    /// スタンプ用キーボードを表示させる
    private func showStickerInputView() {
        if  textView.inputView == nil {
            
            let stickerKeyboardView = StickerKeyboardView()
            var frame = stickerKeyboardView.frame
            frame.size.height = UIScreen.main.bounds.height * 0.35
            stickerKeyboardView.frame = frame
            stickerKeyboardView.delegate = self
            textView.inputView = stickerKeyboardView
            textView.reloadInputViews()
            stampButton.isSelected = true
            
            if !keyboardIsShown {
                textView.becomeFirstResponder(); keyboardIsShown = true
            }
        }
    }
    
    /// stickerInputButtonの選択状態に応じて、スタンプ用キーボードの表示・非表示を行う
    private func switchSelectedStateAction() {
        if stampButton.isSelected {
            textView.inputView = nil
            messageInputView.stickerPreviewImageView.image = nil
            selectedSticker = (nil, nil)
            messageInputView.setStickerPreview(active: false)
        } else {
            let stickerKeyboardView = StickerKeyboardView()
            var frame = stickerKeyboardView.frame
            frame.size.height = UIScreen.main.bounds.height * 0.35
            stickerKeyboardView.frame = frame
            stickerKeyboardView.delegate = self
            textView.inputView = stickerKeyboardView
        }
        
        textView.reloadInputViews()
        stampButton.isSelected.toggle()
        
        if !keyboardIsShown {
            textView.becomeFirstResponder(); keyboardIsShown = true
        }
    }
    
    /// スタンプのプレビューを閉じる
    func closeStickerPreview() {
        messageInputView.setStickerPreview(active: false)
        messageInputView.stickerPreviewImageView.image = nil
        selectedSticker = (nil, nil)
        if textView.text == "" {
            sendButton.isEnabled = false
        }
        messageStickerIsSelected = false
    }
    
    func didSelectMessageSticker(_ image: UIImage, identifier: String) {
        if selectedSticker.sticker == image {
            /* 同じスタンプをタップ2回目 */
            sendMessageSticker()
        } else {
            /* 1回目タップ or 違うスタンプをタップ */
            messageInputView.stickerPreviewImageView.image = image
            selectedSticker.sticker = image
            selectedSticker.identifier = identifier
            sendButton.isEnabled = true
            messageStickerIsSelected = true
            messageInputView.setStickerPreview(active: true)
        }
    }
    
    func didSelectMessageSticker(_ urlString: String) {
        // action
    }
    
    /// スタンプ機能でのエラーアラートを表示する
    private func showStickerErrorAlert(errorCase: Int) {
        let message = (errorCase == 0) ? "正常に処理できませんでした。\n運営にお問い合わせください。" : "スタンプのアップロードに失敗しました。\nアプリを再起動して再度実行をしてください。"
        let alert = UIAlertController(title: "スタンプ送信エラー", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            if errorCase == 0 { return }
            guard let weakSelf = self else { return }
            weakSelf.roomMessages.removeLast()
            weakSelf.messageCollectionView.reloadData()
            weakSelf.scrollToBottom()
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    /// ローカルへメッセージを反映させた後、Firebaseへのアップロードを行う
    func sendMessageSticker() {
        guard let selectedSticker = self.selectedSticker.sticker,
              let identifier = self.selectedSticker.identifier,
              let roomId = room?.document_id,
              let loginUser = GlobalVar.shared.loginUser,
              let partnerUser = room?.partnerUser else {
            showStickerErrorAlert(errorCase: 0)
            return
        }
        
        let localModel = MessageSendModel(
            text: "スタンプが送信されました",
            inputType: .sticker,
            messageType: .sticker,
            sourceType: nil,
            imageUrls: nil,
            sticker: selectedSticker,
            stickerIdentifier: identifier,
            messageId: UUID().uuidString
        )
        
        // 1. 先にローカルへメッセージを反映させる
        addLocalMessages(
            messageId: localModel.messageId,
            messageText: "",
            type: localModel.messageType,
            members: [loginUser.uid, partnerUser.uid],
            sendTime: Timestamp(),
            imageUrls: localModel.imageUrls,
            sticker: localModel.sticker
        )
        
        // 2. Storageへスタンプ画像をアップロードする
        uploadStickerToStrage(roomId, sticker: selectedSticker) { stickerUrl in
            let uploadModel = MessageSendModel(
                text: localModel.text,
                inputType: localModel.inputType,
                messageType: localModel.messageType,
                sourceType: localModel.sourceType,
                imageUrls: [stickerUrl],
                sticker: localModel.sticker,
                stickerIdentifier: identifier,
                messageId: localModel.messageId
            )
            // 3. URL取得後、Firestoreへメッセージをアップロードする
            self.sendMessageToFirestore(uploadModel)
        }
        
        closeStickerPreview()
    }
    
    /// スタンプをStorageへアップロードする。メタデータを作成する。
    private func uploadStickerToStrage(_ roomId: String, sticker: UIImage, completion: @escaping (String) -> Void) {
        let referenceName = "rooms/\(roomId)"
        let folderName = "messages"
        let messageId = UUID().uuidString
        
        let fileId = UUID().uuidString
        let fileName = "sticker_\(fileId).png"
        let metadata = [
            "type": "message",
            "room_id": roomId,
            "message_id": messageId,
            "file_id": fileId
        ]
        
        firebaseController.uploadStickerToFireStorage(
            sticker: sticker,
            referenceName: referenceName,
            folderName: folderName,
            fileName: fileName,
            customMetadata: metadata,
            completion: { result in
                completion(result)
            }
        )
    }
}

// メッセージ関連 --- 取得 ---
extension MessageRoomView {
    
    private func sortMessages(_ messages: [Message], sendAt: String) -> [Message] {
        let filterMessages = messages.filter({ elaspedTime.string(from: $0.created_at.dateValue()) == sendAt })
        let sortMessages = filterMessages.sorted(by: { $0.created_at.dateValue() < $1.created_at.dateValue() })
        
        return sortMessages
    }
    
    private func removeMessageRoomListener() {
        if let listener = listener {
            listener.remove()
            self.listener = nil
            print("MessageRoomView: リスナーをデタッチ！")
        }
    }
    
    private func fetchMessagesForFirestore() {
        guard let room = room else {
            return
        }
        guard let roomId = room.document_id else {
            return
        }
        
        roomMessages = []
        
        print("特定のメッセージルーム監視リスナーのアタッチ ルームID : \(roomId)")
        
        let collection = db.collection("rooms").document(roomId).collection("messages")
        let query = collection.order(by: "updated_at", descending: true).limit(to: 30)
        listener = query.addSnapshotListener { snapshots, error in
            if let error = error {
                print("メッセージ取得失敗:", error);
                return
            }
            
            guard let documents = snapshots?.documentChanges else {
                return
            }
            print("メッセージドキュメント数 : \(documents.count)")
            if self.lastDocument == nil {
                self.lastDocument = documents.last
            }
            
            if documents.count == 0 {
                self.talkView.isHidden = self.isHiddenTalkView(room: room, initFlg: true)
            } else {
                self.talkView.isHidden = true
            }
            
            documents.forEach { document in
                switch document.type {
                case .added:
                    self.addMessageDocument(document)
                    if self.isBackground { return } // background状態の場合既読をつけない
                    self.updateMessageReadFlug(room, messageDocument: document)
                case .modified:
                    // self.unsendRoomMessage(messageDocument: document) フルリプレイス1stリリースでは不要
                    // self.updateMessageReaction(messageDocument: document) フルリプレイス1stリリースでは不要
                    self.updateMessageReadFlug(room, messageDocument: document)
                case .removed:
                    print("メッセージを削除する:\(document.document.documentID)")
                }
            }
            
            if self.isBackground {
                return
            }
            
            self.scrollToBottom()
        }
    }
    
    private func fetchPastMessageForFirestore() {
        guard let room = room else {
            return
        }
        guard let roomId = room.document_id else {
            return
        }
        guard let lastDocument = lastDocument?.document else {
            messageCollectionView.isScrollEnabled = true
            isFetchPastMessages = true
            return
        }
        
        loadingLabel.isHidden = false
        
        let collection = db.collection("rooms").document(roomId).collection("messages")
        let query = collection.order(by: "updated_at", descending: true).limit(to: 30)
        query.start(afterDocument: lastDocument).getDocuments { snapshots, error in
            if let error = error {
                print("Error fetchPastMessage:", error)
                let alert = UIAlertController(title: "読み込み失敗", message: nil, preferredStyle: .alert)
                self.present(alert, animated: true) {
                    self.hideLoadingLabelAnimationAndUpdateFlug()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    alert.dismiss(animated: true)
                }
                return
            }
            
            guard let documentChanges = snapshots?.documentChanges else {
                return
            }
            self.lastDocument = nil
            self.lastDocument = documentChanges.last
            
            documentChanges.forEach { documentChange in
                let message = Message(document: documentChange.document)
                if self.roomMessages.firstIndex(where: { $0.document_id == message.document_id }) != nil {
                    return
                }
                self.roomMessages.insert(message, at: 0)
            }
            self.messageCollectionView.reloadData()
            self.messageCollectionView.scrollToItem(at: IndexPath(item: documentChanges.count, section: 0), at: .top, animated: false)
            
            self.hideLoadingLabelAnimationAndUpdateFlug()
        }
    }
    
    private func addMessageDocument(_ messageDocument: DocumentChange) {
        let document = messageDocument.document
        let message = Message(document: document)
        
        // すでに存在するメッセージの場合は追加しない
        if roomMessages.firstIndex(where: { $0.document_id == message.document_id }) != nil {
            return
        }
        
        roomMessages.insert(message, at: 0)
        roomMessages.sort { (m1, m2) -> Bool in
            let m1Date = m1.created_at.dateValue()
            let m2Date = m2.created_at.dateValue()
            
            return m1Date < m2Date
        }
    }
    
    private func updateMessageReadFlug(_ room: Room, messageDocument: DocumentChange) {
        guard let userId = GlobalVar.shared.loginUser?.uid else {
            return
        }
        guard let roomId = room.document_id else {
            return
        }
        let document = messageDocument.document
        let messageId = document.documentID
        let message = Message(document: document)
        let creator = message.creator
        
        if message.read == true {
            if let messageIndex = roomMessages.firstIndex(where: { $0.document_id == messageId }) {
                roomMessages[messageIndex].read = true  // 相手の既読フラグを更新
            }
        }
        
        let isUnreadMessage = userId != creator && message.read == false
        if isUnreadMessage {
            let collection = db.collection("rooms").document(roomId).collection("messages")
            collection.document(messageId).updateData(["read": true])
        }
        
        if !isAlreadyReloadDataForLocalMessage {
            UIView.performWithoutAnimation {
                messageCollectionView.reloadData()
            }
        } else {
            isAlreadyReloadDataForLocalMessage = false
        }
    }
    
    private func messageRead() {

        guard let roomID = room?.document_id else { return }
        guard let partnerUser = room?.partnerUser else { return }
        
        let partnerUID = partnerUser.uid
        
        db.collection("rooms").document(roomID).collection("messages").whereField("creator", isEqualTo: partnerUID).whereField("read", isEqualTo: false).getDocuments { [weak self] (messageSnapshots, err) in
            guard let weakSelf = self else { return }
            if let err = err { print("メッセージ情報の取得失敗: \(err)"); return }
            guard let messageDocuments = messageSnapshots?.documents else { return }
            
            let batch = weakSelf.db.batch()
            messageDocuments.forEach { messageDocument in
                let messageID = messageDocument.documentID
                let messageRef = weakSelf.db.collection("rooms").document(roomID).collection("messages").document(messageID)
                batch.updateData(["read": true], forDocument: messageRef)
            }
            
            batch.commit() { err in
                if let err = err {
                    print("既読をつけられませんでした。Error writing batch \(err)")
                } else {
                    print("全てに既読をつけました。Batch write succeeded.")
                }
            }
        }
    }
    
    private func hideLoadingLabelAnimationAndUpdateFlug() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            self.loadingLabel.alpha = 0
        } completion: { _ in
            self.messageCollectionView.isScrollEnabled = true
            self.isFetchPastMessages = true
            self.loadingLabel.isHidden = true
            self.loadingLabel.alpha = 0.7
        }
    }
}

// メッセージ関連 --- メッセージ送信 ---
extension MessageRoomView {
    
    private func getSendMessageModel(text: String, inputType: MessageInputType, messageType: CustomMessageType, sourceType: UIImagePickerController.SourceType?, imageUrls: [String]?, messageId: String) -> MessageSendModel {
        let model = MessageSendModel(
            text: text,
            inputType: inputType,
            messageType: messageType,
            sourceType: sourceType,
            imageUrls: imageUrls,
            sticker: nil,
            stickerIdentifier: nil,
            messageId: messageId
        )
        
        return model
    }
    
    private func sendMessageToFirestore(_ model: MessageSendModel) {
        guard let loginUser = GlobalVar.shared.loginUser else {
            return
        }
        guard let roomId = room?.document_id else {
            return
        }
        guard let partnerUser = room?.partnerUser else {
            return
        }
        let messageId = model.messageId
        let members = [loginUser.uid, partnerUser.uid]
        let sendTime = Timestamp()
        let messageType = model.messageType
        
        if model.messageType != .sticker {
            // Firestoreとの通信前にUIを更新することでスピーディーなUXを実現
            addLocalMessages(
                messageId: messageId,
                messageText: model.text,
                type: messageType,
                members: members,
                sendTime: sendTime,
                imageUrls: model.imageUrls,
                sticker: model.sticker
            )
        }
         
        let messageData: [String: Any] = [
            "room_id": roomId,
            "message_id": messageId,
            "text": model.text,
            "photos": model.imageUrls as Any,
            "sticker_identifier": model.stickerIdentifier as Any,
            "read": false,
            "members": members,
            "creator": loginUser.uid,
            "type": model.messageType.rawValue as Any,
            "unread_flg": true,
            "calc_unread_flg": true,
            "created_at": sendTime,
            "updated_at": sendTime
        ]
        db.collection("rooms").document(roomId).collection("messages").document(messageId).setData(messageData)
        
        let removedUser: [String] = []
        let latestMessageData:[String: Any] = [
            "latest_message_id": messageId,
            "latest_message": model.text,
            "latest_sender": loginUser.uid,
            "removed_user": removedUser,
            "unread_\(loginUser.uid)": 0,
            "unread_\(partnerUser.uid)": FieldValue.increment(Int64(1)),
            "creator": loginUser.uid,
            "updated_at": sendTime
        ]
        db.collection("rooms").document(roomId).updateData(latestMessageData)
        
        registNotificationEachUser(
            creator: loginUser.uid,
            members: members,
            roomID: roomId,
            messageID: messageId
        )
        
        let logEventData: [String: Any] = [
            "room_id": roomId,
            "message_id": messageId,
            "text": model.text as Any,
            "target": partnerUser.uid
        ]
        
        switch model.inputType {
        case .talk:
            Log.event(name: "sendMessageFromTalkView", logEventData: logEventData)
        case .camera:
            if model.sourceType == .photoLibrary {
                Log.event(name: "sendMessageFromPhotoLibraryInput", logEventData: logEventData)
            } else if model.sourceType == .camera {
                Log.event(name: "sendMessageFromCameraInput", logEventData: logEventData)
            }
        case .message:
            Log.event(name: "sendMessageFromMessageInput", logEventData: logEventData)
        case .replay:
            Log.event(name: "sendMessageFromMessageReply", logEventData: logEventData)
        case .sticker:
            Log.event(name: "sendMessageFromMessageSticker", logEventData: logEventData)
        }
        
        #if PROD
        Task {
            let _ = try await callFunctionEnabled(loginUser, partnerUser: partnerUser, rallyNum: 1)
            reviewAlert(alertType: "message")
        }
        #endif
    }
    
    private func addLocalMessages(messageId: String, messageText: String, type: CustomMessageType, members: [String], sendTime: Timestamp, imageUrls: [String]?, sticker: UIImage?) {
        
        guard let loginUser = GlobalVar.shared.loginUser, let roomId = room?.document_id else {
            return
        }
        
        // すでに存在している場合はスキップ
        if roomMessages.firstIndex(where: {$0.document_id == messageId}) != nil {
            return
        }
        
        var message: Message?
        
        switch type {
        case .image:
            message = Message(room_id: roomId, text: "画像が送信されました。", photos: imageUrls ?? [], sticker: sticker, stickerIdentifier: "", read: false, creator: loginUser.uid, members: members, type: .image, created_at: sendTime, updated_at: sendTime, is_deleted: false, reactionEmoji: "", reply_message_id: "", document_id: messageId)
        case .sticker:
            message = Message(room_id: roomId, text: "スタンプが送信されました。", photos: imageUrls ?? [], sticker: sticker, stickerIdentifier: "", read: false, creator: loginUser.uid, members: members, type: .sticker, created_at: sendTime, updated_at: sendTime, is_deleted: false, reactionEmoji: "", reply_message_id: "", document_id: messageId)
        case .text:
            message = Message(room_id: roomId, text: messageText, photos: imageUrls ?? [], sticker: sticker, stickerIdentifier: "", read: false, creator: loginUser.uid, members: members, type: .text, created_at: sendTime, updated_at: sendTime, is_deleted: false, reactionEmoji: "", reply_message_id: "", document_id: messageId)
        case .talk:
            message = Message(room_id: roomId, text: messageText, photos: imageUrls ?? [], sticker: sticker, stickerIdentifier: "", read: false, creator: loginUser.uid, members: members, type: .talk, created_at: sendTime, updated_at: sendTime, is_deleted: false, reactionEmoji: "", reply_message_id: "", document_id: messageId)
        case .reply:
            // 処理 //
            break
        }
        
        guard let _message = message else {
            return
        }
        
        UIView.performWithoutAnimation {
            self.messageCollectionView.performBatchUpdates({
                self.roomMessages.insert(_message, at: roomMessages.count)
                self.messageCollectionView.reloadSections(IndexSet(integer: 0))
            }, completion: { _ in
                self.isAlreadyReloadDataForLocalMessage = true
                self.scrollToBottom()
                // 長文送信時にcollectionViewの最上部までスクロールする不具合を解消するための非同期（少し強引）
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.scrollToBottom()
                }
            })
        }
    }
    
    private func setMessageStorage(_ text: String?) {
        let user = GlobalVar.shared.loginUser
        let rooms = user?.rooms
        
        if let index = rooms?.firstIndex(where: { $0.document_id == room?.document_id }) {
            rooms?[index].send_message = text
            textView.text = text
        }
    }
}

// メッセージ関連 --- 画像送信 ---
extension MessageRoomView: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate {
    
    private func uploadImageStrage(_ roomId: String, images: [UIImage], completion: @escaping ([String]) -> Void) {
        guard images.count > 0,
              let currentUid = GlobalVar.shared.loginUser?.uid else {
            self.customAlert(alertType: .notReadFile)
            return
        }
        let referenceName = "rooms/\(roomId)"
        let folderName = "messages"
        let messageId = UUID().uuidString
        var imageUrls: [String] = []
        
        Task {
            
            await images.enumerated().asyncForEach { index, image in
                let fileId = UUID().uuidString
                let fileName = "img_\(fileId).jpg"
                let metadata = [
                    "type": "message",
                    "room_id": roomId,
                    "message_id": messageId,
                    "file_id": fileId
                ]
                
                do {
                    if let imageUrl = try await firebaseController.asyncUploadJPEGImageToStorage(image: image, compressionQuality: 0.05, creator: currentUid, referenceName: referenceName, folderName: folderName, fileName: fileName, customMetadata: metadata) {
                        imageUrls.append(imageUrl)
                    }
                    
                    completion(imageUrls)
                } catch {
                    print("Failure to get Image with", error)
                    self.customAlert(alertType: .notReadFile)
                }
            }
        }
    }
    
    private func presentPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .any(of: [.images])
        configuration.preferredAssetRepresentationMode = .current
        configuration.selection = .ordered
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }
    
    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        
        present(picker, animated: true) {
            self.resetMessageAndCollectionView()
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if results.isEmpty {
            picker.dismiss(animated: true)
            return
        }
        
        var selectionAssetIdentifiers = [PHPickerResult]()
        var selectPickerImages = [UIImage]()
        let alert = UIAlertController(title: "確認", message: "選択した画像を送信しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            Task {
                self.showLoadingView(self.loadingView)
                
                await results.asyncForEach { result in
                    selectionAssetIdentifiers.append(result)
                }

                let itemProviders = selectionAssetIdentifiers.compactMap { $0.itemProvider }.filter { $0.canLoadObject(ofClass: UIImage.self)}
                if itemProviders.isEmpty {
                    picker.dismiss(animated: true)
                    self.customAlert(alertType: .emptyFile)
                    return
                }

                await itemProviders.asyncForEach { itemProvider in
                    do {
                        let itemProviderImage = try await itemProvider.loadObject(ofClass: UIImage.self)
                        if let image = itemProviderImage as? UIImage {
                            if let resizedImage = image.resized(size: CGSize(width: 400, height: 400)) {
                                selectPickerImages.append(resizedImage)
                            } else {
                                selectPickerImages.append(image)
                            }
                        }
                    } catch {
                        print("Failure to get Image with", error)
                        picker.dismiss(animated: true)
                        self.customAlert(alertType: .notReadFile)
                    }
                }

                if selectPickerImages.isEmpty {
                    picker.dismiss(animated: true)
                    self.customAlert(alertType: .emptyFile)
                    return
                }
                
                guard let roomId = self.room?.document_id else {
                    picker.dismiss(animated: true)
                    self.customAlert(alertType: .nonDocumentID)
                    return
                }
                // FIXME: thumbnail 1/2
                self.uploadImageStrage(roomId, images: selectPickerImages) { imageUrls in
                    let model = self.getSendMessageModel(
                        text: "画像が送信されました",
                        inputType: .camera,
                        messageType: .image,
                        sourceType: .photoLibrary,
                        imageUrls: imageUrls,
                        messageId: UUID().uuidString
                    )
                    self.sendMessageToFirestore(model)
                    self.loadingView.removeFromSuperview()
                }
                
                self.textView.becomeFirstResponder()
                picker.dismiss(animated: true)
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        picker.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var images: [UIImage] = []
        
        initTextView()
        textView.becomeFirstResponder()
        picker.dismiss(animated: true)
        
        guard let roomId = room?.document_id else {
            customAlert(alertType: .nonDocumentID)
            return
        }
        
        showLoadingView(loadingView)
        
        if let image = info[.originalImage] as? UIImage {
            let size = CGSize(width: 400, height: 400)
            if let resizedImage = image.resized(size: size) {
                images.append(resizedImage)
            } else {
                images.append(image)
            }
        }
        
        uploadImageStrage(roomId, images: images) { imageUrls in
            let model = MessageSendModel(
                text: "画像が送信されました",
                inputType: .camera,
                messageType: .image,
                sourceType: picker.sourceType,
                imageUrls: imageUrls,
                sticker: nil,
                stickerIdentifier: nil,
                messageId: UUID().uuidString
            )
            self.sendMessageToFirestore(model)
            self.loadingView.removeFromSuperview()
        }
    }
    
    private func customAlert(alertType: SendMessageAlertType) {
            
        loadingView.removeFromSuperview()
            
        switch alertType {
        case .nonDocumentID:
            let title = "送信失敗"
            let message = "送信対象のルームが存在しないため送信できませんでした。"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case .overFileSize:
            let title = "送信失敗"
            let message = "送信するファイルサイズを200MB以下にして送信してください。"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case .emptyFile:
            let title = "送信失敗"
            let message = "送信するファイルが適切に送信できませんでした。再送信をお願いします。"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case .notReadFile:
            let title = "送信失敗"
            let message = "送信するファイルが読み込めませんでした"
            alert(title: title, message: message, actiontitle: "OK")
            break
        }
    }
}

// ---------- フルリプレイス1stリリースでは不要なのでコメントアウト ----------

// メッセージ関連 --- 送信取り消し ---
//extension MessageRoomView {
//
//    // 編集されたメッセージが送信取り消しされたかを判定し、された場合はプロパティの更新とUIの再構築を行う。
//    private func unsendRoomMessage(messageDocument: DocumentChange) {
//        let messageDocument = messageDocumentChange.document
//        let message = Message(document: messageDocument)
//        // is_deletedで判定
//        guard message.is_deleted,
//              let messageId = message.document_id else { return }
//
//        if let unsendedMessageIndex = roomMessages.firstIndex(where: {$0.document_id == messageId}),
//           let localMessage = roomMessages[safe: unsendedMessageIndex] {
//            // ローカルに存在する変更前と同じ値ならここでスキップ
//            if localMessage.is_deleted { return }
//            // ローカルのMessageを更新
//            localMessage.is_deleted = true
//            roomMessages[unsendedMessageIndex] = localMessage
//
//            DispatchQueue.main.async {
//                self.messageCollectionView.reloadData()
//                self.updateLatestMessage(roomId: message.room_id, updatedMessageId: messageId)
//            }
//        }
//    }
//
//    // 送信取り消しがあった場合、最新のメッセージの情報を更新する
//    private func updateLatestMessage(roomId: String, updatedMessageId: String) {
//        // roomの最新のメッセージと一致しない場合はスキップする
//        guard room?.latest_message_id != updatedMessageId else { return }
//
//        let collection = db.collection("rooms").document(roomId).collection("messages")
//        let limit = collection.whereField("is_deleted", isEqualTo: false).order(by: "created_at", descending: true).limit(to: 1)
//        limit.getDocuments { [weak self] messageSnapshots, error in
//
//            guard let weakSelf = self else { return }
//            if let err = error { print("roomId:\(roomId) - LatestMessage情報の取得失敗: \(err)"); return }
//            guard let messageDocument = messageSnapshots?.documents[safe: 0] else { return }
//            let updatedLatestMessage = Message(document: messageDocument)
//            guard let updatedLatestMessageId = updatedLatestMessage.document_id else { return }
//
//            switch updatedLatestMessage.type {
//            case .text:
//                let latestMessageData = [
//                    "latest_message_id": updatedLatestMessageId,
//                    "latest_message": updatedLatestMessage.text,
//                    "latest_sender": updatedLatestMessage.creator,
//                    "updated_at": updatedLatestMessage.created_at
//                ] as [String : Any]
//                weakSelf.db.collection("rooms").document(roomId).updateData(latestMessageData)
//            case.image:
//                let latestMessageData = [
//                    "latest_message_id": updatedLatestMessageId,
//                    "latest_message": "画像が送信されました",
//                    "latest_sender": updatedLatestMessage.creator,
//                    "updated_at": updatedLatestMessage.created_at
//                ] as [String : Any]
//                weakSelf.db.collection("rooms").document(roomId).updateData(latestMessageData)
//            case.sticker:
//                let latestMessageData = [
//                    "latest_message_id": updatedLatestMessageId,
//                    "latest_message": "スタンプが送信されました",
//                    "latest_sender": updatedLatestMessage.creator,
//                    "updated_at": updatedLatestMessage.created_at
//                ] as [String : Any]
//                weakSelf.db.collection("rooms").document(roomId).updateData(latestMessageData)
//            default:
//                break
//            }
//        }
//    }
//
//    // 編集されたメッセージのリアクションが変更されたかを判定し、された場合はプロパティの更新とUIの再構築を行う。
//    private func updateMessageReaction(messageDocument: DocumentChange) {
//        let messageDocument = messageDocumentChange.document
//        let message = Message(document: messageDocument)
//
//        // Messageのdocument_idから該当のメッセージを検索し、更新したMessageと入れ替える
//        if let messageId = message.document_id,
//           let updateMessageIndex = roomMessages.firstIndex(where: {$0.document_id == messageId}),
//           let localMessage = roomMessages[safe: updateMessageIndex] {
//            // ローカルに存在する変更前と同じ値ならここでスキップ
//            if localMessage.reactionEmoji == message.reactionEmoji { return }
//            // ローカルのMessageを更新
//            localMessage.reactionEmoji = message.reactionEmoji
//            roomMessages[updateMessageIndex] = localMessage
//
//            DispatchQueue.main.async {
//                if let _reactionIndexPath = self.reactionIndexPath {
//                    self.messageCollectionView.performBatchUpdates({
//                        self.messageCollectionView.reloadItems(at: [_reactionIndexPath])
//                    })
//                } else {
//                    self.messageCollectionView.reloadData()
//                }
//            }
//        }
//    }
//}

// Popover関連
//extension MessageRoomView: UIPopoverPresentationControllerDelegate, MessagePopMenuViewControllerDelegate, UIGestureRecognizerDelegate {
//
//    // ロングプレスしたmessageCollectionViewのIndexPathを取得する。
//    @objc private func longPressGesture(_ sender: UILongPressGestureRecognizer) {
//        guard sender.state == .began, sender.state != .changed,
//              let indexPath = self.messageCollectionView.indexPathForItem(at: sender.location(in: self.messageCollectionView)) else { return }
//        self.selectedIndexPath = indexPath
//        self.presentPopover(indexPath: indexPath)
//    }
//
//    // タップイベントの干渉の際に必要
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return gestureRecognizer.shouldRequireFailure(of: otherGestureRecognizer)
//    }
//
//    // 取得したIndexPathから暫定的なContainerViewの位置を計算し、Popoverを表示する
//    private func presentPopover(indexPath: IndexPath) {
//        // メッセージ・セルの取得
//        let section = indexPath.section
//        let index = indexPath.row
//        guard let loginUser = GlobalVar.shared.loginUser else { selectedIndexPath = nil; return }
//        let messagesSendAt = messageSendTimes(messages: roomMessages)
//        guard let messageSendAt = messagesSendAt[safe: section] else { return }
//        let sortMessages = sortMessages(roomMessages, sendAt: messageSendAt)
//
//        guard let message = sortMessages[safe: index],
//              !message.is_deleted,
//              let currentCell = messageCollectionView.cellForItem(at: indexPath) else { selectedIndexPath = nil; return }
//
//        // indexPathでのセルの画面上の位置
//        var cellPosition: CGRect {
//            let point = CGPoint(x: currentCell.frame.origin.x - messageCollectionView.contentOffset.x, y: currentCell.frame.origin.y - messageCollectionView.contentOffset.y)
//            let size = currentCell.bounds.size
//            return CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
//        }
//
//        // 位置・範囲内に存在するかの判定
//        let isLoginUser = loginUser.uid == message.creator
//        let isOutOfRange = cellPosition.height > (messageCollectionView.frame.height - 300)
//        // メッセージタイプの判定
//        let type = message.type
//        guard type == .text || type == .image || type == .reply else { selectedIndexPath = nil; return }
//
//        /* 1. Messageの大きさが範囲内か確認 */
//        if !isOutOfRange {
//            // 上向きか下向きかを判定
//            let isUpper = cellPosition.minY <= messageCollectionView.frame.minY + 150
//            // 暫定的なContainerViewのframe
//            let x = isLoginUser ? cellPosition.minX + self.messageCollectionView.frame.width * 0.5 : cellPosition.minX
//            let sourceRect = CGRect(x: x, y: cellPosition.minY + messageCollectionView.contentOffset.y, width: messageCollectionView.frame.width * 0.5, height: cellPosition.height)
//
//            let storyboard = UIStoryboard(name: MessagePopMenuViewController.storyboardName, bundle: nil)
//            let popMenuVC = storyboard.instantiateViewController(identifier: MessagePopMenuViewController.storybaordId) { coder in
//                return MessagePopMenuViewController(coder: coder, isLoginUser: isLoginUser, isUpper: isUpper, type: type)
//            }
//            popMenuVC.delegate = self
//            popMenuVC.modalPresentationStyle = .popover
//            popMenuVC.popoverPresentationController?.sourceView = messageCollectionView
//            popMenuVC.popoverPresentationController?.sourceRect = sourceRect
//            popMenuVC.popoverPresentationController?.permittedArrowDirections = isUpper ? .up : .down
//            popMenuVC.popoverPresentationController?.popoverBackgroundViewClass = MessagePopoverBackgroundView.self
//            popMenuVC.popoverPresentationController?.delegate = self // iPhone で Popover を表示するために必要
//
//            present(popMenuVC, animated: true)
//
//        } else {
//
//            let minYThreshold = messageCollectionView.frame.minY + 180
//            let maxYThreshold = messageCollectionView.frame.maxY - 180
//            let minYInThreshold = cellPosition.minY >= minYThreshold && cellPosition.minY <= maxYThreshold
//            let maxYInThreshold = cellPosition.maxY >= minYThreshold && cellPosition.maxY <= maxYThreshold
//            let isWithinThreshold = minYInThreshold || maxYInThreshold
//
//            /* 2.a. 上下どちらかにPopMenuを表示できる範囲内に存在しているか判定 */
//            if isWithinThreshold {
//                // 上向きか下向きかを判定
//                let isUpper = maxYInThreshold
//                // 暫定的なContainerViewのframe
//                let x = isLoginUser ? cellPosition.minX + self.messageCollectionView.frame.width * 0.5 : cellPosition.minX
//                let sourceRect = CGRect(x: x, y: cellPosition.minY + messageCollectionView.contentOffset.y, width: messageCollectionView.frame.width * 0.5, height: cellPosition.height)
//
//                let storyboard = UIStoryboard(name: MessagePopMenuViewController.storyboardName, bundle: nil)
//                let popMenuVC = storyboard.instantiateViewController(identifier: MessagePopMenuViewController.storybaordId) { coder in
//                    return MessagePopMenuViewController(coder: coder, isLoginUser: isLoginUser, isUpper: isUpper, type: type)
//                }
//                popMenuVC.delegate = self
//                popMenuVC.modalPresentationStyle = .popover
//                popMenuVC.popoverPresentationController?.sourceView = messageCollectionView
//                popMenuVC.popoverPresentationController?.sourceRect = sourceRect
//                popMenuVC.popoverPresentationController?.permittedArrowDirections = isUpper ? .up : .down
//                popMenuVC.popoverPresentationController?.popoverBackgroundViewClass = MessagePopoverBackgroundView.self
//                popMenuVC.popoverPresentationController?.delegate = self // iPhone で Popover を表示するために必要
//
//                present(popMenuVC, animated: true)
//
//            } else {
//                /* 2.b. 上下どちらかにPopMenuを表示できる範囲内に存在していない場合は中央に表示 */
//                if cellPosition.midY > 0 && cellPosition.midY < messageCollectionView.frame.maxY {
//                    let x = isLoginUser ? cellPosition.minX + self.messageCollectionView.frame.width * 0.5 : cellPosition.minX
//                    let sourceRect = CGRect(x: x, y: cellPosition.midY + messageCollectionView.contentOffset.y, width: messageCollectionView.frame.width * 0.5, height: 1.0)
//
//                    let storyboard = UIStoryboard(name: MessagePopMenuViewController.storyboardName, bundle: nil)
//                    let popMenuVC = storyboard.instantiateViewController(identifier: MessagePopMenuViewController.storybaordId) { coder in
//                        return MessagePopMenuViewController(coder: coder, isLoginUser: isLoginUser, isUpper: false, type: type)
//                    }
//                    popMenuVC.delegate = self
//                    popMenuVC.modalPresentationStyle = .popover
//                    popMenuVC.popoverPresentationController?.sourceView = messageCollectionView
//                    popMenuVC.popoverPresentationController?.sourceRect = sourceRect
//                    popMenuVC.popoverPresentationController?.permittedArrowDirections = .down
//                    popMenuVC.popoverPresentationController?.popoverBackgroundViewClass = MessagePopoverBackgroundView.self
//                    popMenuVC.popoverPresentationController?.delegate = self // iPhone で Popover を表示するために必要
//
//                    present(popMenuVC, animated: true)
//                } else {
//                    /* 2.c. 範囲外 */
//                    selectedIndexPath = nil
//                    return
//                }
//            }
//        }
//    }
//
//    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
//        return .none
//    }
//
//    func replyButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController) {
//        print("reply button pressed")
//        messagePopMenuViewController.dismiss(animated: true)
//    }
//
//    func copyButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController) {
//        print("copy button pressed")
//        messagePopMenuViewController.dismiss(animated: true)
//    }
//
//    func showImageButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController) {
//        print("show image button pressed")
//        messagePopMenuViewController.dismiss(animated: true)
//    }
//
//    func unsendButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController) {
//        guard let _selectedIndexPath = selectedIndexPath else {
//            selectedIndexPath = nil
//            messagePopMenuViewController.dismiss(animated: true)
//            return
//        }
//
//        let section = _selectedIndexPath.section
//        let index = _selectedIndexPath.row
//        let messagesSendAt = messageSendTimes(messages: roomMessages)
//        guard let messageSendAt = messagesSendAt[safe: section] else {
//            selectedIndexPath = nil
//            messagePopMenuViewController.dismiss(animated: true)
//            return
//        }
//        let sortMessages = sortMessages(roomMessages, sendAt: messageSendAt)
//        // Firestoreへメッセージ情報の更新を行う
//        if let messageId = sortMessages[safe: index]?.document_id, let roomId = self.room?.document_id {
//            db.collection("rooms").document(roomId).collection("messages").document(messageId).updateData(["is_deleted" : true]) { error in
//                if let _error = error {
//                    print("メッセージ情報の更新に失敗しました: \(_error)")
//                    return
//                }
//            }
//        }
//        selectedIndexPath = nil
//        messagePopMenuViewController.dismiss(animated: true)
//    }
//
//    func reactionButtonPressed(_ messagePopMenuViewController: MessagePopMenuViewController, didSelectedReaction: String) {
//        guard let _selectedIndexPath = selectedIndexPath, !didSelectedReaction.isEmpty else {
//            selectedIndexPath = nil
//            messagePopMenuViewController.dismiss(animated: true)
//            return
//        }
//        // メッセージの取得
//        let section = _selectedIndexPath.section
//        let index = _selectedIndexPath.row
//
//        reactionIndexPath = IndexPath(row: index, section: section)
//
//        let messagesSendAt = messageSendTimes(messages: roomMessages)
//        guard let messageSendAt = messagesSendAt[safe: section] else {
//            selectedIndexPath = nil
//            messagePopMenuViewController.dismiss(animated: true)
//            return
//        }
//        let sortMessages = sortMessages(roomMessages, sendAt: messageSendAt)
//
//        if let selectedMessage = sortMessages[safe: index],
//           let messageId = sortMessages[safe: index]?.document_id,
//           let roomId = self.room?.document_id {
//            // 同じリアクションを選択した場合は取り消す
//            let uploadReaction = (selectedMessage.reactionEmoji == didSelectedReaction) ? "" : didSelectedReaction
//            // Firestoreへメッセージ情報の更新を行う
//            db.collection("rooms").document(roomId).collection("messages").document(messageId).updateData(["reaction": uploadReaction]) { [weak self] error in
//                if let _error = error, let self {
//                    print("メッセージ情報の更新に失敗: \(_error)")
//                    selectedIndexPath = nil
//                    messagePopMenuViewController.dismiss(animated: true)
//                    return
//                }
//            }
//        }
//        selectedIndexPath = nil
//        messagePopMenuViewController.dismiss(animated: true)
//    }
//}

// リプライ関連
//extension MessageRoomView {
//
//    private func setUpReplyPreview() {
//        // リプライプレビュー 全体
//        replyPreview.isHidden = true
//        replyPreview.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: REPRY_VIEW_HEIGHT)
//        replyPreview.backgroundColor = .white
//        replyPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeReplyPreview)))
//        replyPreview.translatesAutoresizingMaskIntoConstraints = true
//        replyPreview.heightAnchor.constraint(equalToConstant: REPRY_VIEW_HEIGHT).isActive = true
//        // リプライププレビュー アイコン画像
//        replyPreviewIconImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        replyPreviewIconImageView.clipsToBounds = true
//        replyPreviewIconImageView.rounded()
//        replyPreviewIconImageView.contentMode = .scaleAspectFill
//        replyPreviewIconImageView.isUserInteractionEnabled = true
//        replyPreview.addSubview(replyPreviewIconImageView)
//        replyPreviewIconImageView.translatesAutoresizingMaskIntoConstraints = false
//        replyPreviewIconImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
//        replyPreviewIconImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
//        replyPreviewIconImageView.leftAnchor.constraint(equalTo: replyPreview.leftAnchor, constant: 15).isActive = true
//        replyPreviewIconImageView.topAnchor.constraint(equalTo: replyPreview.topAnchor, constant: 15).isActive = true
//        // リプライププレビュー Closeボタン
//        let screenWidth = UIScreen.main.bounds.size.width
//        let closeButtonHeight = 30.0
//        let closeButtonWidth = 30.0
//        let replyPreviewCloseButtonConstant = (screenWidth / 2 - 20.0)
//        replyPreviewCloseButton.addTarget(self, action: #selector(closeReplyPreview), for: .touchUpInside)
//        replyPreviewCloseButton.setTitle("", for: .normal)
//        var configuration = UIButton.Configuration.plain()
//        configuration.baseForegroundColor = .lightGray
//        replyPreviewCloseButton.configuration = configuration
//        replyPreview.addSubview(replyPreviewCloseButton)
//        replyPreviewCloseButton.translatesAutoresizingMaskIntoConstraints = false
//        replyPreviewCloseButton.widthAnchor.constraint(equalToConstant: closeButtonWidth).isActive = true
//        replyPreviewCloseButton.heightAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
//        replyPreviewCloseButton.centerXAnchor.constraint(equalTo: replyPreview.centerXAnchor, constant: replyPreviewCloseButtonConstant).isActive = true
//        replyPreviewCloseButton.topAnchor.constraint(equalTo: replyPreview.topAnchor, constant: 10).isActive = true
//        // リプライププレビュー ニックネーム
//        replyPreview.addSubview(replyPreviewNickNameLabel)
//        replyPreviewNickNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
//        replyPreviewNickNameLabel.textColor = .fontColor
//        replyPreviewNickNameLabel.translatesAutoresizingMaskIntoConstraints = false
//        replyPreviewNickNameLabel.leftAnchor.constraint(equalTo: replyPreviewIconImageView.rightAnchor, constant: 10).isActive = true
//        replyPreviewNickNameLabel.topAnchor.constraint(equalTo: replyPreviewIconImageView.topAnchor, constant: 5).isActive = true
//        // リプライププレビュー メッセージ画像
//        let replyPreviewMessageImageViewConstant = (screenWidth / 2 - 20.0 - closeButtonWidth - closeButtonWidth / 2)
//        replyPreviewMessageImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//        replyPreviewMessageImageView.clipsToBounds = true
//        replyPreviewMessageImageView.allMaskedCorners()
//        replyPreview.addSubview(replyPreviewMessageImageView)
//        replyPreviewMessageImageView.translatesAutoresizingMaskIntoConstraints = false
//        replyPreviewMessageImageView.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
//        replyPreviewMessageImageView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
//        replyPreviewMessageImageView.centerXAnchor.constraint(equalTo: replyPreview.centerXAnchor, constant: replyPreviewMessageImageViewConstant).isActive = true
//        replyPreviewMessageImageView.topAnchor.constraint(equalTo: replyPreviewIconImageView.topAnchor).isActive = true
//        // リプライププレビュー メッセージテキスト
//        replyPreview.addSubview(replyPreviewMessageTextLabel)
//        replyPreviewMessageTextLabel.font = UIFont.systemFont(ofSize: 14)
//        replyPreviewMessageTextLabel.textColor = .lightGray
//        replyPreviewMessageTextLabel.lineBreakMode = .byTruncatingTail
//        replyPreviewMessageTextLabel.numberOfLines = 1
//        replyPreviewMessageTextLabel.translatesAutoresizingMaskIntoConstraints = false
//        replyPreviewMessageTextLabel.leftAnchor.constraint(equalTo: replyPreviewIconImageView.rightAnchor, constant: 10).isActive = true
//        replyPreviewMessageTextLabel.rightAnchor.constraint(equalTo: replyPreviewMessageImageView.leftAnchor, constant: 10).isActive = true
//        replyPreviewMessageTextLabel.topAnchor.constraint(equalTo: replyPreviewNickNameLabel.bottomAnchor).isActive = true
//    }
//
//    // リプレイプレビューを閉じる
//    @objc private func closeReplyPreview() {
//        setReplyPreview(active: false)
//    }
//
//    private func showReplyPreview(indexPath: IndexPath) {
//
//        guard let loginUser = GlobalVar.shared.loginUser else { return }
//        guard let partnerUser = room?.partnerUser else { return }
//        guard let roomMessage = roomMessages[safe: indexPath.section] else { return }
//
//        let messageID = roomMessage.document_id ?? ""
//        let messageText = roomMessage.text
//        let messagePhotos = roomMessage.photos
//        let sendMessageUID = roomMessage.creator
//        let customMessageType = roomMessage.type
//
//        let isLoginUser  = (sendMessageUID == loginUser.uid)
//        let isPartnerUID = (sendMessageUID == partnerUser.uid)
//
//        var messageCustomType = "text"
//
//        switch customMessageType {
//        case .image:
//            messageCustomType = "image"
//            break
//        case .sticker:
//            messageCustomType = "sticker"
//            break
//        default:
//            break
//        }
//
//        if isLoginUser {
//            setReplyPreviewData(user: loginUser, messageID: messageID, messageCustomType: messageCustomType, messageText: messageText, messagePhotos: messagePhotos)
//        } else if isPartnerUID {
//            setReplyPreviewData(user: partnerUser, messageID: messageID, messageCustomType: messageCustomType, messageText: messageText, messagePhotos: messagePhotos)
//        }
//    }
//
//    private func setReplyPreviewData(user: User, messageID: String, messageCustomType: String = "text", messageText: String, messagePhotos: [String] = []) {
//
//        let profileIconImg = user.profile_icon_img
//        let nickName = user.nick_name
//
//        replyPreviewIconImageView.setImage(withURLString: profileIconImg)
//
//        replyPreviewNickNameLabel.text = nickName
//
//        replyPreviewMessageTextLabel.isHidden = false
//
//        let imageText = "画像"
//        let movieText = "動画"
//        let stickerText = "スタンプ"
//
//        switch messageCustomType {
//        case "image": replyPreviewMessageTextLabel.text = imageText; break
//        case "movie": replyPreviewMessageTextLabel.text = movieText; break
//        case "sticker": replyPreviewMessageTextLabel.text = stickerText; break
//        default: replyPreviewMessageTextLabel.text = messageText; break
//        }
//
//        if let messagePhoto = messagePhotos.first {
//            replyPreviewMessageImageView.isHidden = false
//            replyPreviewMessageImageView.setImage(withURLString: messagePhoto, isFade: true)
//        } else {
//            replyPreviewMessageImageView.isHidden = true
//        }
//
//        replyMessageID = messageID
//
//        setReplyPreview(active: true)
//    }
//    /// messageReplyPreviewの表示・非表示を行う
//    private func setReplyPreview(active: Bool) {
//        replyPreview.isHidden = (active == true ? false : true)
//        replyIsSelected = active
//        replyMessageID = (active == true ? replyMessageID : nil)
//        setUpInputStackViewReplyPreview()
//    }
//
//    private func setUpInputStackViewReplyPreview() {
//
//        let existReplyPreview = (messageInputView.subviews.contains(replyPreview))
//
//        if existReplyPreview {
//            messageInputView.willRemoveSubview(replyPreview)
//        } else {
//            let replyPreviewY = -(messageInputView.frame.height + 20)
//            replyPreview.frame = CGRect(x: 0, y: replyPreviewY, width: view.bounds.width, height: REPRY_VIEW_HEIGHT)
//            messageInputView.insertSubview(replyPreview, aboveSubview: textView)
//        }
//    }
//    // リプライ機能でのエラーアラートを表示する
//    private func showReplyErrorAlert(errorCase: Int) {
//        let message = (errorCase == 0) ? "正常に処理できませんでした。\n運営にお問い合わせください。" : "スタンプのアップロードに失敗しました。\nアプリを再起動して再度実行をしてください。"
//        let alert = UIAlertController(title: "スタンプ送信エラー", message: message, preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] action in
//            if errorCase == 0 { return }
//            guard let weakSelf = self else { return }
//            weakSelf.roomMessages.removeLast()
//            weakSelf.messageCollectionView.reloadData()
//        }
//        alert.addAction(ok)
//        present(alert, animated: true)
//    }
//}

// 入力状態監視関連
//extension MessageRoomView {
//
//    func removeMessageRoomTypingListener() {
//        GlobalVar.shared.messageRoomTypingListener?.remove()
//        GlobalVar.shared.messageRoomTypingListener = nil
//    }
//    /// 特定のRoomの is_typing_user.uid: Bool'を更新
//    private func updateTypingState(isTyping: Bool) {
//        guard let loginUserId = GlobalVar.shared.loginUser?.uid,
//              let roomId = room?.document_id else { return }
//
//        db.collection("rooms").document(roomId).updateData(["is_typing_\(loginUserId)": isTyping]) { error in
//            if let _error = error { print("メッセージの入力状態の更新に失敗\(_error)") }
//        }
//    }
//
//    // textViewのtextを空にし、ログイン中のユーザーのタイピングの状態をfalseに更新
//    private func deactivateTypingState() {
//        if !textView.text.isEmpty {
//            initTextView()
//        }
//
//        updateTypingState(isTyping: false)
//    }
//
//    // 現在のRoomの更新を監視し、相手のユーザーが入力中かを判断する
//    private func observeTypingState() {
//
//        guard let roomId = room?.document_id else { return }
//
//        removeMessageRoomTypingListener()
//        GlobalVar.shared.messageRoomTypingListener = db.collection("rooms").document(roomId).addSnapshotListener { [weak self] querySnapshot, error in
//            guard let self else { return }
//            if let err = error { print("Room情報の監視に失敗: \(err)"); return }
//            guard let _querySnapshot = querySnapshot,
//                  let partnerUserId = room?.partnerUser?.uid,
//                  let partnerUserIsTyping = _querySnapshot.data()?["is_typing_\(partnerUserId)"] as? Bool else { return }
//            changeTypingIndicatorState(partnerUserIsTyping)
//        }
//    }
//
//    // 相手のユーザーが入力中の場合はTypingIndicatorViewを表示し、入力していない場合は非表示にする
//    private func changeTypingIndicatorState(_ partnerUserIsTyping: Bool) {
//        if partnerUserIsTyping {
//            UIView.animate(withDuration: 0.3, animations: {
//                self.typingIndicatorView?.alpha = 1.0
//            }) {_ in
//                self.typingIndicatorView?.indicatorView.startAnimating()
//                self.typingIndicatorView?.isHidden = false
//            }
//        } else {
//            UIView.animate(withDuration: 0.3, animations: {
//                self.typingIndicatorView?.alpha = 0.0
//            }) {_ in
//                self.typingIndicatorView?.isHidden = true
//                self.typingIndicatorView?.indicatorView.stopAnimating()
//            }
//        }
//    }
//}
