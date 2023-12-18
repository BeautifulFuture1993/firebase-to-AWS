//
//  FirebaseController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/13.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseAnalytics
import FirebaseFunctions

class FirebaseController: NSObject {
    
    let db = Firestore.firestore()
    let adminUID = GlobalVar.shared.adminUID
    lazy var functions = Functions.functions()
}
/** 認証関連の処理 **/
extension FirebaseController {
    // SMSコード送信処理
    func sendSMSCode(phoneNumber: String, type: String, completion: @escaping (String?) -> Void) {
        // 電話番号認証をさせるフローに入る
        Auth.auth().languageCode = "ja"; // 認証を日本語対応させる
        let phoneNumber = phoneNumber // 日本の電話番号のみ入力許可する
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            guard let weakSelf = self else { return }
            if let error = error { print(error.localizedDescription); completion(nil)}
            
            if let verificationID = verificationID {
                print("verificationID \(verificationID)")
                // 確認IDをアプリ側で保持しておく
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                // イベント登録
                let logEventData = [
                   "phone_number": phoneNumber
                ] as [String : Any]
                
                switch type {
                case "send":
                    Log.event(name: "sendSMSCode", logEventData: logEventData)
                    break
                case "resend":
                    Log.event(name: "resendSMSCode", logEventData: logEventData)
                    break
                default:
                    break
                }
                // SMSコードを返す
                completion(verificationID)
            } else {
                completion(nil)
            }
        }
    }
    // 画像送信 (非同期 async/await)
    func asyncUploadJPEGImageToStorage(image: UIImage, compressionQuality: CGFloat, creator: String, referenceName: String, folderName: String, fileName: String, customMetadata: [String:String]) async throws -> String? {
        
        guard let uploadImage = image.jpegData(compressionQuality: compressionQuality) else { return nil }
        
        var customMetaData = customMetadata
        customMetaData.updateValue(creator, forKey: "creator")
        
        let storageMetadata = StorageMetadata()
        storageMetadata.contentType = "image/jpeg"
        storageMetadata.customMetadata = customMetaData
        
        let storageRef = Storage.storage().reference().child(referenceName).child(folderName).child(fileName)
        
        let _ = try await storageRef.putDataAsync(uploadImage, metadata: storageMetadata)
        // if let err = err { print("FireStorageへの保存失敗: \(err)"); return "" }
        let url = try await storageRef.downloadURL()
        // if let err = err { print("FireStorageからのダウンロード失敗: \(err)"); completion(""); return }
        return url.absoluteString
    }
    // 画像送信
    func uploadImageToFireStorage(image: UIImage, referenceName: String, folderName: String, fileName: String, customMetadata: [String:String], completion: @escaping (String) -> Void) {
       
        guard let uploadImage = image.jpegData(compressionQuality: 0.8) else { completion(""); return }
        
        let loginUser = GlobalVar.shared.loginUser?.uid ?? ""
        let currentUser = GlobalVar.shared.currentUID ?? ""
        let creator = (loginUser.isEmpty ? currentUser : loginUser)
        
        var customMetaData = customMetadata
        customMetaData.updateValue(creator, forKey: "creator")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = customMetaData
        
        let storageRef = Storage.storage().reference().child(referenceName).child(folderName).child(fileName)
        storageRef.putData(uploadImage, metadata: metadata) { [weak self] (metadata, err) in
            guard let _ = self else { return }
            if let err = err { print("FireStorageへの保存失敗: \(err)"); completion(""); return }
            
            storageRef.downloadURL{ [weak self] (url, err) in
                guard let _ = self else { return }
                if let err = err { print("FireStorageからのダウンロード失敗: \(err)"); completion(""); return }
                
                guard let urlString = url?.absoluteString else { completion(""); return }
                completion(urlString)
            }
        }
    }
    
    /// スタンプをStorageへアップロードする。PNG画像として保存。
    func uploadStickerToFireStorage(sticker: UIImage, referenceName: String, folderName: String, fileName: String, customMetadata: [String:String], completion: @escaping (String) -> Void) {
        guard let uploadSticker = sticker.pngData(),
              let loginUser = GlobalVar.shared.loginUser?.uid,
              let currentUser = GlobalVar.shared.currentUID else { completion(""); return }
        let creator = (loginUser.isEmpty ? currentUser : loginUser)
        
        var customMetaData = customMetadata
        customMetaData.updateValue(creator, forKey: "creator")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        metadata.customMetadata = customMetaData
        
        let storageRef = Storage.storage().reference().child(referenceName).child(folderName).child(fileName)
        storageRef.putData(uploadSticker, metadata: metadata) { [weak self] (metadata, err) in
            guard let _ = self else { return }
            if let err = err { print("FireStorageへの保存失敗: \(err)"); completion(""); return }
            
            storageRef.downloadURL{ [weak self] (url, err) in
                guard let _ = self else { return }
                if let err = err { print("FireStorageからのダウンロード失敗: \(err)"); completion(""); return }
                
                guard let urlString = url?.absoluteString else { completion(""); return }
                completion(urlString)
            }
        }
    }
    
    func uploadIconsToFireStorage(currentUID: String, beforeImages: [UIImage], afterImages: [UIImage], completion: @escaping ([String]) -> Void) {
        
        let loginUser = GlobalVar.shared.loginUser?.uid ?? ""
        let currentUser = GlobalVar.shared.currentUID ?? ""
        let creator = (loginUser.isEmpty ? currentUser : loginUser)
        
        Task {
            var urlDictionary: Dictionary<String,String> = [:]
            var loopCount = 0
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            await afterImages.asyncForEach { image in
                let countString = loopCount == 0 ? "" : String(loopCount)
                if let uploadImage = afterImages[loopCount].jpegData(compressionQuality: 0.8) {

                    if  let beforeSpecificImage = beforeImages[safe: loopCount], let afterSpecificImage = afterImages[safe: loopCount], beforeSpecificImage == afterSpecificImage, let loginUser = GlobalVar.shared.loginUser {

                        if loopCount == 0 {
                            urlDictionary.updateValue(loginUser.profile_icon_img, forKey: countString)
                        } else {
                            urlDictionary.updateValue(loginUser.profile_icon_sub_imgs[loopCount - 1], forKey: countString)
                        }
                        
                        if afterImages.count == urlDictionary.count {
                            var urls = urlDictionary.sorted { $0.0 < $1.0 }.map { $0.value }
                            urls = urls.filter { $0 != "" }
                            completion(urls)
                        }
                        
                    } else {
                        let referenceName = "users"
                        let folderName = "profile"
                        let fileName = "profile_img_\(currentUID)\(countString).jpg"
                        let storageRef = Storage.storage().reference().child(referenceName).child(folderName).child(fileName)
                        let customMetaData = ["type": "profile", "index": countString, "creator": creator]
                        metadata.customMetadata = customMetaData
                        
                        storageRef.putData(uploadImage, metadata: metadata) { [weak self] metadata, error in
                            guard let _ = self else { return }
                            guard error == nil else { return }

                            storageRef.downloadURL{ [weak self] url, error in
                                guard let _ = self else { return }
                                guard error == nil else { return }
                                
                                let urlString = url?.absoluteString ?? ""
                                urlDictionary.updateValue(urlString, forKey: countString)
                                
                                if afterImages.count == urlDictionary.count {
                                    var urls = urlDictionary.sorted { $0.0 < $1.0 }.map { $0.value }
                                    urls = urls.filter { $0 != "" }
                                    completion(urls)
                                }
                            }
                        }
                    }
                    
                    loopCount += 1
                }
            }
        }
    }
    // アプリ評価内容送信
    func addAppReview(userID: String, mail: String, content: String) {
        let sendTime = Timestamp()
        let sendData = [
            "uid": userID,
            "mail": mail,
            "content": content,
            "created_at": sendTime
        ] as [String : Any]
         // アプリ評価内容の追加
         db.collection("reviews").addDocument(data: sendData) { [weak self] err in
             guard let weakSelf = self else { return }
             if let err = err { print("アプリ評価内容の登録に失敗しました: \(err)"); return }
             print("アプリ評価内容の登録完了しました")
             GlobalVar.shared.loginUser?.is_reviewed = true
             weakSelf.db.collection("users").document(userID).updateData(["is_reviewed": true])
             
             let logEventData = [
                "mail": mail,
                "content": content
             ] as [String : Any]
             Log.event(name: "appReview", logEventData: logEventData)
         }
    }
}
/** 通知関連の処理 **/
extension FirebaseController {
    
