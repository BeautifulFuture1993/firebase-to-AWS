//
//  CardView.swift
//  Tatibanashi-MVP
//
//  Created by Apple on 2022/05/05.
//

import UIKit
import TagListView

protocol CardViewDelegate: AnyObject {
    func didRightStartSwipeCardView(view: CardView)
    func didLeftStartSwipeCardView(view: CardView)
    func didTapViolationBtn(view: CardView)
    func didRightSwipeCardView(view: CardView)
    func didLeftSwipeCardView(view: CardView)
}

final class CardView: UIView {
    
    var cardUser: User?
    var cardUID = ""
    var cardNickName = ""
    var cardHobbyListCount = 0
    var cardHobbyListTotalString = 0
    var cardHobbyMatchPercentage = 0.0
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var bubbleView: BubbleView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var approachLabel: UILabel!
    @IBOutlet weak var approachSorryLabel: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var online: UILabel!
    @IBOutlet weak var onlineTime: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var hobbyListView: TagListView!
    @IBOutlet weak var goodOverlay: UIView!
    @IBOutlet weak var badOverlay: UIView!
    @IBOutlet weak var badIcon: UIImageView!
    @IBOutlet weak var goodIcon: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet var iconIndicators: [UIView]!
    @IBOutlet weak var iconIndicatorHeight: NSLayoutConstraint!
    @IBOutlet weak var typeStackView: UIStackView!
    @IBOutlet weak var holidayStackView: UIStackView!
    @IBOutlet weak var incomeStackView: UIStackView!
    @IBOutlet weak var businessStackView: UIStackView!
    @IBOutlet weak var violationView: UIView!
    @IBOutlet weak var violationLabel: UILabel!
    @IBOutlet weak var violationShadowView: UIView!
    
    weak var delegate: CardViewDelegate?
    var iconURLs = [String]()
    var showingImageIndex = 0 {
        didSet {
            iconIndicators.forEach { $0.alpha = 0.5 }
            iconIndicators[showingImageIndex].alpha = 1
        }
    }
    
    private var loadedImages: [String: UIImage] = [:]
        
    override init(frame: CGRect) {
        super.init(frame: .zero)
        nibInit()
    }
    
