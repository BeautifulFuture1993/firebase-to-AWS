//
//  CallViewController.swift
//  Tauch
//
//  Created by sasaki.ken on 2023/05/11.
//

import UIKit
import SkyWayRoom
import AVFoundation
import AudioToolbox

protocol CallViewControllerDelegate: AnyObject {
    func sendEndCallMessage()
}

final class CallViewController: UIBaseViewController {
    
    @IBOutlet weak var callWaitView: UIView!
    @IBOutlet weak var pertnerIconImageViewForWaitView: UIImageView!
    @IBOutlet weak var callWaitViewLabel: UILabel!
    @IBOutlet weak var closeCallWaitViewButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var micLabel: UILabel!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var speakerLabel: UILabel!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var partnerUserName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var room: SkyWayRoom.Room?
    private var localMember: LocalRoomMember?
    private var dataStream: LocalDataStream?
    private var publication: RoomPublication?
    private var remotePublications: [RoomPublication] = []
    private var localSubscriptions: [RoomSubscription] = []
    private var isAutoSubscribing = false
    private var isMute = false
    private var timer: Timer?
    private var startTime: TimeInterval?
    private var elapsedTime: TimeInterval = 0
    private let audioSession = AVAudioSession.sharedInstance()
    private var isSpeaker = false
    private let indicatorView = UIView(frame: UIScreen.main.bounds)
    
    weak var delegate: CallViewControllerDelegate?
    
    var iconImage: UIImage?
    var partnerName: String?
    var skywayToken = ""
    var roomName = ""
    var isConnect = false
    
    private enum CallStatus {
        case wait
        case callable
        case fail
        case unknown
    }
    
    private var callStatus: CallStatus = .unknown {
        didSet {
            switch callStatus {
            case .wait:
                initSpeakerAndMike()
                callWaitView.isHidden = false
                setUserData()
                timeLabel.text = "待機中"
            case .callable:
                callWaitView.isHidden = true
            case .fail:
                showFailSkyWayTaskAlert()
            case .unknown:
                return
            }
        }
    }
    