    // 通知の登録
    func notificationAction(category: Int, creator: String, notificatedUserID: String) {
        // ログインユーザが自分自身に対して通知を出そうとしている時は処理をさせない
        if commonFilter(creatorUID: creator, targetUID: notificatedUserID) == false { return }
        
        let notificationTime = Timestamp()
        let notificationData = [
            "category": category,
            "creator": creator,
            "read": false,
            "created_at": notificationTime,
            "updated_at": notificationTime
        ] as [String : Any]
        // 通知の追加
        db.collection("users").document(notificatedUserID).collection("notices").addDocument(data: notificationData)
        
        let logEventData = [
            "target": notificatedUserID
        ] as [String : Any]
        
        switch category {
        case 3: // ブロック
            Log.event(name: "blockNotification", logEventData: logEventData)
            break
        case 4: // 違反報告
            Log.event(name: "violationNotification", logEventData: logEventData)
            break
        case 8: // 一発停止
            Log.event(name: "stopNotification", logEventData: logEventData)
            break
        case 12: // 退会
            Log.event(name: "withdrawalNotification", logEventData: logEventData)
            break
        default:
            break
        }
   }
    
    // アプローチ登録通知の登録
    func notificationApproachAction(category: Int, creator: String, notificatedUserID: String, approachID: String) {
        // ログインユーザが自分自身に対して通知を出そうとしている時は処理をさせない
        if commonFilter(creatorUID: creator, targetUID: notificatedUserID) == false { return }
        
        let notificationTime = Timestamp()
        let notificationData = [
            "category": category,
            "creator": creator,
            "approach_id": approachID,
            "read": false,
            "created_at": notificationTime,
            "updated_at": notificationTime
        ] as [String : Any]
        // 通知の追加
        db.collection("users").document(notificatedUserID).collection("notices").addDocument(data: notificationData)
        
        let logEventData = [
            "category": category,
            "target": notificatedUserID,
            "approach_id": approachID
        ] as [String : Any]
        Log.event(name: "approachNotification", logEventData: logEventData)
   }
    
    // ルーム登録通知の登録
    func notificationRoomAction(category: Int, creator: String, notificatedUserID: String, roomID: String, messageID: String? = nil) {
        // ログインユーザが自分自身に対して通知を出そうとしている時は処理をさせない
        if commonFilter(creatorUID: creator, targetUID: notificatedUserID) == false { return }
        
        let notificationTime = Timestamp()
        var notificationData = [
            "category": category,
            "creator": creator,
            "room_id": roomID,
            "read": false,
            "created_at": notificationTime,
            "updated_at": notificationTime
        ] as [String : Any]
        
        var logEventData = [
            "category": category,
            "target": notificatedUserID,
            "room_id": roomID
        ] as [String : Any]
        
        if let messageId = messageID {
            notificationData["message_id"] = messageId
            logEventData["message_id"] = messageId
        }
        // 通知の追加
        db.collection("users").document(notificatedUserID).collection("notices").addDocument(data: notificationData)
        
        switch category {
        case 2: // アプローチマッチ
            Log.event(name: "approachMatchNotification", logEventData: logEventData)
            break
        case 11: // お誘いマッチ
            Log.event(name: "invitationMatchNotification", logEventData: logEventData)
            break
        case 18: // 投稿メッセージ
            Log.event(name: "boardSendMessageNotification", logEventData: logEventData)
            break
        default:
            break
        }
   }
    
