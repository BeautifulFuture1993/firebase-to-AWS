//
//  User.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/13.
//

import Foundation
import FirebaseFirestore
import Typesense

class User {
    
    var uid: String
    var phone_number: String
    var nick_name: String
    var type: String
    var holiday: String
    var business: String
    var income: Int
    var email: String
    var notification_email: String
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
    var is_visitor_notification: Bool
    var is_invitationed_notification: Bool
    var is_dating_notification: Bool
    var is_approached_mail: Bool
    var is_matching_mail: Bool
    var is_message_mail: Bool
    var is_visitor_mail: Bool
    var is_invitationed_mail: Bool
    var is_dating_mail: Bool
    var is_vibration_notification: Bool
    var is_identification_approval: Bool
    var is_deleted: Bool
    var is_activated: Bool
    var is_logined: Bool
    var is_init_reviewed: Bool
    var is_reviewed: Bool
    var is_rested: Bool
    var is_withdrawal: Bool
    var is_tutorial: Bool
    var tutorial_num: Int
    var is_talkguide: Bool
    var is_auto_message: Bool
    var is_display_ranking_talkguide: Bool = false
    var is_friend_emoji: Bool
    var approaches = [String]()
    var approacheds = [String]()
    var reply_approacheds = [String]()
    var logouted_at: Timestamp
    let created_at: Timestamp
    let updated_at: Timestamp
    var min_age_filter: Int
    var max_age_filter: Int
    var address_filter = [String]()
    var hobby_filter = [String]()
    
    var admin_checks: AdminCheck?
    /// DBには反映させていないが処理のためインスタンス内にデータとして持つ
    var profileIconImg = UIImageView()
    var profileIconSubFirstImg = UIImageView()
    var profileIconSubSecondImg = UIImageView()
    var cardUsers = [User]()
    var blocks = [String]()
    var violations = [String]()
    var stops = [String]()
    var approached = [Approach]()
    var rooms = [Room]()
    var visitors = [Visitor]()
    var visitorUnreadList = [String]()
    var invitations = [Invitation]()
    var invitationeds = [Invitation]()
    var deleteUsers = [String]()
    var deactivateUsers = [String]()
    // 相手ユーザとの距離をモデルで保持
    var distance: Int?
    
