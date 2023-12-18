//
//  MessageListViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/10/21.
//

import UIKit
import FirebaseFirestore

final class MessageListViewController: UIBaseViewController {

    @IBOutlet weak var messageListTableView: UITableView!
<<<<<<< HEAD
    @IBOutlet weak var recomMsgCollectionView: UICollectionView!
    
    @IBOutlet weak var recomMsgView: UIView!
    @IBOutlet weak var recomMsgDescription: UILabel!
=======
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    
    private let defaultRowsInSection = 0
    private let defaultCellheight = 0.0
    private let indicatorView = UIView(frame: UIScreen.main.bounds)
    private var isIndicatorShowed = false
    private var isFetchPastMessageList = true
    private var beforeScrollContentOffsetY = CGFloat(0)
    
    private var indicatorStatus: IndicatorStatus = .hide {
        didSet {
            switch indicatorStatus {
            case .show:
                if isIndicatorShowed {
                    return
                }
                showLoadingView(indicatorView)
                isIndicatorShowed = true
            case .hide:
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
                    self.indicatorView.removeFromSuperview()
                    self.isIndicatorShowed = false
                }
            }
        }
    }
    
    private enum IndicatorStatus {
        case show
        case hide
    }
    
    private enum Section: Int {
        case header = 0
        case newMatch = 1
        case roomList = 2
    }
    
    //MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
        
        messageListTableView.tableFooterView = UIView()
        messageListTableView.delegate = self
        messageListTableView.dataSource = self
        
        recomMsgCollectionView.delegate = self
        recomMsgCollectionView.dataSource = self
        
        configureRefreshControl()
        
        GlobalVar.shared.messageListTableView = messageListTableView
        GlobalVar.shared.recomMsgCollectionView = recomMsgCollectionView

        playTutorial(key: "isShowedMessageTutorial", type: "message")
        
        recomMsgDescriptionCustom()