    private var isJoined: Bool = false {
        didSet {
            if isJoined {
                callStatus = .callable
                joinButton.isEnabled = false
                indicatorView.removeFromSuperview()
            } else {
                joinButton.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isJoined = false
        callStatus = .wait
        Task {
            try await setUpSkyWay()
        }
    }
    
    private func setUserData() {
        guard let name = partnerName else {
            return
        }
        callWaitViewLabel.text = "\(name)さんと通話しますか？"
        partnerUserName.text = partnerName
        
        if iconImage == nil {
            pertnerIconImageViewForWaitView.image = UIImage(systemName: "person.fill")
            iconImageView.image = UIImage(systemName: "person.fill")
        } else {
            pertnerIconImageViewForWaitView.image = iconImage
            iconImageView.image = iconImage
        }
    }
    
    private func initSpeakerAndMike() {
        isMute = true
        isSpeaker = true
        onMicButtonTapped(nil)
        speakerButtonTapped(nil)
    }
    
    private func setUpSkyWay() async throws {
        do {
            let token = skywayToken
            let options: ContextOptions = .init()
            options.logLevel = .trace
            try await Context.setup(withToken: token, options: options)
        } catch {
            print("Error setUpSkyWay:", error.localizedDescription)
            print("Error setUpSkyWay:", error)
            failSetUpSkyWay()
        }
    }
    
    private func joinRoom() async throws {
        do {
            let options: SkyWayRoom.Room.InitOptions = .init()
            options.name = roomName
            let memberOptions: SkyWayRoom.Room.MemberInitOptions = .init()
            let room = try await SFURoom.findOrCreate(with: options)
            DispatchQueue.main.async {
                self.remotePublications = room.publications
            }
            let localMember = try await room.join(with: memberOptions)
            self.room = room
            room.delegate = self
            self.localMember = localMember
        } catch {
            print("Error joinRoom:", error.localizedDescription)
            print("Error joinRoom:", error)
            failSetUpSkyWay()
        }
    }
    
    private func publishStream() async throws {
        do {
            let audioStream = MicrophoneAudioSource().createStream()
            let audioPublicationOptions: RoomPublicationOptions = .init()
            publication = try await localMember?.publish(audioStream, options: audioPublicationOptions)
            isJoined = true
        } catch {
            print("Error publishStream:", error.localizedDescription)
            print("Error publishStream:", error)
            failSetUpSkyWay()
        }
    }
    
    private func subscribe(_ publication: RoomPublication) async throws {
        do {
            guard publication.publisher != localMember else {
                return
            }
            guard let localMember = localMember else {
                return
            }
            let option: SubscriptionOptions = .init()
            let subscribe = try await localMember.subscribe(publicationId: publication.id, options: option)
            if let dataStream = subscribe.stream as? RemoteDataStream {
                dataStream.delegate = self
            }
        } catch {
            print("Error subscribe:", error.localizedDescription)
            print("Error subscribe:", error)
            failSetUpSkyWay()
        }
    }
    
    private func leave() async throws {
        do {
            // イベントの購読を停止
            room?.delegate = nil
            dataStream = nil
            publication = nil
            try await localMember?.leave()
            DispatchQueue.main.async {
                self.remotePublications = []
                self.localSubscriptions = []
            }
            // SDK内部で管理しているRoomを破棄
            try await room?.dispose()
            localMember = nil
            room = nil
            timer?.invalidate()
            timer = nil
            callStatus = .wait
            isJoined = false
        } catch {
            print("Error leave", error)
            print("Error leave", error.localizedDescription)
        }
    }
    
    private func endCallTask() {
        Task {
            try await leave()
        }
    }
    
    private func showFailSkyWayTaskAlert() {
        let alert = UIAlertController(title: "確認", message: "接続に失敗しました。\nアプリを終了し時間をおいてから再度やり直してください。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            if self.isJoined {
                self.endCallTask()
                self.dismiss(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func failSetUpSkyWay() {
        callStatus = .fail
    }
    
    @IBAction func onjoinButtonTapped(_ sender: UIButton) {
        showLoadingView(indicatorView)
        Task {
            try await joinRoom()
            try await publishStream()
            for publication in remotePublications {
                try await subscribe(publication)
            }
        }
    }
    
    @IBAction func onCloseCallWaitViewButtonTapped(_ sender: UIButton) {
        Task {
            try await Context.dispose()
        }
        NotificationCenter.default.post(
            name: Notification.Name(NotificationName.EndCall.rawValue),
            object: self
        )
    }
    
    @IBAction func onEndCallButtonTapped(_ sender: UIButton) {
        endCallTask()
        if isConnect {
            delegate?.sendEndCallMessage()
            isConnect = false
        }
    }
    
    @IBAction func onMicButtonTapped(_ sender: UIButton?) {
        if isMute {
            Task {
                try await publication?.enable()
                micButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
                micLabel.text = "マイクをオフ"
                isMute = false
            }
        } else {
            Task {
                try await publication?.disable()
                micButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
                micLabel.text = "マイクをオン"
                isMute = true
            }
        }
    }
    
    @IBAction func speakerButtonTapped(_ sender: UIButton?) {
        if isSpeaker {
            try? audioSession.overrideOutputAudioPort(.none)
            speakerButton.setImage(UIImage(systemName: "speaker.1.fill"), for: .normal)
            speakerLabel.text = "スピーカーをオン"
            isSpeaker = false
        } else {
            try? audioSession.overrideOutputAudioPort(.speaker)
            speakerButton.setImage(UIImage(systemName: "speaker.3.fill"), for: .normal)
            speakerLabel.text = "スピーカーをオフ"
            isSpeaker = true
        }
    }
}

// Timer 関連
extension CallViewController {
    
    private func setTimer() {
        if timer == nil {
            startTime = Date.timeIntervalSinceReferenceDate
            timer = Timer.scheduledTimer(
                timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true
            )
        }
    }
    
    @objc private func updateTimer() {
        if let startTime = startTime {
            elapsedTime = Date.timeIntervalSinceReferenceDate - startTime
        }
        timeLabel.text = formatTimerLabel(elapsedTime)
    }

    private func formatTimerLabel(_ time: TimeInterval) -> String {
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutes = Int((time / 60).truncatingRemainder(dividingBy: 60))
        let hours = Int(time / 3600)

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// SkyWay Delegate 関連
extension CallViewController: RoomDelegate, RemoteDataStreamDelegate {
    
    func room(_ room: SkyWayRoom.Room, didPublishStreamOf publication: RoomPublication) {
        guard let localMember = localMember else {
            return
        }
        
        if publication.publisher != localMember {
            localMember.subscribe(publicationId: publication.id, options: nil, completion: nil)
        }
    }
    
    func room(_ room: SkyWayRoom.Room, memberDidLeave member: RoomMember) {
        DispatchQueue.main.sync {
            endCallTask()
        }
    }
    
    func roomPublicationListDidChange(_ room: SkyWayRoom.Room) {
        DispatchQueue.main.sync {
            remotePublications = room.publications.filter({ $0.publisher != localMember })
        }
    }
    
    func roomSubscriptionListDidChange(_ room: SkyWayRoom.Room) {
        DispatchQueue.main.sync {
            callStatus = .callable
            setTimer()
            isConnect = true
            localSubscriptions = room.subscriptions.filter({ $0.subscriber == localMember })
        }
    }
}
