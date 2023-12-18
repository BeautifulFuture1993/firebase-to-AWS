//
//  HomeViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/13.
//

import UIKit
import StoreKit
import Typesense
import FBSDKCoreKit
import FirebaseFirestore
import FirebaseAnalytics
import FirebaseFunctions

class HomeViewController: UIBaseViewController {
    
    @IBOutlet weak var backgroundLoadingView: UIView!
    @IBOutlet weak var noUserView: UIView!
    @IBOutlet weak var noUserTitleLabel: UILabel!
    
    private var buttonBackgroundView = UIStackView()
    // カードの右側・左側の吹き出し
    private var cardLeftSideView = CardSideView(type: "left")
    private var cardRightSideView = CardSideView(type: "right")
    // カードの上側に重ねるView
    private var cardOverSideView = CardNoneView(comment: "")
    
    var topPadding: CGFloat = 0
    var bottomPadding: CGFloat = 0
    // カード下のボタン
    let bottomButtonsStackView = UIStackView()
    let skipButton = UIButton()
    let approachButton = UIButton()
    // カード操作
    var overlay = UIView()
    var translation: CGFloat = 0
    var timer: Timer?
    
    var cardApproachType = ""
    
    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // カードの土台 (カードデッキ制約)
        setCardContentViewComponent()
        // カードの裏側にロード画面を表示
        setBackgroundLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationWithSetUp(navigationTitle: "お相手からのいいね!")
        tabBarController?.tabBar.backgroundColor = .white
        
        let cardApproachedUsers = GlobalVar.shared.cardApproachedUsers
        DispatchQueue.main.async { self.setCard(users: cardApproachedUsers) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GlobalVar.shared.contentView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GlobalVar.shared.contentView.isHidden = true
        buttonBackgroundView.removeFromSuperview()
        navigationController?.navigationBar.isHidden = false
    }
}

