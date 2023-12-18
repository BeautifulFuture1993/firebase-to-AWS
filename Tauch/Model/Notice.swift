//
//  Notice.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/13.
//

import Foundation
import Firebase

class Notice {
    var category: Int?
    var room_id: String?
    var message_id: String?
    var device_id: String?
    var invitation_id: String?
    var creator: String?
    var creator_name: String?
    var read: Bool?
    var created_at: Timestamp?
    var updated_at: Timestamp?
    
    var document_id: String?
    // DBには作成しないがデータとして保持したいのでモデルに定義
    var creatorInfo: User?
    
    init(document: QueryDocumentSnapshot) {
        self.document_id   = document.documentID
        let data           = document.data()
        self.category      = data["category"] as? Int ?? 0
        self.room_id       = data["room_id"] as? String ?? ""
        self.message_id    = data["message_id"] as? String ?? ""
        self.device_id     = data["device_id"] as? String ?? ""
        self.invitation_id = data["invitation_id"] as? String ?? ""
        self.creator       = data["creator"] as? String ?? ""
        self.creator_name  = data["creator_name"] as? String ?? ""
        self.read          = data["read"] as? Bool ?? false
        self.created_at    = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at    = data["updated_at"] as? Timestamp ?? Timestamp()
    }
    
    static var icon = [UIImage(systemName: "questionmark.circle.fill"), UIImage(systemName: "heart.circle.fill"), UIImage(systemName: "bubble.left.circle.fill")]
    static var iconColor = [UIColor(named: "YellowColor"), UIColor(named: "PinkColor"), UIColor(named: "BlueColor")]
}
