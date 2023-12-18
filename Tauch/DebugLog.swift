//
//  DebugLog.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/10/24.
//

import os

// タスクキル状態のログ出力で使う
final class DebugLog {
    
    static let logger = Logger(subsystem: "com.Touch", category: "ログ")
    static let osLog = OSLog(subsystem: "com.Touch", category: "ログ")
    
    static func print(_ log: String) {
        if #available(iOS 14.0, *) {
            logger.log(level: .default, "\(log)")
        } else {
            os_log("%@", log: osLog, type: .default, log)
        }
    }
}