/** カード関連の処理 **/
extension HomeViewController {
    // カード関連のUI設定
    private func setCardContentViewComponent() {
        guard let window = Window.first else { return }
        guard let navigation = navigationController else { return }
        guard let tabBar = tabBarController else { return }
        
        if noUserView != nil { noUserView.isHidden = true }
        if backgroundLoadingView != nil { backgroundLoadingView.isHidden = false }
        noUserTitleLabel.text = "アプローチされた相手が居ません\n「さがす」から気になる人へ\nアプローチを送ってみましょう"
        let stackViewX = (view.bounds.width / 2) - 75
        let stackViewY = bottomButtonsStackView.frame.minY
        let stackWidth = CGFloat(150)
        let stackHeight = bottomButtonsStackView.frame.height
        bottomButtonsStackView.frame = CGRect(x: stackViewX, y: stackViewY, width: stackWidth, height: stackHeight)
        
        let safeAreaInsets = window.safeAreaInsets
        let safeAreaTop = safeAreaInsets.top
        topPadding = navigation.navigationBar.frame.height + safeAreaTop + 10
        bottomPadding = tabBar.tabBar.frame.height
        let cardHeight = view.bounds.height - topPadding - bottomPadding - 70
        GlobalVar.shared.contentView.frame = CGRect(x: 0, y: topPadding, width: view.bounds.width, height: cardHeight)
        
        bottomButtonsStackView.removeFromSuperview()
        
        bottomButtonsStackView.frame = CGRect(x: stackViewX, y: cardHeight + 10, width: 150, height: 60)
        bottomButtonsStackView.distribution = .equalCentering
        bottomButtonsStackView.alignment = .center
        bottomButtonsStackView.axis = .horizontal
        
        bottomButtonsStackView.addArrangedSubview(skipButton)
        bottomButtonsStackView.addArrangedSubview(approachButton)

        setUpBottomButton(skipButton, systemImageName: "hand.thumbsdown.fill", tintColor: .systemGray2)
        setUpBottomButton(approachButton, systemImageName: "hand.thumbsup.fill", tintColor: .accentColor)
        
        view.addSubview(bottomButtonsStackView)
        
        skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
        approachButton.addTarget(self, action: #selector(didTapApproachButton), for: .touchUpInside)
        
        GlobalVar.shared.contentView.removeFromSuperview()
        GlobalVar.shared.deckView.removeFromSuperview()
        
        window.addSubview(GlobalVar.shared.contentView)
        GlobalVar.shared.contentView.addSubview(GlobalVar.shared.deckView)
        
        GlobalVar.shared.deckView.translatesAutoresizingMaskIntoConstraints = false
        GlobalVar.shared.deckView.topAnchor.constraint(equalTo: GlobalVar.shared.contentView.topAnchor, constant: 10).isActive = true
        GlobalVar.shared.deckView.bottomAnchor.constraint(equalTo: GlobalVar.shared.contentView.bottomAnchor, constant: -10).isActive = true
        GlobalVar.shared.deckView.leftAnchor.constraint(equalTo: GlobalVar.shared.contentView.leftAnchor, constant: 15).isActive = true
        GlobalVar.shared.deckView.rightAnchor.constraint(equalTo: GlobalVar.shared.contentView.rightAnchor, constant: -15).isActive = true
        GlobalVar.shared.deckView.setShadow()
    }
    
    private func setBackgroundLoadingView() {
        if let _ = backgroundLoadingView {
            removeAllSubviews(parentView: backgroundLoadingView)
            let indicator = UIActivityIndicatorView()
            indicator.center = backgroundLoadingView.center
            indicator.style = .large
            indicator.color = UIColor(named: "AccentColor")
            indicator.startAnimating()
            backgroundLoadingView.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.centerXAnchor.constraint(equalTo: backgroundLoadingView.centerXAnchor).isActive = true
            indicator.centerYAnchor.constraint(equalTo: backgroundLoadingView.centerYAnchor).isActive = true
            view.bringSubviewToFront(backgroundLoadingView)
        }
    }
    
    private func setUpBottomButton(_ button: UIButton, systemImageName: String, tintColor: UIColor) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.setImage(UIImage(systemName: systemImageName), for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 25), forImageIn: .normal)
        button.backgroundColor = .white
        button.tintColor = tintColor
        button.layer.cornerRadius = 30
        button.setShadow(opacity: 0.3, color: tintColor)
    }
    
    @objc func didTapSkipButton() {
        if translation != 0 || timer != nil { return }
        
        cardApproachType = "approachSorry"
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        translation = 0
        timer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func didTapApproachButton() {
        if translation != 0 || timer != nil { return }
        
        cardApproachType = "approach"
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        translation = 0
        timer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    // カード自動スワイプ
    @objc func timerUpdate() {
        if let lastCardView = GlobalVar.shared.cardViews.last {
            translation += 1
            if translation == 1 {
                removeAllSubviews(parentView: overlay)
                var overlayIcon = UIImageView()
                let overlayLabel = UILabel()
                if cardApproachType == "approach" {
                    overlay.backgroundColor = UIColor(named: "AccentColor")
                    overlayIcon = UIImageView(image: UIImage(systemName: "hand.thumbsup.circle.fill"))
                    overlayLabel.text = "Match"
                    
                } else if cardApproachType == "approachSorry" {
                    overlay.backgroundColor = .darkGray
                    overlayIcon = UIImageView(image: UIImage(systemName: "hand.thumbsdown.circle.fill"))
                    overlayLabel.text = "NG"
                    
                }
                overlay.layer.cornerRadius = 20
                lastCardView.addSubview(overlay)
                overlay.translatesAutoresizingMaskIntoConstraints = false
                overlay.topAnchor.constraint(equalTo: lastCardView.topAnchor, constant: 0).isActive = true
                overlay.bottomAnchor.constraint(equalTo: lastCardView.bottomAnchor, constant: 0).isActive = true
                overlay.leftAnchor.constraint(equalTo: lastCardView.leftAnchor, constant: 0).isActive = true
                overlay.rightAnchor.constraint(equalTo: lastCardView.rightAnchor, constant: 0).isActive = true
                overlayIcon.tintColor = .white
                overlayIcon.contentMode = .scaleAspectFit
                overlay.addSubview(overlayIcon)
                overlayIcon.translatesAutoresizingMaskIntoConstraints = false
                overlayIcon.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
                overlayIcon.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
                overlayIcon.widthAnchor.constraint(equalToConstant: 200).isActive = true
                overlayIcon.heightAnchor.constraint(equalToConstant: 200).isActive = true
                overlayLabel.textColor = .white
                overlayLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 30)
                overlay.addSubview(overlayLabel)
                overlayLabel.translatesAutoresizingMaskIntoConstraints = false
                overlayLabel.topAnchor.constraint(equalTo: overlayIcon.bottomAnchor, constant: 10).isActive = true
                overlayLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
                overlayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
                overlayLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
                overlay.layer.opacity = 0
                
            } else if translation <= 180 {
                if cardApproachType == "approach" {
                    // 右にスワイプ
                    let rotationalTransform = CGAffineTransform(rotationAngle: translation * .pi / 900)
                    lastCardView.transform = rotationalTransform.translatedBy(x: translation, y: 0)
                    
                } else if cardApproachType == "approachSorry" {
                    // 左にスワイプ
                    let rotationalTransform = CGAffineTransform(rotationAngle: -translation * .pi / 900)
                    lastCardView.transform = rotationalTransform.translatedBy(x: -translation, y: 0)
                    
                }
                //スワイプの進行度に合わせてカードにOverlayを表示
                let progress = Float(translation * .pi / 100)
                if progress > 0 { overlay.layer.opacity = progress }
                
            } else if translation == 181 { // 終了
                
                if cardApproachType == "approach" {

                    lastCardView.removeFromSuperview()
                    
                    if let cardApproachedUser = GlobalVar.shared.cardApproachedUsers.first {
                        let uid = cardApproachedUser.uid
                        let nickName = cardApproachedUser.nick_name
                        approachOK(targetUID: uid, targetNickName: nickName, actionType: "click", approachUser: cardApproachedUser)
                    } else {
                        timerStop()
                    }

                } else if cardApproachType == "approachSorry" {

                    lastCardView.removeFromSuperview()
                    
                    // 相手から
                    if let cardApproachedUser = GlobalVar.shared.cardApproachedUsers.first {
                        let uid = cardApproachedUser.uid
                        let nickName = cardApproachedUser.nick_name
                        print("approachSorry ニックネーム : \(nickName)")
                        approachNG(targetUID: uid, targetNickName: nickName, actionType: "click")
                    } else {
                        timerStop()
                    }

                    
                } else {
                    overlay.removeFromSuperview()
                    timerStop()
                }
            }
            
        } else {
            timerStop()
        }
    }
    
    private func timerStop() {
        timer?.invalidate()
        timer = nil
        translation = 0
    }
}

