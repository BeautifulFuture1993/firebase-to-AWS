//
//  IntExtension.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/09/03.
//

import Foundation

extension Int {
    
    func getIncome() -> String {
        switch self {
        case 0:
            return "未設定"
        case 1:
            return "200万円未満"
        case 2:
            return "200万円以上〜400万円未満"
        case 3:
            return "400万円以上〜600万円未満"
        case 4:
            return "600万円以上〜800万円未満"
        case 5:
            return "800万円以上〜1000万円未満"
        case 6:
            return "1000万円以上〜1500万円未満"
        default:
            return "1500万円以上"
        }
    }
    
    func getIncomeDifference() -> String {
        guard let myIncome = GlobalVar.shared.loginUser?.income,
              myIncome != 0,
              self != 0 else { return "未設定" }

        var difference = myIncome - self
        if difference < 0 {
            difference *= -1
        }
        
        switch difference {
        case 0:
            return "同じ"
        case 1:
            return "近い"
        default:
            return "かけ離れている"
        }
    }
    
    // 日時を特定のフォーマットに変換 (Int => Date)
    func dateFromInt() -> Date {
        let second = Double(self)
        let date = Date(timeIntervalSince1970: second)
        return date
    }
}