    // 応募登録通知の登録
    func notificationInvitationAction(category: Int, creator: String, notificatedUserID: String, invitationID: String) {
        // ログインユーザが自分自身に対して通知を出そうとしている時は処理をさせない
        if commonFilter(creatorUID: creator, targetUID: notificatedUserID) == false { return }
        
        let notificationTime = Timestamp()
        let notificationData = [
            "category": category,
            "creator": creator,
            "invitation_id": invitationID,
            "read": false,
            "created_at": notificationTime,
            "updated_at": notificationTime
        ] as [String : Any]
        // 通知の追加
        db.collection("users").document(notificatedUserID).collection("notices").addDocument(data: notificationData)
        
        let logEventData = [
            "category": category,
            "target": notificatedUserID,
            "invitation_id": invitationID
        ] as [String : Any]
        Log.event(name: "invitationApplicationNotification", logEventData: logEventData)
    }
    
    // 足あと登録通知の登録
    func notificationVisitorAction(category: Int, creator: String, notificatedUserID: String, visitorID: String) {
        // ログインユーザが自分自身に対して通知を出そうとしている時は処理をさせない
        if commonFilter(creatorUID: creator, targetUID: notificatedUserID) == false { return }
        
        let notificationTime = Timestamp()
        let notificationData = [
            "category": category,
            "creator": creator,
            "visitor_id": visitorID,
            "read": false,
            "created_at": notificationTime,
            "updated_at": notificationTime
        ] as [String : Any]
        // 通知の追加
        db.collection("users").document(notificatedUserID).collection("notices").addDocument(data: notificationData)
        
        let logEventData = [
            "category": category,
            "target": notificatedUserID,
            "visitor_id": visitorID
        ] as [String : Any]
        Log.event(name: "visitorNotification", logEventData: logEventData)
   }
    // フィルターをかける (ブロック、違反報告、一発停止、削除ユーザ)
    private func commonFilter(creatorUID: String?, targetUID: String?) -> Bool {
        if let creator = creatorUID {
            if GlobalVar.shared.loginUser?.blocks.firstIndex(of: creator) != nil { return false }
            if GlobalVar.shared.loginUser?.violations.firstIndex(of: creator) != nil { return false }
            if GlobalVar.shared.loginUser?.stops.firstIndex(of: creator) != nil { return false }
            if GlobalVar.shared.loginUser?.deleteUsers.firstIndex(of: creator) != nil { return false }
        }
        if let target = targetUID {
            if GlobalVar.shared.loginUser?.blocks.firstIndex(of: target) != nil { return false }
            if GlobalVar.shared.loginUser?.violations.firstIndex(of: target) != nil { return false }
            if GlobalVar.shared.loginUser?.stops.firstIndex(of: target) != nil { return false }
            if GlobalVar.shared.loginUser?.deleteUsers.firstIndex(of: target) != nil { return false }
        }
        if creatorUID == targetUID { return false }
        return true
    }
}
/** メッセージ関連の処理 **/
extension FirebaseController {
    