=======
        setUp()
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.sortRoom()
            GlobalVar.shared.messageListTableView.reloadData()
            self.setUpRefreshControl()
            self.prefetcher.isPaused = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initLatestRoomIdAndLatestUnReadCount()
        showTalkGuideDisplayRanking()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.indicatorStatus = .hide
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeRefreshControl()
        resetLatestRoomIdAndLatestUnReadCount()
        if messageListTableView != nil {
            GlobalVar.shared.messageListTableView = messageListTableView
        }
        prefetcher.isPaused = true
        indicatorStatus = .hide
    }
    
    private func setUp() {
        indicatorStatus = .show
        setUpNavigationBar()
        setUpTableView()
        setUpTableViewCell()
        setUpNotification()
        playTutorial(key: "isShowedMessageTutorial", type: "message")
    }
    
    private func setUpNavigationBar() {
        // ナビゲーションバーを表示する
        navigationController?.setNavigationBarHidden(false, animated: true)
        // ナビゲーションの戻るボタンを消す
        navigationItem.setHidesBackButton(true, animated: true)
        // ナビゲーションバーの透過させない
        navigationController?.navigationBar.isTranslucent = false
        // ナビゲーションバーの右側にボタンを設定
        let image = UIImage(systemName: "questionmark.circle")
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action:#selector(moveFriendEmoji))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.tintColor = .fontColor
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // ナビゲーションアイテムのタイトルを設定
        navigationItem.title = "メッセージ"
        // ナビゲーションバー設定
        hideNavigationBarBorderAndShowTabBarBorder()
    }
    
    private func setUpTableView() {
        messageListTableView.tableFooterView = UIView()
        messageListTableView.delegate = self
        messageListTableView.dataSource = self
        messageListTableView.isPrefetchingEnabled = true
        messageListTableView.prefetchDataSource = self
        GlobalVar.shared.messageListTableView = messageListTableView
    }
    
    private func setUpTableViewCell() {
        messageListTableView.register(UINib(nibName: MessageListHeaderTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: MessageListHeaderTableViewCell.cellIdentifier)
        messageListTableView.register(UINib(nibName: NewMatchTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NewMatchTableViewCell.cellIdentifier)
        messageListTableView.register(UINib(nibName: MessageListTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: MessageListTableViewCell.cellIdentifier)
    }
    
    @objc private func setUpRefreshControl() {
        GlobalVar.shared.messageListTableView.refreshControl = UIRefreshControl()
        GlobalVar.shared.messageListTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    private func removeRefreshControl() {
        GlobalVar.shared.messageListTableView.refreshControl = nil
    }

    @objc private func handleRefreshControl() {
        DispatchQueue.main.async { 
            GlobalVar.shared.messageListTableView.reloadData()
            GlobalVar.shared.messageListTableView.refreshControl?.endRefreshing()
            Log.event(name: "reloadMessageList")
        }
    }
    
    private func setUpNotification() {
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setUpRefreshControl),
            name: NSNotification.Name(NotificationName.MessageListBack.rawValue),
            object: nil
        )
    }
    
    @objc private func foreground(_ notification: Notification) {
        print("come back foreground.")
        
        DispatchQueue.main.async {
            self.indicatorStatus = .show
            GlobalVar.shared.messageListTableView.reloadData()
            self.setUpRefreshControl()
            self.prefetcher.isPaused = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.indicatorStatus = .hide
            }
        }
    }
    
    @objc private func background(_ notification: Notification) {
        print("go to background.")
        removeRefreshControl()
        resetLatestRoomIdAndLatestUnReadCount()
        if messageListTableView != nil {
            GlobalVar.shared.messageListTableView = messageListTableView
        }
        prefetcher.isPaused = true
        indicatorStatus = .hide
    }
    
    private func sortRoom() {
        Task {
            guard var rooms = GlobalVar.shared.loginUser?.rooms else {
                return
            }
            var tempRooms: [Room] = []
            
            await rooms.asyncForEach { room in
                let notFindRoom = tempRooms.firstIndex(where: { room.document_id == $0.document_id }) == nil
                if notFindRoom {
                    tempRooms.append(room)
                }
            }
            
            rooms.sort { (m1, m2) -> Bool in
                let m1Date = m1.updated_at.dateValue()
                let m2Date = m2.updated_at.dateValue()
                return m1Date > m2Date
            }
            
<<<<<<< HEAD
            messageListTableView.reloadData()
            recomMsgCollectionView.reloadData()
        }
    }

    // 画面表示終了時の処理
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if messageListTableView != nil {
            GlobalVar.shared.messageListTableView = messageListTableView
        }
        if recomMsgCollectionView != nil {
            GlobalVar.shared.recomMsgCollectionView = recomMsgCollectionView
=======
            GlobalVar.shared.loginUser?.rooms = rooms
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
        }
    }
    
    private func moveMessageRoom(_ indexPath: IndexPath) {
        guard let loginUser = GlobalVar.shared.loginUser else {
            return
        }
        let uid = loginUser.uid
        let rooms = loginUser.rooms
        
        let filterRooms = rooms.filter {
            messageListFilter(room: $0, loginUID: uid)
        }
        
        if let specificRoom = filterRooms[safe: indexPath.row] {
            let specificRoomID = specificRoom.document_id ?? ""
            Log.event(name: "selectMessageRoom", logEventData: ["roomID": specificRoomID])
        }
        
        //本人確認していない場合は確認ページを表示
        if loginUser.admin_checks?.admin_id_check_status == nil {
            popUpIdentificationView()
            return
        } else if loginUser.admin_checks?.admin_id_check_status == 1 {
            if let specificRoom = filterRooms[safe: indexPath.row] {
                specificMessageRoomMove(specificRoom: specificRoom)
            }
        } else if loginUser.admin_checks?.admin_id_check_status == 2 {
            let alert = UIAlertController(title: "本人確認失敗しました", message: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { _ in
                self.popUpIdentificationView()
            }
            alert.addAction(ok)
            
            present(alert, animated: true)
       } else {
           let alert = UIAlertController(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", preferredStyle: .alert)
           let ok = UIAlertAction(title: "OK", style: .default)
           alert.addAction(ok)
           
           present(alert, animated: true)
       }
    }
    
    private func matchElapsedTime(created_at: Timestamp) -> Bool {
        let now = Date()
        let span = now.timeIntervalSince(created_at.dateValue())
        let hourSpan = Int(floor(span/60/60))
        if hourSpan < 24 { return true }
        return false
    }
    
    private func recomMsgDescriptionCustom() {
        
        guard let recomMsgDescriptionText = recomMsgDescription.text else { return }
        
        let attrText = NSMutableAttributedString(string: recomMsgDescriptionText)
        
        attrText.addAttributes([
            .foregroundColor: UIColor(.black),
            .font: UIFont.boldSystemFont(ofSize: 14)
        ], range: NSMakeRange(6, 6))
        
        recomMsgDescription.attributedText = attrText
    }
    
    private func roomFilter(room: Room) -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        let loginUID = loginUser.uid
        
        let isNotMatchElapsedTime = (matchElapsedTime(created_at: room.created_at) == false)
        let isNotRemovedUser = (room.removed_user.contains(loginUID) == false)
        let isMatchElapsedTime = (matchElapsedTime(created_at: room.created_at) == true)
        let isRoomOpend = (room.is_room_opened == true)
        
        let isRoomFilter = (
            isNotMatchElapsedTime &&
            isNotRemovedUser ||
            isMatchElapsedTime &&
            isRoomOpend &&
            isNotRemovedUser
        )
        return isRoomFilter
    }
    
    private func recommendRoomFilter(room: Room) -> Bool {
        
        let isMatchElapsedTime = (matchElapsedTime(created_at: room.created_at) == true)
        let isNotRoomOpend = (room.is_room_opened == false)
        
        let isRoomFilter = (isMatchElapsedTime && isNotRoomOpend)
        return isRoomFilter
    }
}

