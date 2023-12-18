//
//  DeleteUser.swift
//  Tauch
//
//  Created by Apple on 2022/07/27.
//

import Foundation
import FirebaseFirestore

class DeleteUser {
    var uid: String?
    var nick_name: String?
    var email: String?
    var content: String?
    var registed_at: Timestamp?
    var created_at: Timestamp?
    var updated_at: Timestamp?
    
    var document_id: String?
    
    init(document: QueryDocumentSnapshot) {
        self.document_id = document.documentID
        let data         = document.data()
        self.uid         = data["uid"] as? String ?? ""
        self.nick_name   = data["nick_name"] as? String ?? ""
        self.email       = data["email"] as? String ?? ""
        self.content     = data["content"] as? String ?? ""
        self.registed_at = data["registed_at"] as? Timestamp ?? Timestamp()
        self.created_at  = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(document: DocumentSnapshot) {
        self.document_id = document.documentID
        let data         = document.data()
        self.uid         = data?["uid"] as? String ?? ""
        self.nick_name   = data?["nick_name"] as? String ?? ""
        self.email       = data?["email"] as? String ?? ""
        self.content     = data?["content"] as? String ?? ""
        self.registed_at = data?["registed_at"] as? Timestamp ?? Timestamp()
        self.created_at  = data?["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data?["updated_at"] as? Timestamp ?? Timestamp()
    }
}
