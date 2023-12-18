//
//  NewMatchChildCollectionViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/06/16.
//

import UIKit
import FirebaseFirestore

protocol NewMatchChildCollectionViewCellDelegate: AnyObject {
    func didTapGoRoom(cell: NewMatchChildCollectionViewCell)
}

final class NewMatchChildCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgColorLabel: UILabel!
    @IBOutlet weak var bgLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopWatchView: UIView!
    
    static let nibName = "NewMatchChildCollectionViewCell"
    static let cellIdentifier = "NewMatchChildCollectionViewCell"
    static let height: CGFloat = 100
    static let width: CGFloat = 80
    
    weak var delegate : NewMatchChildCollectionViewCellDelegate?
    var room: Room?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUp()
    }
    
    private func setUp() {
        setGradient()
        setUpRounded()
        setUpTapGesture()
    }
    
    private func setGradient() {
        //グラデーションをつける
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bgColorLabel.bounds
        //グラデーションさせるカラーの設定
        let color1 = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 0.35).cgColor //白
        let color2 = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0).cgColor //水色
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1, color2]
        //グラデーションの開始地点・終了地点の設定
        gradientLayer.startPoint = CGPoint.init(x: 0.25, y: 0.75)
        gradientLayer.endPoint = CGPoint.init(x: 0.75 , y:0.25)
        //ViewControllerのViewレイヤーにグラデーションレイヤーを挿入する
        bgColorLabel.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setUpRounded() {
        bgLabel.rounded()
        bgColorLabel.clipsToBounds = true
        bgColorLabel.rounded()
        iconImage.rounded()
        stopWatchView.rounded()
    }
    
    private func setUpTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGoRoom))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func getTime(created_at: Timestamp) {
        let now = Date()
        let span = now.timeIntervalSince(created_at.dateValue())
        let hourSpan = Int(floor(span/60/60))
        let time = 24 - hourSpan
        timeLabel.text = "残り\(String(time))時間"
    }
    
    func configure(with room: Room) {
        self.room = room
        // 相手の情報を表示
        userInfoLabel.text = "..."
        // 相手の画像を設定
        iconImage.image = UIImage()
        // ルームにメッセージ相手がいる場合
        if let partner = room.partnerUser {
            // ユーザ情報設定
            let partnerAge = partner.birth_date.calcAge()
            let partnerAddress = partner.address
            let partnerProfileIconImg = partner.profile_icon_img
            userInfoLabel.text = "\(partnerAge) \(partnerAddress)"
            // 画像設定
            let isNotMember = (userInfoLabel.text != "...")
            if isNotMember && partnerProfileIconImg.isEmpty == false {
                iconImage.setImage(withURLString: partnerProfileIconImg)
            }
            // オンラインステータス表示
            statusLabel.isHidden = false
            statusLabel.textColor = .green
            let partnerLogined = partner.is_logined
            let partnerLogoutTime = partner.logouted_at.dateValue()
            let elaspedTime = elapsedTime(isLogin: partnerLogined, logoutTime: partnerLogoutTime)
            if let elaspedTimeDay = elaspedTime[4], elaspedTimeDay > 5 {
                statusLabel.isHidden = true
            }
        }
        getTime(created_at: room.created_at)
    }
    
    @objc private func didTapGoRoom(cell: NewMatchChildCollectionViewCell) {
        delegate?.didTapGoRoom(cell: self)
    }
}