extension MessageListViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scroll = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if scrollView.contentSize.height <= scroll && beforeScrollContentOffsetY < scrollView.contentSize.height {
            // 一番下までスクロールした時に実行したい処理を記述
            print("#### MessageListViewController scrollViewDidScroll done ####")
            if isFetchPastMessageList {
                isFetchPastMessageList = false
                fetchPastMessageListInfoForFirestore()
            }
        }
        
        beforeScrollContentOffsetY = scroll
    }
}

extension MessageListViewController {
    // ルーム情報を取得
    private func fetchPastMessageListInfoForFirestore() {

        guard let loginUser = GlobalVar.shared.loginUser else {
            return
        }
        let loginUID = loginUser.uid
        
        guard let beforeLastDocument = GlobalVar.shared.lastRoomDocument else {
            isFetchPastMessageList = true
            return
        }
        print("fetchPastMessageListInfoForFirestore")
        let collection = db.collection("users").document(loginUID).collection("rooms")
        let query = collection.order(by: "updated_at", descending: true).limit(to: 30)
        query.start(afterDocument: beforeLastDocument).getDocuments { snapshots, error in
            if let error = error {
                print("Error fetchPastMessageList:", error)
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
            guard let lastDocument = documentChanges.last?.document else {
                return
            }
            GlobalVar.shared.lastRoomDocument = nil
            GlobalVar.shared.lastRoomDocument = lastDocument
            
            let lastDocumentID = lastDocument.documentID
            
            documentChanges.forEach { documentChange in
                self.addRoom(roomDocument: documentChange.document, lastDocumentID: lastDocumentID)
            }
            self.messageListTableView.reloadData()
            self.hideLoadingLabelAnimationAndUpdateFlug()
        }
    }
    
    private func hideLoadingLabelAnimationAndUpdateFlug() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            
        } completion: { _ in
            self.isFetchPastMessageList = true
        }
    }

    private func initLatestRoomIdAndLatestUnReadCount() {
        guard let cell = GlobalVar.shared.messageListTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? MessageListTableViewCell else {
            return
        }
        guard let room = cell.room else {
            return
        }
        
        if GlobalVar.shared.currentLatestRoomId == nil || GlobalVar.shared.unReadCountForCurrentLatestRoom == nil {
            print("最新のRoomIDと未既読数をclassに保存")
            GlobalVar.shared.currentLatestRoomId = room.document_id
            GlobalVar.shared.unReadCountForCurrentLatestRoom = room.unreadCount
        }
    }
    
    private func resetLatestRoomIdAndLatestUnReadCount() {
        GlobalVar.shared.currentLatestRoomId = nil
        GlobalVar.shared.unReadCountForCurrentLatestRoom = nil
    }
}

// フレンド絵文字関連
extension MessageListViewController {
    