/** ユーザ関連の処理 **/
extension HomeViewController {
    
    // GlobalVar.shared.deckViewへの貼付
    private func configureCardViews(setCardViews: [CardView]) {
        // デッキカードリセット (Viewのインスタンスを破棄: メモリが増長しないための処理)
        removeAllSubviews(parentView: GlobalVar.shared.deckView)
        setCardViews.forEach { cardView in
            GlobalVar.shared.deckView.addSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            cardView.topAnchor.constraint(equalTo: GlobalVar.shared.deckView.topAnchor).isActive = true
            cardView.leftAnchor.constraint(equalTo: GlobalVar.shared.deckView.leftAnchor).isActive = true
            cardView.bottomAnchor.constraint(equalTo: GlobalVar.shared.deckView.bottomAnchor).isActive = true
            cardView.rightAnchor.constraint(equalTo: GlobalVar.shared.deckView.rightAnchor).isActive = true
            cardView.layer.cornerRadius = 20
            cardView.clipsToBounds = true
        }
    }
    
    // カードをセットする
    func setCard(users: [User]) {
        // ユーザカード初期化
        GlobalVar.shared.cardViews = [CardView]()
        // カードユーザ配列
        var cardUserViews = [CardView]()
        if users.isEmpty {
            // ユーザが存在しない場合はViewを表示する
            if noUserView != nil { noUserView.isHidden = false }
            // ローディング画面を非表示にする
            if backgroundLoadingView != nil { backgroundLoadingView.isHidden = true }
            // カードの制約をつける
            configureCardViews(setCardViews: GlobalVar.shared.cardViews)
            
        } else {
            // ユーザが存在しない場合はViewを非表示にする
            if noUserView != nil { noUserView.isHidden = true }
            // ローディング画面を表示する
            if backgroundLoadingView != nil { backgroundLoadingView.isHidden = false }
            // ユーザ数に応じてカードを生成
            for (index, user) in users.enumerated() {
                let cardView = CardView(user: user)
                cardView.delegate = self
                cardUserViews.append(cardView)
                // 10人単位・最後ユーザの場合 カードを生成
                let isLastUser = (user.uid == users.last?.uid)
                if index == 9 || isLastUser {
                    setCardView(cardUserViews: cardUserViews)
                    break
                }
            }
        }
    }
    
