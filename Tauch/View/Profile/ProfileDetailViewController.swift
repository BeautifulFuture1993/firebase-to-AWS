//
//  ProfileDetailViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/05/24.
//

import UIKit
import TagListView

class ProfileDetailViewController: UIBaseViewController {
    
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var specialStatus: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var onlineTime: UILabel!
    @IBOutlet weak var onlineCircle: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var hobbyListView: TagListView!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var violationLabel: UILabel!
    @IBOutlet weak var typeStackView: UIStackView!
    @IBOutlet weak var holidayStackView: UIStackView!
    @IBOutlet weak var incomeStackView: UIStackView!
    @IBOutlet weak var businessStackView: UIStackView!
    @IBOutlet weak var violationShadowView: UIView!
    @IBOutlet weak var violationView: UIView!
    @IBOutlet var imageIndicators: [UIView]!
    @IBOutlet weak var iconIndicatorHeight: NSLayoutConstraint!
    @IBOutlet weak var goodBtnView: UIView!
    @IBOutlet weak var goodBtn: UIButton!
    
    var isViolation: Bool = true
    var user: User?
    var profileVC: ProfileViewController?
    var iconURLs = [String]()
    var previewIcons = [UIImage]()
    var showingImageIndex = 0 {
        didSet {
            if let indicator = imageIndicators[safe: showingImageIndex] {
                imageIndicators.forEach { $0.alpha = 0.5 }
                indicator.alpha = 1
            }
        }
    }
    
    var comment: String = ""
    var commentImg: String = ""

    private var loadedImages: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goodBtn.layer.cornerRadius = 25
        
        guard user != nil || profileVC != nil else { return }
        var hobbyListTotalString = 0
        var hobbyListCount = 0
        previewIcons = []
        loadedImages = [:]
        