    private func getFriendEmoji(_ room: Room?) -> String? {
        guard let room = room else { return nil }
        guard let partnerUser = room.partnerUser else { return nil }
        guard let loginUser = GlobalVar.shared.loginUser else { return nil }
        let totalMessageNum = room.message_num
        let ownMessageNum = room.own_message_num
        let partnerMessageNum = totalMessageNum - ownMessageNum
        let messsageRallyNum = (ownMessageNum > partnerMessageNum ? partnerMessageNum : ownMessageNum)

//        print(
//            "totalMessageNum :", totalMessageNum,
//            "ownMessageNum :", ownMessageNum,
//            "partnerMessageNum :", partnerMessageNum,
//            "messsageRallyNum :", messsageRallyNum
//        )

        let nowDate = Date()
        let roomCreatedAt = room.created_at.dateValue()

        let sameAge = (loginUser.birth_date.calcAgeForInt() == partnerUser.birth_date.calcAgeForInt())
        let sameAddress = (loginUser.address == partnerUser.address)
        let hobbyTagMatches = loginUser.hobbies.filter({ partnerUser.hobbies.contains($0) })
        let enoughHobbyTagMatches = (hobbyTagMatches.count >= 5)

//        print(
//            "ownBirthDate :", loginUser.birth_date,
//            "ownAge :", loginUser.birth_date.calcAgeForInt(),
//            "partnerBirthDate :", partnerUser.birth_date,
//            "partnerAge :", partnerUser.birth_date.calcAgeForInt(),
//            "sameAge :", sameAge
//        )
//        print(
//            "ownAddress :", loginUser.address,
//            "partnerAddress :", partnerUser.address,
//            "sameAddress :", sameAddress
//        )
//        print(
//            "ownHobbies :", loginUser.hobbies,
//            "partnerHobbies :", partnerUser.hobbies,
//            "hobbyTagMatches :", hobbyTagMatches,
//            "enoughHobbyTagMatches :", enoughHobbyTagMatches
//        )

        let birthDateFormat = "YYYY年M月D日"
        let loginUserBirthDate = loginUser.birth_date.dateFromString(format: birthDateFormat)
        let partnerUserBirthDate = partnerUser.birth_date.dateFromString(format: birthDateFormat)

        let sssBest = "🥰💕"
        let ssBest = "❤️"
        let sBest = "💛"
        let best = "😊"
        let common = "🎾"
        let birthDay = "🎂🤝"
        var emoji = ""

        let birthDateElaspedDays = Calendar.current.dateComponents([.day], from: loginUserBirthDate, to: partnerUserBirthDate).day ?? 0

//        print(
//            "ownBirthDate :", loginUser.birth_date,
//            "partnerBirthDate :", partnerUser.birth_date,
//            "ownBirthDate (Date) :", loginUserBirthDate,
//            "partnerBirthDate (Date) :", partnerUserBirthDate,
//            "birthDateElaspedDays :", birthDateElaspedDays
//        )

        let roomElaspedDays = Calendar.current.dateComponents([.day], from: roomCreatedAt, to: nowDate).day ?? 0
        let averageMessageRallyNum = (roomElaspedDays > 0 ? (Double(messsageRallyNum) / Double(roomElaspedDays)) : 0)

//        print(
//            "partner :", partnerUser.nick_name,
//            "nowDate :", nowDate,
//            "roomCreatedAt :", roomCreatedAt,
//            "roomElaspedDays :", roomElaspedDays,
//            "messsageRallyNum :", messsageRallyNum,
//            "averageMessageRallyNum :", averageMessageRallyNum
//        )

        // SSSベストフレンド (5ラリー以上/1日, 150日以上)
        let sssBestFriend = (averageMessageRallyNum >= 5.0 && roomElaspedDays >= 150)
        // SSベストフレンド (3ラリー以上/1日, 100日以上)
        let ssBestFriend = (averageMessageRallyNum >= 3.0 && roomElaspedDays >= 100)
        // Sベストフレンド (1ラリー以上/1日, 50日以上)
        let sBestFriend = (averageMessageRallyNum >= 1.0 && roomElaspedDays >= 50)
        // ベストフレンド (0.5ラリー以上/1日, 14日以上)
        let bestFriend = (averageMessageRallyNum >= 0.5 && roomElaspedDays >= 14)
        // シークレット1 (年齢が一緒, よく行く場所が一緒, 共通の趣味タグが5個以上)
        let commonFriend = (sameAge && sameAddress && enoughHobbyTagMatches)
        // シークレット2 (相手との誕生日が一緒, 1日違いで表示)
        let birthDayFriend = (-1 <= birthDateElaspedDays && birthDateElaspedDays <= 1)

        if sssBestFriend {
            emoji += sssBest
        } else if ssBestFriend {
            emoji += ssBest
        } else if sBestFriend {
            emoji += sBest
        } else if bestFriend {
            emoji += best
        }
        if commonFriend {
            emoji += common
        }
        if birthDayFriend {
            emoji += birthDay
        }

//        print(
//            "roomElaspedDays :", roomElaspedDays,
//            "messsageRallyNum :", messsageRallyNum,
//            "averageMessageRallyNum :", averageMessageRallyNum,
//            "sameAge :", sameAge,
//            "sameAddress :", sameAddress,
//            "enoughHobbyTagMatches :", enoughHobbyTagMatches,
//            "birthDateElaspedDays :", birthDateElaspedDays
//        )
//        print(
//            "sssBestFriend :", sssBestFriend,
//            "ssBestFriend :", ssBestFriend,
//            "sBestFriend :", sBestFriend,
//            "bestFriend :", bestFriend,
//            "commonFriend :", commonFriend,
//            "birthDayFriend :", birthDayFriend
//        )

        return emoji
    }
}