    func fetchMessageRoomUserInfo(room: Room, uid: String) -> User? {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] (document, error) in
            guard let _ = self else { return }
            if let document = document, document.exists {
                let user = User(document: document)
                room.partnerUser = user
            }
        }
        return room.partnerUser
    }
    
    // メッセージルーム登録 (メンバー => メッセージルーム)
    func messageRoomAction(roomType: String, rooms: [Room], invitation: Invitation? = nil, board: Board? = nil, boardSendText: String? = nil, loginUID: String, targetUID: String, completion: @escaping (String?) -> Void) {
        let sameRooms = rooms.filter({
            let isCurrentUser = $0.members.contains(loginUID)
            let isTargetUser = $0.members.contains(targetUID)
            return isCurrentUser && isTargetUser
        })
        print("マッチング後のルーム追加開始 : \(sameRooms.count)")
        if sameRooms.count == 0 {
            // ルーム情報を登録
            let onlineUser = [String]()
            let removedUser = [String]()
            let registTime = Timestamp()
            var roomData = [
                "members": [loginUID, targetUID],
                "online_user": onlineUser,
                "removed_user": removedUser,
                "unread_\(loginUID)": 0,
                "unread_\(targetUID)": 0,
                "creator": loginUID,
                "created_at": registTime,
                "updated_at": registTime
            ] as [String : Any]
            
            var roomRef: DocumentReference? = nil
            roomRef = db.collection("rooms").addDocument(data: roomData) { [weak self] error in
                if let error = error { print("メッセージルームの追加に失敗しました : \(error)"); completion(nil) }
                guard let weakSelf = self else { completion(nil); return }
                guard let roomID = roomRef?.documentID else { completion(nil); return }
                // ルームの追加
                roomData["room_id"] = roomID
                let room = Room(data: roomData)
                // 自分以外のルーム内のユーザー情報を取得
                room.partnerUser = weakSelf.fetchMessageRoomUserInfo(room: room, uid: targetUID)
                // ルームの追加
                GlobalVar.shared.loginUser?.rooms.append(room)
                // イベント登録
                let logEventData = [
                    "target": targetUID,
                    "room_id": roomID
                ] as [String : Any]
                // アプローチ
                let isApproachType = (roomType == "approach")
                if isApproachType {
                    Log.event(name: "approachMatchCreateRoom", logEventData: logEventData)
                    weakSelf.sendApproachMatchMessageToFirestore(loginUID: loginUID, targetUID: targetUID, roomID: roomID)
                }
                // タイムライン
                let isBoardType = (roomType == "board")
                if isBoardType {
                    Log.event(name: "boardCreateRoom", logEventData: logEventData)
                    if let _board = board, let sendText = boardSendText {
                        weakSelf.sendBoardMessageToFirestore(loginUID: loginUID, targetUID: targetUID, roomID: roomID, board: _board, boardSendText: sendText)
                    }
                }
                // お誘い
                let isInvitationType = (roomType == "invitation")
                if isInvitationType {
                    Log.event(name: "invitationMatchCreateRoom", logEventData: logEventData)
                    if let _invitation = invitation {
                        weakSelf.sendInvitationMatchMessageToFirestore(loginUID: loginUID, targetUID: targetUID, roomID: roomID, invitation: _invitation)
                    }
                }
                completion(roomID)
           }
            
        } else {
            guard let roomID = sameRooms.first?.document_id else { completion(nil); return }
            // タイムライン
            let isBoardType = (roomType == "board")
            if isBoardType {
                if let _board = board, let sendText = boardSendText  {
                    sendBoardMessageToFirestore(loginUID: loginUID, targetUID: targetUID, roomID: roomID, board: _board, boardSendText: sendText)
                }
            }
            // お誘い
            let isInvitationType = (roomType == "invitation")
            if isInvitationType {
                if let _invitation = invitation {
                    sendInvitationMatchMessageToFirestore(loginUID: loginUID, targetUID: targetUID, roomID: roomID, invitation: _invitation)
                }
            }
            completion(roomID)
        }
    }

    private func sendApproachMatchMessageToFirestore(loginUID: String, targetUID: String, roomID: String) {
        
        let autoMessage = GlobalVar.shared.loginUser?.is_auto_message ?? true
        
        if autoMessage {
            
            let sendText = """
            マッチありがとうございます。仲良くしてください♪
            最近、ハマってる事などありますか？？🤗
            """
            sendMessageToFirestore(loginUID: loginUID, targetUID: targetUID, roomID: roomID, sendText: sendText, messageType: "approach")
            
        } else {
            
            let approachedCategory = 2
            notificationRoomAction(category: approachedCategory, creator: loginUID, notificatedUserID: targetUID, roomID: roomID)
        }
    }

    private func sendInvitationMatchMessageToFirestore(loginUID: String, targetUID: String, roomID: String, invitation: Invitation) {
        
        let date = invitation.date.joined(separator: ", ")
        let area = invitation.area ?? "..."
        let content = invitation.content ?? "..."
        
        let sendText = """
        お誘いマッチングしました!
        
        ▽ お誘い内容 ▽
        曜日 : \(date)
        場所 : \(area)
        募集内容 : \(content)
        
        * 詳細はメッセージにてやりとりしてください!
        """
        
        sendMessageToFirestore(loginUID: loginUID, targetUID: targetUID, roomID: roomID, sendText: sendText, messageType: "invitation")
    }
    
    private func sendBoardMessageToFirestore(loginUID: String, targetUID: String, roomID: String, board: Board, boardSendText: String) {
        
        let category = board.category
        let messageText = board.text
        
        let sendText = """
        あなたの投稿にメッセージが届きました!
        
        ▽ 投稿内容 ▽
        カテゴリ : \(category)
        内容 : \(messageText)
        
        ▽ 投稿へのメッセージ ▽
        \(boardSendText)
        """
        
        sendMessageToFirestore(loginUID: loginUID, targetUID: targetUID, roomID: roomID, sendText: sendText, messageType: "board")
    }
    
    private func sendMessageToFirestore(loginUID: String, targetUID: String, roomID: String, sendText: String, messageType: String) {
        
        guard let rooms = GlobalVar.shared.loginUser?.rooms else { return }
        
        let sendTime = Timestamp()
        let sendData = [
            "room_id": roomID,
            "text": sendText,
            "read": false,
            "creator": loginUID,
            "members": [loginUID, targetUID],
            "unread_flg": true,
            "calc_unread_flg": true,
            "created_at": sendTime,
            "updated_at": sendTime
        ] as [String : Any]
        
        for (index, room) in rooms.enumerated() {
            if room.document_id == roomID {
                GlobalVar.shared.loginUser?.rooms[index].latest_message = sendText
                GlobalVar.shared.loginUser?.rooms[index].latest_sender = loginUID
                GlobalVar.shared.loginUser?.rooms[index].unreadCount = 0
                GlobalVar.shared.loginUser?.rooms[index].removed_user = []
                GlobalVar.shared.loginUser?.rooms[index].updated_at = sendTime
            }
        }

        var messageRef: DocumentReference? = nil
        messageRef = db.collection("rooms").document(roomID).collection("messages").addDocument(data: sendData, completion: { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                print("メッセージの保存に失敗しました: \(err)")
                return
            }
            guard let messageID = messageRef?.documentID else { return }
            let removedUser = [String]()
            let latestMessageData = [
                "latest_message_id": messageID,
                "latest_message": sendText,
                "latest_sender": loginUID,
                "unread_\(loginUID)": 0,
                "unread_\(targetUID)": FieldValue.increment(Int64(1)),
                "removed_user": removedUser,
                "creator": loginUID,
                "updated_at": sendTime
            ] as [String : Any]
            weakSelf.db.collection("rooms").document(roomID).updateData(latestMessageData)
            // イベント登録
            let logEventData = [
                "target": targetUID,
                "text": sendText,
                "room_id": roomID,
                "message_id": messageID
            ] as [String : Any]
            
            if messageType == "approach" {
                
                Log.event(name: "approachMatchMessage", logEventData: logEventData)
                
                let approachedCategory = 2
                weakSelf.notificationRoomAction(category: approachedCategory, creator: loginUID, notificatedUserID: targetUID, roomID: roomID)
            }
            if messageType == "board" {
                
                Log.event(name: "boardMessage", logEventData: logEventData)
                
                let approachedCategory = 18
                weakSelf.notificationRoomAction(category: approachedCategory, creator: loginUID, notificatedUserID: targetUID, roomID: roomID, messageID: messageID)
            }
            if messageType == "invitation" {
                Log.event(name: "invitationMatchMessage", logEventData: logEventData)
                
                let invitationedCategory = 11
                weakSelf.notificationRoomAction(category: invitationedCategory, creator: loginUID, notificatedUserID: targetUID, roomID: roomID)
            }
        })
    }
}
/** 違反報告関連の処理 **/
extension FirebaseController {
    // 違反報告する
    func violation(loginUID: String, targetUID: String, content: String, category: String, violationedID: String, completion: @escaping (Bool) -> Void) {
        
        let violations = GlobalVar.shared.loginUser?.violations ?? []
        // すでに違反報告している場合は、これ以降の処理をさせない
        if violations.contains(targetUID) { completion(false); return }
        // 違反報告情報を登録
        let registTime = Timestamp()
        let registData = [
            "category": category,
            "violationedID": violationedID,
            "content": content,
            "target": targetUID,
            "creator": loginUID,
            "admin_check_status": 0,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]
        // 違反報告の追加
        db.collection("violations").addDocument(data: registData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err { print("違反報告追加失敗 : \(err)"); completion(false); return }
            // ユーザが違反報告リストに追加されていない場合
            if GlobalVar.shared.loginUser?.violations.firstIndex(of: targetUID) == nil {
                // 自分を違反報告したユーザを配列に登録
                GlobalVar.shared.loginUser?.violations.append(targetUID)
            }
            // イベント登録
            let logEventData = [
                "target": targetUID,
                "text": content
            ] as [String : Any]
            Log.event(name: "violation", logEventData: logEventData)
            // 違反報告通知の登録
            let violationCategory = 4
            weakSelf.notificationAction(category: violationCategory, creator: loginUID, notificatedUserID: weakSelf.adminUID)
            completion(true)
        }
    }
}
/** ブロック関連の処理 **/
extension FirebaseController {
    // ブロックする
    func block(loginUID: String, targetUID: String, completion: @escaping (Bool) -> Void) {
        
        let blocks = GlobalVar.shared.loginUser?.blocks ?? []
        // すでにブロックしている場合は、これ以降の処理をさせない
        if blocks.contains(targetUID) { completion(false); return }
        // ブロック情報を更新
        let registTime = Timestamp()
        let registData = [
            "target": targetUID,
            "creator": loginUID,
            "admin_check_status": 0,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]
        // ブロックの追加
        db.collection("blocks").addDocument(data: registData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err { print("ブロック追加失敗 : \(err)"); completion(false); return }
            // ユーザがブロックリストに追加されていない場合
            if GlobalVar.shared.loginUser?.blocks.firstIndex(of: targetUID) == nil {
                // 自分をブロックしたユーザを配列に登録
                GlobalVar.shared.loginUser?.blocks.append(targetUID)
            }
            // イベント登録
            let logEventData = [
                "target": targetUID
            ] as [String : Any]
            Log.event(name: "block", logEventData: logEventData)
            // ブロック通知の登録
            let blockCategory = 3
            weakSelf.notificationAction(category: blockCategory, creator: loginUID, notificatedUserID: weakSelf.adminUID)
            completion(true)
        }
    }
}
/** 一発停止申請関連の処理 **/
extension FirebaseController {
    // 一発停止する
    func stop(loginUID: String, targetUID: String, status: Bool, solicitationContent: String, purposeOfSolicitation: String, unpleasantFeelings: String, completion: @escaping (Bool) -> Void) {
        
        let stops = GlobalVar.shared.loginUser?.stops ?? []
        // すでに一発停止している場合は、これ以降の処理をさせない
        if stops.contains(targetUID) { completion(false); return }
        // 一発停止申請情報を登録
        let registTime = Timestamp()
        let registData = [
            "status": status,
            "solicitationContent": solicitationContent,
            "purposeOfSolicitation": purposeOfSolicitation,
            "unpleasantFeelings": unpleasantFeelings,
            "target": targetUID,
            "creator": loginUID,
            "admin_check_status": false,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]
        // 一発停止の追加
        db.collection("stops").addDocument(data: registData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err { print("一発停止追加失敗 : \(err)"); completion(false); return }
            // ユーザが一発停止リストに追加されていない場合
            if GlobalVar.shared.loginUser?.stops.firstIndex(of: targetUID) == nil {
                // 自分が一発停止したユーザを配列に登録
                GlobalVar.shared.loginUser?.stops.append(targetUID)
            }
            // イベント登録
            let logEventData = [
                "target": targetUID,
                "status": status,
                "solicitationContent": solicitationContent,
                "purposeOfSolicitation": purposeOfSolicitation,
                "unpleasantFeelings": unpleasantFeelings
            ] as [String : Any]
            Log.event(name: "stop", logEventData: logEventData)
            // 一発停止通知の登録
            let stopCategory = 8
            weakSelf.notificationAction(category: stopCategory, creator: loginUID, notificatedUserID: weakSelf.adminUID)
            completion(true)
       }
    }
}
/** 退会関連の処理 **/
extension FirebaseController {
    // 退会する
    func withdraw(loginUID: String, nickName: String, email: String, address: String, address2: String, birthDate: String, registedAt: Timestamp, content: String, completion: @escaping (Bool) -> Void) {
        // 退会情報を登録
        let registTime = Timestamp()
        let registData = [
            "uid": loginUID,
            "nick_name": nickName,
            "email": email,
            "address": address,
            "address2": address2,
            "birth_date": birthDate,
            "registed_at": registedAt,
            "content": content,
            "created_at": registTime
        ] as [String : Any]
        // 退会情報の追加
        db.collection("withdrawals").addDocument(data: registData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err { print("退会情報追加失敗 : \(err)"); completion(false); return }
            // イベント登録
            let logEventData = [
                "nick_name": nickName,
                "email": email,
                "address": address,
                "address2": address2,
                "birth_date": birthDate,
                "registed_at": registedAt,
                "content": content
            ] as [String : Any]
            Log.event(name: "withdrawal", logEventData: logEventData)
            // 退会通知の登録
            let withdrawalCategory = 12
            weakSelf.notificationAction(category: withdrawalCategory, creator: loginUID, notificatedUserID: weakSelf.adminUID)
            completion(true)
        }
    }
}
/** アプローチ関連の処理 **/
extension FirebaseController {
    
