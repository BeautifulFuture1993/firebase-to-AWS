//
//  CallManager.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/05/08.
//

import UIKit
import CallKit
import AVFoundation
import PushKit

final class CallManager {
    private let controller = CXCallController()
    private let provider: CXProvider
    private var uuid = UUID()
    var myName = ""
    var partnerName = ""
    var isStartCallSuccess = false
    var isIncomingCallSuccess = false
    var isEndCallSuccess = false
    
    init() {
        let providerConfiguration = CXProviderConfiguration()
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.includesCallsInRecents = false
        providerConfiguration.iconTemplateImageData = UIImage(named: "CallAppIcon")?.pngData()
        
        provider = CXProvider(configuration: providerConfiguration)
    }
    
    func setUp(_ delegate: CXProviderDelegate) {
        provider.setDelegate(delegate, queue: nil)
    }
    
    func startCall() {
        uuid = UUID()
        
        let callUpdate = CXCallUpdate()
        let handle = CXHandle(type: .generic, value: myName)
        let starCallAction = CXStartCallAction(call: uuid, handle: handle)
        let transaction = CXTransaction(action: starCallAction)
        
        controller.request(transaction) { error in
            if let error = error {
                self.isStartCallSuccess = false
            } else {
                self.isStartCallSuccess = true
                self.provider.reportCall(with: self.uuid, updated: callUpdate)
            }
        }
    }
    
    func incomingCall() {
        uuid = UUID()
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: partnerName)
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                self.isIncomingCallSuccess = false
            } else {
                self.isIncomingCallSuccess = true
            }
        }
    }
    
    func endCall() {
        let action = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: action)
        
        controller.request(transaction) { error in
            if let error = error {
                self.isEndCallSuccess = false
            } else {
                self.isEndCallSuccess = true
            }
        }
    }
    
    func connecting() {
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }
    
    func connected() {
        provider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }
    
    func ConfigureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(
            AVAudioSession.Category.playAndRecord,
            mode: .voiceChat,
            options: []
        )
    }
}
