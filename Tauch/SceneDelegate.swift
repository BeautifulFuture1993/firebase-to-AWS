//
//  SceneDelegate.swift
//  Tatibanashi-MVP
//
//  Created by Apple on 2022/05/03.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AudioToolbox
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics
import Typesense
import TikTokOpenSDKCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let viewController = UIViewController()
    let homeVC = HomeViewController()
    let loadingView = UIView(frame: UIScreen.main.bounds)
    let backgroundView = UIView()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        Log.event(name: "scene", logEventData: ["type": "willConnectTo"])
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        Log.event(name: "scene", logEventData: ["type": "didDisConnect"])
    }

    func sceneWillResignActive(_ scene: UIScene) {
        setApplicationIconBadgeNumber()
        logoutUpdated()
        stopBackgroundTask()
        messageRoomStatusUpdate(statusFlg: false)
        removeListener(updateFlg: false)
        Log.event(name: "scene", logEventData: ["type": "willResignActive"])
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        setApplicationIconBadgeNumber()
        loginUpdated()
        listenerUpdateSchedule()
        Log.event(name: "scene", logEventData: ["type": "didBecomeActive"])
    }
    
    func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        logoutUpdated()
        stopBackgroundTask()
        messageRoomStatusUpdate(statusFlg: false)
        removeListener(updateFlg: false)
        
        let logEventData = [
            "type": "didFailToContinueUserActivity",
            "activityType": userActivityType,
            "content": error.localizedDescription
        ]
        Log.event(name: "scene", logEventData: logEventData)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else { return }
        
        let tiktokHandleOpenURL = TikTokURLHandler.handleOpenURL(url)
        if tiktokHandleOpenURL { return }
        
        let scheme = url.scheme
        let host = url.host
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let firstParam = components?.queryItems?.first?.value
        let secondParam = components?.queryItems?[safe: 1]?.value
        // カスタムスキームURLでの遷移
        var customScheme = "touch-app"
        #if PROD // 本番環境
        customScheme = "touch-app"
        #elseif DEV // 検証環境
        customScheme = "tatibanashimvp-app"
        #endif
        if scheme == customScheme {
            // アプローチへの遷移の場合
            if host == "approach" {
                if let _ = firstParam, let specificUID = secondParam {
                    approachMove(specificUID: specificUID)
                }
            }
            // ルームへの遷移の場合
            if host == "room" {
                if let specificRoomID = firstParam {
                    readyForSpecificMessageRoomMove(specificRoomID: specificRoomID)
                }
            }
            // トークガイドを表示
            if host == "guide" {
                if let specificRoomID = firstParam, let talkGuideCategory = secondParam {
                    readyForSpecificTalkGuide(specificRoomID: specificRoomID, talkGuideCategory: talkGuideCategory)
                }
            }
            // 足あとへの遷移の場合
            if host == "visitor" {
                if let specificUID = firstParam {
                    visitorMove(specificUID: specificUID)
                }
            }
            Log.event(name: "openPushNotification", logEventData: ["notification_type": host ?? ""])
        }
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    private func setApplicationIconBadgeNumber() {
        // アプリに表示するバッチの初期化 (メッセージの未読だけカウント)
        let messageBadgeNumber = UserDefaults.standard.integer(forKey: "applicationIconMessageBadgeNumber")
        UIApplication.shared.applicationIconBadgeNumber = messageBadgeNumber
    }
    
    private func loginUpdated() {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let loginUID = loginUser.uid
        let loginEmail = loginUser.email
        let loginNotifiactionEmail = (loginUser.notification_email == "" ? loginEmail : loginUser.notification_email)
        let loginTalkGuide = loginUser.is_talkguide
        let loginAutoMessage = loginUser.is_auto_message
        let loginFriendEmoji = loginUser.is_friend_emoji
        
        let isVisitorNotification = loginUser.is_visitor_notification
        
        let isApproachedMail = loginUser.is_approached_mail
        let isMatchingMail = loginUser.is_matching_mail
        let isMessageMail = loginUser.is_message_mail
        let isInvitationedMail = loginUser.is_invitationed_mail
        let isDatingMail = loginUser.is_dating_mail
        let isVisitorMail = loginUser.is_visitor_mail
        
        let db = Firestore.firestore()
        let updateTime = Timestamp()
        let updateData = [
            "is_logined": true,
            "is_visitor_notification": isVisitorNotification,
            "notification_email": loginNotifiactionEmail,
            "is_talkguide": loginTalkGuide,
            "is_auto_message": loginAutoMessage,
            "is_friend_emoji": loginFriendEmoji,
            "is_approached_mail": isApproachedMail,
            "is_matching_mail": isMatchingMail,
            "is_message_mail": isMessageMail,
            "is_invitationed_mail": isInvitationedMail,
            "is_dating_mail": isDatingMail,
            "is_visitor_mail": isVisitorMail,
            "updated_at": updateTime
        ] as [String : Any]
        db.collection("users").document(loginUID).updateData(updateData) { [weak self] err in
            guard let _ = self else { return }
            if let err = err { print(err); return }
            // ログイン状態の更新
            GlobalVar.shared.loginUser?.is_logined = true
        }
    }
    
    private func logoutUpdated() {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let loginUID = loginUser.uid
        let loginTalkGuide = loginUser.is_talkguide
        let loginAutoMessage = loginUser.is_auto_message
        let loginFriendEmoji = loginUser.is_friend_emoji
        
        let db = Firestore.firestore()
        let updateTime = Timestamp()
        let updateData = [
            "is_logined": false,
            "is_talkguide": loginTalkGuide,
            "is_auto_message": loginAutoMessage,
            "is_friend_emoji": loginFriendEmoji,
            "logouted_at": updateTime,
            "updated_at": updateTime
        ] as [String : Any]
        
        db.collection("users").document(loginUID).updateData(updateData) { [weak self] err in
            guard let _ = self else { return }
            if let err = err { print(err); return }
            // ログイン状態の更新
            GlobalVar.shared.loginUser?.is_logined = false
        }
    }
    
    private func stopBackgroundTask() {
        if GlobalVar.shared.timer != nil {
            GlobalVar.shared.timer?.invalidate()
            GlobalVar.shared.timer = nil
        }
    }
}

