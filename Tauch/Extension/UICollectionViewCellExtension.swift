//
//  UICollectionViewCellExtension.swift
//  Tauch
//
//  Created by Apple on 2023/05/12.
//

import UIKit
import Foundation

extension UICollectionViewCell {
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