        // プレビュー情報反映
        if let p = profileVC, let u = GlobalVar.shared.loginUser {
            
            violationView.isUserInteractionEnabled = false
            
            iconImg.image = p.profileIcon[0].image
            p.profileIcon.forEach { icon in
                if let image = icon.image {
                    previewIcons.append(image)
                }
            }
            if previewIcons.count == 1 {
                iconIndicatorHeight.constant = 0
            } else {
                u.profile_icon_sub_imgs.forEach{ iconURLs.append($0) }
                imageIndicators.forEach {
                    if $0.tag >= previewIcons.count {
                        $0.isHidden = true
                    }
                }
            }
            onlineCustom(user: u)
            hobbyListView.addTags(u.hobbies)
            hobbyListCount = u.hobbies.count
            u.hobbies.forEach { hobby in
                hobbyListTotalString += hobby.count
            }
            
            nickName.text = p.nameField.text
            specialStatus.text = customSpecialStatus(user: u)
            age.text = u.birth_date.calcAge()
            typeLabel.text = p.typeField.text
            holidayLabel.text = p.holidayField.text
            address.text = "\(p.addressField.text ?? "")\(p.address2Field.text ?? "")"
            status.text = p.statusTextView.text
            violationLabel.text = "\(u.violation_count)"
            typeLabel.text = "タイプ：\(p.typeField.text ?? "")"
            holidayLabel.text = "休日：\(p.holidayField.text ?? "")"
            setInfo(item: "職業", stack: businessStackView, label: businessLabel, text: p.businessField.text ?? "")
            setInfo(item: "収入", stack: incomeStackView, label: incomeLabel, text: p.selectedIncome.getIncomeDifference())
            
            goodBtnCustom(user: u, ownFlg: true)
            
            Log.event(name: "profilePreview")
            
        // ユーザー情報反映
        } else if let u = user, let l = GlobalVar.shared.loginUser {
            
            iconImg.setImage(withURLString: u.profile_icon_img)
            iconURLs.append(u.profile_icon_img)
            
            if u.profile_icon_sub_imgs.count == 0 {
                iconIndicatorHeight.constant = 0
            } else {
                u.profile_icon_sub_imgs.forEach{ iconURLs.append($0) }
                imageIndicators.forEach {
                    if $0.tag >= iconURLs.count {
                        $0.isHidden = true
                    }
                }
                iconURLs.forEach {
                    self.loadImageFromURL(from: $0)
                }
            }
            
            nickName.text = u.nick_name
            specialStatus.text = customSpecialStatus(user: u)
            age.text = u.birth_date.calcAge()
            typeLabel.text = u.type
            holidayLabel.text = u.holiday
            address.text = "\(u.address.removePrefectureCharacters()) \(u.address2)"
            status.text = u.profile_status
            violationLabel.text = "\(u.violation_count)"
            typeLabel.text = "タイプ：\(u.type)"
            holidayLabel.text = "休日：\(u.holiday)"
            setInfo(item: "職業", stack: businessStackView, label: businessLabel, text: u.business)
            setInfo(item: "収入", stack: incomeStackView, label: incomeLabel, text: u.income.getIncomeDifference())
            onlineCustom(user: u)
            hobbyListView.addTags(u.hobbies)
            hobbyListCount = u.hobbies.count
            u.hobbies.forEach { hobby in
                hobbyListTotalString += hobby.count
            }
            
            if u.uid == l.uid {
                print("自分のプロフィールを閲覧")
                isViolation = false
                
                goodBtnCustom(user: u, ownFlg: true)
                
                Log.event(name: "profilePreview")
                
            } else {
                print("相手のプロフィールを閲覧")
                isViolation = true
                
                goodBtnCustom(user: u, ownFlg: false)
                
                Log.event(name: "profileDetail")
                // 足あとをつける
                checkVisitor(ownUser: l, targetUser: u, comment: self.comment, commentImg: self.commentImg)
            }
        }
        hobbyListView.textFont = UIFont.boldSystemFont(ofSize: 14)
        var hobbyListViewWidth: CGFloat = 0
        if hobbyListCount*40 + hobbyListTotalString*14 < Int(UIScreen.main.bounds.width - 40) {
            hobbyListViewWidth = UIScreen.main.bounds.width - 40
            hobbyListView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            hobbyListViewWidth = CGFloat(hobbyListCount*20 + hobbyListTotalString*7)
        }
        hobbyListView.widthAnchor.constraint(equalToConstant: hobbyListViewWidth).isActive = true
        violationView.layer.cornerRadius = 15
        violationShadowView.layer.cornerRadius = 15
        violationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(violation)))
        
        GlobalVar.shared.specificUser = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
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
        if int == 0 {
            stack.isHidden = true
        } else {
            stack.isHidden = false
            label.text = "\(item)：\(int)"
        }
    }
    
    @IBAction func nextImageAction(_ sender: UIButton) {
        // User情報
        if previewIcons == [] {
            if showingImageIndex < iconURLs.count - 1 {
                showingImageIndex += 1
                
                if let iconURL = iconURLs[safe: showingImageIndex] {
                    if let image = loadedImages[iconURL] {
                        // 先にダウンロードした画像があればそれを入れる
                        iconImg.image = image
                    } else {
                        // Nukeでその場で読み込む
                        iconImg.setImage(withURLString: iconURL)
                    }
                }
                
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                
                let logEventData = [
                    "nextImageIndex": showingImageIndex
                ] as [String : Any]
                Log.event(name: "nextProfileDetailSubImg", logEventData: logEventData)
            }
            // プレビュー情報
        } else {
            if showingImageIndex < previewIcons.count - 1 {
                showingImageIndex += 1
                iconImg.image = previewIcons[showingImageIndex]
                
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                
                let logEventData = [
                    "nextImageIndex": showingImageIndex
                ] as [String : Any]
                Log.event(name: "nextProfilePreviewSubImg", logEventData: logEventData)
            }
        }
    }
    
    @IBAction func prevImageAction(_ sender: UIButton) {
        // User情報
        if previewIcons == [] {
            if showingImageIndex > 0 {
                showingImageIndex -= 1
                
                if let iconURL = iconURLs[safe: showingImageIndex] {
                    if let image = loadedImages[iconURL] {
                        // 先にダウンロードした画像があればそれを入れる
                        iconImg.image = image
                    } else {
                        // Nukeでその場で読み込む
                        iconImg.setImage(withURLString: iconURL)
                    }
                }
                
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                
                let logEventData = [
                    "prevImageIndex": showingImageIndex
                ] as [String : Any]
                Log.event(name: "prevProfileDetailSubImg", logEventData: logEventData)
            }
            // プレビュー情報
        } else {
            if showingImageIndex > 0 {
                showingImageIndex -= 1
                iconImg.image = previewIcons[showingImageIndex]
                
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                
                let logEventData = [
                    "prevImageIndex": showingImageIndex
                ] as [String : Any]
                Log.event(name: "prevProfilePreviewSubImg", logEventData: logEventData)
            }
        }
    }
    
    @objc func violation() {
        if isViolation == false { return }
        let storyBoard = UIStoryboard.init(name: "ViolationView", bundle: nil)
        let violationVC = storyBoard.instantiateViewController(withIdentifier: "ViolationView") as! ViolationViewController
        violationVC.targetUser = user
        violationVC.transitioningDelegate = self
        violationVC.presentationController?.delegate = self
        present(violationVC, animated: true, completion: nil)
    }
    
    @IBAction func goodBtnAction(_ sender: Any) {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        guard let user = user else { return }
        
        let isNotApproachRelatedContains = (checkApproachRelated(user: user) == false)
        let isApproachedsRelated = (checkApproacheds(user: user) == true)
        
        if isNotApproachRelatedContains {
            approach(loginUser: loginUser, user: user)
        } else if isApproachedsRelated {
            approachMatch(loginUser: loginUser, user: user)
        }
    }
    
    private func approach(loginUser: User, user: User) {
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        // アプローチデータを追加
        let loginUID = loginUser.uid
        let targetUID = user.uid
        let targetNickName = user.nick_name
        let approachType = "approach"
        let approachStatus = 0
        let actionType = "click"
        firebaseController.approach(loginUID: loginUID, targetUID: targetUID, approachType: approachType, approachStatus: approachStatus, actionType: actionType, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            
            if let res = result {
                
                if res {
                    if approachType == "approach" { print("\(targetNickName)さんへのアプローチが完了しました！😆👍") }
                    GlobalVar.shared.loginUser?.approaches.append(targetUID)
                    
                } else {
                    weakSelf.alert(title: "アプローチ処理エラー", message: "正常にアプローチ処理がされませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
                }
                
            } else {
                // print("アプローチが重複していたため、処理を行わずスキップしました。")
            }
            
            weakSelf.goodBtnCustom(user: user, ownFlg: false)
        })
    }
    
    private func approachMatch(loginUser: User, user: User) {
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        let targetUID = user.uid
        let targetNickName = user.nick_name
        let actionType = "click"
        
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
                    
                    print("\(targetNickName)さんとのマッチングが完了しルームを生成しました！😆👍")
                    weakSubSelf.goodBtnCustom(user: user, ownFlg: false)
                    
                    if let _ = subResult {
                        
                        let autoMessage = GlobalVar.shared.loginUser?.is_auto_message ?? true
                        if autoMessage {
                            
                            weakSubSelf.loadingView.removeFromSuperview()
                            
                            GlobalVar.shared.displayAutoMessage = true
                            GlobalVar.shared.specificUser = user
                            
                            weakSubSelf.dismiss(animated: true)
                            
                        } else {
                            weakSubSelf.loadingView.removeFromSuperview()
                            weakSubSelf.alert(title: "マッチングに成功しました!", message: "メッセージルームにてやりとりを開始してください!", actiontitle: "OK")
                        }
                        
                    } else {
                        weakSubSelf.loadingView.removeFromSuperview()
                        weakSubSelf.alert(title: "マッチングに失敗しました。。", message: "このユーザに何か問題がある可能性があります。気になる場合は運営に報告してください。", actiontitle: "OK")
                    }
                })
                print("\(targetNickName)さんとのマッチングが完了しました！😆👍")
                
            } else {
                weakSelf.loadingView.removeFromSuperview()
                weakSelf.alert(title: "マッチングに失敗しました。。", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
            }
        })
    }
    
    private func onlineCustom(user: User) {
        
        let isPartnerUser = determineUserIsPartner(user: user)
        onlineTime.isHidden = (isPartnerUser ? true : false)
        onlineCircle.isHidden = (isPartnerUser ? true : false)
        
        let isLogin = user.is_logined
        let logoutTime = user.logouted_at.dateValue()
        let elaspedTime = elapsedTime(isLogin: isLogin, logoutTime: logoutTime)
        if elaspedTime[0] != nil {
            onlineTime.text = "オンライン"
            onlineCircle.textColor = .green
        } else if let elaspedTimeSecond = elaspedTime[1] {
            onlineTime.text = "\(elaspedTimeSecond)秒前"
            onlineCircle.textColor = .green
        } else if let elaspedTimeMinute = elaspedTime[2] {
            onlineTime.text = "\(elaspedTimeMinute)分前"
            onlineCircle.textColor = .green
        } else if let elaspedTimeHour = elaspedTime[3] {
            onlineTime.text = "\(elaspedTimeHour)時間前"
            onlineCircle.textColor = .green
        } else if let elaspedTimeDay = elaspedTime[4] {
            if elaspedTimeDay > 5 {
                onlineTime.isHidden = true
            } else {
                onlineTime.text = "\(elaspedTimeDay)日前"
                onlineCircle.textColor = .green
            }
        }
    }
    // いいねボタンをカスタム
    private func goodBtnCustom(user: User, ownFlg: Bool) {
        
        if ownFlg {
            /* ログイン中のユーザーのプロフィール詳細 */
            goodBtnView.isHidden = true
            
        } else {
            /* ログイン中のユーザー以外のプロフィール詳細 */
            goodBtn.tintColor = .white
            goodBtn.layer.shadowOpacity = 0
            
            let approachesRelated = checkApproaches(user: user)
            let approachedsRelated = checkApproacheds(user: user)
            let isPartnerUser = determineUserIsPartner(user: user)
            
            // 1. マッチング済みか判定 → 2. アプローチ済みか判定
            if isPartnerUser {
                // マッチング済みの場合は、いいねボタンを非表示
                goodBtnView.isHidden = true
                
            } else if approachesRelated {
                // マッチング済みでない && いいね済み
                goodBtnView.isHidden = false
                goodBtn.setTitle("いいね!送信済み", for: .normal)
                goodBtn.backgroundColor = .lightGray
                goodBtn.configuration = nil
                goodBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                goodBtn.setCustomShadow()
                goodBtn.disable()
                
            } else if approachedsRelated {
                // マッチング済みでない && いいねされている
                goodBtnView.isHidden = false
                goodBtn.setTitle("いいね！ありがとう", for: .normal)
                goodBtn.backgroundColor = .accentColor
                goodBtn.configuration = nil
                goodBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                goodBtn.setCustomShadow()
                goodBtn.enable()
                
            } else {
                // マッチング済みでない && いいね済みでない
                goodBtnView.isHidden = false
                goodBtn.setTitle("いいね!", for: .normal)
                goodBtn.backgroundColor = .accentColor
                goodBtn.configuration = nil
                goodBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                goodBtn.setCustomShadow()
                goodBtn.enable()
            }
        }
    }
    // 足あとをつける
    private func checkVisitor(ownUser: User, targetUser: User, comment: String, commentImg: String) {
        let loginUID = ownUser.uid
        let targetUID = targetUser.uid
        // 1. マッチング済みか判定 → 2. アプローチ済みか判定
        let isPartnerUser = determineUserIsPartner(user: targetUser)
        let isNotMatch = (isPartnerUser == false)
        if isNotMatch {
            DispatchQueue.main.async { self.firebaseController.visitor(loginUID: loginUID, targetUID: targetUID, comment: comment, commentImg: commentImg) }
        }
    }
    
    func checkApproaches(user: User) -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        let uid = user.uid
        
        let approachs = loginUser.approaches
        
        let approachContains = (approachs.contains(uid) == true)
        if approachContains { return true }
        
        return false
    }
    
    func checkApproacheds(user: User) -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        let uid = user.uid
        
        let approaches = loginUser.approaches
        let approacheds = loginUser.approacheds
        let replyApproacheds = loginUser.reply_approacheds
        
        let approachOrMatch = approaches + replyApproacheds
        let filterApproacheds = approacheds.filter({ approachOrMatch.contains($0) == false })
        
        let approachedContains = (filterApproacheds.contains(uid) == true)
        if approachedContains { return true }
        
        return false
    }
    
    /// Determine if specific user is a partner user
    /// - Parameter user :A specific user, not a loging in user.
    /// - Returns: Determine if the user is a partner user and return it with Bool type.
    private func determineUserIsPartner(user: User) -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        let uid = user.uid
        var specificMembers: Set<String> = []
        let rooms = loginUser.rooms
        
        rooms.forEach { room in
            let members = Set(room.members)
            specificMembers = specificMembers.union(members)
        }
        
        return specificMembers.contains(uid)
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
    
    private func customSpecialStatus(user: User) -> String {
        
        var specialStatusText = ""
        
        let birthDateComponents = user.birth_date.getDiffDateComponents()
        
        let birthDateElaspedMonths = birthDateComponents.month ?? 0
        let birthDateElaspedDays = birthDateComponents.day ?? 0

        let noticeBeforeBirthDay = (birthDateElaspedMonths == 0 && -14 <= birthDateElaspedDays && birthDateElaspedDays < 0)
        let noticeBirthDay = (birthDateElaspedMonths == 0 && birthDateElaspedDays == 0)

        specialStatusText = (noticeBeforeBirthDay ? "🎂" : specialStatusText)
        specialStatusText = (noticeBirthDay ? "👑" : specialStatusText)

//        print(
//            "birthDateElaspedMonths : \(birthDateElaspedMonths)",
//            "birthDateElaspedDays : \(birthDateElaspedDays)",
//            "specialStatusText : \(specialStatusText)"
//        )
        return specialStatusText
    }
}