    init(document: QueryDocumentSnapshot) {
        let data                     = document.data()
        uid                          = document.documentID
        phone_number                 = data["phone_number"] as? String ?? ""
        nick_name                    = data["nick_name"] as? String ?? ""
        type                         = data["type"] as? String ?? "未設定"
        holiday                      = data["holiday"] as? String ?? "未設定"
        business                     = data["business"] as? String ?? "未設定"
        income                       = data["income"] as? Int ?? 0
        email                        = data["email"] as? String ?? ""
        notification_email           = data["notification_email"] as? String ?? ""
        gender                       = data["gender"] as? Int ?? 0
        violation_count              = data["violation_count"] as? Int ?? 0
        birth_date                   = data["birth_date"] as? String ?? ""
        profile_icon_img             = data["profile_icon_img"] as? String ?? ""
        thumbnail                    = data["thumbnail"] as? String ?? ""
        small_thumbnail              = data["small_thumbnail"] as? String ?? ""
        profile_icon_sub_imgs        = data["profile_icon_sub_imgs"] as? [String] ?? []
        sub_thumbnails               = data["sub_thumbnails"] as? [String] ?? []
        profile_status               = data["profile_status"] as? String ?? ""
        address                      = data["address"] as? String ?? ""
        address2                     = data["address2"] as? String ?? ""
        hobbies                      = data["hobbies"] as? [String] ?? [String]()
        peerId                       = data["peerId"] as? String ?? ""
        fcmToken                     = data["fcmToken"] as? String ?? ""
        deviceToken                  = data["deviceToken"] as? String ?? ""
        is_approached_notification   = data["is_approached_notification"] as? Bool ?? true
        is_matching_notification     = data["is_matching_notification"] as? Bool ?? true
        is_message_notification      = data["is_message_notification"] as? Bool ?? true
        is_visitor_notification      = data["is_visitor_notification"] as? Bool ?? true
        is_vibration_notification    = data["is_vibration_notification"] as? Bool ?? true
        is_identification_approval   = data["is_identification_approval"] as? Bool ?? false
        is_invitationed_notification = data["is_invitationed_notification"] as? Bool ?? true
        is_dating_notification       = data["is_dating_notification"] as? Bool ?? true
        is_approached_mail           = data["is_approached_mail"] as? Bool ?? true
        is_matching_mail             = data["is_matching_mail"] as? Bool ?? true
        is_message_mail              = data["is_message_mail"] as? Bool ?? true
        is_visitor_mail              = data["is_visitor_mail"] as? Bool ?? true
        is_invitationed_mail         = data["is_invitationed_mail"] as? Bool ?? true
        is_dating_mail               = data["is_dating_mail"] as? Bool ?? true
        is_deleted                   = data["is_deleted"] as? Bool ?? false
        is_activated                 = data["is_activated"] as? Bool ?? true
        is_logined                   = data["is_logined"] as? Bool ?? false
        is_init_reviewed             = data["is_init_reviewed"] as? Bool ?? false
        is_reviewed                  = data["is_reviewed"] as? Bool ?? false
        is_rested                    = data["is_rested"] as? Bool ?? false
        is_withdrawal                = data["is_withdrawal"] as? Bool ?? false
        is_tutorial                  = data["is_tutorial"] as? Bool ?? false
        tutorial_num                 = data["tutorial_num"] as? Int ?? 0
        is_talkguide                 = data["is_talkguide"] as? Bool ?? true
        is_auto_message              = data["is_auto_message"] as? Bool ?? true
        is_display_ranking_talkguide = data["is_display_ranking_talkguide"] as? Bool ?? false
        is_friend_emoji              = data["is_friend_emoji"] as? Bool ?? true
        approaches                   = data["approaches"] as? [String] ?? [String]()
        approacheds                  = data["approached"] as? [String] ?? [String]()
        reply_approacheds            = data["reply_approacheds"] as? [String] ?? [String]()
        blocks                       = data["blocks"] as? [String] ?? [String]()
        violations                   = data["violations"] as? [String] ?? [String]()
        stops                        = data["stops"] as? [String] ?? [String]()
        logouted_at                  = data["logouted_at"] as? Timestamp ?? Timestamp()
        created_at                   = data["created_at"] as? Timestamp ?? Timestamp()
        updated_at                   = data["updated_at"] as? Timestamp ?? Timestamp()
        min_age_filter               = data["min_age_filter"] as? Int ?? 12
        max_age_filter               = data["max_age_filter"] as? Int ?? 120
        address_filter               = data["address_filter"] as? [String] ?? [String]()
        hobby_filter                 = data["hobby_filter"] as? [String] ?? [String]()
    }
    
