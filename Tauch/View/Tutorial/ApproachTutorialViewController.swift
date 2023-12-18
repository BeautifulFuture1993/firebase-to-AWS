//
//  ApproachTutorialViewController.swift
//  Tauch
//
//  Created by Apple on 2023/05/18.
//

import UIKit
import Typesense

class ApproachTutorialViewController: UIBaseViewController {

    @IBOutlet weak var backgroundLoadingView: UIView!
    
    let typesenseClient = GlobalVar.shared.typesenseClient
    let typesensePerPage = 100
    
    private var buttonBackgroundView = UIStackView()
    // カードの右側・左側の吹き出し
    private var cardLeftSideView = CardSideView(type: "left")
    private var cardRightSideView = CardSideView(type: "right")
    // カードの上側に重ねるView
    private var cardOverSideView = CardNoneView(comment: "")
    
    var topPadding: CGFloat = 0
    var bottomPadding: CGFloat = 0
    
    let topStackView = UIStackView()
    let processLabel = UILabel()
    
    let bottomButtonsStackView = UIStackView()
    let skipButton = UIButton()
    let approachButton = UIButton()

    var overlay = UIView()
    var translation: CGFloat = 0
    var timer: Timer?
    
    var tutorialNum = 1
    var cardApproachType = ""
    
    private let overlayView = UIView(frame: UIScreen.main.bounds)
    private let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = GlobalVar.shared.loginUser else { return }
        
        let loginTutorialNum = GlobalVar.shared.loginUser?.tutorial_num ?? 0
        tutorialNum = (tutorialNum - loginTutorialNum)
        
        if tutorialNum <= 0 { endTutorial(); return }
        
        GlobalVar.shared.loginUser?.tutorial_num = tutorialNum
        
        // tutorialNum > 1で設定した時の文言
        // processLabel.text = "あと\(tutorialNum)人アプローチしてください！"
        // tutorialNum = 1で設定した時の文言
        processLabel.text = "まず1人アプローチしてみましょう"
        
