//
//  Approach.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/13.
//

import Foundation
import FirebaseFirestore

class Approach {
    
    var target: String?
    var creator: String?
    var status: Int?
    var type: String?
    var comment: String?
    var created_at: Timestamp
    var updated_at: Timestamp
    
    var document_id: String?
    // DBには作成しないがデータとして保持したいのでモデルに定義
    var userInfo: User!

    init(document: QueryDocumentSnapshot) {
        self.document_id = document.documentID
        let data         = document.data()
        self.target      = data["target"] as? String ?? ""
        self.creator     = data["creator"] as? String ?? ""
        self.status      = data["status"] as? Int ?? 0
        self.type        = data["type"] as? String ?? ""
        self.comment     = data["comment"] as? String ?? ""
        self.created_at  = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(document: DocumentSnapshot) {
        self.document_id = document.documentID
        let data         = document.data()
        self.target      = data?["target"] as? String ?? ""
        self.creator     = data?["creator"] as? String ?? ""
        self.status      = data?["status"] as? Int ?? 0
        self.type        = data?["type"] as? String ?? ""
        self.comment     = data?["comment"] as? String ?? ""
        self.created_at  = data?["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at  = data?["updated_at"] as? Timestamp ?? Timestamp()
    }
}