    init(document: DocumentSnapshot) {
        let data                     = document.data()
        uid                          = document.documentID
        phone_number                 = data?["phone_number"] as? String ?? ""
        nick_name                    = data?["nick_name"] as? String ?? ""
        type                         = data?["type"] as? String ?? "気軽に誘ってください"
        holiday                      = data?["holiday"] as? String ?? "土日休み"
        business                     = data?["business"] as? String ?? "未設定"
        income                       = data?["income"] as? Int ?? 0
        email                        = data?["email"] as? String ?? ""
        notification_email           = data?["notification_email"] as? String ?? ""
        gender                       = data?["gender"] as? Int ?? 0
        violation_count              = data?["violation_count"] as? Int ?? 0
        birth_date                   = data?["birth_date"] as? String ?? ""
        profile_icon_img             = data?["profile_icon_img"] as? String ?? ""
        thumbnail                    = data?["thumbnail"] as? String ?? ""
        small_thumbnail              = data?["small_thumbnail"] as? String ?? ""
        profile_icon_sub_imgs        = data?["profile_icon_sub_imgs"] as? [String] ?? []
        sub_thumbnails               = data?["sub_thumbnails"] as? [String] ?? []
        profile_status               = data?["profile_status"] as? String ?? ""
        address                      = data?["address"] as? String ?? ""
        address2                     = data?["address2"] as? String ?? ""
        hobbies                      = data?["hobbies"] as? [String] ?? [String]()
        peerId                       = data?["peerId"] as? String ?? ""
        fcmToken                     = data?["fcmToken"] as? String ?? ""
        deviceToken                  = data?["deviceToken"] as? String ?? ""
        is_approached_notification   = data?["is_approached_notification"] as? Bool ?? true
        is_matching_notification     = data?["is_matching_notification"] as? Bool ?? true
        is_message_notification      = data?["is_message_notification"] as? Bool ?? true
        is_visitor_notification      = data?["is_visitor_notification"] as? Bool ?? true
        is_identification_approval   = data?["is_identification_approval"] as? Bool ?? false
        is_vibration_notification    = data?["is_vibration_notification"] as? Bool ?? true
        is_invitationed_notification = data?["is_invitationed_notification"] as? Bool ?? true
        is_dating_notification       = data?["is_dating_notification"] as? Bool ?? true
        is_approached_mail           = data?["is_approached_mail"] as? Bool ?? true
        is_matching_mail             = data?["is_matching_mail"] as? Bool ?? true
        is_message_mail              = data?["is_message_mail"] as? Bool ?? true
        is_visitor_mail              = data?["is_visitor_mail"] as? Bool ?? true
        is_invitationed_mail         = data?["is_invitationed_mail"] as? Bool ?? true
        is_dating_mail               = data?["is_dating_mail"] as? Bool ?? true
        is_deleted                   = data?["is_deleted"] as? Bool ?? false
        is_activated                 = data?["is_activated"] as? Bool ?? true
        is_logined                   = data?["is_logined"] as? Bool ?? false
        is_init_reviewed             = data?["is_init_reviewed"] as? Bool ?? false
        is_reviewed                  = data?["is_reviewed"] as? Bool ?? false
        is_rested                    = data?["is_rested"] as? Bool ?? false
        is_withdrawal                = data?["is_withdrawal"] as? Bool ?? false
        is_tutorial                  = data?["is_tutorial"] as? Bool ?? false
        tutorial_num                 = data?["tutorial_num"] as? Int ?? 0
        is_talkguide                 = data?["is_talkguide"] as? Bool ?? true
        is_auto_message              = data?["is_auto_message"] as? Bool ?? true
        is_display_ranking_talkguide = data?["is_display_ranking_talkguide"] as? Bool ?? false
        is_friend_emoji              = data?["is_friend_emoji"] as? Bool ?? true
        approaches                   = data?["approaches"] as? [String] ?? [String]()
        approacheds                  = data?["approached"] as? [String] ?? [String]()
        reply_approacheds            = data?["reply_approacheds"] as? [String] ?? [String]()
        blocks                       = data?["blocks"] as? [String] ?? [String]()
        violations                   = data?["violations"] as? [String] ?? [String]()
        stops                        = data?["stops"] as? [String] ?? [String]()
        logouted_at                  = data?["logouted_at"] as? Timestamp ?? Timestamp()
        created_at                   = data?["created_at"] as? Timestamp ?? Timestamp()
        updated_at                   = data?["updated_at"] as? Timestamp ?? Timestamp()
        min_age_filter               = data?["min_age_filter"] as? Int ?? 12
        max_age_filter               = data?["max_age_filter"] as? Int ?? 120
        address_filter               = data?["address_filter"] as? [String] ?? [String]()
        hobby_filter                 = data?["hobby_filter"] as? [String] ?? [String]()
    }
    