    init(user: User) {
        self.init()
        
        loadedImages = [:]
        
//        let testMessageText = """
//        初めまして🤗
//        地方から出てきて周りに友達も少ないので仲良くしてください。
//        仕事で返信が遅くなりますが必ず返しますのでよろしくお願い致します😊
//        """
        let testMessageText = ""
        messageView.isHidden = (testMessageText.isEmpty ? true : false)
        messageTextView.text = testMessageText
        // UI外の保持したい変数
        cardUser = user
        cardUID = user.uid
        cardNickName = user.nick_name
        iconImg.setImage(withURLString: user.profile_icon_img)
        iconURLs.append(user.profile_icon_img)
        
        if user.profile_icon_sub_imgs.count == 0 {
            iconIndicatorHeight.constant = 0
        } else {
            user.profile_icon_sub_imgs.forEach{ iconURLs.append($0) }
            iconIndicators.forEach {
                if $0.tag >= iconURLs.count {
                    $0.isHidden = true
                }
            }
            iconURLs.forEach {
                self.loadImageFromURL(from: $0)
            }
        }
        
        nickName.text = user.nick_name
        age.text = user.birth_date.calcAge()
        address.text = "\(user.address)\(user.address2)"
        typeLabel.text = "タイプ：\(user.type)"
        holidayLabel.text = "休日：\(user.holiday)"
        setInfo(item: "職業", stack: businessStackView, label: businessLabel, text: user.business)
        setInfo(item: "収入", stack: incomeStackView, label: incomeLabel, text: user.income.getIncomeDifference())
        violationLabel.text = "\(user.violation_count)"
        online.text = "●"
        // オンライン状態をテキスト表示
        let isLogin = user.is_logined
        let logoutTime = user.logouted_at.dateValue()
        let elaspedTime = elapsedTime(isLogin: isLogin, logoutTime: logoutTime)
        if elaspedTime[0] != nil {
            onlineTime.text = "オンライン"
            online.textColor = .green
        } else if let elaspedTimeSecond = elaspedTime[1] {
            onlineTime.text = "\(elaspedTimeSecond)秒前"
            online.textColor = .green
        } else if let elaspedTimeMinute = elaspedTime[2] {
            onlineTime.text = "\(elaspedTimeMinute)分前"
            online.textColor = .green
        } else if let elaspedTimeHour = elaspedTime[3] {
            onlineTime.text = "\(elaspedTimeHour)時間前"
            online.textColor = .green
        } else if let elaspedTimeDay = elaspedTime[4] {
            if elaspedTimeDay > 5 {
                onlineTime.isHidden = true
            } else {
                onlineTime.text = "\(elaspedTimeDay)日前"
                online.textColor = .green
            }
        }
        // 趣味カード
        hobbyListView.addTags(user.hobbies)
        cardHobbyListCount = user.hobbies.count
        user.hobbies.forEach { hobby in
            cardHobbyListTotalString += hobby.count
        }
        var hobbyListViewWidth: CGFloat = 0
        if cardHobbyListCount*40 + cardHobbyListTotalString*14 < Int(UIScreen.main.bounds.width - 40) {
            hobbyListViewWidth = UIScreen.main.bounds.width - 40
            hobbyListView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            hobbyListViewWidth = CGFloat(cardHobbyListCount*20 + cardHobbyListTotalString*7)
        }
        hobbyListView.widthAnchor.constraint(equalToConstant: hobbyListViewWidth).isActive = true
        // ログインユーザとターゲットユーザの興味タグ一致率を計算
        let hobbies = GlobalVar.shared.loginUser?.hobbies ?? [String]()
        cardHobbyMatchPercentage = hobbyMatchingRate(ownHobbyList: hobbies, targetHobbyList: user.hobbies)
        // プロフィールステータス
        status.text = user.profile_status
    }

