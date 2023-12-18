//
//  Visitor.swift
//  Tauch
//
//  Created by Apple on 2023/05/29.
//

import Foundation
import FirebaseFirestore
import Typesense

class Visitor {

    var target: String
    var creator: String
    var comment: String
    var comment_img: String
    var read: Bool
    var created_at: Timestamp
    var updated_at: Timestamp
    
    var document_id: String
    
    var userInfo: User?
    
    init(document: QueryDocumentSnapshot) {
        self.document_id = document.documentID
        let data         = document.data()
        self.target      = data["target"] as? String ?? ""
        self.creator     = data["creator"] as? String ?? ""
        self.comment     = data["comment"] as? String ?? ""
        self.comment_img = data["comment_img"] as? String ?? ""
        self.read        = data["read"] as? Bool ?? false
        self.created_at  = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(data: [String:Any]) {
        self.document_id = data["visitor_id"] as? String ?? ""
        self.target      = data["target"] as? String ?? ""
        self.creator     = data["creator"] as? String ?? ""
        self.comment     = data["comment"] as? String ?? ""
        self.comment_img = data["comment_img"] as? String ?? ""
        self.read        = data["read"] as? Bool ?? false
        self.created_at  = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(visitorQuery: SearchResultHit<VisitorQuery>) {
        let visitorQueryDocument = visitorQuery.document
        document_id              = visitorQueryDocument?.id ?? ""
        target                   = visitorQueryDocument?.target ?? ""
        creator                  = visitorQueryDocument?.creator ?? ""
        comment                  = visitorQueryDocument?.comment ?? ""
        comment_img              = visitorQueryDocument?.comment_img ?? ""
        read                     = visitorQueryDocument?.read ?? false
        let created_at_int       = visitorQueryDocument?.created_at ?? 0
        let updated_at_int       = visitorQueryDocument?.updated_at ?? 0
        created_at               = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at               = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
    }
    
    init(visitorQuery: VisitorQuery) {
        document_id        = visitorQuery.id ?? ""
        target             = visitorQuery.target ?? ""
        creator            = visitorQuery.creator ?? ""
        comment            = visitorQuery.comment ?? ""
        comment_img        = visitorQuery.comment_img ?? ""
        read               = visitorQuery.read ?? false
        let created_at_int = visitorQuery.created_at ?? 0
        let updated_at_int = visitorQuery.updated_at ?? 0
        created_at         = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at         = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
    }
}