// マッチ関連
extension MessageListViewController {
    
    private func matchElapsedTime(created_at: Timestamp) -> Bool {
        let date = Date()
        let span = date.timeIntervalSince(created_at.dateValue())
        let hourSpan = Int(floor(span / 60 / 60))
        
        if hourSpan < 24 {
            return true
        } else {
            return false
        }
    }
    
    private func newMatchFilter(room: Room, loginUID: String) -> Bool {
        let isLatestMessage = room.latest_message == ""
        let isMatchElapsedTime = matchElapsedTime(created_at: room.created_at) == true
        let isContainRemovedUser = room.removed_user.contains(loginUID) == false
        let isRoomFilter = isLatestMessage && isMatchElapsedTime && isContainRemovedUser
        
        return isRoomFilter
    }
    
    private func messageListFilter(room: Room, loginUID: String) -> Bool {
        let isNewMatch = newMatchFilter(room: room, loginUID: loginUID) == true
        
        if isNewMatch {
            return false
        }
        
        let isContainRemovedUser = room.removed_user.contains(loginUID) == false
        let isRoomFilter = isContainRemovedUser
        
        return isRoomFilter
    }
    
    private func newMatchRooms() -> [Room]? {
        guard let loginUser = GlobalVar.shared.loginUser else {
            return nil
        }
        let uid = loginUser.uid
        let rooms = loginUser.rooms
        let newMatchRooms = rooms.filter({ newMatchFilter(room: $0, loginUID: uid) })
        
        return newMatchRooms
    }
}

// TableView関連 --- 表示設定 ---
extension MessageListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let newMatchRooms = newMatchRooms() else {
            return defaultCellheight
        }
        
        switch indexPath.section {
        case Section.header.rawValue:
            return MessageListHeaderTableViewCell.height
        case Section.newMatch.rawValue:
            if newMatchRooms.count > 0 {
                return NewMatchTableViewCell.height
            } else {
                return defaultCellheight
            }
        case Section.roomList.rawValue:
            return MessageListTableViewCell.height
        default:
            return defaultCellheight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
<<<<<<< HEAD
        guard let loginUser = GlobalVar.shared.loginUser else { return 0 }
        let currentUID = loginUser.uid
        let rooms = loginUser.rooms
        let filterRooms = rooms.filter({ roomFilter(room: $0) })
        return filterRooms.count
=======
        guard let loginUser = GlobalVar.shared.loginUser else {
            return defaultRowsInSection
        }
        
        switch section {
        case Section.header.rawValue:
            return 1
        case Section.newMatch.rawValue:
            return 1
        case Section.roomList.rawValue:
            let uid = loginUser.uid
            let rooms = loginUser.rooms
            let filterRooms = rooms.filter {
                messageListFilter(room: $0, loginUID: uid)
            }
            return filterRooms.count
        default:
            return defaultRowsInSection
        }
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
<<<<<<< HEAD
        guard let loginUser = GlobalVar.shared.loginUser else { return UITableViewCell() }
        let currentUID = loginUser.uid
        let rooms = loginUser.rooms
        let cell = messageListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageListTableViewCell
        let filterRooms = rooms.filter({ roomFilter(room: $0) })
        if filterRooms[safe: indexPath.row] != nil { cell.room = filterRooms[indexPath.row] }
        return cell
    }
    
    // セルスワイプ時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        let currentUID = loginUser.uid
        let rooms = loginUser.rooms
        let filterRooms = rooms.filter({ roomFilter(room: $0) })
        if filterRooms[safe: indexPath.row] != nil {
            let roomID = filterRooms[indexPath.row].document_id ?? ""
            tableView.beginUpdates()
            GlobalVar.shared.loginUser?.rooms.filter({ roomFilter(room: $0) })[indexPath.row].removed_user.append(currentUID)
            db.collection("rooms").document(roomID).updateData([
                "removed_user": FieldValue.arrayUnion([currentUID]),
                "unread_\(currentUID)": 0,
            ])
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
            let logEventData = [
                "roomID": roomID
            ] as [String : Any]
            logEvent(name: "removeMessageRoom", logEventData: logEventData)
        }
    }
    
    // セル選択時