        setCardContentViewComponent()
        setBackgroundLoadingView()
        // 見た目上の画面遷移を速く見せるため、スコープ内の処理をサブスレッドで行う
        DispatchQueue.global(qos: .userInteractive).async { self.getTutorialCardUsers() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

/** チュートリアルカードUI関連の処理 **/
extension ApproachTutorialViewController {
    // カード関連のUI設定
    private func setCardContentViewComponent() {
        
        let safeAreaInsets = Window.first?.safeAreaInsets
        let safeAreaTop = safeAreaInsets?.top ?? 0
        let safeAreaBottom = safeAreaInsets?.bottom ?? 0
        
        let navigationHeight = navigationController?.navigationBar.frame.height ?? 0
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? safeAreaBottom
        
        let topStackHeight = CGFloat(30)
        let bottomStackHeight = CGFloat(60)
        
        topPadding = navigationHeight + safeAreaTop + 10
        bottomPadding = tabBarHeight
        
        let topStackViewX = (view.bounds.width / 2) - 150
        let topStackViewY = topPadding - 30
        let topStackWidth = CGFloat(300)
        
        topStackView.frame = CGRect(x: topStackViewX, y: topStackViewY, width: topStackWidth, height: topStackHeight)
        
        let cardHeight = view.bounds.height - topPadding - bottomPadding - 70
        
        let bottomStackViewX = (view.bounds.width / 2) - 75
        let bottomStackViewY = cardHeight + topPadding
        let bottomStackWidth = CGFloat(150)
        
        bottomButtonsStackView.frame = CGRect(x: bottomStackViewX, y: bottomStackViewY, width: bottomStackWidth, height: bottomStackHeight)
        
        GlobalVar.shared.tutorialContentView.frame = CGRect(x: 0, y: topPadding, width: view.bounds.width, height: cardHeight)
        
        topStackView.removeFromSuperview()
        bottomButtonsStackView.removeFromSuperview()
        
        topStackView.distribution = .equalCentering
        topStackView.alignment = .center
        topStackView.axis = .horizontal
        
        processLabel.lineBreakMode = .byWordWrapping
        topStackView.addArrangedSubview(processLabel)
        
        setUpTopLabel(processLabel, tintColor: .fontColor)
        
        view.addSubview(topStackView)
        
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
        
        GlobalVar.shared.tutorialContentView.removeFromSuperview()
        GlobalVar.shared.tutorialDeckView.removeFromSuperview()
        
        Window.first?.addSubview(GlobalVar.shared.tutorialContentView)
        GlobalVar.shared.tutorialContentView.addSubview(GlobalVar.shared.tutorialDeckView)
        
        GlobalVar.shared.tutorialDeckView.translatesAutoresizingMaskIntoConstraints = false
        GlobalVar.shared.tutorialDeckView.topAnchor.constraint(equalTo: GlobalVar.shared.tutorialContentView.topAnchor, constant: 10).isActive = true
        GlobalVar.shared.tutorialDeckView.bottomAnchor.constraint(equalTo: GlobalVar.shared.tutorialContentView.bottomAnchor, constant: -10).isActive = true
        GlobalVar.shared.tutorialDeckView.leftAnchor.constraint(equalTo: GlobalVar.shared.tutorialContentView.leftAnchor, constant: 15).isActive = true
        GlobalVar.shared.tutorialDeckView.rightAnchor.constraint(equalTo: GlobalVar.shared.tutorialContentView.rightAnchor, constant: -15).isActive = true
        GlobalVar.shared.tutorialDeckView.setShadow()
    }
    
    private func setBackgroundLoadingView() {
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
    
    private func setUpTopLabel(_ label: UILabel, tintColor: UIColor) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 60).isActive = true
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        label.backgroundColor = .white
        label.tintColor = tintColor
        label.font = UIFont.boldSystemFont(ofSize: 20)
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
        if let lastCardView = GlobalVar.shared.tutorialCardViews.last {
            translation += 1
            if translation == 1 {
                removeAllSubviews(parentView: overlay)
                var overlayIcon = UIImageView()
                let overlayLabel = UILabel()
                if cardApproachType == "approach" {
                    overlay.backgroundColor = UIColor(named: "AccentColor")
                    overlayIcon = UIImageView(image: UIImage(systemName: "hand.thumbsup.circle.fill"))
                    overlayLabel.text = "Good"
                    
                } else if cardApproachType == "approachSorry" {
                    overlay.backgroundColor = .darkGray
                    overlayIcon = UIImageView(image: UIImage(systemName: "hand.thumbsdown.circle.fill"))
                    overlayLabel.text = "Skip"
                    
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
                    
                    let uid = lastCardView.cardUID
                    let nickName = lastCardView.cardNickName
                    let approachType = "approach"
                    let approachStatus = 0
                    let actionType = "click"
                    approachCheck(
                        approachType: approachType,
                        approachStatus: approachStatus,
                        targetUID: uid,
                        targetNickName: nickName,
                        actionType: actionType
                    )

                } else if cardApproachType == "approachSorry" {

                    lastCardView.removeFromSuperview()

                    let uid = lastCardView.cardUID
                    let nickName = lastCardView.cardNickName
                    let approachType = "approachSorry"
                    let approachStatus = 3
                    let actionType = "click"
                    approachCheck(
                        approachType: approachType,
                        approachStatus: approachStatus,
                        targetUID: uid,
                        targetNickName: nickName,
                        actionType: actionType
                    )
                    
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

/** チュートリアル関連の処理 **/
extension ApproachTutorialViewController {
    
    private func getTutorialSearchParameters(type: String = "search", page: Int = 1, refetch: Bool = false) -> SearchParameters {
        
        var searchFilterBy = "is_activated:= true && is_deleted:= false"
        let searchSortBy = "is_logined:desc, logouted_at:desc, created_at:desc"
        
        var searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, page: page, perPage: typesensePerPage)
        
        guard let loginUser = GlobalVar.shared.loginUser else { return searchParameters }

        let loginUID = loginUser.uid
        var address = loginUser.address
        if refetch { address = "東京都" }
        
        searchFilterBy = "uid:!= \(loginUID) && address:= \(address)"
        
        searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, page: page, perPage: typesensePerPage)

        return searchParameters
    }
    
    func getTutorialCardUsers(page: Int = 1, refetch: Bool = false) {
        
        Task {
            do {
                let start = Date()
                
                let searchParameters = getTutorialSearchParameters(page: page, refetch: refetch)
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParameters, for: CardUserQuery.self)
                
                let elapsed = Date().timeIntervalSince(start)
                print("users全文検索の取得時間を計測 : \(elapsed)\n")
                
                searchResultTutorialCardUsers(searchResult: searchResult, page: page, refetch: refetch)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func searchResultTutorialCardUsers(searchResult: SearchResult<CardUserQuery>?, page: Int, refetch: Bool = false) {
        
        guard let hits = searchResult?.hits else { setTutorialCardUsers(); return }
        
        let isEmptyHits = (hits.count == 0)
        if isEmptyHits { setTutorialCardUsers(); return }
            
        let tutorialCardUsers = hits.map({ User(cardUserQuery: $0) })
        
        let filterTutorialCardUsers = tutorialCardUsers.filter({
            let existUser = checkUserInfo(user: $0)
            let isApproached = filterApproachedMethod(user: $0)
            return existUser && isApproached
        })
        
        print(
            "\nチュートリアルカードの取得",
            "カード取得数 : \(tutorialCardUsers.count), ",
            "フィルター カード取得数 : \(filterTutorialCardUsers.count), ",
            "ページ数 : \(page)",
            "refetch : \(refetch)"
        )
        
        let isEmptyTutorialCardUsers = (
            tutorialCardUsers.count < typesensePerPage &&
            filterTutorialCardUsers.count == 0 &&
            refetch == false
        )
        if isEmptyTutorialCardUsers { getTutorialCardUsers(refetch: true); return }
        
        let isEmptyFilterTutorialCardUsers = (filterTutorialCardUsers.count == 0)
        if isEmptyFilterTutorialCardUsers { getTutorialCardUsers(page: page + 1); return }
        
        setTutorialCardUsers(cardUsers: filterTutorialCardUsers)
    }
    
    private func setTutorialCardUsers(cardUsers: [User] = []) {
        
        let globalTutorialCardUsers = GlobalVar.shared.tutorialCardUsers
        let globalTutorialCardUserNum = globalTutorialCardUsers.count
        
        let duplicateCardUsers = cardUsers.filter({
            let specificUID = $0.uid
            let checkFilterUsers = globalTutorialCardUsers.filter({ $0.uid == specificUID }).count
            let isNotExistFilterUsers = (checkFilterUsers == 0)
            return isNotExistFilterUsers
        })
        let mergeTutorialCardUsers = globalTutorialCardUsers + duplicateCardUsers
        let mergeTutorialCardUserNum = mergeTutorialCardUsers.count
        
//        print("\n##########################")
//        print("typesense cardApproached")
//        sortedMergeCardApproachedUsers.forEach({
//            print("uid : \($0.uid) nick_name : \($0.nick_name)")
//        })
//        print("##########################\n")
        
        GlobalVar.shared.tutorialCardUsers = mergeTutorialCardUsers
        
        print(
            "setTutorialCardUsers ",
            "カードユーザ数 : \(globalTutorialCardUserNum), ",
            "マージ後 : \(mergeTutorialCardUserNum)"
        )
        
        setCard(users: mergeTutorialCardUsers)
    }
    
    // カードをセットする
    func setCard(users: [User]) {
        // ユーザカード初期化
        GlobalVar.shared.tutorialCardViews = [CardView]()
        // カードユーザ配列
        var cardUserViews = [CardView]()
        if users.isEmpty {
            if backgroundLoadingView != nil { backgroundLoadingView.isHidden = true }
            configureCardViews(setCardViews: GlobalVar.shared.tutorialCardViews)
            
        } else {
            // ローディング画面を表示する
            if backgroundLoadingView != nil { backgroundLoadingView.isHidden = false }
            // ユーザ数に応じてカードを生成
            for (index, user) in users.enumerated() {
                let cardView = CardView(user: user)
                cardView.delegate = self
                cardView.violationView.isHidden = true
                cardView.violationLabel.isHidden = true
                cardView.violationShadowView.isHidden = true
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
        // カードユーザ
        GlobalVar.shared.tutorialCardViews = cardUserViews.reversed()
        // カードの制約をつける
        configureCardViews(setCardViews: GlobalVar.shared.tutorialCardViews)
        // チュートリアル
        playTutorial(key: "isShowedApproachTutorial", type: "approach")
    }
    
    private func configureCardViews(setCardViews: [CardView]) {
        // デッキカードリセット (Viewのインスタンスを破棄: メモリが増長しないための処理)
        removeAllSubviews(parentView: GlobalVar.shared.tutorialDeckView)
        setCardViews.forEach { cardView in
            GlobalVar.shared.tutorialDeckView.addSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            cardView.topAnchor.constraint(equalTo: GlobalVar.shared.tutorialDeckView.topAnchor).isActive = true
            cardView.leftAnchor.constraint(equalTo: GlobalVar.shared.tutorialDeckView.leftAnchor).isActive = true
            cardView.bottomAnchor.constraint(equalTo: GlobalVar.shared.tutorialDeckView.bottomAnchor).isActive = true
            cardView.rightAnchor.constraint(equalTo: GlobalVar.shared.tutorialDeckView.rightAnchor).isActive = true
            cardView.layer.cornerRadius = 20
            cardView.clipsToBounds = true
        }
    }
}

/** チュートリアルカード操作関連の処理 **/
extension ApproachTutorialViewController: CardViewDelegate {
    
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
        if approach.contains("Good") { cardRightSideView.rightSideLabel.text = "Good" }
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
        if approachSorry.contains("Skip") { cardLeftSideView.leftSideLabel.text = "Skip" }
        cardOverSideView.backgroundColor = UIColor().setColor(colorType: "fontColor", alpha: 0.5)
        cardOverSideViewConstraint(view: view)
    }
    
    // 違反報告
    func didTapViolationBtn(view: CardView) {
        let storyBoard = UIStoryboard.init(name: "ViolationView", bundle: nil)
        let violationVC = storyBoard.instantiateViewController(withIdentifier: "ViolationView") as! ViolationViewController
        violationVC.targetUser = view.cardUser
        violationVC.transitioningDelegate = self
        violationVC.presentationController?.delegate = self
        present(violationVC, animated: true, completion: nil)
    }
    
    // アプローチ
    func didRightSwipeCardView(view: CardView) {
        let uid = view.cardUID
        let nickName = view.cardNickName
        let approach = view.approachLabel.text ?? ""
        if approach.contains("Good") {
            let approachType = "approach"
            let approachStatus = 0
            let actionType = "swipe"
            approachCheck(
                approachType: approachType,
                approachStatus: approachStatus,
                targetUID: uid,
                targetNickName: nickName,
                actionType: actionType
            )
        }
    }
    
    // アプローチ見送り
    func didLeftSwipeCardView(view: CardView) {
        let uid = view.cardUID
        let nickName = view.cardNickName
        let approachSorry = view.approachSorryLabel.text ?? ""
        if approachSorry.contains("Skip") {
            let approachType = "approachSorry"
            let approachStatus = 3
            let actionType = "swipe"
            approachCheck(
                approachType: approachType,
                approachStatus: approachStatus,
                targetUID: uid,
                targetNickName: nickName,
                actionType: actionType
            )
        }
    }

    func tryResetCardView(status: Int, actionType: String) {
        
        if GlobalVar.shared.tutorialCardUsers.count != 0 {
            if let tutorialCardUser = GlobalVar.shared.tutorialCardUsers.first {
                GlobalVar.shared.tutorialCardUsers.removeFirst()
                approachLogEvent(cardUser: tutorialCardUser, status: status, actionType: actionType)
            }
        }
        
        if let _ = GlobalVar.shared.tutorialCardViews.last { GlobalVar.shared.tutorialCardViews.removeLast() }
        
        timerStop()
        
        GlobalVar.shared.loginUser?.tutorial_num = tutorialNum
        
        // tutorialNum > 1で設定した時の文言
        // processLabel.text = (tutorialNum > 0 ? "あと\(tutorialNum)人アプローチしてください！" : "チュートリアルが完了しました！\nホーム画面に遷移します。")
        // tutorialNum = 1で設定した時の文言
        processLabel.text = (tutorialNum > 0 ? "まず1人アプローチしてみましょう" : "チュートリアルが完了しました！\nホーム画面に遷移します。")
        
        if tutorialNum <= 0 { endTutorial(); return }
        
        if GlobalVar.shared.tutorialCardViews.count < 1 {
            if GlobalVar.shared.tutorialCardUsers.count == 0 {
                if backgroundLoadingView != nil { backgroundLoadingView.isHidden = true }
            } else {
                setCard(users: GlobalVar.shared.tutorialCardUsers)
            }
        }
    }
    
    private func endTutorial() {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        GlobalVar.shared.loginUser?.is_tutorial = false
        
        let loginTutorialNum = loginUser.tutorial_num
        let updateData = [
            "is_tutorial": false,
            "tutorial_num": loginTutorialNum
        ] as [String : Any]
        
        let loginUID = loginUser.uid
        db.collection("users").document(loginUID).updateData(updateData)
        
        tabBarTransition()
    }
    
    // 相手にアプローチを送る前のチェック
    private func approachCheck(approachType: String, approachStatus: Int, targetUID: String, targetNickName: String, actionType: String) {
        
        guard let loginUID = GlobalVar.shared.currentUID else { return }
        // ロード画面の表示
        if approachStatus == 0 { showLoadingView(loadingView) }
        // アプローチデータを追加
        firebaseController.approach(loginUID: loginUID, targetUID: targetUID, approachType: approachType, approachStatus: approachStatus, actionType: actionType, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            
            if approachStatus == 0 { weakSelf.loadingView.removeFromSuperview() }
            
            if let res = result {
                
                if res {
                    
                    if approachType == "approach" {
                        print("\(targetNickName)さんへのアプローチが完了しました！😆👍")
                        weakSelf.tutorialNum = weakSelf.tutorialNum - 1
                    }
                    
                    GlobalVar.shared.loginUser?.approaches.append(targetUID)
                    
                    weakSelf.tryResetCardView(status: approachStatus, actionType: actionType)
                    
                } else {
                    let title = "アプローチ処理エラー"
                    let message = "正常にアプローチ処理がされませんでした。\n不具合の報告からシステムエラーを報告してください"
                    weakSelf.alert(title: title, message: message, actiontitle: "OK")
                }
                
            } else {
                // print("アプローチが重複していたため、処理を行わずスキップしました。")
            }
        })
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
}
