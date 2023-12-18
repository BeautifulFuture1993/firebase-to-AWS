//
//  CustomTableViewCell.swift
//  Tatibanashi
//
//  Created by Apple on 2022/03/26.
//

import UIKit

extension UITableViewCell: UIViewControllerTransitioningDelegate {
    // 生年月日から年齢を計算
    func calcAge(birthDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.dateStyle = .long
        let calendar = Calendar(identifier: .gregorian)
        
        guard let date = dateFormatter.date(from: birthDate) else { return "未設定" }
        guard let formatDate = calendar.date(byAdding: .day, value: 1, to: date) else { return "未設定" }

        let birthDateCalendar = calendar.dateComponents([.year, .month, .day], from: formatDate)
        let nowCalendar = calendar.dateComponents([.year, .month, .day], from: Date())
        let ageComponents = calendar.dateComponents([.year], from: birthDateCalendar, to: nowCalendar)
        let age = ageComponents.year ?? 0
        let ageStr = "\(age)歳"
        return ageStr
    }
    // 新着表示
    func elapsedOnlineTime(registTime: Date) -> String {
        let now = Date()
        let span = now.timeIntervalSince(registTime)
        let daySpan = Int(floor(span/60/60/24))
        
        if daySpan > 1 {
            return "\(daySpan)日前"
            
        } else {
            return "新着"
        }
    }
    // ログアウト後からの経過時間
    func elapsedTime(isLogin: Bool, logoutTime: Date) -> [Int:Int] {
        // ログアウトしていない場合
        if isLogin { return [0:0] }
        
        let now = Date()
        let span = now.timeIntervalSince(logoutTime)
        
        let secondSpan = Int(floor(span))
        let minuteSpan = Int(floor(span/60))
        let hourSpan   = Int(floor(span/60/60))
        let daySpan    = Int(floor(span/60/60/24))

        if secondSpan > 0 && secondSpan < 60 {
            // ログアウトから秒数的な差がある場合
            return [1:secondSpan]
            
        } else if minuteSpan > 0 && minuteSpan < 60 {
            // ログアウトから分数的な差がある場合
            return [2:minuteSpan]
            
        } else if hourSpan > 0 && hourSpan < 24 {
            // ログアウトから時刻的な差がある場合
            return [3:hourSpan]
            
        } else if daySpan > 0 {
            // ログアウトから日数的な差がある場合
            return [4:daySpan]
            
        } else {
            // ログアウトしていない場合
            return [0:0]
            
        }
    }
}