    init(cardUser: CardUser) {
        uid                          = cardUser.uid
        phone_number                 = cardUser.phone_number
        nick_name                    = cardUser.nick_name
        type                         = cardUser.type
        holiday                      = cardUser.holiday
        business                     = cardUser.business
        income                       = cardUser.income
        email                        = cardUser.email
        gender                       = cardUser.gender
        violation_count              = cardUser.violation_count
        birth_date                   = cardUser.birth_date
        profile_icon_img             = cardUser.profile_icon_img
        thumbnail                    = cardUser.thumbnail
        small_thumbnail              = cardUser.small_thumbnail
        profile_icon_sub_imgs        = cardUser.profile_icon_sub_imgs
        sub_thumbnails               = cardUser.sub_thumbnails
        profile_status               = cardUser.profile_status
        address                      = cardUser.address
        address2                     = cardUser.address2
        hobbies                      = cardUser.hobbies
        peerId                       = cardUser.peerId
        fcmToken                     = cardUser.fcmToken
        deviceToken                  = cardUser.deviceToken
        is_approached_notification   = cardUser.is_approached_notification
        is_matching_notification     = cardUser.is_matching_notification
        is_message_notification      = cardUser.is_message_notification
        is_invitationed_notification = cardUser.is_invitationed_notification
        is_dating_notification       = cardUser.is_dating_notification
        is_vibration_notification    = cardUser.is_vibration_notification
        is_identification_approval   = cardUser.is_identification_approval
        is_deleted                   = cardUser.is_deleted
        is_activated                 = cardUser.is_activated
        is_logined                   = cardUser.is_logined
        is_reviewed                  = cardUser.is_reviewed
        is_rested                    = cardUser.is_rested
        is_withdrawal                = cardUser.is_withdrawal
        is_talkguide                 = cardUser.is_talkguide
        approaches                   = cardUser.approaches
        approacheds                  = cardUser.approacheds
        reply_approacheds            = cardUser.reply_approacheds
        min_age_filter               = cardUser.min_age_filter
        max_age_filter               = cardUser.max_age_filter
        address_filter               = cardUser.address_filter
        hobby_filter                 = cardUser.hobby_filter
        logouted_at                  = Timestamp(date: cardUser.logouted_at)
        created_at                   = Timestamp(date: cardUser.created_at)
        updated_at                   = Timestamp(date: cardUser.updated_at)
        is_visitor_notification      = false
        notification_email           = ""
        is_approached_mail           = false
        is_matching_mail             = false
        is_message_mail              = false
        is_visitor_mail              = false
        is_invitationed_mail         = false
        is_dating_mail               = false
        is_tutorial                  = false
        tutorial_num                 = 0
        is_auto_message              = false
        is_friend_emoji              = false
        is_init_reviewed             = false
    }
    
    init(cardUserQuery: SearchResultHit<CardUserQuery>) {
        let cardUserQueryDocument    = cardUserQuery.document
        uid                          = cardUserQueryDocument?.uid ?? ""
        nick_name                    = cardUserQueryDocument?.nick_name ?? ""
        type                         = cardUserQueryDocument?.type ?? ""
        holiday                      = cardUserQueryDocument?.holiday ?? ""
        business                     = cardUserQueryDocument?.business ?? ""
        income                       = cardUserQueryDocument?.income ?? 0
        violation_count              = cardUserQueryDocument?.violation_count ?? 0
        birth_date                   = cardUserQueryDocument?.birth_date ?? ""
        profile_icon_img             = cardUserQueryDocument?.profile_icon_img ?? ""
        thumbnail                    = cardUserQueryDocument?.thumbnail ?? ""
        small_thumbnail              = cardUserQueryDocument?.small_thumbnail ?? ""
        profile_icon_sub_imgs        = cardUserQueryDocument?.profile_icon_sub_imgs ?? [String]()
        sub_thumbnails               = cardUserQueryDocument?.sub_thumbnails ?? [String]()
        profile_status               = cardUserQueryDocument?.profile_status ?? ""
        address                      = cardUserQueryDocument?.address ?? ""
        address2                     = cardUserQueryDocument?.address2 ?? ""
        hobbies                      = cardUserQueryDocument?.hobbies ?? [String]()
        is_deleted                   = cardUserQueryDocument?.is_deleted ?? false
        is_activated                 = cardUserQueryDocument?.is_activated ?? true
        is_logined                   = cardUserQueryDocument?.is_logined ?? false
        is_rested                    = cardUserQueryDocument?.is_rested ?? false
        approacheds                  = cardUserQueryDocument?.approached ?? [String]()
        phone_number                 = ""
        email                        = ""
        notification_email           = ""
        gender                       = 0
        peerId                       = ""
        fcmToken                     = ""
        deviceToken                  = ""
        is_approached_notification   = false
        is_matching_notification     = false
        is_visitor_notification      = false
        is_message_notification      = false
        is_invitationed_notification = false
        is_dating_notification       = false
        is_approached_mail           = false
        is_matching_mail             = false
        is_message_mail              = false
        is_visitor_mail              = false
        is_invitationed_mail         = false
        is_dating_mail               = false
        is_vibration_notification    = false
        is_identification_approval   = false
        is_init_reviewed             = false
        is_reviewed                  = false
        is_withdrawal                = false
        is_tutorial                  = false
        tutorial_num                 = 0
        is_talkguide                 = false
        is_auto_message              = false
        is_friend_emoji              = false
        approaches                   = [String]()
        reply_approacheds            = [String]()
        min_age_filter               = 12
        max_age_filter               = 120
        address_filter               = [String]()
        hobby_filter                 = [String]()
        let logouted_at_int          = cardUserQueryDocument?.logouted_at ?? 0
        let created_at_int           = cardUserQueryDocument?.created_at ?? 0
        let updated_at_int           = cardUserQueryDocument?.updated_at ?? 0
        let logouted_at_date         = logouted_at_int.dateFromInt()
        let created_at_date          = created_at_int.dateFromInt()
        let updated_at_date          = updated_at_int.dateFromInt()
        logouted_at                  = Timestamp(date: logouted_at_date)
        created_at                   = Timestamp(date: created_at_date)
        updated_at                   = Timestamp(date: updated_at_date)
    }
    
