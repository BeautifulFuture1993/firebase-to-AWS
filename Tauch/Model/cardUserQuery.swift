//
//  CardUserQuery.swift
//  Tauch
//
//  Created by Apple on 2023/03/01.
//

import Foundation

class CardUserQuery: Codable {
    
    var uid: String?
    var nick_name: String?
    var type: String?
    var holiday: String?
    var business: String?
    var income: Int?
    var violation_count: Int?
    var birth_date: String?
    var profile_icon_img: String?
    var thumbnail: String?
    var small_thumbnail: String?
    var profile_icon_sub_imgs: [String]?
    var sub_thumbnails: [String]?
    var profile_status: String?
    var address: String?
    var address2: String?
    var hobbies: [String]?
    var is_deleted: Bool?
    var is_activated: Bool?
    var is_logined: Bool?
    var is_rested: Bool?
    var is_withdrawal: Bool?
    var approached: [String]?
    var logouted_at: Int?
    var created_at: Int?
    var updated_at: Int?

    enum CodingKeys: String, CodingKey {
        case uid
        case nick_name
        case type
        case holiday
        case business
        case income
        case violation_count
        case birth_date
        case profile_icon_img
        case thumbnail
        case small_thumbnail
        case profile_icon_sub_imgs
        case sub_thumbnails
        case profile_status
        case address
        case address2
        case hobbies
        case is_deleted
        case is_activated
        case is_logined
        case is_rested
        case is_withdrawal
        case approached
        case logouted_at
        case created_at
        case updated_at
    }
}
