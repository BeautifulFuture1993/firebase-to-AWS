//
//  CardUser.swift
//  Tauch
//
//  Created by Apple on 2023/01/19.
//

import Foundation

struct CardUser: Codable {
    var uid: String
    var phone_number: String
    var nick_name: String
    var type: String
    var holiday: String
    var business: String
    var income: Int
    var email: String
    var gender: Int
    var violation_count: Int
    var birth_date: String
    var profile_icon_img: String
    var thumbnail: String
    var small_thumbnail: String
    var profile_icon_sub_imgs: [String]
    var sub_thumbnails: [String]
    var profile_status: String
    var address: String
    var address2: String
    var hobbies = [String]()
    var peerId: String
    var fcmToken: String
    var deviceToken: String
    var is_approached_notification: Bool
    var is_matching_notification: Bool
    var is_message_notification: Bool
    var is_invitationed_notification: Bool
    var is_dating_notification: Bool
    var is_vibration_notification: Bool
    var is_identification_approval: Bool
    var is_deleted: Bool
    var is_activated: Bool
    var is_logined: Bool
    var is_reviewed: Bool
    var is_rested: Bool
    var is_withdrawal: Bool
    var is_talkguide: Bool
    var approaches = [String]()
    var approacheds = [String]()
    var reply_approacheds = [String]()
    var logouted_at = Date()
    var created_at = Date()
    var updated_at = Date()
    var min_age_filter: Int
    var max_age_filter: Int
    var address_filter = [String]()
    var hobby_filter = [String]()
    
    enum CodingKeys: String, CodingKey {
        case uid
        case phone_number
        case nick_name
        case type
        case holiday
        case business
        case income
        case email
        case gender
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
        case peerId
        case fcmToken
        case deviceToken
        case is_approached_notification
        case is_matching_notification
        case is_message_notification
        case is_invitationed_notification
        case is_dating_notification
        case is_vibration_notification
        case is_identification_approval
        case is_deleted
        case is_activated
        case is_logined
        case is_reviewed
        case is_rested
        case is_withdrawal
        case is_talkguide
        case approaches
        case approacheds
        case reply_approacheds
        case min_age_filter
        case max_age_filter
        case address_filter
        case hobby_filter
        case logouted_at
        case created_at
        case updated_at
    }
    
    init(user: User) {
        uid                          = user.uid
        phone_number                 = user.phone_number
        nick_name                    = user.nick_name
        type                         = user.type
        holiday                      = user.holiday
        business                     = user.business
        income                       = user.income
        email                        = user.email
        gender                       = user.gender
        violation_count              = user.violation_count
        birth_date                   = user.birth_date
        profile_icon_img             = user.profile_icon_img
        thumbnail                    = user.thumbnail
        small_thumbnail              = user.small_thumbnail
        profile_icon_sub_imgs        = user.profile_icon_sub_imgs
        sub_thumbnails               = user.sub_thumbnails
        profile_status               = user.profile_status
        address                      = user.address
        address2                     = user.address2
        hobbies                      = user.hobbies
        peerId                       = user.peerId
        fcmToken                     = user.fcmToken
        deviceToken                  = user.deviceToken
        is_approached_notification   = user.is_approached_notification
        is_matching_notification     = user.is_matching_notification
        is_message_notification      = user.is_message_notification
        is_invitationed_notification = user.is_invitationed_notification
        is_dating_notification       = user.is_dating_notification
        is_vibration_notification    = user.is_vibration_notification
        is_identification_approval   = user.is_identification_approval
        is_deleted                   = user.is_deleted
        is_activated                 = user.is_activated
        is_logined                   = user.is_logined
        is_reviewed                  = user.is_reviewed
        is_rested                    = user.is_rested
        is_withdrawal                = user.is_withdrawal
        is_talkguide                 = user.is_talkguide
        approaches                   = user.approaches
        approacheds                  = user.approacheds
        reply_approacheds            = user.reply_approacheds
        min_age_filter               = user.min_age_filter
        max_age_filter               = user.max_age_filter
        address_filter               = user.address_filter
        hobby_filter                 = user.hobby_filter
        logouted_at                  = user.logouted_at.dateValue()
        created_at                   = user.created_at.dateValue()
        updated_at                   = user.updated_at.dateValue()
    }
}
