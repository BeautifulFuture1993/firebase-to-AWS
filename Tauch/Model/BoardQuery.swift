//
//  BoardQuery.swift
//  Tauch
//
//  Created by Apple on 2023/06/07.
//

import Foundation

class BoardQuery: Codable {
    
    var id: String?
    var category: String?
    var text: String?
    var photos: [String]?
    var creator: String?
    var visitors: [String]?
    var messangers: [String]?
    var is_admin: Bool?
    var created_at: Int?
    var updated_at: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case text
        case photos
        case creator
        case visitors
        case messangers
        case is_admin
        case created_at
        case updated_at
    }
}
