//
//  Board.swift
//  Tauch
//
//  Created by Apple on 2023/06/07.
//

import Foundation
import FirebaseFirestore
import Typesense

class Board {
    
    var category: String
    var text: String
    var photos = [String]()
    var creator: String
    var visitors = [String]()
    var messangers = [String]()
    var is_admin: Bool
    var created_at: Timestamp
    var updated_at: Timestamp
    
    var document_id: String
    
    var userInfo: User?
    
    init(document: QueryDocumentSnapshot) {
        self.document_id = document.documentID
        let data         = document.data()
        self.category    = data["category"] as? String ?? ""
        self.text        = data["text"] as? String ?? ""
        self.photos      = data["photos"] as? [String] ?? [String]()
        self.creator     = data["creator"] as? String ?? ""
        self.visitors    = data["visitors"] as? [String] ?? [String]()
        self.messangers  = data["messangers"] as? [String] ?? [String]()
        self.is_admin    = data["is_admin"] as? Bool ?? false
        self.created_at  = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(document: DocumentSnapshot) {
        self.document_id = document.documentID
        let data         = document.data()
        self.category    = data?["category"] as? String ?? ""
        self.text        = data?["text"] as? String ?? ""
        self.photos      = data?["photos"] as? [String] ?? [String]()
        self.creator     = data?["creator"] as? String ?? ""
        self.visitors    = data?["visitors"] as? [String] ?? [String]()
        self.messangers  = data?["messangers"] as? [String] ?? [String]()
        self.is_admin    = data?["is_admin"] as? Bool ?? false
        self.created_at  = data?["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data?["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(data: [String:Any]) {
        self.document_id = data["document_id"] as? String ?? ""
        self.category    = data["category"] as? String ?? ""
        self.text        = data["text"] as? String ?? ""
        self.photos      = data["photos"] as? [String] ?? [String]()
        self.creator     = data["creator"] as? String ?? ""
        self.visitors    = data["visitors"] as? [String] ?? [String]()
        self.messangers  = data["messangers"] as? [String] ?? [String]()
        self.is_admin    = data["is_admin"] as? Bool ?? false
        self.created_at  = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(boardQuery: SearchResultHit<BoardQuery>) {
        let boardQueryDocument = boardQuery.document
        document_id            = boardQueryDocument?.id ?? ""
        category               = boardQueryDocument?.category ?? ""
        text                   = boardQueryDocument?.text ?? ""
        photos                 = boardQueryDocument?.photos ?? [String]()
        creator                = boardQueryDocument?.creator ?? ""
        visitors               = boardQueryDocument?.visitors ?? [String]()
        messangers             = boardQueryDocument?.messangers ?? [String]()
        is_admin               = boardQueryDocument?.is_admin ?? false
        let created_at_int     = boardQueryDocument?.created_at ?? 0
        let updated_at_int     = boardQueryDocument?.updated_at ?? 0
        created_at             = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at             = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
    }
    
    init(boardQuery: BoardQuery) {
        document_id        = boardQuery.id ?? ""
        category           = boardQuery.category ?? ""
        text               = boardQuery.text ?? ""
        photos             = boardQuery.photos ?? [String]()
        creator            = boardQuery.creator ?? ""
        visitors           = boardQuery.visitors ?? [String]()
        messangers         = boardQuery.messangers ?? [String]()
        is_admin           = boardQuery.is_admin ?? false
        let created_at_int = boardQuery.created_at ?? 0
        let updated_at_int = boardQuery.updated_at ?? 0
        created_at         = Timestamp(seconds: Int64(created_at_int), nanoseconds: Int32(0))
        updated_at         = Timestamp(seconds: Int64(updated_at_int), nanoseconds: Int32(0))
    }
}
