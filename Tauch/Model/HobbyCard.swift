//
//  LikeCard.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/04/03.
//

import Foundation
import FirebaseFirestore
import Typesense

class HobbyCard {
    
    var id: String
    var title: String
    var category: String
    var iconImageURL: String
    var approvalFlag: Bool
    var count: Int
    let created_at: Timestamp
    let updated_at: Timestamp
    var document_id: String
    
    init(document: QueryDocumentSnapshot) {
        document_id  = document.documentID
        let data     = document.data()
        id           = document.documentID
        title        = data["title"] as? String ?? ""
        category     = data["category"] as? String ?? ""
        iconImageURL = data["image"] as? String ?? ""
        approvalFlag = data["approval_flg"] as? Bool ?? true
        count        = data["count"] as? Int ?? 0
        created_at   = data["created_at"] as? Timestamp ?? Timestamp()
        updated_at   = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(document: DocumentSnapshot) {
        document_id  = document.documentID
        let data     = document.data()
        id           = document.documentID
        title        = data?["title"] as? String ?? ""
        category     = data?["category"] as? String ?? ""
        iconImageURL = data?["image"] as? String ?? ""
        approvalFlag = data?["approval_flg"] as? Bool ?? true
        count        = data?["count"] as? Int ?? 0
        created_at   = data?["created_at"] as? Timestamp ?? Timestamp()
        updated_at   = data?["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(hobbyCardQuery: SearchResultHit<HobbyCardQuery>) {
        let hobbyCardQueryDocument = hobbyCardQuery.document
<<<<<<< HEAD
        id                         = hobbyCardQueryDocument?.id ?? ""
        title                      = hobbyCardQueryDocument?.title ?? ""
        category                   = hobbyCardQueryDocument?.category ?? ""
        iconImageURL               = hobbyCardQueryDocument?.image ?? ""
        approvalFlag               = hobbyCardQueryDocument?.approval_flg ?? false
        count                      = hobbyCardQueryDocument?.count ?? 0
        let created_at_int         = hobbyCardQueryDocument?.created_at ?? 0
        let updated_at_int         = hobbyCardQueryDocument?.updated_at ?? 0
        let created_at_date        = created_at_int.dateFromInt()
        let updated_at_date        = updated_at_int.dateFromInt()
        created_at                 = Timestamp(date: created_at_date)
        updated_at                 = Timestamp(date: updated_at_date)
=======
        document_id                = hobbyCardQueryDocument?.id ?? ""
        title                      = hobbyCardQueryDocument?.title ?? ""
        category                   = hobbyCardQueryDocument?.category ?? ""
        iconImageURL               = hobbyCardQueryDocument?.iconImageURL ?? ""
        approvalFlag               = hobbyCardQueryDocument?.approvalFlag ?? true
        count                      = hobbyCardQueryDocument?.count ?? 0
        let created_at_int         = hobbyCardQueryDocument?.created_at ?? 0
        let updated_at_int         = hobbyCardQueryDocument?.updated_at ?? 0
        created_at                 = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at                 = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
    }
    
    init(hobbyCardQuery: HobbyCardQuery) {
        document_id        = hobbyCardQuery.id ?? ""
        title              = hobbyCardQuery.title ?? ""
        category           = hobbyCardQuery.category ?? ""
        iconImageURL       = hobbyCardQuery.iconImageURL ?? ""
        approvalFlag       = hobbyCardQuery.approvalFlag ?? false
        count              = hobbyCardQuery.count ?? 0
        let created_at_int = hobbyCardQuery.created_at ?? 0
        let updated_at_int = hobbyCardQuery.updated_at ?? 0
        created_at         = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at         = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    }
}