    // 相手にアプローチを送る
    func approach(loginUID: String, targetUID: String, approachType: String, approachStatus: Int, actionType: String, completion: @escaping (Bool?) -> Void) {

        let approaches = GlobalVar.shared.loginUser?.approaches ?? [String]()
        let approacheds = GlobalVar.shared.loginUser?.approacheds ?? [String]()
        // すでにアプローチした・されている場合は、これ以降の処理をさせない
        if approaches.contains(targetUID) || approacheds.contains(targetUID) { completion(nil); return }
        // アプローチ情報を更新
        let registTime = Timestamp()
        let registData = [
            "target": targetUID,
            "creator": loginUID,
            "status": String(approachStatus),
            "updateFlg": true,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]

        print(loginUID, ":", targetUID, ":", approachType, ":", approachStatus, ":", actionType)
        // アプローチの追加
        var approachRef: DocumentReference? = nil
        approachRef = db.collection("approachs").addDocument(data: registData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err { print("アプローチ エラーログ : \(err)"); completion(false); return }
            guard let approachID = approachRef?.documentID else { print("Not Approach DocumentID"); completion(false); return }

            weakSelf.db.collection("users").document(loginUID).updateData(["approaches": FieldValue.arrayUnion([targetUID])])
            weakSelf.db.collection("users").document(targetUID).updateData(["approached": FieldValue.arrayUnion([loginUID])])

            GlobalVar.shared.loginUser?.approaches.append(targetUID)

            let logEventData = [
                "target": targetUID
            ] as [String : Any]
            // アプローチの通知
            if approachType == "approach" {
                Log.event(name: "approachGood", logEventData: logEventData)
                // 相手に通知の登録
                let approachedCategory = 1
                weakSelf.notificationApproachAction(category: approachedCategory, creator: loginUID, notificatedUserID: targetUID, approachID: approachID)

            } else if approachType == "approachSorry" {
                Log.event(name: "approachSkip", logEventData: logEventData)
            }
            completion(true)
        }
    }
    // アプローチ返信処理
    func approachedReply(loginUID: String, targetUID: String, status: Int, actionType: String, completion: @escaping (Bool) -> Void) {
        /// アプローチ情報を更新
        /// status = 1: マッチングした
        /// status = 2: アプローチNGをした
        let updateTime = Timestamp()
        let updateData = [
            "target": loginUID,
            "creator": targetUID,
            "status": status,
            "updated_at": updateTime
        ] as [String : Any]
        
        db.collection("users").document(loginUID).updateData(["reply_approacheds": FieldValue.arrayUnion([targetUID])])
        GlobalVar.shared.loginUser?.reply_approacheds.append(targetUID)
        
        let logEventData = [
            "target": targetUID
        ] as [String : Any]
        
        switch status {
        case 1: // アプローチマッチング
            Log.event(name: "approachMatch", logEventData: logEventData)
            break
        case 2: // アプローチNG
            Log.event(name: "approachNG", logEventData: logEventData)
            break
        default:
            break
        }
        
        approachedUpdate(creator: targetUID, target: loginUID, updateData: updateData) { result in
            completion(result)
        }
    }
    // アプローチ強制マッチ
    func approachForceMatch(loginUID: String, targetUID: String, completion: @escaping (String) -> Void) {
        
        let approaches = GlobalVar.shared.loginUser?.approaches ?? [String]()
        let approacheds = GlobalVar.shared.loginUser?.approacheds ?? [String]()
        // すでにアプローチしている場合
        if approaches.contains(targetUID) { completion("already-approach"); return }
        if approacheds.contains(targetUID) { // すでにアプローチされている場合
            boardApproachedMatch(loginUID: loginUID, targetUID: targetUID, completion: { result in
                if let res = result, res { completion("approached-match"); return }
                completion("approached-match-error")
            })
        } else { // アプローチ関連がない場合
            boardApproachMatch(loginUID: loginUID, targetUID: targetUID, completion: { result in
                if let res = result, res { completion("approach-match"); return }
                completion("approach-match-error")
            })
        }
    }
    
