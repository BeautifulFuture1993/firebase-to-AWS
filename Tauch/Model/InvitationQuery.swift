//
//  InvitationQuery.swift
//  Tauch
//
//  Created by Apple on 2023/05/26.
//

import Foundation

class InvitationQuery: Codable {
    
    var id: String?
    var category: String?
    var date: [String]?
    var area: String?
    var content: String?
    var members: [String]?
    var read_members: [String]?
    var match_members: [String]?
    var ng_members: [String]?
    var creator: String?
    var is_delete_alert: Int?
    var is_deleted: Bool?
    var created_at: Int?
    var updated_at: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case date
        case area
        case content
        case members
        case read_members
        case match_members
        case ng_members
        case creator
        case is_delete_alert
        case is_deleted
        case created_at
        case updated_at
    }
}