=======
        tableView.tableFooterView = UIView(frame: .zero)
        let cell = UITableViewCell()
        
        guard let loginUser = GlobalVar.shared.loginUser else {
            return cell
        }
        guard let newMatchRooms = newMatchRooms() else {
            return cell
        }
        
        if indexPath.section == Section.header.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageListHeaderTableViewCell.cellIdentifier) as! MessageListHeaderTableViewCell
            return cell
        } else if indexPath.section == Section.newMatch.rawValue {
            if newMatchRooms.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: NewMatchTableViewCell.cellIdentifier, for: indexPath) as! NewMatchTableViewCell
                cell.configure(with: newMatchRooms)
                return cell
            } else {
                return cell
            }
        } else if indexPath.section == Section.roomList.rawValue {
            let uid = loginUser.uid
            let rooms = loginUser.rooms
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageListTableViewCell.identifier, for: indexPath) as! MessageListTableViewCell
            cell.isHidden = false // 初回表示で何故か非表示になっているセルが存在するのでフラグ追加
            let filterRooms = rooms.filter {
                messageListFilter(room: $0, loginUID: uid)
            }
            if filterRooms[safe: indexPath.row] != nil {
                cell.room = filterRooms[indexPath.row]
                if let roomId = filterRooms[indexPath.row].document_id {
                    if roomId == cell.room?.document_id {
                        // 🥰💕etc...をここでセット
                        cell.friendEmoji = getFriendEmoji(cell.room)
                        // ⌛️をここでセット非同期のため'fetchConsectiveCount'で事前取得している
                        cell.consectiveCount = GlobalVar.shared.consectiveCountDictionary[roomId]
                    }
                }
                return cell
            } else {
                return cell
            }
        }
        
        return cell
    }
    
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case Section.header.rawValue:
            let storyboard = UIStoryboard(name: BusinessSolicitationCrackdownViewController.storyboardName, bundle: nil)
            let viewcontroller = storyboard.instantiateViewController(withIdentifier: BusinessSolicitationCrackdownViewController.storyboardId)
            navigationController?.pushViewController(viewcontroller, animated: true)
        case Section.newMatch.rawValue:
            return
        case Section.roomList.rawValue:
            moveMessageRoom(indexPath)
        default:
            return
        }
    }
}

// TableView関連 --- スワイプ ---
extension MessageListViewController {
 
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let loginUser = GlobalVar.shared.loginUser else {
            return
        }

        switch indexPath.section {
        case Section.header.rawValue:
            return
        case Section.newMatch.rawValue:
            return
        case Section.roomList.rawValue:
            let uid = loginUser.uid
            let rooms = loginUser.rooms
            let filterRooms = rooms.filter{
                messageListFilter(room: $0, loginUID: uid)
            }
            if filterRooms[safe: indexPath.row] != nil {
                let alert = UIAlertController(
                    title: "本当に削除しますか？",
                    message: "1度削除するとお相手からメッセージが来ない限り復元しませんが\n本当にトークルームを削除しますか？",
                    preferredStyle: .alert
                )
                let ok = UIAlertAction(title: "OK", style: .default) { _ in
                    let roomId = filterRooms[indexPath.row].document_id ?? ""
                    tableView.beginUpdates()
                    GlobalVar.shared.loginUser?.rooms.filter {
                        self.messageListFilter(room: $0, loginUID: uid) 
                    } [indexPath.row].removed_user.append(uid)
                    
                    self.db.collection("rooms").document(roomId).updateData([
                        "removed_user": FieldValue.arrayUnion([uid]),
                        "unread_\(uid)": 0,
                    ])
                    
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                    
                    Log.event(name: "removeMessageRoom", logEventData: ["roomID": roomId])
                }
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
                alert.addAction(cancel)
                alert.addAction(ok)
                
                present(alert, animated: true)
            }
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch indexPath.section {
        case Section.header.rawValue:
            return .none
        case Section.newMatch.rawValue:
            return .none
        case Section.roomList.rawValue:
            return .delete
        default:
            return .none
        }
    }
}

// TableView関連 --- prefetch ---
extension MessageListViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let loginUser = GlobalVar.shared.loginUser else {
            return
        }
        let uid = loginUser.uid
        let rooms = loginUser.rooms