    private func boardApproachMatch(loginUID: String, targetUID: String, completion: @escaping (Bool?) -> Void) {
        
        let registTime = Timestamp()
        let registData = [
            "target": targetUID,
            "creator": loginUID,
            "status": 1,
            "updateFlg": true,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]

        print("approachForceMatch boardApproachMatch :", loginUID, ":", targetUID)
        // アプローチの追加
        var approachRef: DocumentReference? = nil
        approachRef = db.collection("approachs").addDocument(data: registData) { [weak self] err in
            if let err = err { print("アプローチ エラーログ : \(err)"); completion(false); return }
            guard let _ = approachRef?.documentID else { print("Not Approach DocumentID"); completion(false); return }

            self?.db.collection("users").document(loginUID).updateData(["approaches": FieldValue.arrayUnion([targetUID])])
            self?.db.collection("users").document(targetUID).updateData(["approached": FieldValue.arrayUnion([loginUID])])

            GlobalVar.shared.loginUser?.approaches.append(targetUID)

            let logEventData = [
                "target": targetUID
            ] as [String : Any]

            Log.event(name: "boardMatch", logEventData: logEventData)

            completion(true)
        }
    }
    
    private func boardApproachedMatch(loginUID: String, targetUID: String, completion: @escaping (Bool?) -> Void) {
        /// アプローチ情報を更新
        let updateTime = Timestamp()
        let updateData = [
            "target": loginUID,
            "creator": targetUID,
            "status": 1,
            "updated_at": updateTime
        ] as [String : Any]
        
        print("approachForceMatch boardApproachedMatch :", loginUID, ":", targetUID)
        db.collection("users").document(loginUID).updateData(["reply_approacheds": FieldValue.arrayUnion([targetUID])])
        GlobalVar.shared.loginUser?.reply_approacheds.append(targetUID)
        
        let logEventData = [
            "target": targetUID
        ] as [String : Any]
        
        Log.event(name: "boardMatch", logEventData: logEventData)
        
        approachedUpdate(creator: targetUID, target: loginUID, updateData: updateData) { result in
            completion(result)
        }
    }
    
