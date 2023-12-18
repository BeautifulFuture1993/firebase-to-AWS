//
//  PushVoIPNotificationDataModel.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/05/29.
//

import Foundation

struct PushVoIPNotificationDataModel {
    private let myName: String
    private let myImage: String
    private let deviceToken: String
    private let skywayToken: String
    private let roomName: String
    private var production = true
    
    init(myName: String, myImage: String, deviceToken: String, skywayToken: String, roomName: String) {
        self.myName = myName
        self.myImage = myImage
        self.deviceToken = deviceToken
        self.skywayToken = skywayToken
        self.roomName = roomName
        #if DEBUG
        self.production = false
        #else
        self.production = true
        #endif
    }
    
    func createData() -> [String: Any] {
        let data: [String: Any] = [
            "nickName": myName,
            "profileIconImg": myImage,
            "deviceToken": deviceToken,
            "skywayToken": skywayToken,
            "roomName": roomName,
            "production": production
        ]
        
        return data
    }
}