extension SceneDelegate {
    // リスナー初期化
    private func initListener() {
        GlobalVar.shared.userAdminCheckStatusListener = nil
        GlobalVar.shared.userDeactiveListener = nil
        GlobalVar.shared.userForceDeactiveListener = nil
        GlobalVar.shared.approachedListener = nil
        GlobalVar.shared.blockListener = nil
        GlobalVar.shared.violationListener = nil
        GlobalVar.shared.stopListener = nil
        GlobalVar.shared.messageListListener = nil
        GlobalVar.shared.messageRoomListener = nil
        GlobalVar.shared.messageRoomTypingListener = nil
        GlobalVar.shared.boardListener = nil
        GlobalVar.shared.visitorListener = nil
        GlobalVar.shared.hobbyCardListener = nil
    }
    
    // リスナーのデタッチ
    private func removeListener(updateFlg: Bool) {
        GlobalVar.shared.userAdminCheckStatusListener?.remove()
        GlobalVar.shared.userDeactiveListener?.remove()
        GlobalVar.shared.userForceDeactiveListener?.remove()
        GlobalVar.shared.approachedListener?.remove()
        GlobalVar.shared.blockListener?.remove()
        GlobalVar.shared.violationListener?.remove()
        GlobalVar.shared.stopListener?.remove()
        GlobalVar.shared.messageListListener?.remove()
        GlobalVar.shared.messageRoomListener?.remove()
        GlobalVar.shared.messageRoomTypingListener?.remove()
        GlobalVar.shared.boardListener?.remove()
        GlobalVar.shared.visitorListener?.remove()
        GlobalVar.shared.hobbyCardListener?.remove()
        // リスナー初期化
        initListener()
        // アプリフォアグラウンド時にリスナーを定期更新する場合
        if updateFlg { viewController.attachListener() }
    }
    
    private func listenerUpdateSchedule() {
        // 28分ごとに処理を行う
        if GlobalVar.shared.timer == nil {
            // print("リスナー バックグラウンドタイマーを設定")
            listenerUpdate()
            // 28分ごと(1680秒)にリスナーを更新
            GlobalVar.shared.timer = Timer.scheduledTimer(timeInterval: 1680, target: self, selector: #selector(listenerUpdate), userInfo: nil, repeats: true)
        }
    }
    
    @objc func listenerUpdate() {
        // リスナーのデタッチ
        removeListener(updateFlg: true)
    }
}
 
extension SceneDelegate {
    
