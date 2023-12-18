//
//  HobbyCardQuery.swift
//  Tauch
//
<<<<<<< HEAD
//  Created by Apple on 2023/04/30.
=======
//  Created by Apple on 2023/11/09.
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
//

import Foundation

class HobbyCardQuery: Codable {
    
    var id: String?
    var title: String?
    var category: String?
<<<<<<< HEAD
    var image: String?
    var approval_flg: Bool?
    var count: Int?
    var created_at: Int?
    var updated_at: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case image
        case approval_flg
        case count
        case created_at
        case updated_at
=======
    var iconImageURL: String?
    var approvalFlag: Bool?
    var count: Int?
    var created_at: Int?
    var updated_at: Int?

    enum CodingKeys: String, CodingKey {
        
        case id
        case title
        case category
        case iconImageURL
        case approvalFlag
        case count
        case created_at
        case updated_at
        
        var stringValue: String {
            switch self {
            case .id:
                return "id"
            case .title:
                return "title"
            case .category:
                return "category"
            case .iconImageURL:
                return "iconImageURL"
            case .approvalFlag:
                return "approvalFlag"
            case .count:
                return "count"
            case .created_at:
                return "created_at"
            case .updated_at:
                return "updated_at"
            }
        }
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    }
}
