//
//  Message.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/21.
//

import Foundation
import FirebaseFirestore

final class Message {
    var room_id: String
    var text: String
    var photos = [String]()
    var sticker: UIImage?
    var stickerIdentifier: String
    var read: Bool
    var creator: String
    var members = [String]()
    var type: CustomMessageType
    var created_at: Timestamp
    var updated_at: Timestamp
    var is_deleted: Bool
    var reactionEmoji: String
    var reply_message_id: String
    var document_id: String?
    
    init(room_id: String, text: String, photos: [String], sticker: UIImage?, stickerIdentifier: String, read: Bool, creator: String, members: [String],
         type: CustomMessageType, created_at: Timestamp, updated_at: Timestamp, is_deleted: Bool,
         reactionEmoji: String, reply_message_id: String, document_id: String?) {
        self.room_id           = room_id
        self.text              = text
        self.photos            = photos
        self.sticker           = sticker
        self.stickerIdentifier = stickerIdentifier
        self.read              = read
        self.creator           = creator
        self.members           = members
        self.type              = type
        self.created_at        = created_at
        self.updated_at        = updated_at
        self.is_deleted        = is_deleted
        self.reactionEmoji     = reactionEmoji
        self.reply_message_id  = reply_message_id
        self.document_id       = document_id
    }
    
    init(document: QueryDocumentSnapshot) {
        document_id       = document.documentID
        let data          = document.data()
        let typeInt       = data["type"] as? Int ?? 0
        type              = CustomMessageType(rawValue: typeInt) ?? .text
        room_id           = data["room_id"] as? String ?? ""
        text              = data["text"] as? String ?? ""
        photos            = data["photos"] as? [String] ?? [String]()
        stickerIdentifier = data["sticker_identifier"] as? String ?? ""
        read              = data["read"] as? Bool ?? false
        creator           = data["creator"] as? String ?? ""
        members           = data["members"] as? [String] ?? [String]()
        created_at        = data["created_at"] as? Timestamp ?? Timestamp()
        updated_at        = data["updated_at"] as? Timestamp ?? Timestamp()
        is_deleted        = data["is_deleted"] as? Bool ?? false
        reactionEmoji     = data["reaction"] as? String ?? ""
        reply_message_id  = data["reply_message_id"] as? String ?? ""
    }
    
    init(document: DocumentSnapshot) {
        document_id       = document.documentID
        let data          = document.data()
        let typeInt       = data?["type"] as? Int ?? 0
        type              = CustomMessageType(rawValue: typeInt) ?? .text
        room_id           = data?["room_id"] as? String ?? ""
        text              = data?["text"] as? String ?? ""
        photos            = data?["photos"] as? [String] ?? [String]()
        stickerIdentifier = data?["sticker_identifier"] as? String ?? ""
        read              = data?["read"] as? Bool ?? false
        creator           = data?["creator"] as? String ?? ""
        members           = data?["members"] as? [String] ?? [String]()
        created_at        = data?["created_at"] as? Timestamp ?? Timestamp()
        updated_at        = data?["updated_at"] as? Timestamp ?? Timestamp()
        is_deleted        = data?["is_deleted"] as? Bool ?? false
        reactionEmoji     = data?["reaction"] as? String ?? ""
        reply_message_id  = data?["reply_message_id"] as? String ?? ""
    }
}