    deinit {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // カスタムビューの初期化
    private func nibInit() {
        let nib = UINib(nibName: "CardView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.addSubview(view)
            configure()
        }
    }
    
    private func configure() {
        violationView.layer.cornerRadius = 15
        violationView.layer.cornerRadius = 15
        violationShadowView.layer.cornerRadius = 15
        hobbyListView.textFont = UIFont.boldSystemFont(ofSize: 14)
        bubbleView.setCustomShadow(opacity: 0.3, height: 5)
        // カード操作を定義
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(panGesture)
        // 違反報告ボタンを最前面
        violationView.layer.zPosition = 1
        // 違反報告動作を定義
        violationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapViolationBtn)))
    }
    
    private func setInfo(item: String, stack: UIStackView, label: UILabel, text: String) {
        if text == "未設定" {
            stack.isHidden = true
        } else {
            stack.isHidden = false
            label.text = "\(item)：\(text)"
        }
    }
    
    private func setIntInfo(item: String, stack: UIStackView, label: UILabel, int: Int) {
        print("ドタキャン回数：\(int)")
        if int == 0 {
            stack.isHidden = true
        } else {
            stack.isHidden = false
            label.text = "\(item)：\(int)"
        }
    }
        
    // panGestureの動きをswitchで分岐
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            superview?.subviews.forEach { $0.layer.removeAllAnimations() }
        case .changed:
            panCard(sender: sender)
        case .ended:
            resetCardPosition(sender: sender)
        default:
            break
        }
    }
    
    // カードを持った時、指についていく滑らかな移動の処理
    private func panCard(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 90
        let rotationalTransform = CGAffineTransform(rotationAngle: angle)
        transform = rotationalTransform.translatedBy(x: translation.x, y: translation.y)
        //スワイプの進行度に合わせてカードにOverlayを表示
        let goodProgress = Float(translation.x / 100)
        let badProgress = goodProgress * -1
        if goodProgress > 0 {
            badOverlay.isHidden = true
            goodOverlay.isHidden = false
            goodOverlay.layer.opacity = goodProgress
        } else if badProgress > 0 {
            badOverlay.isHidden = false
            goodOverlay.isHidden = true
            badOverlay.layer.opacity = badProgress
        } else {
            badOverlay.isHidden = true
            goodOverlay.isHidden = true
        }
    }
    
    // スワイプが終わった時のカードが退く動きの処理
    private func resetCardPosition(sender: UIPanGestureRecognizer) {
        let direction = CGFloat(sender.translation(in: nil).x > 100 ? 1 : -1)
        let shouldDismissCard = abs(sender.translation(in: nil).x) > 100
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let me = self else { return }
            //スワイプしきった時
            if shouldDismissCard {
                let translation = sender.translation(in: nil).x > 100
                if translation {
                    self?.didRightSwipeCardView()
                } else {
                    self?.didLeftSwipeCardView()
                }
                me.transform = me.transform.translatedBy(x: 400 * direction, y: 400)
            //スワイプを辞めた時
            } else {
                me.transform = .identity
                self?.goodOverlay.isHidden = true
                self?.badOverlay.isHidden = true
            }
        }) { [weak self] _ in
            guard let me = self else { return }
            if shouldDismissCard {
                me.removeFromSuperview()
            }
        }
    }
    
    // 興味タグの一致率を算出
    func hobbyMatchingRate(ownHobbyList: [String], targetHobbyList: [String]) -> Double {
        let ownHobbiesCount = ownHobbyList.count
        let targetHobbyListFilter = targetHobbyList.filter({ ownHobbyList.contains($0) })
        let targetHobbyListFilterCount = targetHobbyListFilter.count
        let hobbyMatchingRate = Double(targetHobbyListFilterCount) / Double(ownHobbiesCount)
        return hobbyMatchingRate
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
    
    // 右スワイプ起動動作
    @objc func didRightStartSwipeCardView() {
        delegate?.didRightStartSwipeCardView(view: self)
    }
    
    // 左スワイプ起動動作
    @objc func didLeftStartSwipeCardView() {
        delegate?.didLeftStartSwipeCardView(view: self)
    }
    
    // 違反報告タップ動作
    @objc func didTapViolationBtn() {
        delegate?.didTapViolationBtn(view: self)
    }
    
    // 右スワイプ動作
    @objc func didRightSwipeCardView() {
        delegate?.didRightSwipeCardView(view: self)
    }
    
    // 左スワイプ動作
    @objc func didLeftSwipeCardView() {
        delegate?.didLeftSwipeCardView(view: self)
    }
    
    @IBAction func nextImageAction(_ sender: UIButton) {
        if showingImageIndex < iconURLs.count - 1 {
            showingImageIndex += 1
            
            if let iconURL = iconURLs[safe: showingImageIndex] {
                if let image = loadedImages[iconURL] {
                    iconImg.image = image
                } else {
                    iconImg.setImage(withURLString: iconURL)
                }
            }
            
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            
            let logEventData = [
                "nextImageIndex": showingImageIndex
            ] as [String : Any]
            Log.event(name: "nextCardProfileSubImg", logEventData: logEventData)
            
        } else {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
    }
    
    @IBAction func prevImageAction(_ sender: UIButton) {
        if showingImageIndex > 0 {
            showingImageIndex -= 1
            
            if let iconURL = iconURLs[safe: showingImageIndex] {
                if let image = loadedImages[iconURL] {
                    iconImg.image = image
                } else {
                    iconImg.setImage(withURLString: iconURL)
                }
            }

            let feedback = UIImpactFeedbackGenerator(style: .heavy)
            feedback.impactOccurred()
            
            let logEventData = [
                "prevImageIndex": showingImageIndex
            ] as [String : Any]
            Log.event(name: "prevCardProfileSubImg", logEventData: logEventData)
            
        } else {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
    }
    
    // viewDidLoadで先に読み込む
    private func loadImageFromURL(from urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let _ = self else { return }
            // success
            if error == nil, case .some(let result) = data, let image = UIImage(data: result) {
                self?.loadedImages[urlString] = image
                // failure
            } else {
                print(error ?? "urlからの画像の読み込みに失敗")
            }
        }.resume()
    }
}