    // カードのセット
    func setCardView(cardUserViews: [CardView]) {
        // アプローチされた
        let approachedUsers = GlobalVar.shared.cardApproachedUsers
        // アプローチされたユーザはラベル名・アイコンを変更する
        cardUserViews.forEach { cardUserView in
            let cardUID = cardUserView.cardUID
            let isApproahedUser = (approachedUsers.firstIndex(where: { $0.uid == cardUID }) != nil)
            if isApproahedUser {
                cardUserView.approachLabel.text = "Match"
                cardUserView.approachSorryLabel.text = "NG"
                cardUserView.goodIcon.image = UIImage(systemName: "circle.circle.fill")
                cardUserView.badIcon.image = UIImage(systemName: "multiply.circle.fill")
            }
        }
        // カードユーザ
        GlobalVar.shared.cardViews = cardUserViews.reversed()
        // カードの制約をつける
        configureCardViews(setCardViews: GlobalVar.shared.cardViews)
        // チュートリアル
        playTutorial(key: "isShowedApproachedTutorial", type: "approachMatch")
    }
}

extension HomeViewController: CardViewDelegate {
    
    func cardOverSideViewConstraint(view: CardView) {
        cardOverSideView.removeFromSuperview()
        view.addSubview(cardOverSideView)
        cardOverSideView.translatesAutoresizingMaskIntoConstraints = false
        cardOverSideView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cardOverSideView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cardOverSideView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cardOverSideView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cardOverSideView.layer.opacity = 0.5
        cardOverSideView.layer.cornerRadius = 20
        cardOverSideView.clipsToBounds = true
        view.bringSubviewToFront(cardOverSideView)
    }
    
    // 右側スワイプの開始
    func didRightStartSwipeCardView(view: CardView) {
        cardLeftSideView.isHidden = true
        cardLeftSideView.layer.opacity = 0.8
        cardRightSideView.isHidden = false
        cardRightSideView.layer.opacity = 1.0
        let approach = view.approachLabel.text ?? ""
        // 自分からアプローチする場合
        if approach.contains("Good") {
            cardRightSideView.rightSideLabel.text = "Good"
        }
        // 相手からのアプローチに返答する場合
        if approach.contains("Match") {
            cardRightSideView.rightSideLabel.text = "Match"
        }
        cardOverSideView.backgroundColor = UIColor().setColor(colorType: "accentColor", alpha: 0.5)
        cardOverSideViewConstraint(view: view)
    }
    