<<<<<<< HEAD
        let filterRooms = rooms.filter({ roomFilter(room: $0) })
        if let specificRoom = filterRooms[safe: indexPath.row] {
            let specificRoomID = specificRoom.document_id ?? ""
            let logEventData = [
                "roomID": specificRoomID
            ] as [String : Any]
            logEvent(name: "selectMessageRoom", logEventData: logEventData)
=======
        let filterRooms = rooms.filter {
            messageListFilter(room: $0, loginUID: uid)
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
        }
        let urls = indexPaths.compactMap {
            getPartnerIconImgURL(filterRooms, index: $0.section)
        }
        prefetcher.startPrefetching(with: urls)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        guard let loginUser = GlobalVar.shared.loginUser else {
            return
        }
<<<<<<< HEAD
        if adminIDCheckStatus == 1 {
            
            if let specificRoom = filterRooms[safe: indexPath.row] {
                specificMessageRoomMove(specificRoom: specificRoom)
                GlobalVar.shared.loginUser?.rooms.filter({ roomFilter(room: $0) })[indexPath.row].unreadCount = 0
                GlobalVar.shared.loginUser?.rooms.filter({ roomFilter(room: $0) })[indexPath.row].unread = 0
            }
            
        } else if adminIDCheckStatus == 2 {
           dialog(title: "本人確認失敗しました", subTitle: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", confirmTitle: "OK", completion: { [weak self] confirm in
               guard let weakSelf = self else { return }
               if confirm { weakSelf.popUpIdentificationView() }
           })
       } else {
           alert(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", actiontitle: "OK")
       }
    }
}

//新しいマッチ
extension MessageListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //メッセージがないルームのみカウント
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rooms = GlobalVar.shared.loginUser?.rooms ?? [Room]()
        let recomMsgRoomCount = rooms.filter({ recommendRoomFilter(room: $0) }).count
        //２４時間以内にマッチした人がいないときのトルツメ
        if recomMsgRoomCount == 0 {
            recomMsgView.isHidden = true
        } else {
            recomMsgView.isHidden = false
        }
        return recomMsgRoomCount
    }
    //メッセージがないルームのみ生成
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecomMsgCell", for: indexPath) as! RecomMsgCollectionViewCell
        let rooms = GlobalVar.shared.loginUser?.rooms ?? [Room]()
        let filterRooms = rooms.filter({ recommendRoomFilter(room: $0) })
        if filterRooms[safe: indexPath.row] != nil { cell.room = filterRooms[indexPath.row] }
        return cell
    }
    //ルームに移動
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        newMatchRoomMove(indexPath: indexPath)
=======
        let uid = loginUser.uid
        let rooms = loginUser.rooms
        let filterRooms = rooms.filter {
            messageListFilter(room: $0, loginUID: uid)
        }
        let urls = indexPaths.compactMap {
            getPartnerIconImgURL(filterRooms, index: $0.section)
        }
        prefetcher.stopPrefetching(with: urls)
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    }
    
    func getPartnerIconImgURL(_ rooms: [Room], index: Int) -> URL? {
        let partnerUser = rooms[index].partnerUser
        let profileIconImg = partnerUser?.profile_icon_img ?? ""
        let iconImgURL = URL(string: profileIconImg)
        
<<<<<<< HEAD
        let rooms = GlobalVar.shared.loginUser?.rooms ?? [Room]()
        let filterRooms = rooms.filter({ recommendRoomFilter(room: $0) })
        if let specificRoom = filterRooms[safe: indexPath.row] {
            let specificRoomID = specificRoom.document_id ?? ""
            let logEventData = [
                "roomID": specificRoomID
            ] as [String : Any]
            logEvent(name: "selectNewMatchRoom", logEventData: logEventData)
        }
        //本人確認していない場合は確認ページを表示
        guard let adminIDCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status else {
            popUpIdentificationView()
            return
        }
        if adminIDCheckStatus == 1 {
    
            if let specificRoom = filterRooms[safe: indexPath.row] {
                specificMessageRoomMove(specificRoom: specificRoom)
            }
            
        } else if adminIDCheckStatus == 2 {
           dialog(title: "本人確認失敗しました", subTitle: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", confirmTitle: "OK", completion: { [weak self] confirm in
               guard let weakSelf = self else { return }
               if confirm { weakSelf.popUpIdentificationView() }
           })
       } else {
           alert(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", actiontitle: "OK")
       }
    }
}

class MessageListTableViewCell: UITableViewCell {
    