    func approachedUpdate(creator: String, target: String, updateData: [String:Any], completion: @escaping (Bool) -> Void) {
        
        db.collection("approachs").whereField("creator", isEqualTo: creator).whereField("target", isEqualTo: target).limit(to: 1).getDocuments { [weak self] (querySnapshots, err) in
            guard let weakSelf = self else { completion(false); return }
            if let err = err { print("アプローチされた情報の取得失敗: \(err)"); completion(false); return }
            guard let approachedDocuments = querySnapshots?.documents else { completion(false); return }
            
            let batch = weakSelf.db.batch()
            approachedDocuments.forEach { approachedDocument in
                let approachedID = approachedDocument.documentID
                let approachedRef = weakSelf.db.collection("approachs").document(approachedID)
                batch.updateData(updateData, forDocument: approachedRef)
            }
            
            batch.commit() { err in
                if let err = err {
                    print("アプローチされた情報を更新されませんでした。Error writing batch \(err)")
                    completion(false)
                } else {
                    print("アプローチされた情報を更新されました。Batch write succeeded.")
                    completion(true)
                }
            }
        }
    }
}
/** 募集関連の処理 **/
extension FirebaseController {
    
    // お誘いする
    func invitation(loginUID: String, category: String, date: [String], area: String, content: String, completion: @escaping (Bool) -> Void) {
        // お誘いを登録
        let members = [String]()
        let isDeleted = false
        let registTime = Timestamp()
        let registData = [
            "category": category,
            "date": date,
            "area": area,
            "content": content,
            "members": members,
            "read_members": members,
            "creator": loginUID,
            "is_deleted": isDeleted,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]
        // 募集の追加
        var invitationRef: DocumentReference? = nil
        invitationRef = db.collection("invitations").addDocument(data: registData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                print("募集データ登録失敗 : \(err)")
                completion(false)
                return
            }
            guard let invitationID = invitationRef?.documentID else { completion(false); return }
            
            let logEventData = [
                "invitation_id": invitationID,
                "category": category,
                "date": date,
                "area": area,
                "content": content
            ] as [String : Any]
            Log.event(name: "invitationCreate", logEventData: logEventData)
           
            print("募集データ登録")
           completion(true)
       }
    }
    // お誘い編集
    func invitationEdit(invitationUID: String, loginUID: String, category: String, date: [String], area: String, content: String, completion: @escaping (Bool) -> Void) {
        // お誘いを編集
        let updateTime = Timestamp()
        let updateData = [
            "category": category,
            "date": date,
            "area": area,
            "content": content,
            "updated_at": updateTime
        ] as [String : Any]
        // 募集を編集
        db.collection("invitations").document(invitationUID).updateData(updateData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                print("募集データ編集失敗 : \(err)")
                completion(false)
            }
            print("募集データ編集")
            // イベント登録
            let logEventData = [
                "invitation_id": invitationUID,
                "category": category,
                "date": date,
                "area": area,
                "content": content
            ] as [String : Any]
            Log.event(name: "invitationEdit", logEventData: logEventData)
            
            completion(true)
        }
    }
    // お誘い削除
    func invitationDelete(invitationUID: String, loginUID: String, targetUID: String, completion: @escaping (Bool) -> Void) {
        /// お誘い情報を更新
        let members = [String]()
        let readMembers = [String]()
        let updateData = [
            "members": members,
            "read_members": readMembers,
            "is_deleted": true
        ] as [String : Any]
        
        db.collection("invitations").document(invitationUID).updateData(updateData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                print("お誘い状態の更新に失敗しました: \(err)")
                completion(false)
            }
            print("お誘い状態の更新に成功しました")
            // イベント登録
            let logEventData = [
                "invitation_id": invitationUID
            ] as [String : Any]
            Log.event(name: "invitationDelete", logEventData: logEventData)
            completion(true)
        }
    }
    // 応募する
    func application(invitationUID: String, invitationMembers: [String], loginUID: String, targetUID: String, completion: @escaping (Bool) -> Void) {
        
        let isContainLoginUID = (invitationMembers.contains(loginUID) == true)
        // すでに応募済みのお誘いの場合
        if isContainLoginUID { completion(false) }
        // 応募情報を更新
        let updateData = [
            "members": FieldValue.arrayUnion([loginUID])
        ] as [String : Any]
        // 応募情報の更新
        db.collection("invitations").document(invitationUID).updateData(updateData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err { print("応募データ更新失敗 : \(err)"); completion(false); return }
            // イベント登録
            let logEventData = [
                "invitation_id": invitationUID,
                "target": targetUID
            ] as [String : Any]
            Log.event(name: "invitationApplication", logEventData: logEventData)
            // 応募通知の登録
            let invitationCategory = 10
            weakSelf.notificationInvitationAction(category: invitationCategory, creator: loginUID, notificatedUserID: targetUID, invitationID: invitationUID)
            completion(true)
       }
    }
}

/** 足あと関連の処理 **/
extension FirebaseController {
    // 相手に足あとを送る
    func visitor(loginUID: String, targetUID: String, comment: String = "", commentImg: String = "", forceUpdate: Bool = false) {
        // 自分に足あとをつけない
        if loginUID == targetUID { return }
        
        let visitors = GlobalVar.shared.loginUser?.visitors ?? [Visitor]()
        if let visitor = visitors.filter({ $0.creator == loginUID && $0.target == targetUID }).first {
            updateVisitor(loginUID: loginUID, targetUID: targetUID, visitor: visitor, comment: comment, commentImg: commentImg, forceUpdate: forceUpdate)
        } else {
            preUpdateVisitor(loginUID: loginUID, targetUID: targetUID, comment: comment, commentImg: commentImg, forceUpdate: forceUpdate)
        }
    }
    