    private func getMessageRoom(roomID: String, talkGuideCategory: String? = nil) {
        
        showLoadingView(loadingView)
        
        Task {
            do {
                let start = Date()
                
                let typesenseClient = GlobalVar.shared.typesenseClient
                let searchFilterBy = "id:= \(roomID)"
                let perPage = 1
                let searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, perPage: perPage)
                let (searchResult, _) = try await typesenseClient.collection(name: "rooms").documents().search(searchParameters, for: RoomQuery.self)

                let elapsed = Date().timeIntervalSince(start)
                print("roomsドキュメント取得時間を計測 : \(elapsed)\n")
                guard let hits = searchResult?.hits else { loadingView.removeFromSuperview(); return }

                let messageRooms = hits.map({ Room(roomQuery: $0) })
                if let messageRoom = messageRooms.first {
                    // ルームやりとりユーザが存在しない場合、これ以降の処理をさせない
                    let loginUID = GlobalVar.shared.loginUser?.uid ?? ""
                    guard let partnerUID = messageRoom.members.filter({ $0 != loginUID }).first else { loadingView.removeFromSuperview(); return }

                    getUser(uid: partnerUID, room: messageRoom, talkGuideCategory: talkGuideCategory)
                    
                } else {
                    loadingView.removeFromSuperview()
                }
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
                loadingView.removeFromSuperview()
            }
        }
    }
    
    private func getInvitation(invitationID: String) {
        
        showLoadingView(loadingView)
        
        Task {
            do {
                let start = Date()
                
                let typesenseClient = GlobalVar.shared.typesenseClient
                let searchFilterBy = "id:= \(invitationID)"
                let perPage = 1
                let searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, perPage: perPage)
                let (searchResult, _) = try await typesenseClient.collection(name: "invitations").documents().search(searchParameters, for: InvitationQuery.self)
                
                let elapsed = Date().timeIntervalSince(start)
                print("invitationsドキュメント取得時間を計測 : \(elapsed)\n")
                
                guard let hits = searchResult?.hits else { loadingView.removeFromSuperview(); return }

                let invitations = hits.map({ Invitation(invitationQuery: $0) })
                if let invitation = invitations.first {
                    // ルームやりとりユーザが存在しない場合、これ以降の処理をさせない
                    guard let invitationCreator = invitation.creator else { loadingView.removeFromSuperview(); return }
                    
                    getUser(uid: invitationCreator, invitation: invitation)
                    
                } else {
                    loadingView.removeFromSuperview()
                }
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
                loadingView.removeFromSuperview()
            }
        }
    }
    
    private func getUser(uid: String, room: Room? = nil, talkGuideCategory: String? = nil, invitation: Invitation? = nil) {
        
        Task {
            do {
                let start = Date()
                
                let typesenseClient = GlobalVar.shared.typesenseClient
                let searchFilterBy = "id:= \(uid)"
                let perPage = 1
                let searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, perPage: perPage)
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParameters, for: CardUserQuery.self)
                
                let elapsed = Date().timeIntervalSince(start)
                print("usersドキュメント取得時間を計測 : \(elapsed)\n")
                guard let hits = searchResult?.hits else { loadingView.removeFromSuperview(); return }

                let users = hits.map({ User(cardUserQuery: $0) })
                
                loadingView.removeFromSuperview()
                
                if let user = users.first {
                    // ルームが存在している場合はルームに遷移させる
                    if let room = room {
                        let roomID = room.document_id ?? ""
                        room.partnerUser = user
                        GlobalVar.shared.specificRoom = room
                        GlobalVar.shared.backgroundClassName = ["MessageListViewController", "MessageRoomView"]

                        if let talkGuideCategory = talkGuideCategory {
                            specificTalkGuide(specificRoomID: roomID, talkGuideCategory: talkGuideCategory)
                        } else {
                            tabBarVCMove(selectedIndex: 2, setKey: "specificRoomID", setValue: roomID)
                        }
                    }
                    // お誘いが存在している場合はお誘いに遷移させる
                    if let invitation = invitation {
                        let invitationID = invitation.document_id ?? ""
                        invitation.userInfo = user
                        GlobalVar.shared.specificInvitation = invitation
                        GlobalVar.shared.backgroundClassName = ["InvitationViewController", "InvitationDetailViewController"]
                        tabBarVCMove(selectedIndex: 3, setKey: "specificInvitationID", setValue: invitationID)
                    }
                }
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
                loadingView.removeFromSuperview()
            }
        }
    }
}

extension SceneDelegate {
    
