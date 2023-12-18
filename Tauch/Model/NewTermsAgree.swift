//
//  NewTermsAgree.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/11/22.
//

import FirebaseFirestore

final class NewTermsAgree {
    var updated_for_2023_11_17: Bool?
    let created_at: Timestamp?
    let updated_at: Timestamp?
    
    init(document: DocumentSnapshot) {
        let data = document.data()
        
        self.updated_for_2023_11_17 = data?["is_agree"] as? Bool ?? false
        self.created_at = data?["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data?["updated_at"] as? Timestamp ?? Timestamp()
    }
}