    // roomに値がセットされたら呼ばれる
    var room: Room? {
        didSet {
            if let room = room {
                // 相手の名前を表示
                partnerLabel.text = "..."
                // 相手の画像を設定
                userImageView.image = UIImage()
                // メッセージ最新投稿日時
                dateLabel.text = ElapsedTime.format(from: room.updated_at.dateValue())
                // 最新のメッセージを判定して、条件分岐
                if room.latest_message == "" && !(room.is_room_opened) {
                    latestMessageLabel.text = "マッチ成立しました！"
                    latestMessageLabel.textColor = UIColor(red: 249/255, green: 102/255, blue: 102/255, alpha: 1.0)
                    latestMessageLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.bold)
                } else if room.latest_message == "" && room.is_room_opened {
                    latestMessageLabel.text = "トークしてみよう！"
                    latestMessageLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
                } else {
                    latestMessageLabel.text = room.latest_message
                    latestMessageLabel.textColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1.0)
                }
                // 未読の場合
                if room.unreadCount > 0 {
                    unreadView.isHidden = false
                    unreadView.image = UIImage(systemName: "circle.fill")
                    unreadView.tintColor = UIColor(named: "AccentColor")
                    unreadLabel.text = "\(room.unreadCount)"
                // 最後に自分がメッセージを送った場合
                } else if room.latest_sender == GlobalVar.shared.loginUser?.uid {
                    unreadView.isHidden = false
                    unreadView.image = UIImage(systemName: "checkmark.circle.fill")
                    unreadView.tintColor = .lightGray
                    unreadLabel.text = ""
                // その他
                } else {
                    unreadView.isHidden = true
                    unreadLabel.text = ""
                }
                // ルームにメッセージ相手がいる場合
                if let partner = room.partnerUser {
                    let partnerNickName = partner.nick_name
                    let partnerProfileIconImg = partner.profile_icon_img
                    if partnerNickName.isEmpty == false {
                        partnerLabel.text = partnerNickName
                    }
                    // 画像設定
                    let isNotMember = (partnerLabel.text != "...")
                    if isNotMember && partnerProfileIconImg.isEmpty == false {
                        userImageView.setImage(withURLString: partnerProfileIconImg)
                    }
                }
            }
        }
    }
        
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var unreadView: UIImageView!
    @IBOutlet weak var unreadLabel: UILabel!
    // カスタムセルを初期化
    override func awakeFromNib() {
        super.awakeFromNib()
        // 未読アイコンを加工
        unreadView.layer.cornerRadius = unreadView.frame.width / 2
        // プロフィールを加工
        userImageView.rounded()
    }
    
    // カスタムセル選択時
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    //アイコンタップ時にユーザー情報表示
    @IBAction func userImageAction(_ sender: UIButton) {
        guard let partner = room?.partnerUser else { return }
        if partner.is_deleted == true { return }
        let storyBoard = UIStoryboard.init(name: "ProfileDetailView", bundle: nil)
        let modalVC = storyBoard.instantiateViewController(withIdentifier: "ProfileDetailView") as! ProfileDetailViewController
        modalVC.user = partner
        modalVC.transitioningDelegate = self
        if let parentVC = parentViewController() as? MessageListViewController {
            parentVC.present(modalVC, animated: true, completion: nil)
        }
    }
    //cellから親viewControllerにアクセス
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }
}


class RecomMsgCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImgView: UIView!
    @IBOutlet weak var bgColorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    var timeLeft: Int = 0

    var room: Room? {
        didSet {
            if let room = room {
                
                iconImage.image = UIImage()
                setGradient()
                
                if let partner = room.partnerUser {
                    let partnerAge = partner.birth_date.calcAge()
                    let partnerAddress = partner.address
                    let partnerProfileIconImg = partner.profile_icon_img
                    userInfo.text = "\(partnerAge) \(partnerAddress)"

                    let isNotMember = (userInfo.text != "...")
                    if isNotMember && partnerProfileIconImg.isEmpty == false {
                        iconImage.setImage(withURLString: partnerProfileIconImg)
                    }
                    
                    let partnerLogined = (partner.is_logined)
                    if partnerLogined {
                        statusLabel.textColor = .green
                    } else {
                        statusLabel.isHidden = true
                    }
                }
                getTimeLeft(created_at: room.created_at)
            }
        }
    }
    //アイコン周りのグラデーション
    func setGradient() {
        //グラデーションをつける
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.userImgView.bounds

        //グラデーションさせるカラーの設定
        //今回は、徐々に色を濃くしていく
        let color1 = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 0.35).cgColor     //白
        let color2 = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0).cgColor   //水色

        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1, color2]

        //グラデーションの開始地点・終了地点の設定
        gradientLayer.startPoint = CGPoint.init(x: 0.25, y: 0.75)
        gradientLayer.endPoint = CGPoint.init(x: 0.75 , y:0.25)

        //ViewControllerのViewレイヤーにグラデーションレイヤーを挿入する
        self.userImgView.layer.insertSublayer(gradientLayer, at: 0)

        userImgView.mask = bgColorLabel
    }
    //残り時間の取得
    func getTimeLeft(created_at: Timestamp) {
        let now = Date()
        let span = now.timeIntervalSince(created_at.dateValue())
        let hourSpan = Int(floor(span/60/60))
        let timeLeft = 24 - hourSpan
        self.timeLeft = timeLeft
        self.timeLeftLabel.text = "残り\(String(self.timeLeft))時間"
=======
        return iconImgURL
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    }
}
