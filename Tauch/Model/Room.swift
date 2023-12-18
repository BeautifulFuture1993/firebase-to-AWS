//
//  Room.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/21.
//

import Foundation
import FirebaseFirestore
<<<<<<< HEAD
import MessageKit
=======
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
import Typesense

class Room {
    var members: [String]
    var latest_message_id: String
    var latest_message: String?
    var latest_sender: String?
    var send_message: String?
    var creator: String
    var is_deleted: Bool
    var is_room_opened: Bool
    var talk_guide_users: [String]
    var topic_reply_received: [String]
    var topic_reply_received_read: [String]
    var leave_message_received: [String]
    var leave_message_received_read: [String]
    var removed_user: [String]
    var unread: Int
    var message_num: Int
    var own_message_num: Int
    let created_at: Timestamp
    var updated_at: Timestamp
<<<<<<< HEAD
    var is_room_opened: Bool
    
=======
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    var document_id: String?
    var skywayToken: String?
    var lastUpdatedAtForSkyWayToken: Int
    var consectiveCount: Int
    // DBには反映させていないが処理のためインスタンス内にデータとして持つ
    var messages: [Message]?
    var partnerUser: User?
    var unreadCount = 0
    
    init(document: QueryDocumentSnapshot) {
<<<<<<< HEAD
        let currentUID         = GlobalVar.shared.loginUser?.uid ?? ""
        self.document_id       = document.documentID
        let data               = document.data()
        self.members           = data["members"] as? [String] ?? []
        self.latest_message_id = data["latest_message_id"] as? String ?? ""
        self.latest_message    = data["latest_message"] as? String ?? ""
        self.latest_sender     = data["latest_sender"] as? String ?? ""
        self.send_message      = data["send_message_\(currentUID)"] as? String ?? ""
        self.creator           = data["creator"] as? String ?? ""
        self.is_deleted        = data["is_deleted"] as? Bool ?? false
        self.removed_user      = data["removed_user"] as? [String] ?? []
        self.unread            = data["unread_\(currentUID)"] as? Int ?? 0
        self.created_at        = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at        = data["updated_at"] as? Timestamp ?? Timestamp()
        self.is_room_opened    = data["is_room_opened_\(currentUID)"] as? Bool ?? false
    }
    