    private func addVisitor(loginUID: String, targetUID: String, comment: String = "", commentImg: String = "", forceUpdate: Bool = false) {
        // 足あと情報を登録
        let registTime = Timestamp()
        let registData = [
            "target": targetUID,
            "creator": loginUID,
            "comment": comment,
            "comment_img": commentImg,
            "read": false,
            "updateFlg": true,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]
        
        let visitorID = UUID().uuidString
        
        db.collection("visitors").document(visitorID).setData(registData, merge: true){ [weak self] err in
            guard let self else { return }
            if let err = err {
                // weakSelf.alert(title: "足あと登録エラー", message: "正常に足あと登録されませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
                print("足あと登録エラー : \(err)")
                return
            }
            db.collection("users").document(targetUID).collection("visitors").document(visitorID).setData(registData, merge: true)
            db.collection("users").document(loginUID).collection("visitors").document(visitorID).setData(registData, merge: true)
            print("足あと登録 作成者 :", loginUID, "更新者 :", targetUID)
            let logEventData = [
                "target": targetUID
            ] as [String : Any]
            // 足あとの通知
            Log.event(name: "makeVisitor", logEventData: logEventData)
            // 相手に足あと通知の登録
            notificationVisitor(notificateUID: loginUID, notificatedUID: targetUID, visitorID: visitorID, forceUpdate: forceUpdate)
        }
    }
    
    private func preUpdateVisitor(loginUID: String, targetUID: String, comment: String = "", commentImg: String = "", forceUpdate: Bool = false) {
        
        DispatchQueue.main.async { [weak self] in
            self?.db.collection("visitors").whereField("creator", isEqualTo: loginUID).whereField("target", isEqualTo: targetUID).order(by: "updated_at", descending: true).limit(to: 1).getDocuments { [weak self] (visitorSnapshots, err) in

                guard let weakSelf = self else { return }
                if let err = err { print("足あと情報の取得失敗: \(err)"); return }
                
                // print("足あと更新 事前取得 作成者 :", loginUID, "更新者 :", targetUID)
                
                let visitorDocuments = visitorSnapshots?.documents
                if let _visitorDocuments = visitorDocuments {
                    if _visitorDocuments.isEmpty {
                        weakSelf.addVisitor(loginUID: loginUID, targetUID: targetUID, comment: comment, commentImg: commentImg, forceUpdate: forceUpdate)
                    } else {
                        if let _visitorDocument = _visitorDocuments.first {
                            let visitor = Visitor(document: _visitorDocument)
                            weakSelf.updateVisitor(loginUID: loginUID, targetUID: targetUID, visitor: visitor, comment: comment, commentImg: commentImg, forceUpdate: forceUpdate)
                        }
                    }
                } else {
                    weakSelf.addVisitor(loginUID: loginUID, targetUID: targetUID, comment: comment, commentImg: commentImg, forceUpdate: forceUpdate)
                }
            }
        }
    }
    
    private func updateVisitor(loginUID: String, targetUID: String, visitor: Visitor, comment: String = "", commentImg: String = "", forceUpdate: Bool = false) {
        // 時刻的な差がある場合 (1日以内)
        if elapsedTime(time: visitor.updated_at.dateValue()) < 1440 && forceUpdate == false { return }
        // 足あと情報を更新
        let updateTime = Timestamp()
        let updateData = [
            "comment": comment,
            "comment_img": commentImg,
            "read": false,
            "updated_at": updateTime
        ] as [String : Any]
        
        let visitorID = visitor.document_id
        
        db.collection("visitors").document(visitorID).updateData(updateData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err { print("足あと状態の更新に失敗しました: \(err)"); return }
            print("足あと更新 作成者 :", loginUID, "更新者 :", targetUID)
            
            let logEventData = [
                "target": targetUID
            ] as [String : Any]
            // 足あとの通知
            Log.event(name: "makeVisitor", logEventData: logEventData)
            // 相手に足あと通知の登録
            weakSelf.notificationVisitor(notificateUID: loginUID, notificatedUID: targetUID, visitorID: visitorID, forceUpdate: forceUpdate)
        }
    }
    // 相手に足あと通知の登録
    private func notificationVisitor(notificateUID: String, notificatedUID: String, visitorID: String, forceUpdate: Bool) {
        if forceUpdate {
            let makeVisitorCategory = 17
            notificationVisitorAction(category: makeVisitorCategory, creator: notificateUID, notificatedUserID: notificatedUID, visitorID: visitorID)
        } else {
            let makeVisitorCategory = 16
            notificationVisitorAction(category: makeVisitorCategory, creator: notificateUID, notificatedUserID: notificatedUID, visitorID: visitorID)
        }
    }
    // 経過時間の取得
    func elapsedTime(time: Date) -> Int {
        
        let now = Date()
        let span = now.timeIntervalSince(time)
        
        let minuteSpan = Int(floor(span/60))
        
        return minuteSpan
    }
}

/** 掲示板関連の処理 **/
extension FirebaseController {
    // 投稿の削除
    func boardDelete(boardID: String, targetUID: String, completion: @escaping (Bool) -> Void) {
        
        db.collection("boards").document(boardID).delete() { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                print("投稿の削除に失敗しました: \(err)")
                completion(false)
                return
            }
            print("投稿の削除に成功しました")
            
            GlobalVar.shared.boardTableView.reloadData()
            // イベント登録
            let logEventData = [
                "board_id": boardID,
                "target": targetUID
            ] as [String : Any]
            Log.event(name: "boardDelete", logEventData: logEventData)
            completion(true)
        }
    }
}
