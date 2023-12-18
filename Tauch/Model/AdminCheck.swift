//
//  AdminCheck.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/17.
//

import Foundation
import FirebaseFirestore

class AdminCheck {
    var identification: String?
    var admin_id_check_status: Int?
    let created_at: Timestamp?
    let updated_at: Timestamp?
    
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.identification = data["identification"] as? String ?? ""
        self.admin_id_check_status = data["admin_id_check_status"] as? Int ?? 0
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    init(document: DocumentSnapshot) {
        let data = document.data()
        self.identification = data?["identification"] as? String ?? ""
        self.admin_id_check_status = data?["admin_id_check_status"] as? Int ?? 0
        self.created_at = data?["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data?["updated_at"] as? Timestamp ?? Timestamp()
    }
}
