//
//  VisitorQuery.swift
//  Tauch
//
//  Created by Apple on 2023/05/29.
//

import Foundation

class VisitorQuery: Codable {
    
    var id: String?
    var target: String?
    var creator: String?
    var comment: String?
    var comment_img: String?
    var read: Bool?
    var created_at: Int?
    var updated_at: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case target
        case creator
        case comment
        case comment_img
        case read
        case created_at
        case updated_at
    }
}