    init(document: DocumentSnapshot) {
        let currentUID         = GlobalVar.shared.loginUser?.uid ?? ""
        self.document_id       = document.documentID
        let data               = document.data()
        self.members           = data?["members"] as? [String] ?? []
        self.latest_message_id = data?["latest_message_id"] as? String ?? ""
        self.latest_message    = data?["latest_message"] as? String ?? ""
        self.latest_sender     = data?["latest_sender"] as? String ?? ""
        self.send_message      = data?["send_message_\(currentUID)"] as? String ?? ""
        self.creator           = data?["creator"] as? String ?? ""
        self.is_deleted        = data?["is_deleted"] as? Bool ?? false
        self.removed_user      = data?["removed_user"] as? [String] ?? []
        self.unread            = data?["unread_\(currentUID)"] as? Int ?? 0
        self.created_at        = data?["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at        = data?["updated_at"] as? Timestamp ?? Timestamp()
        self.is_room_opened    = data?["is_room_opened_\(currentUID)"] as? Bool ?? false
    }
    
    init(data: [String:Any]) {
        let currentUID         = GlobalVar.shared.loginUser?.uid ?? ""
        self.document_id       = data["room_id"] as? String ?? ""
        self.members           = data["members"] as? [String] ?? []
        self.latest_message_id = data["latest_message_id"] as? String ?? ""
        self.latest_message    = data["latest_message"] as? String ?? ""
        self.latest_sender     = data["latest_sender"] as? String ?? ""
        self.send_message      = data["send_message_\(currentUID)"] as? String ?? ""
        self.creator           = data["creator"] as? String ?? ""
        self.is_deleted        = data["is_deleted"] as? Bool ?? false
        self.removed_user      = data["removed_user"] as? [String] ?? []
        self.unread            = data["unread_\(currentUID)"] as? Int ?? 0
        self.created_at        = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at        = data["updated_at"] as? Timestamp ?? Timestamp()
        self.is_room_opened    = data["is_room_opened_\(currentUID)"] as? Bool ?? false
    }
    
    init(roomQuery: SearchResultHit<RoomQuery>) {
        let roomQueryDocument  = roomQuery.document
        document_id            = roomQueryDocument?.id ?? ""
        members                = roomQueryDocument?.members ?? []
        latest_message_id      = roomQueryDocument?.latest_message_id ?? ""
        latest_message         = roomQueryDocument?.latest_message ?? ""
        latest_sender          = roomQueryDocument?.latest_sender ?? ""
        removed_user           = roomQueryDocument?.removed_user ?? []
        creator                = roomQueryDocument?.creator ?? ""
        is_deleted             = false
        is_room_opened         = false
        unread                 = 0
        let created_at_int     = roomQueryDocument?.created_at ?? 0
        let updated_at_int     = roomQueryDocument?.updated_at ?? 0
        let created_at_date    = created_at_int.dateFromInt()
        let updated_at_date    = updated_at_int.dateFromInt()
        created_at             = Timestamp(date: created_at_date)
        updated_at             = Timestamp(date: updated_at_date)
=======
        let currentUID                   = GlobalVar.shared.loginUser?.uid ?? ""
        self.document_id                 = document.documentID
        let data                         = document.data()
        self.members                     = data["members"] as? [String] ?? []
        self.latest_message_id           = data["latest_message_id"] as? String ?? ""
        self.latest_message              = data["latest_message"] as? String ?? ""
        self.latest_sender               = data["latest_sender"] as? String ?? ""
        self.send_message                = data["send_message_\(currentUID)"] as? String ?? ""
        self.creator                     = data["creator"] as? String ?? ""
        self.is_deleted                  = data["is_deleted"] as? Bool ?? false
        self.is_room_opened              = data["is_room_opened_\(currentUID)"] as? Bool ?? false
        self.talk_guide_users            = data["talk_guide_users"] as? [String] ?? []
        self.topic_reply_received        = data["topic_reply_received"] as? [String] ?? []
        self.topic_reply_received_read   = data["topic_reply_received_read"] as? [String] ?? []
        self.leave_message_received      = data["leave_message_received"] as? [String] ?? []
        self.leave_message_received_read = data["leave_message_received_read"] as? [String] ?? []
        self.removed_user                = data["removed_user"] as? [String] ?? []
        self.unread                      = data["unread_\(currentUID)"] as? Int ?? 0
        self.message_num                 = data["message_num"] as? Int ?? 0
        self.own_message_num             = data["messageNum_\(currentUID)"] as? Int ?? 0
        self.created_at                  = data["created_at"] as? Timestamp ?? Timestamp()
        let updatedAt                    = data["updated_at"] as? Timestamp ?? Timestamp()
        let ownUpdatedAt                 = data["updated_at_\(currentUID)"] as? Timestamp ?? updatedAt
        self.updated_at                  = (ownUpdatedAt.dateValue() > updatedAt.dateValue() ? ownUpdatedAt : updatedAt)
        self.skywayToken                 = document["skyway_token"] as? String ?? ""
        self.lastUpdatedAtForSkyWayToken = document["last_updated_at_for_skyway_token"] as? Int ?? 0
        self.consectiveCount             = document["consective_count"] as? Int ?? 0
    }
    
    init(document: DocumentSnapshot) {
        let currentUID                   = GlobalVar.shared.loginUser?.uid ?? ""
        self.document_id                 = document.documentID
        let data                         = document.data()
        self.members                     = data?["members"] as? [String] ?? []
        self.latest_message_id           = data?["latest_message_id"] as? String ?? ""
        self.latest_message              = data?["latest_message"] as? String ?? ""
        self.latest_sender               = data?["latest_sender"] as? String ?? ""
        self.send_message                = data?["send_message_\(currentUID)"] as? String ?? ""
        self.creator                     = data?["creator"] as? String ?? ""
        self.is_deleted                  = data?["is_deleted"] as? Bool ?? false
        self.is_room_opened              = data?["is_room_opened_\(currentUID)"] as? Bool ?? false
        self.talk_guide_users            = data?["talk_guide_users"] as? [String] ?? []
        self.topic_reply_received        = data?["topic_reply_received"] as? [String] ?? []
        self.topic_reply_received_read   = data?["topic_reply_received_read"] as? [String] ?? []
        self.leave_message_received      = data?["leave_message_received"] as? [String] ?? []
        self.leave_message_received_read = data?["leave_message_received_read"] as? [String] ?? []
        self.removed_user                = data?["removed_user"] as? [String] ?? []
        self.unread                      = data?["unread_\(currentUID)"] as? Int ?? 0
        self.message_num                 = data?["message_num"] as? Int ?? 0
        self.own_message_num             = data?["messageNum_\(currentUID)"] as? Int ?? 0
        self.created_at                  = data?["created_at"] as? Timestamp ?? Timestamp()
        let updatedAt                    = data?["updated_at"] as? Timestamp ?? Timestamp()
        let ownUpdatedAt                 = data?["updated_at_\(currentUID)"] as? Timestamp ?? updatedAt
        self.updated_at                  = (ownUpdatedAt.dateValue() > updatedAt.dateValue() ? ownUpdatedAt : updatedAt)
        self.skywayToken                 = document["skyway_token"] as? String ?? ""
        self.lastUpdatedAtForSkyWayToken = document["last_updated_at_for_skyway_token"] as? Int ?? 0
        self.consectiveCount             = document["consective_count"] as? Int ?? 0
    }
    
    init(data: [String:Any]) {
        let currentUID                   = GlobalVar.shared.loginUser?.uid ?? ""
        self.document_id                 = data["room_id"] as? String ?? ""
        self.members                     = data["members"] as? [String] ?? []
        self.latest_message_id           = data["latest_message_id"] as? String ?? ""
        self.latest_message              = data["latest_message"] as? String ?? ""
        self.latest_sender               = data["latest_sender"] as? String ?? ""
        self.send_message                = data["send_message_\(currentUID)"] as? String ?? ""
        self.creator                     = data["creator"] as? String ?? ""
        self.is_deleted                  = data["is_deleted"] as? Bool ?? false
        self.is_room_opened              = data["is_room_opened_\(currentUID)"] as? Bool ?? false
        self.talk_guide_users            = data["talk_guide_users"] as? [String] ?? []
        self.topic_reply_received        = data["topic_reply_received"] as? [String] ?? []
        self.topic_reply_received_read   = data["topic_reply_received_read"] as? [String] ?? []
        self.leave_message_received      = data["leave_message_received"] as? [String] ?? []
        self.leave_message_received_read = data["leave_message_received_read"] as? [String] ?? []
        self.removed_user                = data["removed_user"] as? [String] ?? []
        self.unread                      = data["unread_\(currentUID)"] as? Int ?? 0
        self.message_num                 = data["message_num"] as? Int ?? 0
        self.own_message_num             = data["messageNum_\(currentUID)"] as? Int ?? 0
        self.created_at                  = data["created_at"] as? Timestamp ?? Timestamp()
        let updatedAt                    = data["updated_at"] as? Timestamp ?? Timestamp()
        let ownUpdatedAt                 = data["updated_at_\(currentUID)"] as? Timestamp ?? updatedAt
        self.updated_at                  = (ownUpdatedAt.dateValue() > updatedAt.dateValue() ? ownUpdatedAt : updatedAt)
        self.skywayToken                 = data["skyway_token"] as? String ?? ""
        self.lastUpdatedAtForSkyWayToken = data["last_updated_at_for_skyway_token"] as? Int ?? 0
        self.consectiveCount             = data["consective_count"] as? Int ?? 0
    }
    
    init(roomQuery: SearchResultHit<RoomQuery>) {
        let roomQueryDocument       = roomQuery.document
        document_id                 = roomQueryDocument?.id ?? ""
        members                     = roomQueryDocument?.members ?? [String]()
        latest_message_id           = roomQueryDocument?.latest_message_id ?? ""
        latest_message              = roomQueryDocument?.latest_message ?? ""
        latest_sender               = roomQueryDocument?.latest_sender ?? ""
        send_message                = roomQueryDocument?.send_message ?? ""
        creator                     = roomQueryDocument?.creator ?? ""
        is_deleted                  = roomQueryDocument?.is_deleted ?? false
        is_room_opened              = roomQueryDocument?.is_room_opened ?? false
        talk_guide_users            = roomQueryDocument?.talk_guide_users ?? [String]()
        topic_reply_received        = roomQueryDocument?.topic_reply_received ?? [String]()
        topic_reply_received_read   = roomQueryDocument?.topic_reply_received_read ?? [String]()
        leave_message_received      = roomQueryDocument?.leave_message_received ?? [String]()
        leave_message_received_read = roomQueryDocument?.leave_message_received_read ?? [String]()
        removed_user                = roomQueryDocument?.removed_user ?? [String]()
        unread                      = roomQueryDocument?.unread ?? 0
        unreadCount                 = roomQueryDocument?.unread ?? 0
        message_num                 = roomQueryDocument?.message_num ?? 0
        own_message_num             = roomQueryDocument?.own_message_num ?? 0
        let created_at_int          = roomQueryDocument?.created_at ?? 0
        let updated_at_int          = roomQueryDocument?.updated_at ?? 0
        let own_updated_at_int      = roomQueryDocument?.own_updated_at ?? 0
        let updatedAt               = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
        let ownUpdatedAt            = Timestamp(seconds: Int64(own_updated_at_int), nanoseconds: Int32(0))
        created_at                  = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at                  = (own_updated_at_int > updated_at_int ? ownUpdatedAt : updatedAt)
        skywayToken                 = roomQueryDocument?.skywayToken ?? ""
        lastUpdatedAtForSkyWayToken = roomQueryDocument?.lastUpdatedAtForSkyWayToken ?? 0
        consectiveCount             = roomQueryDocument?.consective_count ?? 0
    }
    
    init(roomQuery: RoomQuery) {
        document_id                 = roomQuery.id ?? ""
        members                     = roomQuery.members ?? [String]()
        latest_message_id           = roomQuery.latest_message_id ?? ""
        latest_message              = roomQuery.latest_message ?? ""
        latest_sender               = roomQuery.latest_sender ?? ""
        send_message                = roomQuery.send_message ?? ""
        creator                     = roomQuery.creator ?? ""
        is_deleted                  = roomQuery.is_deleted ?? false
        is_room_opened              = roomQuery.is_room_opened ?? false
        talk_guide_users            = roomQuery.talk_guide_users ?? [String]()
        topic_reply_received        = roomQuery.topic_reply_received ?? [String]()
        topic_reply_received_read   = roomQuery.topic_reply_received_read ?? [String]()
        leave_message_received      = roomQuery.leave_message_received ?? [String]()
        leave_message_received_read = roomQuery.leave_message_received_read ?? [String]()
        removed_user                = roomQuery.removed_user ?? [String]()
        unread                      = roomQuery.unread ?? 0
        unreadCount                 = roomQuery.unread ?? 0
        message_num                 = roomQuery.message_num ?? 0
        own_message_num             = roomQuery.own_message_num ?? 0
        let created_at_int          = roomQuery.created_at ?? 0
        let updated_at_int          = roomQuery.updated_at ?? 0
        let own_updated_at_int      = roomQuery.own_updated_at ?? 0
        let updatedAt               = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
        let ownUpdatedAt            = Timestamp(seconds: Int64(own_updated_at_int), nanoseconds: Int32(0))
        created_at                  = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at                  = (own_updated_at_int > updated_at_int ? ownUpdatedAt : updatedAt)
        skywayToken                 = roomQuery.skywayToken ?? ""
        lastUpdatedAtForSkyWayToken = roomQuery.lastUpdatedAtForSkyWayToken ?? 0
        consectiveCount             = roomQuery.consective_count ?? 0
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    }
}
