//
//  Stop.swift
//  Tauch
//
//  Created by Apple on 2022/05/16.
//

import Foundation
import FirebaseFirestore

class Stop {
    var status: Bool?
    var solicitationContent: String?
    var purposeOfSolicitation: String?
    var unpleasantFeelings: String?
    var target: String?
    var creator: String?
    var admin_check_status: Bool?
    var created_at: Timestamp?
    var updated_at: Timestamp?
    
    var document_id: String?
    
    init(document: QueryDocumentSnapshot) {
        self.document_id            = document.documentID
        let data                    = document.data()
        self.status                 = data["status"] as? Bool ?? false
        self.solicitationContent    = data["solicitationContent"] as? String ?? ""
        self.purposeOfSolicitation  = data["purposeOfSolicitation"] as? String ?? ""
        self.unpleasantFeelings     = data["unpleasantFeelings"] as? String ?? ""
        self.target                 = data["target"] as? String ?? ""
        self.creator                = data["creator"] as? String ?? ""
        self.admin_check_status     = data["admin_check_status"] as? Bool ?? false
        self.created_at             = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at             = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(document: DocumentSnapshot) {
        self.document_id            = document.documentID
        let data                    = document.data()
        self.status                 = data?["status"] as? Bool ?? false
        self.solicitationContent    = data?["solicitationContent"] as? String ?? ""
        self.purposeOfSolicitation  = data?["purposeOfSolicitation"] as? String ?? ""
        self.unpleasantFeelings     = data?["unpleasantFeelings"] as? String ?? ""
        self.target                 = data?["target"] as? String ?? ""
        self.creator                = data?["creator"] as? String ?? ""
        self.admin_check_status     = data?["admin_check_status"] as? Bool ?? false
        self.created_at             = data?["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at             = data?["updated_at"] as? Timestamp ?? Timestamp()
    }
}