    // 左側スワイプの開始
    func didLeftStartSwipeCardView(view: CardView) {
        cardRightSideView.isHidden = true
        cardRightSideView.layer.opacity = 0.8
        cardLeftSideView.isHidden = false
        cardLeftSideView.layer.opacity = 1.0
        let approachSorry = view.approachSorryLabel.text ?? ""
        // 自分からアプローチする場合
        if approachSorry.contains("Skip") {
            cardLeftSideView.leftSideLabel.text = "Skip"
        }
        // 相手からのアプローチに返答する場合
        if approachSorry.contains("NG") {
            cardLeftSideView.leftSideLabel.text = "NG"
        }
        cardOverSideView.backgroundColor = UIColor().setColor(colorType: "fontColor", alpha: 0.5)
        cardOverSideViewConstraint(view: view)
    }
    
    // 違反報告
    func didTapViolationBtn(view: CardView) {
        // 違反報告画面に遷移
        let storyBoard = UIStoryboard.init(name: "ViolationView", bundle: nil)
        let violationVC = storyBoard.instantiateViewController(withIdentifier: "ViolationView") as! ViolationViewController
        violationVC.targetUser = view.cardUser
        violationVC.transitioningDelegate = self
        violationVC.presentationController?.delegate = self
        present(violationVC, animated: true, completion: nil)
    }
    
    // アプローチ(マッチング)
    func didRightSwipeCardView(view: CardView) {
        let uid = view.cardUID
        let nickName = view.cardNickName
        let approach = view.approachLabel.text ?? ""
        guard let approachUser = view.cardUser else { return }
        if approach.contains("Match") { approachOK(targetUID: uid, targetNickName: nickName, actionType: "swipe", approachUser: approachUser) }
    }
    
    // アプローチ見送り(NG)
    func didLeftSwipeCardView(view: CardView) {
        let uid = view.cardUID
        let nickName = view.cardNickName
        let approachSorry = view.approachSorryLabel.text ?? ""
        if approachSorry.contains("NG") { approachNG(targetUID: uid, targetNickName: nickName, actionType: "swipe") }
    }
    
    // マッチング時の動作
    private func approachOK(targetUID: String, targetNickName: String, actionType: String, approachUser: User) {
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        let loginUID = loginUser.uid
        let rooms = loginUser.rooms
        // ロード画面の表示
        showLoadingView(loadingView)
        // アプローチOK処理を実施
        let statusOK = 1
        firebaseController.approachedReply(loginUID: loginUID, targetUID: targetUID, status: statusOK, actionType: actionType, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            if result {
                let roomType = "approach"
                // メッセージルームを作成し画面遷移
                weakSelf.firebaseController.messageRoomAction(roomType: roomType, rooms: rooms, loginUID: loginUID, targetUID: targetUID, completion: { [weak self] subResult in
                    guard let weakSubSelf = self else { return }
                    
                    weakSubSelf.loadingView.removeFromSuperview()
                    print("\(targetNickName)さんとのマッチングが完了しルームを生成しました！😆👍")
                    
                    if let roomID = subResult {
                        
                        let autoMessage = GlobalVar.shared.loginUser?.is_auto_message ?? true
                        if autoMessage {
                            
                            GlobalVar.shared.displayAutoMessage = true
                            weakSubSelf.moveMessageRoom(roomID: roomID, target: approachUser)
                            
                        } else {
                            weakSubSelf.alert(title: "マッチングに成功しました!", message: "メッセージルームにてやりとりを開始してください!", actiontitle: "OK")
                        }
                        
                    } else {
                        weakSubSelf.alert(title: "マッチングに失敗しました。。", message: "このユーザに何か問題がある可能性があります。気になる場合は運営に報告してください。", actiontitle: "OK")
                    }
                })
                print("\(targetNickName)さんとのマッチングが完了しました！😆👍")
                weakSelf.tryResetCardView(status: statusOK, actionType: actionType)
                
            } else {
                weakSelf.loadingView.removeFromSuperview()
                weakSelf.alert(title: "マッチングに失敗しました。。", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
            }
        })
    }
    
