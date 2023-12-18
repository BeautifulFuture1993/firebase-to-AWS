//
//  RoomQuery.swift
//  Tauch
//
<<<<<<< HEAD
//  Created by Apple on 2023/05/02.
=======
//  Created by Apple on 2023/05/25.
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
//

import Foundation

class RoomQuery: Codable {
    
    var id: String?
    var members: [String]?
<<<<<<< HEAD
    var latest_message: String?
    var latest_message_id: String?
    var latest_sender: String?
    var creator: String?
    var removed_user: [String]?
    var created_at: Int?
    var updated_at: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case members
        case latest_message
        case latest_message_id
        case latest_sender
        case creator
        case removed_user
        case created_at
        case updated_at
=======
    var latest_message_id: String?
    var latest_message: String?
    var latest_sender: String?
    var send_message: String?
    var creator: String?
    var is_deleted: Bool?
    var is_room_opened: Bool?
    var talk_guide_users: [String]?
    var topic_reply_received: [String]?
    var topic_reply_received_read: [String]?
    var leave_message_received: [String]?
    var leave_message_received_read: [String]?
    var removed_user: [String]?
    var unread: Int?
    var message_num: Int?
    var own_message_num: Int?
    var created_at: Int?
    var updated_at: Int?
    var own_updated_at: Int?
    var skywayToken: String?
    var lastUpdatedAtForSkyWayToken: Int?
    var consective_count: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case members
        case latest_message_id
        case latest_message
        case latest_sender
        case send_message
        case creator
        case is_deleted
        case is_room_opened
        case talk_guide_users
        case topic_reply_received
        case topic_reply_received_read
        case leave_message_received
        case leave_message_received_read
        case removed_user
        case unread
        case message_num
        case own_message_num
        case created_at
        case updated_at
        case own_updated_at
        case skywayToken
        case lastUpdatedAtForSkyWayToken
        case consective_count
        
        var stringValue: String {
            switch self {
            case .id:
                return "id"
            case .members:
                return "members"
            case .latest_message_id:
                return "latest_message_id"
            case .latest_message:
                return "latest_message"
            case .latest_sender:
                return "latest_sender"
            case .send_message:
                return "send_message_\(GlobalVar.shared.loginUser?.uid ?? "")"
            case .creator:
                return "creator"
            case .is_deleted:
                return "is_deleted"
            case .is_room_opened:
                return "is_room_opened_\(GlobalVar.shared.loginUser?.uid ?? "")"
            case .talk_guide_users:
                return "talk_guide_users"
            case .topic_reply_received:
                return "topic_reply_received"
            case .topic_reply_received_read:
                return "topic_reply_received_read"
            case .leave_message_received:
                return "leave_message_received"
            case .leave_message_received_read:
                return "leave_message_received_read"
            case .removed_user:
                return "removed_user"
            case .unread:
                return "unread_\(GlobalVar.shared.loginUser?.uid ?? "")"
            case .message_num:
                return "message_num"
            case .own_message_num:
                return "messageNum_\(GlobalVar.shared.loginUser?.uid ?? "")"
            case .created_at:
                return "created_at"
            case .updated_at:
                return "updated_at"
            case .own_updated_at:
                return "updated_at_\(GlobalVar.shared.loginUser?.uid ?? "")"
            case .skywayToken:
               return "skyway_token"
            case .lastUpdatedAtForSkyWayToken:
                return "last_updated_at_for_skyway_token"
            case .consective_count:
                return "consective_count"
            }
        }
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    }
}
