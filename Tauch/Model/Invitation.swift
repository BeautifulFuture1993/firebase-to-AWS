//
//  Invitation.swift
//  Tauch
//
//  Created by Apple on 2022/05/31.
//

import Foundation
import FirebaseFirestore
import Typesense

class Invitation {
    var category: String?
    var date: [String]
    var area: String?
    var content: String?
    var members: [String]
    var read_members: [String]
    var match_members: [String]
    var ng_members: [String]
    var creator: String?
    var is_delete_alert: Int?
    var is_deleted: Bool?
    var created_at: Timestamp?
    var updated_at: Timestamp?
    
    var document_id: String?
    // DBには作成しないがデータとして保持したいのでモデルに定義
    var userInfo: User?
    var goodUsers = [User]()
    
    init(document: QueryDocumentSnapshot) {
        self.document_id     = document.documentID
        let data             = document.data()
        self.category        = data["category"] as? String ?? ""
        self.date            = data["date"] as? [String] ?? []
        self.area            = data["area"] as? String ?? ""
        self.content         = data["content"] as? String ?? ""
        self.members         = data["members"] as? [String] ?? []
        self.read_members    = data["read_members"] as? [String] ?? []
        self.match_members   = data["match_members"] as? [String] ?? []
        self.ng_members      = data["ng_members"] as? [String] ?? []
        self.creator         = data["creator"] as? String ?? ""
        self.is_delete_alert = data["is_delete_alert"] as? Int ?? 0
        self.is_deleted      = data["is_deleted"] as? Bool ?? false
        self.created_at      = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at      = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(document: DocumentSnapshot) {
        self.document_id     = document.documentID
        let data             = document.data()
        self.category        = data?["category"] as? String ?? ""
        self.date            = data?["date"] as? [String] ?? []
        self.area            = data?["area"] as? String ?? ""
        self.content         = data?["content"] as? String ?? ""
        self.members         = data?["members"] as? [String] ?? []
        self.read_members    = data?["read_members"] as? [String] ?? []
        self.match_members   = data?["match_members"] as? [String] ?? []
        self.ng_members      = data?["ng_members"] as? [String] ?? []
        self.creator         = data?["creator"] as? String ?? ""
        self.is_delete_alert = data?["is_delete_alert"] as? Int ?? 0
        self.is_deleted      = data?["is_deleted"] as? Bool ?? false
        self.created_at      = data?["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at      = data?["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(invitationQuery: SearchResultHit<InvitationQuery>) {
        let invitationQueryDocument = invitationQuery.document
        document_id                 = invitationQueryDocument?.id ?? ""
        category                    = invitationQueryDocument?.category ?? ""
        date                        = invitationQueryDocument?.date ?? [String]()
        area                        = invitationQueryDocument?.area ?? ""
        content                     = invitationQueryDocument?.content ?? ""
        members                     = invitationQueryDocument?.members ?? [String]()
        read_members                = invitationQueryDocument?.read_members ?? [String]()
        match_members               = invitationQueryDocument?.match_members ?? [String]()
        ng_members                  = invitationQueryDocument?.ng_members ?? [String]()
        creator                     = invitationQueryDocument?.creator ?? ""
        is_delete_alert             = invitationQueryDocument?.is_delete_alert ?? 0
        is_deleted                  = invitationQueryDocument?.is_deleted ?? false
        let created_at_int          = invitationQueryDocument?.created_at ?? 0
        let updated_at_int          = invitationQueryDocument?.updated_at ?? 0
        created_at                  = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at                  = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
    }
}