    // アプローチNG時の動作
    private func approachNG(targetUID: String, targetNickName: String, actionType: String) {
        
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        // アプローチNG処理を実施
        let statusNG = 2
        firebaseController.approachedReply(loginUID: loginUID, targetUID: targetUID, status: statusNG, actionType: actionType, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            if result {
                print("\(targetNickName)さんとのマッチングNGしました！😭")
                weakSelf.tryResetCardView(status: statusNG, actionType: actionType)
                
            } else {
                print("アプローチNG失敗しました。。アプローチNGに失敗しました。アプリを再起動して再度実行してください。")
            }
        })
    }
    
    func tryResetCardView(status: Int, actionType: String) {
        // 相手からユーザ (アプローチされたユーザ)の場合
        if GlobalVar.shared.cardApproachedUsers.count != 0 {
            if let cardApproachedUser = GlobalVar.shared.cardApproachedUsers.first {
                GlobalVar.shared.cardApproachedUsers.removeFirst()
                approachLogEvent(cardUser: cardApproachedUser, status: status, actionType: actionType)
            }
        }
        
        if let _ = GlobalVar.shared.cardViews.last { GlobalVar.shared.cardViews.removeLast() }
        
        timerStop()
        
        if GlobalVar.shared.cardViews.count < 1 {
            // 相手からユーザ (アプローチされたユーザ)の場合
            if GlobalVar.shared.cardApproachedUsers.count == 0 {
                if noUserView != nil { noUserView.isHidden = false }
                if backgroundLoadingView != nil { backgroundLoadingView.isHidden = true }
            } else {
                setCard(users: GlobalVar.shared.cardApproachedUsers)
            }
        }
        
        setApproachedTabBadges()
    }
    
    private func approachLogEvent(cardUser: User, status: Int, actionType: String) {
        let cardUID = cardUser.uid
        let logEventData = [
            "target": cardUID
        ] as [String : Any]
        
        switch status {
        case 0: // アプローチGood
            if actionType == "click" {
                Log.event(name: "clickApproachGood", logEventData: logEventData)
            }  else if actionType == "swipe" {
                Log.event(name: "swipeApproachGood", logEventData: logEventData)
            }
            break
        case 1: // アプローチMatch
            if actionType == "click" {
                Log.event(name: "clickApproachMatch", logEventData: logEventData)
            }  else if actionType == "swipe" {
                Log.event(name: "swipeApproachMatch", logEventData: logEventData)
            }
            break
        case 2: // アプローチNG
            if actionType == "click" {
                Log.event(name: "clickApproachNG", logEventData: logEventData)
            }  else if actionType == "swipe" {
                Log.event(name: "swipeApproachNG", logEventData: logEventData)
            }
            break
        case 3: // アプローチSkip
            if actionType == "click" {
                Log.event(name: "clickApproachSkip", logEventData: logEventData)
            }  else if actionType == "swipe" {
                Log.event(name: "swipeApproachSkip", logEventData: logEventData)
            }
            break
        default:
            break
        }
    }
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        setClass(className: className)
        // 相手からユーザ (アプローチされたユーザ)の場合
        let cardApproachedUsers = GlobalVar.shared.cardApproachedUsers
        setCard(users: cardApproachedUsers)
    }
}

/** アプローチされた関連の処理 **/
extension HomeViewController {
    
    private func getApproachedSearchParameters(type: String = "search", page: Int = 1, specificUID: String = "") -> SearchParameters {
        
        let perPage = 100
        var searchFilterBy = "is_activated:= true && is_deleted:= false"
        var searchParameters = SearchParameters(q: "*", queryBy: "", page: page, perPage: perPage)
        
        guard let loginUser = GlobalVar.shared.loginUser else { return searchParameters }

        let approached = loginUser.approacheds
        let replyApproached = loginUser.reply_approacheds
        
        var duplicateApproached = approached.filter({ replyApproached.contains($0) == false })
        
        if specificUID != "" {
            duplicateApproached = duplicateApproached.filter({ $0 != specificUID })
            duplicateApproached.append(specificUID)
        }
        
        searchFilterBy = "uid: \(duplicateApproached)"
        
        searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, page: page, perPage: perPage)

