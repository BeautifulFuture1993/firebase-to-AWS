//
//  Violation.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/13.
//

import Foundation
import FirebaseFirestore

class Violation {
    var content: String?
    var target: String?
    var creator: String?
    var admin_check_status: Int?
    var created_at: Timestamp?
    var updated_at: Timestamp?
    
    var document_id: String?
    
    init(document: QueryDocumentSnapshot) {
        self.document_id        = document.documentID
        let data                = document.data()
        self.content            = data["content"] as? String ?? ""
        self.target             = data["target"] as? String ?? ""
        self.creator            = data["creator"] as? String ?? ""
        self.admin_check_status = data["admin_check_status"] as? Int ?? 0
        self.created_at         = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at         = data["updated_at"] as? Timestamp ?? Timestamp()
    }
}