    private func tabBarVCMove(selectedIndex: Int, setKey: String, setValue: String) {
        
        switch selectedIndex {
        case 1, 2, 3, 4: // アプローチされた、メッセージ、足あと、お誘いタブ
            UserDefaults.standard.set(setValue, forKey: setKey)
            UserDefaults.standard.synchronize()
            break
        default:
            break
        }
        
        let tabBarController = CustomTabBarController()
        tabBarController.selectedIndex = selectedIndex
        GlobalVar.shared.tabBarVC = tabBarController
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    private func approachMove(specificUID: String) {
        GlobalVar.shared.backgroundClassName = ["HomeViewController"]
        if let _ = GlobalVar.shared.loginUser { homeVC.getApproachedCardUsers(specificUID: specificUID) }
        tabBarVCMove(selectedIndex: 1, setKey: "specificUID", setValue: specificUID)
    }
    
    private func readyForSpecificMessageRoomMove(specificRoomID: String) {
        getMessageRoom(roomID: specificRoomID)
    }
    
    private func readyForSpecificTalkGuide(specificRoomID: String, talkGuideCategory: String) {
        if specificRoomID == "custom" {
            GlobalVar.shared.backgroundClassName = ["MessageListViewController", "TalkGuideViewController"]
            specificTalkGuide(specificRoomID: specificRoomID, talkGuideCategory: talkGuideCategory)
            return
        }
        getMessageRoom(roomID: specificRoomID, talkGuideCategory: talkGuideCategory)
    }
    
    private func specificTalkGuide(specificRoomID: String, talkGuideCategory: String) {
        // メッセージ一覧画面に遷移
        tabBarVCMove(selectedIndex: 2, setKey: "specificRoomID", setValue: specificRoomID)
        // お話ガイドを表示させる準備
        GlobalVar.shared.showTalkGuide = true
        GlobalVar.shared.talkGuideCategory = talkGuideCategory
    }
    
    private func readyForSpecificInvitationDetailMove(specificInvitationID: String) {
        getInvitation(invitationID: specificInvitationID)
    }
    
    private func visitorMove(specificUID: String) {
        GlobalVar.shared.backgroundClassName = ["VisitorViewController"]
        tabBarVCMove(selectedIndex: 4, setKey: "specificVisitorID", setValue: specificUID)
    }
    
    private func onlineUserUpdate(statusFlg: Bool) {
        guard let currentUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let roomID = GlobalVar.shared.specificRoom?.document_id else { return }
        let db = Firestore.firestore()
        if statusFlg { // ルームオンライン状態の場合
            db.collection("rooms").document(roomID).updateData([
                "online_user": FieldValue.arrayUnion([currentUID]),
                "unread_\(currentUID)": 0,
            ])
        } else { // ルームオフライン状態の場合
            db.collection("rooms").document(roomID).updateData([
                "online_user": FieldValue.arrayRemove([currentUID]),
                "unread_\(currentUID)": 0,
            ])
        }
    }
    
    private func messageRoomStatusUpdate(statusFlg: Bool) {
        
        guard let currentUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let roomID = GlobalVar.shared.specificRoom?.document_id else { return }
        
        let sendMessage = GlobalVar.shared.specificRoom?.send_message ?? ""
        
        let db = Firestore.firestore()
        
        var updateRoomData = [
            "send_message_\(currentUID)": sendMessage
        ] as [String:Any]
        
        if statusFlg { // ルームオンライン状態の場合
            updateRoomData["online_user"] = FieldValue.arrayUnion([currentUID])
        } else { // ルームオフライン状態の場合
            updateRoomData["online_user"] = FieldValue.arrayRemove([currentUID])
        }
        
        db.collection("rooms").document(roomID).updateData(updateRoomData)
    }
}

extension SceneDelegate {
    // ローディング画面を表示
    func showLoadingView(_ loadingView: UIView, text: String = "", color: UIColor = .accentColor) {
        
        loadingView.backgroundColor = .white.withAlphaComponent(0.5)
        let indicator = UIActivityIndicatorView()
        indicator.center = loadingView.center
        indicator.style = .large
        indicator.color = color
        indicator.startAnimating()
        loadingView.addSubview(indicator)
        guard let windowFirst = Window.first else { return }
        
        if text != "" {
            backgroundView.backgroundColor = .white
            backgroundView.layer.cornerRadius = 10
            backgroundView.setShadow()
            loadingView.addSubview(backgroundView)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.widthAnchor.constraint(equalToConstant: 150).isActive = true
            backgroundView.heightAnchor.constraint(equalToConstant: 150).isActive = true
            backgroundView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
            backgroundView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
            
            let textLabel = UILabel()
            textLabel.text = text
            textLabel.font = .boldSystemFont(ofSize: 16)
            textLabel.textColor = color
            backgroundView.addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            textLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
            textLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 110).isActive = true
            
            do {
                let gif = try UIImage(gifName: "Bean.gif")
                let imageView = UIImageView(gifImage: gif)
                loadingView.addSubview(imageView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
                imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 5).isActive = true
            } catch {
                print("gifエラー\(error)")
            }
        }
        
        windowFirst.addSubview(loadingView)
    }
}