    init(cardUserQuery: CardUserQuery) {
        uid                          = cardUserQuery.uid ?? ""
        nick_name                    = cardUserQuery.nick_name ?? ""
        type                         = cardUserQuery.type ?? ""
        holiday                      = cardUserQuery.holiday ?? ""
        business                     = cardUserQuery.business ?? ""
        income                       = cardUserQuery.income ?? 0
        violation_count              = cardUserQuery.violation_count ?? 0
        birth_date                   = cardUserQuery.birth_date ?? ""
        profile_icon_img             = cardUserQuery.profile_icon_img ?? ""
        thumbnail                    = cardUserQuery.thumbnail ?? ""
        small_thumbnail              = cardUserQuery.small_thumbnail ?? ""
        profile_icon_sub_imgs        = cardUserQuery.profile_icon_sub_imgs ?? [String]()
        sub_thumbnails               = cardUserQuery.sub_thumbnails ?? [String]()
        profile_status               = cardUserQuery.profile_status ?? ""
        address                      = cardUserQuery.address ?? ""
        address2                     = cardUserQuery.address2 ?? ""
        hobbies                      = cardUserQuery.hobbies ?? [String]()
        is_deleted                   = cardUserQuery.is_deleted ?? false
        is_activated                 = cardUserQuery.is_activated ?? true
        is_logined                   = cardUserQuery.is_logined ?? false
        is_rested                    = cardUserQuery.is_rested ?? false
        approacheds                  = cardUserQuery.approached ?? [String]()
        phone_number                 = ""
        email                        = ""
        notification_email           = ""
        gender                       = 0
        peerId                       = ""
        fcmToken                     = ""
        deviceToken                  = ""
        is_approached_notification   = false
        is_matching_notification     = false
        is_visitor_notification      = false
        is_message_notification      = false
        is_invitationed_notification = false
        is_dating_notification       = false
        is_approached_mail           = false
        is_matching_mail             = false
        is_message_mail              = false
        is_visitor_mail              = false
        is_invitationed_mail         = false
        is_dating_mail               = false
        is_vibration_notification    = false
        is_identification_approval   = false
        is_init_reviewed             = false
        is_reviewed                  = false
        is_withdrawal                = false
        is_tutorial                  = false
        tutorial_num                 = 0
        is_talkguide                 = false
        is_auto_message              = false
        is_friend_emoji              = false
        approaches                   = [String]()
        reply_approacheds            = [String]()
        min_age_filter               = 12
        max_age_filter               = 120
        address_filter               = [String]()
        hobby_filter                 = [String]()
        let logouted_at_int          = cardUserQuery.logouted_at ?? 0
        let created_at_int           = cardUserQuery.created_at ?? 0
        let updated_at_int           = cardUserQuery.updated_at ?? 0
        let logouted_at_date         = logouted_at_int.dateFromInt()
        let created_at_date          = created_at_int.dateFromInt()
        let updated_at_date          = updated_at_int.dateFromInt()
        logouted_at                  = Timestamp(date: logouted_at_date)
        created_at                   = Timestamp(date: created_at_date)
        updated_at                   = Timestamp(date: updated_at_date)
    }
}