        return searchParameters
    }
    
    func getApproachedCardUsers(page: Int = 1, specificUID: String = "") {
        
        Task {
            do {
                // let start = Date()
                
                let searchParameters = getApproachedSearchParameters(page: page, specificUID: specificUID)
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParameters, for: CardUserQuery.self)
                
                // let elapsed = Date().timeIntervalSince(start)
                // print("users全文検索の取得時間を計測 : \(elapsed)\n")
                
                setApproachedCardUsers(searchResult: searchResult, page: page, specificUID: specificUID)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func setApproachedCardUsers(searchResult: SearchResult<CardUserQuery>?, page: Int, specificUID: String = "") {
        
        guard let hits = searchResult?.hits else { setApproachedCardUsers(page: page); return }
        
        let isEmptyHits = (hits.count == 0)
        if isEmptyHits { setApproachedCardUsers(page: page); return }
            
        let approachedCardUsers = hits.map({ User(cardUserQuery: $0) })
        
        let filterApproachedCardUsers = approachedCardUsers.filter({
            let isApproached = filterApproachedMethod(user: $0)
            let existUser = checkUserInfo(user: $0)
            return isApproached && existUser
        })
        
        print(
            "カード取得数 : \(approachedCardUsers.count), ",
            "フィルター カード取得数 : \(filterApproachedCardUsers.count)"
        )
        
        let isEmptyApproachedCardUsers = (filterApproachedCardUsers.count == 0)
        if isEmptyApproachedCardUsers { getApproachedCardUsers(page: page + 1); return }
        
        var approached = GlobalVar.shared.loginUser?.approacheds ?? [String]()
        let isNotContainApproached = (specificUID != "" && approached.firstIndex(of: specificUID) == nil)
        if isNotContainApproached { approached.append(specificUID) }
        
        setApproachedCardUsers(cardUsers: filterApproachedCardUsers, page: page, approached: approached)
    }
    
    private func setApproachedCardUsers(cardUsers: [User] = [], page: Int = 1, approached: [String] = []) {
        
        let globalCardApproachedUsers = GlobalVar.shared.cardApproachedUsers
        let globalCardApproachedUserNum = globalCardApproachedUsers.count
        
        let duplicateCardUsers = cardUsers.filter({
            let specificUID = $0.uid
            let checkFilterUsers = globalCardApproachedUsers.filter({ $0.uid == specificUID }).count
            let isNotExistFilterUsers = (checkFilterUsers == 0)
            return isNotExistFilterUsers
        })
        let mergeCardApproachedUsers = globalCardApproachedUsers + duplicateCardUsers
        let mergeCardApproachedUserNum = mergeCardApproachedUsers.count

        let sortedMergeCardApproachedUsers = mergeCardApproachedUsers.sorted(by: {
            let currentIndex = approached.firstIndex(of: $0.uid) ?? 0
            let nextIndex = approached.firstIndex(of: $1.uid) ?? 0
            return currentIndex > nextIndex
        })
        
//        print("\n##########################")
//        print("typesense cardApproached")
//        sortedMergeCardApproachedUsers.forEach({
//            print("uid : \($0.uid) nick_name : \($0.nick_name)")
//        })
//        print("##########################\n")
        
        GlobalVar.shared.cardApproachedUsers = sortedMergeCardApproachedUsers
        
        let isNotEmptyCardApproachedUserNum = (globalCardApproachedUserNum != mergeCardApproachedUserNum)
        if isNotEmptyCardApproachedUserNum { getApproachedCardUsers(page: page + 1); return }
        
//        print(
//            "setCardApproachedUsers ",
//            "カードユーザ数 : \(globalCardApproachedUserNum), ",
//            "マージ後 : \(mergeCardApproachedUserNum)",
//            "指定されたページ : \(page)"
//        )
        
        setApproachedTabBadges(); setCard(users: sortedMergeCardApproachedUsers)
    }
}
