//
//  UIViewControllerExtension.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/12.
//

import UIKit
import Nuke
import SDWebImage
import CallKit
import AVFoundation
import FBSDKLoginKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseAnalytics
import SafariServices
import StoreKit
import Typesense
<<<<<<< HEAD
=======
import SideMenu
import ESTabBarController
import AdSupport
import AppTrackingTransparency
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8

extension UIViewController: UIViewControllerTransitioningDelegate {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    // 現在表示されているViewを取得する
    func currentViewController(controller: UIViewController?) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return currentViewController(controller: selected)
            }
        }

        if let navigationController = controller as? UINavigationController {
            return currentViewController(controller: navigationController.visibleViewController)
        }

        if let presented = controller?.presentedViewController {
            return currentViewController(controller: presented)
        }

        return controller
    }
    
    func getStoryboardInfo(name: String) -> [String:String] {
        
        var storyboardInfo = [String:String]()
        
        switch name {
        case "LikeCardTop":
            storyboardInfo = [
                "storyboardName": "LikeCardTopView",
                "storyboardID": "LikeCardTopView"
            ]
            break
        default:
            break
        }
        
        return storyboardInfo
    }
    
    // 画面遷移
    func screenTransition(storyboardName: String, storyboardID: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: storyboardID)
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    // ナビゲーションモーダル遷移
    func navigationModalTransition(storyboardName: String, storyboardID: String, presentationStyle: UIModalPresentationStyle) {
        let storyBoard = UIStoryboard.init(name: storyboardName, bundle: nil)
        let modalVC = storyBoard.instantiateViewController(withIdentifier: storyboardID)
        let navVC = UINavigationController(rootViewController: modalVC)
        navVC.transitioningDelegate = self
        navVC.presentationController?.delegate = self
        navVC.modalPresentationStyle = presentationStyle
        present(navVC, animated: true)
    }
    
    // tabBar遷移
    func tabBarTransition() {
        let tabBarController = CustomTabBarController()
        tabBarController.modalPresentationStyle = .overFullScreen
        tabBarController.modalTransitionStyle = .crossDissolve
        present(tabBarController, animated: true, completion: nil)
        
        GlobalVar.shared.tabBarVC = tabBarController
    }
    
    func tabBarVCMove(selectedIndex: Int, setKey: String, setValue: String) {
        
        switch selectedIndex {
        case 1, 2, 3: // アプローチされた、メッセージ、お誘いタブ
            UserDefaults.standard.set(setValue, forKey: setKey)
            UserDefaults.standard.synchronize()
            break
        default:
            break
        }

        GlobalVar.shared.tabBarVC?.selectedIndex = selectedIndex
    }
    
    //NavigationBarの境目を消す
    func hideNavigationBarBorderAndShowTabBarBorder(color: UIColor? = nil) {
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        
        navigationBarAppearance.backgroundColor = .white
        if let color = color { navigationBarAppearance.backgroundColor = color }
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .systemBackground
        if let color = color { tabBarAppearance.backgroundColor = color }
        
        GlobalVar.shared.tabBarVC?.tabBar.standardAppearance = tabBarAppearance
        GlobalVar.shared.tabBarVC?.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    func showNavigationBarBorder() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    func customNavigationBarBorder() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.shadowColor = .systemGray4
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        tabBarController?.tabBar.backgroundColor = .white
    }
    
    // タイトル付きのナビゲーション
    func navigationWithSetUp(navigationTitle: String, color: UIColor = .white) {
        // ナビゲーションバーを表示する
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // ナビゲーションの戻るボタンを消す
        self.navigationItem.setHidesBackButton(true, animated: true)
        // ナビゲーションバーの透過させない
        self.navigationController?.navigationBar.isTranslucent = false
        // ナビゲーションアイテムのタイトルを設定
        self.navigationItem.title = navigationTitle
        // ナビゲーションバー設定
        hideNavigationBarBorderAndShowTabBarBorder(color: color)
    }
    
    // Backボタン付きのナビゲーション
    func navigationWithBackBtnSetUp(navigationTitle: String, color: UIColor? = nil) {
        // ナビゲーションバーを表示する
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // ナビゲーションの戻るボタンを消す
        self.navigationItem.setHidesBackButton(true, animated: true)
        // ナビゲーションバーの透過させない
        self.navigationController?.navigationBar.isTranslucent = false
        //ナビゲーションアイテムのタイトルを設定
        self.navigationItem.title = navigationTitle
        // ナビゲーションバー設定
        hideNavigationBarBorderAndShowTabBarBorder(color: color)
        //ナビゲーションバー左ボタンを設定
        let backImage = UIImage(systemName: "chevron.backward")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action:#selector(self.pageBack))
        self.navigationItem.leftBarButtonItem?.tintColor = .fontColor
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 一つ前の画面に戻る
    @objc private func pageBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Backボタン付きのナビゲーション
    func navigationWithModalBackBtnSetUp(navigationTitle: String) {
        // ナビゲーションバーを表示する
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // ナビゲーションの戻るボタンを消す
        self.navigationItem.setHidesBackButton(true, animated: true)
        // ナビゲーションバーの透過させる
        self.navigationController?.navigationBar.isTranslucent = true
        //ナビゲーションアイテムのタイトルを設定
        self.navigationItem.title = navigationTitle
        // ナビゲーションバー設定
        hideNavigationBarBorderAndShowTabBarBorder()
        //ナビゲーションバー左ボタンを設定
        let backImage = UIImage(systemName: "xmark")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action:#selector(self.modalPageBack))
        self.navigationItem.rightBarButtonItem?.tintColor = .fontColor
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    // 一つ前の画面に戻る
    @objc private func modalPageBack() {
        self.dismiss(animated: true)
    }
    
    // プロフィール詳細ボタン付きのナビゲーション
    func navigationWithProfileBtnSetUp(title: String, profileImage: UIImage) {
        // ナビゲーションバーを表示する
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // ナビゲーションの戻るボタンを消す
        self.navigationItem.setHidesBackButton(true, animated: true)
        // ナビゲーションバーの透過させる
        self.navigationController?.navigationBar.isTranslucent = true
        //ナビゲーションアイテムのタイトルを設定
        self.navigationItem.title = title
        //ナビゲーションバー左ボタンを設定
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(showSetting))
        self.navigationItem.leftBarButtonItem?.tintColor = .fontColor
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc func showSetting() {
        
        let settingViewStoryboard = UIStoryboard(name: "SettingView", bundle: nil)
        let settingVC = settingViewStoryboard.instantiateViewController(withIdentifier: "SettingView") as! SettingViewController
        
        let leftMenuNavigationController = SideMenuNavigationController(rootViewController: settingVC)
        leftMenuNavigationController.settings = makeSettings()
        leftMenuNavigationController.leftSide = true

        present(leftMenuNavigationController, animated: true, completion: nil)
    }
    
    @objc func didTapFilterButton() {
        DispatchQueue.main.async { [weak self] in
            let storyBoard = UIStoryboard.init(name: "FilterView", bundle: nil)
            let modalVC = storyBoard.instantiateViewController(withIdentifier: "FilterView") as! FilterViewController
            modalVC.transitioningDelegate = self
            modalVC.presentationController?.delegate = self
            self?.present(modalVC, animated: true)
        }
    }
    
    func configSideMenu(currentView: UIView) {
        
        let settingViewStoryboard = UIStoryboard(name: "SettingView", bundle: nil)
        let settingVC = settingViewStoryboard.instantiateViewController(withIdentifier: "SettingView") as! SettingViewController
        
        let leftMenuNavigationController = SideMenuNavigationController(rootViewController: settingVC)
        leftMenuNavigationController.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = leftMenuNavigationController
        
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: currentView, forMenu: .left)
    }
    
    func makeSettings() -> SideMenuSettings {
        
        let presentationStyle: SideMenuPresentationStyle = .menuSlideIn
        presentationStyle.onTopShadowOpacity = 1.0
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.statusBarEndAlpha = 0
        settings.menuWidth = min(view.frame.width, view.frame.height) * CGFloat(0.8)
        
        return settings
    }
    
    // ログイン画面に戻る
    func loginScreenTransition() {
        // ログイン画面に戻る
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainView")
        mainVC.hidesBottomBarWhenPushed = true // タブバーを消す
        self.navigationController?.pushViewController(mainVC, animated: true)
        // 全てを初期化
        removeListener(initFlg: true)
    }
    
    // サブビューを全て削除
    func removeAllSubviews(parentView: UIView){
        let subviews = parentView.subviews
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    // アラート表示
    func alert(title: String, message: String, actiontitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // OKボタン後の処理付き、アラート表示
    func alertWithAction(title: String, message: String, actiontitle: String, type: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: {
            [weak self] (action: UIAlertAction!) -> Void in
            guard let weakSelf = self else { return }
            if type == "settings" {
                weakSelf.openSettingURL()
            }
            if type == "back" {
                weakSelf.navigationController?.popViewController(animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openSettingURL() {
        let openSettingURL = UIApplication.openSettingsURLString
        if let url = URL(string: openSettingURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            // イベント登録
            let logEventData = [
                "url": openSettingURL
            ] as [String : Any]
            Log.event(name: "openNotificationSetting", logEventData: logEventData)
        }
    }
    
    // OKボタン後の画面遷移付き、アラート表示
    func alertWithPageMove(title: String, message: String, actiontitle: String, storyboardID: String, storyboardName: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: {
            [weak self] (action: UIAlertAction!) -> Void in
            guard let weakSelf = self else { return }
            weakSelf.screenTransition(storyboardName: storyboardName, storyboardID: storyboardID)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // OKボタン後のモーダルを閉じるアラート表示
    func alertWithDismiss(title: String, message: String, actiontitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actiontitle, style: .default, handler: {
            [weak self] (action: UIAlertAction!) -> Void in
            guard let weakSelf = self else { return }
            weakSelf.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 確認ダイアログ
    func dialog(title: String, subTitle: String, confirmTitle: String, completion: @escaping (Bool) -> Void) {
        //UIAlertControllerのスタイルがalert
        let alert: UIAlertController = UIAlertController(title: title, message:  subTitle, preferredStyle:  UIAlertController.Style.alert)
        // 継続処理
        let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: UIAlertAction.Style.default, handler:{
            [weak self] (action: UIAlertAction!) -> Void in
            guard let _ = self else { return }
            completion(true)
        })
        // キャンセル処理
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            [weak self] (action: UIAlertAction!) -> Void in
            guard let _ = self else { return }
            completion(false)
        })
        // UIAlertControllerに継続とキャンセル時のActionを追加
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .cancel, handler: nil)], completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions { alert.addAction(action) }
        present(alert, animated: true, completion: nil)
    }
    
    func moveBackground() {
        
        let backgroundClassName = GlobalVar.shared.backgroundClassName
        if backgroundClassName.count < 2 { return }
        
        let backgroundClassCount = backgroundClassName.count - 1
        let lastClassName = backgroundClassName[backgroundClassCount]
        let lastPrevClassName = backgroundClassName[backgroundClassCount - 1]

        GlobalVar.shared.backgroundClassName = []
        filterMoveBackground(backgroundClassName: backgroundClassName, lastPrevClassName: lastPrevClassName, lastClassName: lastClassName)
    }
    
    private func filterMoveBackground(backgroundClassName: [String], lastPrevClassName: String, lastClassName: String) {
        
        let isLastPrevClassMessageListVC = (lastPrevClassName == "MessageListViewController")
        let isLastClassMessageRoomVC = (lastClassName == "MessageRoomView")
        let isLastClassTalkGuideVC = (lastClassName == "TalkGuideViewController")
        
        let isLastPrevClassInvitaionVC = (lastPrevClassName == "InvitationViewController")
        let isLastClassInvitationDetailVC = (lastClassName == "InvitationDetailViewController")
        
        let isMessageRoom = (isLastPrevClassMessageListVC && isLastClassMessageRoomVC)
        let isTalkGuide = (isLastPrevClassMessageListVC && isLastClassTalkGuideVC)
        let isInvitationDetail = (isLastPrevClassInvitaionVC && isLastClassInvitationDetailVC)
        
        let isMoveCondition = (isMessageRoom || isTalkGuide || isInvitationDetail)
        if isMoveCondition { specificPageTransition(lastClassName: lastClassName) }
    }
    
    // 特定の画面遷移
    private func specificPageTransition(lastClassName: String) {
        switch lastClassName {
        case "MessageRoomView":
            messageRoomMove()
            break
        case "TalkGuideViewController":
            talkGuideMove()
            break
        case "InvitationDetailViewController":
            invitationDetailMove()
            break
        default:
            break
        }
    }
    
    func adminCheckStatus() -> Bool {
        
        var adminCheckStatus = false
        //本人確認していない場合は確認ページを表示
        if let adminIDCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status {
            switch adminIDCheckStatus {
            case 1:
                adminCheckStatus = true
                break
            case 2:
                dialog(title: "本人確認失敗しました", subTitle: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", confirmTitle: "OK", completion: { [weak self] confirm in
                    guard let weakSelf = self else { return }
                    if confirm { weakSelf.popUpIdentificationView() }
                })
                break
            default:
                alert(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", actiontitle: "OK")
                break
            }
            
        } else {
            popUpIdentificationView()
        }
        
        return adminCheckStatus
    }
    
    private func tagEditScreenTransition() {
        let storyboard = UIStoryboard(name: "ProfileView", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileView") as! ProfileViewController
        profileVC.tagEditFlg = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func pushNotificationScreenTransition(pushNotificationHidden: Bool = false) {
        let storyboard = UIStoryboard(name: "PushNotificationSettingView", bundle: nil)
        let pushNotificationSettingVC = storyboard.instantiateViewController(withIdentifier: "PushNotificationSettingView") as! PushNotificationSettingViewController
        pushNotificationSettingVC.pushNotificationHidden = pushNotificationHidden
        self.navigationController?.pushViewController(pushNotificationSettingVC, animated: true)
    }
    
    func profileDetailMove(user: User, comment: String = "", commentImg: String = "") {
        if user.is_deleted == true { return }
        let storyBoard = UIStoryboard.init(name: "ProfileDetailView", bundle: nil)
        let profileDetailVC = storyBoard.instantiateViewController(withIdentifier: "ProfileDetailView") as! ProfileDetailViewController
        profileDetailVC.user = user
        profileDetailVC.comment = comment
        profileDetailVC.commentImg = commentImg
        profileDetailVC.transitioningDelegate = self
        profileDetailVC.presentationController?.delegate = self
        present(profileDetailVC, animated: true, completion: nil)
    }
    
    func talkGuideMove() {
        let storyboard = UIStoryboard.init(name: "TalkGuideView", bundle: nil)
        let guideVC = storyboard.instantiateViewController(withIdentifier: "TalkGuideView") as! TalkGuideViewController
        let guideNavVC = UINavigationController(rootViewController: guideVC)
        guideNavVC.transitioningDelegate = self
        guideNavVC.presentationController?.delegate = self
        present(guideNavVC, animated: true, completion: nil)
    }
    
    func autoMessageMove() {
        let storyboard = UIStoryboard.init(name: "AutoMessageView", bundle: nil)
        let guideVC = storyboard.instantiateViewController(withIdentifier: "AutoMessageView") as! AutoMessageViewController
        let guideNavVC = UINavigationController(rootViewController: guideVC)
        guideNavVC.transitioningDelegate = self
        guideNavVC.presentationController?.delegate = self
        present(guideNavVC, animated: true, completion: nil)
    }
    
    func moveMessageRoom(roomID: String, target: User) {
        let db = Firestore.firestore()
        db.collection("rooms").document(roomID).getDocument { [weak self] (document, error) in
            guard let weakSelf = self else { return }
            if let document = document, document.exists {
                let room = Room(document: document)
                room.partnerUser = target
                let messageRoomStoryBoard = UIStoryboard.init(name: "MessageRoomView", bundle: nil)
                let messageRoomVC = messageRoomStoryBoard.instantiateViewController(withIdentifier: "MessageRoomView") as! MessageRoomView
                messageRoomVC.room = room
                weakSelf.navigationController?.pushViewController(messageRoomVC, animated: true)
            } else {
                weakSelf.alert(title: "ルームの作成に失敗しました。。", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
            }
        }
    }
    
    private func messageRoomMove() {
        if let specificRoom = GlobalVar.shared.specificRoom {
            let specificRoomID = UserDefaults.standard.string(forKey: "specificRoomID")
            if specificRoom.document_id == specificRoomID {
                adminCheckStatusMessageRoom(specificRoom: specificRoom)
            }
            UserDefaults.standard.set("", forKey: "specificRoomID")
            UserDefaults.standard.synchronize()
        }
    }
    
    private func adminCheckStatusMessageRoom(specificRoom: Room) {
        //本人確認していない場合は確認ページを表示
        guard let adminIDCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status else {
            popUpIdentificationView()
            return
        }
        if adminIDCheckStatus == 1 {
            specificMessageRoomMove(specificRoom: specificRoom)
            
        } else if adminIDCheckStatus == 2 {
           dialog(title: "本人確認失敗しました", subTitle: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", confirmTitle: "OK", completion: { [weak self] confirm in
               guard let weakSelf = self else { return }
               if confirm { weakSelf.popUpIdentificationView() }
           })
            
        } else {
           alert(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", actiontitle: "OK")
        }
    }
    
    func specificMessageRoomMove(specificRoom: Room) {

        guard let _ = specificRoom.partnerUser else { return }
        
        Task {
            let storyBoard = UIStoryboard.init(name: "MessageRoomView", bundle: nil)
            let messageRoomVC = storyBoard.instantiateViewController(withIdentifier: "MessageRoomView") as! MessageRoomView
            messageRoomVC.room = specificRoom
            navigationController?.pushViewController(messageRoomVC, animated: true)
        }
    }
    
    private func invitationDetailMove() {
        if let specificInvitation = GlobalVar.shared.specificInvitation {
            let specificInvitationID = UserDefaults.standard.string(forKey: "specificInvitationID")
            if specificInvitation.document_id == specificInvitationID {
                GlobalVar.shared.specificInvitation = nil
                adminCheckStatusInvitationDetail(specificInvitation: specificInvitation)
            }
            UserDefaults.standard.set("", forKey: "specificInvitationID")
            UserDefaults.standard.synchronize()
        }
    }
    
    private func adminCheckStatusInvitationDetail(specificInvitation: Invitation) {
        //本人確認していない場合は確認ページを表示
        guard let adminIDCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status else {
            popUpIdentificationView()
            return
        }
        if adminIDCheckStatus == 1 {
            specificInvitationDetailMove(specificInvitation: specificInvitation)
            
        } else if adminIDCheckStatus == 2 {
           dialog(title: "本人確認失敗しました", subTitle: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", confirmTitle: "OK", completion: { [weak self] confirm in
               guard let weakSelf = self else { return }
               if confirm { weakSelf.popUpIdentificationView() }
           })
       } else {
           alert(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", actiontitle: "OK")
       }
    }
    
    private func specificInvitationDetailMove(specificInvitation: Invitation) {
        let storyBoard = UIStoryboard.init(name: "InvitationDetailView", bundle: nil)
        let invitationDetailVC = storyBoard.instantiateViewController(withIdentifier: "InvitationDetailView") as! InvitationDetailViewController
        invitationDetailVC.specificInvitation = specificInvitation
        navigationController?.pushViewController(invitationDetailVC, animated: true)
    }
    
    private func imageDetailMove() {
        let storyBoard = UIStoryboard.init(name: "ImageDetailView", bundle: nil)
        let modalVC = storyBoard.instantiateViewController(withIdentifier: "ImageDetailView") as! ImageDetailViewController
        modalVC.modalPresentationStyle = .fullScreen
        modalVC.transitioningDelegate = self
        modalVC.presentationController?.delegate = self
        present(modalVC, animated: true, completion: nil)
    }
    
    func playTutorial(key: String, type: String) {
        if UserDefaults.standard.bool(forKey: key) == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                 if let window = Window.first {
                     let tutorialView = TutorialView(frame: window.frame, type: type)
                     window.addSubview(tutorialView)
                     self?.tutorialLogEvent(type: type)
                 }
             }
             UserDefaults.standard.set(true, forKey: key)
             UserDefaults.standard.synchronize()
         }
    }
    func tutorialLogEvent(type: String) {
        switch type {
        case "approach":
            Log.event(name: "approachTutorial")
            break
        case "message":
            Log.event(name: "messageTutorial")
            break
        case "invitation":
            Log.event(name: "invitationTutorial")
            break
        case "phone":
            Log.event(name: "phoneTutorial")
            break
        default:
            break
        }
    }
    //URLでSafariを開く
    func openURLForSafari(url: String, category: String) {
        guard let openURL = URL(string: url) else { return }
        let safariController = SFSafariViewController(url: openURL)
        present(safariController, animated: true, completion: nil)
        
        switch category {
        case "help":
            Log.event(name: "openHelpURL")
            break
        case "bugReport":
            Log.event(name: "openBugReportURL")
            break
        case "opinionsAndRequests":
            Log.event(name: "openOpinionsAndRequestsURL")
            break
        case "termsOfService":
            Log.event(name: "openTermsOfServiceURL")
            break
        case "privacyPolicy":
            Log.event(name: "openPrivacyPolicyURL")
            break
        case "safetyAndSecurityGuidelines":
            Log.event(name: "openSafetyAndSecurityGuidelinesURL")
            break
        case "specialCommercialLaw":
            Log.event(name: "openSpecialCommercialLawURL")
            break
        default:
            break
        }
    }
    
    func setClass(className: String) {
        GlobalVar.shared.thisClassName = className
    }
    // ナビゲーションバーのタイトルをカスタマイズ
    func navitationSetTitleCustomWithAction(navitationTitle: String) {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 300, height: 40)
        button.setTitleColor(UIColor(named: "FontColor"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        button.setTitle(navitationTitle, for: .normal)
        button.setTitleColor(UIColor().setColor(colorType: "fontColor", alpha: 1.0), for: .normal)
        navigationItem.titleView = button
    }
    // ナビゲーションバーのタイトルをカスタマイズ
    func navitationSetTitleCustom(navitationTitle: String) {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 300, height: 40)
        button.setTitleColor(UIColor(named: "FontColor"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.contentHorizontalAlignment = .left
        button.setTitle(navitationTitle, for: .normal)
        button.setTitleColor(UIColor().setColor(colorType: "fontColor", alpha: 1.0), for: .normal)
        navigationItem.titleView = button
    }
    //ナビゲーションバータイトルクリック時
    @objc func showProfile() {
        guard let room = GlobalVar.shared.specificRoom else { return }
        guard let roomID = room.document_id else { return }
        guard let partner = room.partnerUser else { return }
        let partnerUID = partner.uid
        let logEventData = [
            "roomID": roomID,
            "target": partnerUID
        ] as [String : Any]
        Log.event(name: "showMessageRoomNavigationProfile", logEventData: logEventData)

        if partner.is_deleted == true { return }
        let storyBoard = UIStoryboard.init(name: "ProfileDetailView", bundle: nil)
        let modalVC = storyBoard.instantiateViewController(withIdentifier: "ProfileDetailView") as! ProfileDetailViewController
        modalVC.user = partner
        modalVC.isViolation = false
        modalVC.modalPresentationStyle = .popover
        modalVC.transitioningDelegate = self
        modalVC.presentationController?.delegate = self
        present(modalVC, animated: true) {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    // ブロック、違反報告、一発停止・退会が実行された場合はナビゲーションバーとメッセージ入力バーをカスタマイズする
    func messageRoomCustom(room: Room, limitIconEnabled: Bool, consectiveCount: Int?) {
        guard let partnerUser = room.partnerUser else {
            return
        }
        let partnerUID = partnerUser.uid
        var partnerNickName: String
        partnerNickName = partnerUser.nick_name
        
        if let consectiveCount = consectiveCount {
            if consectiveCount >= 5 {
                if limitIconEnabled {
                    partnerNickName = partnerUser.nick_name + "⌛️"
                } else {
                    partnerNickName = partnerUser.nick_name + "🔥\(consectiveCount)日"
                }
            }
        }
        
        navigationController?.navigationBar.standardAppearance.backgroundColor = .white
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .white
        
        let loginUser = GlobalVar.shared.loginUser
        let deleteUsers = loginUser?.deleteUsers ?? [String]()
        let isDeleteUser = (deleteUsers.firstIndex(of: partnerUID) != nil)
        let isDeletedForPartner = (partnerUser.is_deleted == true)
        let isDeleteRelated = (isDeleteUser || isDeletedForPartner)
        if isDeleteRelated {
            //ナビゲーションアイテムのタイトルを設定
            navitationSetTitleCustom(navitationTitle: partnerNickName)
        } else {
            //ナビゲーションアイテムのタイトルを設定
            navitationSetTitleCustomWithAction(navitationTitle: partnerNickName)
        }
    }
    
    func setMessageInputBar(room: Room, messageInputView: MessageInputView) -> Bool {
        guard let partnerUser = room.partnerUser else { return false }
        let partnerUID = partnerUser.uid
        // メッセージやりとりしているユーザがブロック・違反報告・一発停止されている場合
        let loginUser = GlobalVar.shared.loginUser
        let blocks = loginUser?.blocks ?? [String]()
        let violations = loginUser?.violations ?? [String]()
        let stops = loginUser?.stops ?? [String]()
        let isBlockUser = (blocks.firstIndex(of: partnerUID) != nil)
        let isViolationUser = (violations.firstIndex(of: partnerUID) != nil)
        let isStopUser = (stops.firstIndex(of: partnerUID) != nil)
        let isNotActivatedForPartner = (partnerUser.is_activated == false)
        let isNotActivated = (isBlockUser || isViolationUser || isStopUser || isNotActivatedForPartner)
        if isNotActivated { configureMessageInputBarCustom(type: "other", messageInputView: messageInputView); return false }
        
        let deleteUsers = loginUser?.deleteUsers ?? [String]()
        let isDeleteUser = (deleteUsers.firstIndex(of: partnerUID) != nil)
        let isDeletedForPartner = (partnerUser.is_deleted == true)
        let isDeleted = (isDeleteUser || isDeletedForPartner)
        if isDeleted { configureMessageInputBarCustom(type: "delete", messageInputView: messageInputView); return false }
        
        return true
    }
    
    // ブロックされた側のユーザーのメッセージ入力部分を更新する
    private func configureMessageInputBarCustom(type: String, messageInputView: MessageInputView) {
        messageInputView.removeAllSubviews()
        let frame = CGRect(
            x: 0,
            y: 0,
            width: messageInputView.frame.width,
            height: messageInputView.frame.height
        )
        let disableLabel = UILabel()
        disableLabel.text = "退会済み"
        disableLabel.frame = frame
        disableLabel.tintColor = .fontColor
        disableLabel.textAlignment = .center
        disableLabel.backgroundColor = .clear
        disableLabel.font = UIFont.systemFont(ofSize: 16)
        messageInputView.addSubview(disableLabel)
    }
}

extension UIViewController: UIAdaptivePresentationControllerDelegate {
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // setClass(className: className)
    }
    
    func presentationDidDismissMoveMessageRoomAction() {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let displayAutoMessage = GlobalVar.shared.displayAutoMessage
        let specificUser = GlobalVar.shared.specificUser
        
        let rooms = loginUser.rooms
        
        if displayAutoMessage {
            
            if let target = specificUser, let room = rooms.filter({ $0.members.contains(target.uid) }).first, let roomID = room.document_id {
                
                GlobalVar.shared.specificUser = nil
                
                moveMessageRoom(roomID: roomID, target: target)
            }
        }
    }
}

extension UIViewController: UNUserNotificationCenterDelegate {
    // バックグランド && 通知をタッチ動作
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("バックグラウンド通知 : \(userInfo)")
        if let urlStr = userInfo["url"] as? String, let url = URL(string: urlStr) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        completionHandler()
    }
    // フォアグラウンドで通知を受信
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("フォアグラウンド通知 : \(userInfo)")
        let thisClassName = (GlobalVar.shared.thisClassName ?? "")
        let isMessageList = (thisClassName == "MessageListViewController")
        let isMessageRoom = (thisClassName == "MessageRoomView")
        print("現在のクラス : \(thisClassName)")
        if isMessageRoom {
            if let urlStr = userInfo["url"] as? String, let url = URL(string: urlStr) {
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let idParam = components?.queryItems?.first?.value
                let specificRoomID = GlobalVar.shared.specificRoom?.document_id ?? ""
                let isSameRoomID = (idParam == specificRoomID)
                if isSameRoomID { completionHandler([]); return }
            }
            var soundIdRing:SystemSoundID = 1005
            if let soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil) {
                AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                AudioServicesPlaySystemSound(soundIdRing)
            }
            completionHandler([.badge, .sound]); return
        }
        if isMessageList {
            // メッセージ一覧画面に滞在中は時間差があるのでNotificationで通知しない
            completionHandler([])
            return
        }
        completionHandler([.badge, .sound, .banner])
    }
    // iOS通知設定ダイアログ
    func userNotificationSettings() {
        // リモート通知にアプリを登録
        if #available(iOS 10.0, *) {
            // 通知設定 0: 未選択, 1: 許可 2: 未許可
            var settingNotificationStatus = 0
            // iOSの通知設定を取得するため処理を一時的にロックする (処理を直列にする)
            let semaphore = DispatchSemaphore(value: 0)
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] setting in
                guard let _ = self else { return }
                let authorizationStatus = setting.authorizationStatus
                switch authorizationStatus {
                case .notDetermined:
                    // 許可の設定を行っていない
                    print("ダイアログが強制的に表示されるため、ここでは処理を行わない")
                    break
                case .authorized:
                    // 許可の設定を行っていない
                    print("通知が許可されています")
                    break
                default:
                    /// 下記3つのいづれかの状態の場合は、通知画面に飛ばす
                    /// ①  通知拒否 ② Provisional Authorization が有効  ③ AppClip など限られた時間内の通知が有効
                    print("未許可")
                    settingNotificationStatus = 2
                    break
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            switch settingNotificationStatus {
            case 2:
                self.alertWithAction(title: "通知が未許可になっています", message: "通知をONにしたい場合は設定からアプリの通知をONにしてください。", actiontitle: "OK", type: "settings")
                break
            default:
                break
            }
            // iOS 10 APIsを利用
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            // 通知情報取得許可ダイアログの表示
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        // APNsにデバイスを登録（デバイストークンが返却される）
        UIApplication.shared.registerForRemoteNotifications()
    }
    // iOS通知設定チェック
    func getUserNotification() {
        // iOSの通知設定を取得するため処理を一時的にロックする (処理を直列にする)
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { setting in
            DispatchQueue.main.async {
                let authorizationStatus = setting.authorizationStatus
                switch authorizationStatus {
                case .notDetermined, .denied, .ephemeral, .provisional:
                    // ① 通知拒否 ② 通知未設定 ③ Provisional Authorization有効 ④ AppClip など限られた時間内の通知有効
                    GlobalVar.shared.iosNotificationIsPermitted = false
                    GlobalVar.shared.pushNotificationToggleSwitches.forEach { $0.isEnabled = false }
                    GlobalVar.shared.pushNotificationSettingTableView.reloadData()
                    break
                case .authorized:
                    // 通知が許可されている場合
                    GlobalVar.shared.iosNotificationIsPermitted = true
                    GlobalVar.shared.pushNotificationToggleSwitches.forEach { $0.isEnabled = true }
                    GlobalVar.shared.pushNotificationSettingTableView.reloadData()
                    break
                default:
                    break
                }
            }
            semaphore.signal()
        })
        semaphore.wait()
    }
    
    func appTrackingAutorization() {
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied:
                print("😭拒否")
            case .restricted:
                print("🥺制限")
            case .notDetermined:
                showRequestTrackingAuthorizationAlert()
            @unknown default:
                fatalError()
            }
        } else { // iOS14未満
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            } else {
                print("🥺制限")
            }
        }
    }
    // アプリトラッキング許可チェック
    private func showRequestTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    print("🎉")
                    // IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("😭")
                @unknown default:
                    fatalError()
                }
            })
        }
    }
}

/** 画面遷移関連の処理 **/
extension UIViewController {
    // フレンド絵文字ガイド画面に遷移
    @objc func moveFriendEmoji() {
        // フレンド絵文字ガイド画面に遷移
        let storyboard = UIStoryboard.init(name: "FriendEmojiView", bundle: nil)
        let guideVC = storyboard.instantiateViewController(withIdentifier: "FriendEmojiView") as! FriendEmojiViewController
        let guideNavVC = UINavigationController(rootViewController: guideVC)
        guideNavVC.transitioningDelegate = self
        guideNavVC.presentationController?.delegate = self
        present(guideNavVC, animated: true, completion: nil)
    }
    // フレンド絵文字設定画面に遷移
    @objc func moveFriendEmojiSetting() {
        // フレンド絵文字ガイド画面に遷移
        let storyboard = UIStoryboard.init(name: "FriendEmojiSettingView", bundle: nil)
        let settingVC = storyboard.instantiateViewController(withIdentifier: "FriendEmojiSettingView") as! FriendEmojiSettingViewController
        present(settingVC, animated: true, completion: nil)
    }
}

/** ユーザ関連の処理 **/
extension UIViewController {
    
    // リスナー初期化
    private func initListener(initFlg: Bool = false) {
        GlobalVar.shared.userAdminCheckStatusListener = nil
        GlobalVar.shared.userDeactiveListener = nil
        GlobalVar.shared.userForceDeactiveListener = nil
        GlobalVar.shared.approachedListener = nil
        GlobalVar.shared.blockListener = nil
        GlobalVar.shared.violationListener = nil
        GlobalVar.shared.stopListener = nil
        GlobalVar.shared.messageListListener = nil
        GlobalVar.shared.messageRoomListener = nil
        GlobalVar.shared.messageRoomTypingListener = nil
        GlobalVar.shared.boardListener = nil
        GlobalVar.shared.visitorListener = nil
        GlobalVar.shared.hobbyCardListener = nil
        
        if initFlg { GlobalVar.shared.reInit() }
    }
    
    // リスナーのデタッチ
    func removeListener(initFlg: Bool = false) {
        GlobalVar.shared.userAdminCheckStatusListener?.remove()
        GlobalVar.shared.userDeactiveListener?.remove()
        GlobalVar.shared.userForceDeactiveListener?.remove()
        GlobalVar.shared.approachedListener?.remove()
        GlobalVar.shared.blockListener?.remove()
        GlobalVar.shared.violationListener?.remove()
        GlobalVar.shared.stopListener?.remove()
        GlobalVar.shared.messageListListener?.remove()
        GlobalVar.shared.messageRoomListener?.remove()
        GlobalVar.shared.messageRoomTypingListener?.remove()
        GlobalVar.shared.boardListener?.remove()
        GlobalVar.shared.visitorListener?.remove()
        GlobalVar.shared.hobbyCardListener?.remove()
        // リスナー初期化
        initListener(initFlg: initFlg)
    }
    
    // リスナーのアタッチ
    func attachListener() {
        // 趣味カードの情報を監視
        let isNotHobbyCardListener = (
            GlobalVar.shared.hobbyCardListener == nil
        )
        if isNotHobbyCardListener {
            fetchHobbyCardInfoFromFirestore()
        }
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        let loginUID = loginUser.uid
        // ユーザの認証状態を監視
        let isNotUserAdminCheckStatusListener = (
            GlobalVar.shared.userAdminCheckStatusListener == nil
        )
        if isNotUserAdminCheckStatusListener {
            fetchUserAdminCheckBatchFromFirestore(uid: loginUID)
        }
        // ユーザアクティブ状態を監視
        let isNotUserDeactiveListener = (
            GlobalVar.shared.userDeactiveListener == nil
        )
        if isNotUserDeactiveListener {
            fetchUserDeactiveInfoFromFirestore(uid: loginUID)
        }
        // ユーザ強制非アクティブ状態を監視
        let isNotUserForceDeactiveListener = (
            GlobalVar.shared.userForceDeactiveListener == nil
        )
        if isNotUserForceDeactiveListener {
            fetchUserForceDeactiveInfoFromFirestore(uid: loginUID)
        }
        // アプローチ情報を監視
        let isNotApproachListener = (
            GlobalVar.shared.approachedListener == nil
        )
        if isNotApproachListener {
            fetchApproachInfoFromFirestore(uid: loginUID)
        }
        // メッセージルームの監視
        let isNotMessageListListener = (
            GlobalVar.shared.messageListListener == nil
        )
        if isNotMessageListListener {
            fetchMessageListInfoFromFirestore(uid: loginUID)
        }
        // タイムラインの監視
        let isNotBoardListener = (
            GlobalVar.shared.boardListener == nil
        )
        if isNotBoardListener {
            fetchBoardInfoFromFirestore(uid: loginUID)
        }
        // 足あとの監視
        let isNotVisitorListener = (
            GlobalVar.shared.visitorListener == nil
        )
        if isNotVisitorListener {
            fetchVisitorInfoFromFirestore(uid: loginUID)
        }
        // 違反報告情報を監視
        let isNotViolationListener = (
            GlobalVar.shared.violationListener == nil
        )
        if isNotViolationListener {
            fetchViolationInfoFromFirestore(uid: loginUID)
        }
        // ブロック情報を監視
        let isNotBlockListener = (
            GlobalVar.shared.blockListener == nil
        )
        if isNotBlockListener {
            fetchBlockInfoFromFirestore(uid: loginUID)
        }
        // 一発停止情報を監視
        let isNotStopListener = (
            GlobalVar.shared.stopListener == nil
        )
        if isNotStopListener {
            fetchStopInfoFromFirestore(uid: loginUID)
        }
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.setApproachedTabBadges()
            weakSelf.setMessageTabBadges()
            weakSelf.setVisitorTabBadges()
        }
        
        getUserNotification()
    }
    
    // ログインユーザのインスタンスを生成
    func authInstance(uid: String, bootFlg: Bool) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] (document, error) in
            guard let weakSelf = self else { return }
            if let document = document, document.exists {
                let user = User(document: document)
                weakSelf.globalAuthInstance(user: user, bootFlg: bootFlg)
            }
        }
    }
    
    private func globalAuthInstance(user: User, bootFlg: Bool) {
        if GlobalVar.shared.loginUser == nil {
            GlobalVar.shared.loginUser = user
        } else {
            GlobalVar.shared.loginUser?.nick_name = user.nick_name
            GlobalVar.shared.loginUser?.notification_email = user.notification_email
            GlobalVar.shared.loginUser?.type = user.type
            GlobalVar.shared.loginUser?.holiday = user.holiday
            GlobalVar.shared.loginUser?.business = user.business
            GlobalVar.shared.loginUser?.income = user.income
            GlobalVar.shared.loginUser?.violation_count = user.violation_count
            GlobalVar.shared.loginUser?.birth_date = user.birth_date
            GlobalVar.shared.loginUser?.profile_icon_img = user.profile_icon_img
            GlobalVar.shared.loginUser?.profile_icon_sub_imgs = user.profile_icon_sub_imgs
            GlobalVar.shared.loginUser?.profile_status = user.profile_status
            GlobalVar.shared.loginUser?.address = user.address
            GlobalVar.shared.loginUser?.address2 = user.address2
            GlobalVar.shared.loginUser?.hobbies = user.hobbies
            GlobalVar.shared.loginUser?.peerId = user.peerId
            GlobalVar.shared.loginUser?.fcmToken = user.fcmToken
            GlobalVar.shared.loginUser?.deviceToken = user.deviceToken
            GlobalVar.shared.loginUser?.is_approached_notification = user.is_approached_notification
            GlobalVar.shared.loginUser?.is_matching_notification = user.is_matching_notification
            GlobalVar.shared.loginUser?.is_message_notification = user.is_message_notification
            GlobalVar.shared.loginUser?.is_visitor_notification = user.is_visitor_notification
            GlobalVar.shared.loginUser?.is_invitationed_notification = user.is_invitationed_notification
            GlobalVar.shared.loginUser?.is_dating_notification = user.is_dating_notification
            GlobalVar.shared.loginUser?.is_approached_mail = user.is_approached_mail
            GlobalVar.shared.loginUser?.is_matching_mail = user.is_matching_mail
            GlobalVar.shared.loginUser?.is_message_mail = user.is_message_mail
            GlobalVar.shared.loginUser?.is_visitor_mail = user.is_visitor_mail
            GlobalVar.shared.loginUser?.is_invitationed_mail = user.is_invitationed_mail
            GlobalVar.shared.loginUser?.is_dating_mail = user.is_dating_mail
            GlobalVar.shared.loginUser?.is_vibration_notification = user.is_vibration_notification
            GlobalVar.shared.loginUser?.is_identification_approval = user.is_identification_approval
            GlobalVar.shared.loginUser?.is_deleted = user.is_deleted
            GlobalVar.shared.loginUser?.is_activated = user.is_activated
            GlobalVar.shared.loginUser?.is_logined = user.is_logined
            GlobalVar.shared.loginUser?.is_init_reviewed = user.is_init_reviewed
            GlobalVar.shared.loginUser?.is_reviewed = user.is_reviewed
            GlobalVar.shared.loginUser?.is_rested = user.is_rested
            GlobalVar.shared.loginUser?.is_withdrawal = user.is_withdrawal
            GlobalVar.shared.loginUser?.is_tutorial = user.is_tutorial
            GlobalVar.shared.loginUser?.tutorial_num = user.tutorial_num
            GlobalVar.shared.loginUser?.is_talkguide = user.is_talkguide
            GlobalVar.shared.loginUser?.is_auto_message = user.is_auto_message
            GlobalVar.shared.loginUser?.is_display_ranking_talkguide = user.is_display_ranking_talkguide
            GlobalVar.shared.loginUser?.is_friend_emoji = user.is_friend_emoji
            GlobalVar.shared.loginUser?.approaches = user.approaches
            GlobalVar.shared.loginUser?.approacheds = user.approacheds
            GlobalVar.shared.loginUser?.reply_approacheds = user.reply_approacheds
            GlobalVar.shared.loginUser?.logouted_at = user.logouted_at
            GlobalVar.shared.loginUser?.min_age_filter = user.min_age_filter
            GlobalVar.shared.loginUser?.max_age_filter = user.max_age_filter
            GlobalVar.shared.loginUser?.address_filter = user.address_filter
            GlobalVar.shared.loginUser?.hobby_filter = user.hobby_filter
        }
        // 初回起動
<<<<<<< HEAD
        if bootFlg { tabBarTransition() }
    }
    
    // ログインユーザ状態の監視
    func fetchUserStatusBatchFromFirestore(uid: String) {
//        print("ユーザ監視リスナーアタッチ")
        let db = Firestore.firestore()
        GlobalVar.shared.userStatusListener = db.collection("users").document(uid).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let weakSelf = self else { return }
            if let error = error { print("ユーザ状態のスナップショットの取得ができませんでした: \(error)"); return }
            guard let document = documentSnapshot else { print("ユーザ状態のスナップショットが存在しませんでした"); return }
            let user = User(document: document)
            let oldApproacheds = GlobalVar.shared.loginUser?.approacheds ?? [String]()
            // ユーザインスタンスに最新の値をセット
            weakSelf.globalAuthInstance(user: user, bootFlg: false)
            // 非アクティブ・未削除
            weakSelf.activeConditionsUser(user: user)
            // 未対応のアプローチされたユーザ
            weakSelf.cardApproachedUsers(user: user, oldApproacheds: oldApproacheds)
        }
    }
    
    private func cardApproachedUsers(user: User, oldApproacheds: [String]) {
        let approacheds = user.approacheds
        let cardApproachedUsers = GlobalVar.shared.cardApproachedUsers
        Task {
            let filterApproacheds = approacheds.filter({ approachedCommonFilter(creatorUID: $0, targetUID: nil) })
            let db = Firestore.firestore()
            let filterApproachedUsers = try await filterApproacheds.asyncMap {
                let uid = $0
                if let index = cardApproachedUsers.firstIndex(where: { $0.uid == uid }), let user = cardApproachedUsers[safe: index] {
                    return user
                } else {
                    let userDocument = try await db.collection("users").document(uid).getDocument()
                    return User(document: userDocument)
                }
            }
            let filterApproachedActiveUsers = filterApproachedUsers.filter ({
                let isActivated = ($0.is_deleted == false && $0.is_activated == true)
                let isApproached = approachedCommonFilter(creatorUID: $0.uid, targetUID: nil)
                let existUser = checkUserInfo(user: $0)
                return isActivated && isApproached && existUser
            })
            // print("アプローチされた ユーザ総数 : \(approacheds.count), フィルター後のユーザ数 : \(filterApproacheds.count), フィルター後のアクティブユーザ数 : \(filterApproachedActiveUsers.count)")
            GlobalVar.shared.cardApproachedUsers = filterApproachedActiveUsers.reversed()
            
            setApproachedTabBadges()
            
            if oldApproacheds != approacheds { setApproachCard() }
        }
    }

    private func activeConditionsUser(user: User) {
        // ログインユーザの非アクティブ・未削除
        let isNotActivated = (user.is_activated == false)
        let isDeleted = (user.is_deleted == true)
        if isNotActivated && isDeleted {
            loginScreenTransition()
        } else if isNotActivated && !isDeleted {
            loginScreenTransition()
        } else if !isNotActivated && isDeleted {
            logoutAction()
        } else {
            let isEmptyLoginUser = (GlobalVar.shared.loginUser == nil)
            if isEmptyLoginUser { globalAuthInstance(user: user, bootFlg: true) }
=======
        if bootFlg {
            tabBarTransition()
            // screenTransition(storyboardName: "ApproachTutorialView", storyboardID: "ApproachTutorialView")
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
        }
    }
    
    // アプローチバッジの設定
    func setApproachedTabBadges(reload: Bool = false) {
        
        let cardApproachedUsers = GlobalVar.shared.cardApproachedUsers
        let approachedCount = cardApproachedUsers.count
        if approachedCount > 0 {
            GlobalVar.shared.tabBarVC?.tabBar.items?[1].badgeValue = String(approachedCount)
        } else {
            GlobalVar.shared.tabBarVC?.tabBar.items?[1].badgeValue = nil
        }
        
        if reload { GlobalVar.shared.visitorTableView.reloadData() }
    }
    
    // メッセージバッジの設定
    func setMessageTabBadges() {
        let originRooms = GlobalVar.shared.loginUser?.rooms ?? [Room]()
        var rooms = [Room]()
        Task {
            await originRooms.asyncForEach { originRoom in
                let notFindRoom = (rooms.firstIndex(where: { originRoom.document_id == $0.document_id }) == nil)
                if notFindRoom { rooms.append(originRoom) }
            }
            rooms.sort{ (m1, m2) -> Bool in
                let m1Date = m1.updated_at.dateValue()
                let m2Date = m2.updated_at.dateValue()
                return m1Date > m2Date
            }
            GlobalVar.shared.loginUser?.rooms = rooms
            GlobalVar.shared.messageListTableView.reloadData()
            GlobalVar.shared.recomMsgCollectionView.reloadData()
            let messageUnreadCount = rooms.reduce(0, { currentUnreadCount, room in
                let unreadTotal = currentUnreadCount + room.unreadCount
                return unreadTotal
            })
            if messageUnreadCount > 0 {
                GlobalVar.shared.tabBarVC?.tabBar.items?[2].badgeValue = String(messageUnreadCount)
            } else {
                GlobalVar.shared.tabBarVC?.tabBar.items?[2].badgeValue = nil
            }
            
            UserDefaults.standard.set(messageUnreadCount, forKey: "applicationIconMessageBadgeNumber")
            UserDefaults.standard.synchronize()
        }
    }
    
    // 足あとバッジの設定
    func setVisitorTabBadges() {
        
        Task {

            var originVisitors = GlobalVar.shared.loginUser?.visitors ?? [Visitor]()
            originVisitors = originVisitors.filter({ commonFilter(creatorUID: $0.creator, targetUID: nil) })
            
            var visitors = [Visitor]()
            await originVisitors.asyncForEach { originVisitor in
                let notFindVisitor = (visitors.firstIndex(where: { originVisitor.document_id == $0.document_id }) == nil)
                if notFindVisitor { visitors.append(originVisitor) }
            }
            visitors.sort{ (m1, m2) -> Bool in
                let m1Date = m1.updated_at.dateValue()
                let m2Date = m2.updated_at.dateValue()
                return m1Date > m2Date
            }
            GlobalVar.shared.loginUser?.visitors = visitors
            
            let deleteUsers = GlobalVar.shared.loginUser?.deleteUsers ?? [String]()
            let loginUID = GlobalVar.shared.loginUser?.uid ?? ""
            let visitorUnreadList = visitors.filter({
                deleteUsers.firstIndex(of: $0.creator) == nil &&
                $0.target == loginUID &&
                $0.read == false
            })
            GlobalVar.shared.loginUser?.visitorUnreadList = visitorUnreadList.map({ $0.document_id })
            
            GlobalVar.shared.visitorTableView.reloadData()
            
            if visitorUnreadList.count > 0 {
                GlobalVar.shared.tabBarVC?.tabBar.items?[4].badgeValue = "N"
            } else {
                GlobalVar.shared.tabBarVC?.tabBar.items?[4].badgeValue = nil
            }
        }
    }
    
    // お誘いバッジの設定
    func setInvitationTabBadges() {
        var invitations = GlobalVar.shared.loginUser?.invitations ?? [Invitation]()
        let deleteUsers = GlobalVar.shared.loginUser?.deleteUsers ?? [String]()
        invitations = invitations.filter({ $0.is_deleted == false })
        GlobalVar.shared.loginUser?.invitations = invitations
        let invitationUnreadCount = invitations.reduce(0, { currentUnreadCount, invitation in
            let members = invitation.members.filter({ deleteUsers.firstIndex(of: $0) == nil })
            let readMembers = invitation.read_members.filter({ deleteUsers.firstIndex(of: $0) == nil })
            let unreadCount = (members.count - readMembers.count)
            let unreadTotal = currentUnreadCount + unreadCount
            return unreadTotal
        })
        if invitationUnreadCount > 0 {
            GlobalVar.shared.tabBarVC?.tabBar.items?[3].badgeValue = String(invitationUnreadCount)
        } else {
            GlobalVar.shared.tabBarVC?.tabBar.items?[3].badgeValue = nil
        }
    }
    
    // ユーザの認証状態を監視
    func fetchUserAdminCheckBatchFromFirestore(uid: String) {
        // print("ユーザ本人確認監視リスナーアタッチ")
        let db = Firestore.firestore()
        GlobalVar.shared.userAdminCheckStatusListener = db.collection("users").document(uid).collection("admin_checks").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let weakSelf = self else { return }
            if let error = error { print("ユーザの本人確認状態のスナップショットの取得ができませんでした: \(error)"); return }
            guard let documentChanges = querySnapshot?.documentChanges else { return }
            print("本人確認されたドキュメント数 : \(documentChanges.count)")
            if documentChanges.isEmpty {
                print("本人確認書類なし")
                return
            }
            documentChanges.forEach({ weakSelf.userAdminCheckDocumentSnapShotListener(documentChange: $0) })
        }
    }
    
    private func userAdminCheckDocumentSnapShotListener(documentChange: DocumentChange) {
        if (documentChange.type == .added || documentChange.type == .modified) {
            // ユーザの本人確認状態の更新
            GlobalVar.shared.loginUser?.admin_checks = AdminCheck(document: documentChange.document)
        }
        if (documentChange.type == .removed) {
            print("ユーザの本人確認状態が削除されました(本来は削除されない) : \(documentChange.document.data())")
            GlobalVar.shared.loginUser?.admin_checks = nil
        }
    }
    
    func popUpIdentificationView() {
        // 本人確認画面遷移を表示
        let storyBoard = UIStoryboard.init(name: "IdentificationView", bundle: nil)
        let modalVC = storyBoard.instantiateViewController(withIdentifier: "IdentificationView") as! IdentificationViewController
        // モーダル表示をポップアップ全画面で表示
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.transitioningDelegate = self
        present(modalVC, animated: true, completion: nil)
    }
    
    func logoutAction() {
        let firebaseAuth = Auth.auth()
        //facebookログアウト
        if GlobalVar.shared.loginUser?.phone_number == "facebook" {
            let manager = LoginManager()
            manager.logOut()
        }
        do {
            try firebaseAuth.signOut()
            loginScreenTransition()
            
            let loginType = UserDefaults.standard.string(forKey: "LOGIN_TYPE") ?? ""
            switch loginType {
            case "apple", "facebook", "google", "phone":
                Log.event(name: "logout", logEventData: ["login_type": loginType])
                break
            default:
                break
            }
    
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // FCM Token, Device Tokenの更新
    func tokenUpdate(uid: String) {
        let fcmToken = UserDefaults.standard.string(forKey: "FCM_TOKEN") ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "DEVICE_TOKEN") ?? ""
        // Tokenの更新
        let updateData = [
            "fcmToken": fcmToken,
            "deviceToken": deviceToken
        ]
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData(updateData)
    }
    
    // ユーザの必須情報の欠損がないかをチェック (本来必要な情報が存在しない場合)
    func checkUserInfo(user: User) -> Bool {
        // 一部でもデータの欠損があればfalse
        let isEmptyNickName = (user.nick_name == "")
        let isEmptyBirthDate = (user.birth_date == "")
        let isEmptyProfileIconImg = (user.profile_icon_img == "")
        let isEmptyProfileStatus = (user.profile_status == "")
        let isEmptyAddress = (user.address == "")
        let isEmptyHobbies = (user.hobbies.count == 0)
        let partOfEmpty = (
            isEmptyNickName || isEmptyBirthDate ||
            isEmptyProfileIconImg || isEmptyProfileStatus ||
            isEmptyAddress || isEmptyHobbies
        )
        if partOfEmpty {
            return false
        // データの欠損がなければtrue
        } else {
            return true
        }
    }
    
    // ユーザ取得 (非同期)
    func fetchUserInfo(uid: String) async throws -> User {
        let db = Firestore.firestore()
        let userDocument = try await db.collection("users").document(uid).getDocument()
        let user = User(document: userDocument)
        return user
    }
    
    func fetchInvitationGoodUserInfo(invitation: Invitation) -> [User] {
        
        let db = Firestore.firestore()
        
        let members = invitation.members.filter({ commonFilter(creatorUID: $0, targetUID: nil) })
        if members.isEmpty { return [User]() }
        
        Task {
            invitation.goodUsers = try await members.asyncMap {
                let memberDocument = try await db.collection("users").document($0).getDocument()
                return User(document: memberDocument)
            }
            invitation.goodUsers = invitation.goodUsers.filter ({
                $0.is_deleted == false && $0.is_activated == true
            })
            invitation.goodUsers = invitation.goodUsers.reversed()
            GlobalVar.shared.specificInvitation = invitation
            GlobalVar.shared.goodTableView.reloadData()
        }
        
        return invitation.goodUsers
    }
    
    // ユーザドキュメントの有無に応じて画面遷移
    func userExistCheckPageMove(uid: String, loadingView: UIView) {
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] (document, error) in
            guard let weakSelf = self else { return }
            if let document = document, document.exists {
                let user = User(document: document)
                if weakSelf.checkUserInfo(user: user) {
                    weakSelf.checkUserPageMove(user: user, loadingView: loadingView)
                } else {
                    weakSelf.screenTransition(storyboardName: "LoginPageView", storyboardID: "LoginPageView")
                    loadingView.removeFromSuperview()
                }

            } else {
                weakSelf.screenTransition(storyboardName: "LoginPageView", storyboardID: "LoginPageView")
                loadingView.removeFromSuperview()
            }
        }
    }
    
    // ユーザのドキュメント状態に応じて画面遷移
    private func checkUserPageMove(user: User, loadingView: UIView) {
        // ユーザがアクティブの場合
        GlobalVar.shared.loginUser = user
        // ユーザのアクティブ状態に応じた画面遷移
//        let loginState = (user.is_activated && user.is_tutorial == false)
//        let tutorialState = (user.is_activated && user.is_tutorial)
//        
//        if loginState {
//            tabBarTransition()
//        } else if tutorialState {
//            screenTransition(storyboardName: "ApproachTutorialView", storyboardID: "ApproachTutorialView")
//        } else {
//            screenTransition(storyboardName: "StoppedView", storyboardID: "StoppedView")
//        }
        
        let loginState = (user.is_activated == true)
        if loginState {
            tabBarTransition()
        } else {
            screenTransition(storyboardName: "StoppedView", storyboardID: "StoppedView")
        }
        loadingView.removeFromSuperview()
    }
    
    func filterInitGlobalData() {
        GlobalVar.shared.likeCardUsers = []
        GlobalVar.shared.cardRecommendFilterFlg = false
        GlobalVar.shared.cardSearchUserPage = 1
        GlobalVar.shared.cardPriorityUserPage = 1
        GlobalVar.shared.searchCardRecommendUsers = []
        GlobalVar.shared.pickupCardRecommendUsers = []
        GlobalVar.shared.priorityCardRecommendUsers = []
        GlobalVar.shared.pickupUserIndex = 7
        GlobalVar.shared.searchCardUserEnd = false
        GlobalVar.shared.priorityCardUserEnd = false
    }
    
    func mergeUsers(users: [User], mergedUsers: [User]) -> [User] {
    
        let duplicateCardUsers = mergedUsers.filter({
            let specificUID = $0.uid
            let checkFilterUsers = users.filter({ $0.uid == specificUID }).count
            let isNotExistFilterUsers = (checkFilterUsers == 0)
            return isNotExistFilterUsers
        })
        let duplicateFilterCardUsers = duplicateCardUsers.filter({ filterMethod(user: $0) })
        let duplicateSortCardUsers = sortMethod(users: duplicateFilterCardUsers)
        
        let mergeCardUsers = users + duplicateSortCardUsers
        
        return mergeCardUsers
    }
    
    func moveGenerateHobbyCard() {
        //本人確認していない場合は確認ページを表示
        guard let adminIDCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status else {
            popUpIdentificationView(); return
        }
        if adminIDCheckStatus == 1 {
            
            let storyboardName = GenerateNewHobbyCardViewController.storyboardName
            let storyboardID = GenerateNewHobbyCardViewController.storyboardId
            
            screenTransition(storyboardName: storyboardName, storyboardID: storyboardID)

        } else if adminIDCheckStatus == 2 {
            dialog(title: "本人確認失敗しました", subTitle: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", confirmTitle: "OK", completion: { [weak self] confirm in
                guard let weakSelf = self else { return }
                if confirm { weakSelf.popUpIdentificationView() }
            })
        } else {
            alert(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", actiontitle: "OK")
        }
    }
}

/** アプローチ関連の処理 **/
extension UIViewController {
    
    func fetchApproachedInfoFromTypesense(page: Int = 1) {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let typesenseClient = GlobalVar.shared.typesenseClient
        
        let loginUID = loginUser.uid
        let loginApproacheds = loginUser.approacheds
        
        let filterLoginApproacheds = loginApproacheds.filter({ approachedCommonFilter(creatorUID: $0, targetUID: nil) })
        
        let searchFilterBy = "is_activated:= true && is_deleted:= false && uid: \(filterLoginApproacheds)"
        
        let perPage = 200
        let searchParams = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, perPage: perPage)
        
        Task {
            do {
                let start = Date()
                
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParams, for: CardUserQuery.self)
                
                let elapsed = Date().timeIntervalSince(start)
                print("\nアプローチされたユーザの取得完了 : \(elapsed)")
                
                guard let hits = searchResult?.hits else { return }
                
                let isEmptyHits = (hits.count == 0)
                if isEmptyHits { return }
                
                let cardUsers = hits.map({ User(cardUserQuery: $0) })
                let globalApproachedCards = GlobalVar.shared.cardApproachedUsers
                
                let mergedApproachedCards = mergeUsers(users: cardUsers, mergedUsers: globalApproachedCards)
                
                GlobalVar.shared.cardApproachedUsers = mergedApproachedCards
                
                if globalApproachedCards.count == mergedApproachedCards.count {
                    setApproachedTabBadges()
                    setApproachCard()
                    return
                }
                
                fetchApproachedInfoFromTypesense(page: page + 1)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    // アプローチ情報の監視
    func fetchApproachInfoFromFirestore(uid: String) {
        // アプローチされたユーザの事前取得
        fetchApproachedInfoFromTypesense()
        // print("アプローチされたユーザ監視リスナーのアタッチ")
        // 初回アプローチされたユーザを取得
        let homeVC = HomeViewController()
        homeVC.getApproachedCardUsers()
        
        let db = Firestore.firestore()
        GlobalVar.shared.approachedListener = db.collection("approachs").whereField("target", isEqualTo: uid).order(by: "updated_at", descending: true).limit(to: 1).addSnapshotListener { [weak self] (querySnapshot, err) in
            guard let weakSelf = self else { return }
            if let err = err { print("アプローチされた情報の取得失敗: \(err)"); return }
            guard let documentChanges = querySnapshot?.documentChanges else { return }
            guard let lastDocumentID = documentChanges.last?.document.documentID else { return }
            print("アプローチされたドキュメント数 : \(documentChanges.count)")
            documentChanges.forEach({
                weakSelf.approachDocumentSnapShotListener(documentChange: $0, currentUID: uid, lastDocumentID: lastDocumentID)
            })
        }
    }

    private func approachDocumentSnapShotListener(documentChange: DocumentChange, currentUID: String, lastDocumentID: String) {
        if documentChange.type == .added {
            handleApproachAddedDocumentChange(approachsDocumentChanges: documentChange, uid: currentUID, lastDocumentID: lastDocumentID)
        }
        if documentChange.type == .modified {
            print("アプローチの更新")
            setApproachedTabBadges(reload: true)
        }
        if documentChange.type == .removed {
            print("アプローチの削除")
            setApproachedTabBadges(reload: true)
        }
    }
    
    // ドキュメント追加時のハンドラー
    private func handleApproachAddedDocumentChange(approachsDocumentChanges: DocumentChange, uid: String, lastDocumentID: String) {
        // ユーザのアプローチ状態を取得
        let approach = Approach(document: approachsDocumentChanges.document)
        let approachedUIDs = GlobalVar.shared.loginUser?.approacheds ?? [String]()

        guard let creatorUID = approach.creator else { return }
        guard let targetUID = approach.target else { return }
               
        let approachDocumentID = approach.document_id
        
        Task {
            if targetUID == uid {
                // 自分がアプローチされた情報
                if approachedUIDs.first(where: { $0 == creatorUID }) != nil { return }
                GlobalVar.shared.loginUser?.approacheds.append(creatorUID)
                // 自分がアプローチされた
                let addApproachCard = (approach.status == 0)
                if addApproachCard {
                    let cardApproachedUsers = GlobalVar.shared.cardApproachedUsers
                    if cardApproachedUsers.first(where: { $0.uid == creatorUID }) == nil {
                        let db = Firestore.firestore()
                        let userDocument = try await db.collection("users").document(creatorUID).getDocument()
                        let user = User(document: userDocument)
                        GlobalVar.shared.cardApproachedUsers.insert(user, at: 0)
                        let homeVC = HomeViewController(); homeVC.setCard(users: GlobalVar.shared.cardApproachedUsers)
                    }
                }
                // アプローチされたタブの更新
                if approachDocumentID == lastDocumentID { setApproachedTabBadges(reload: true) }
            }
        }
    }
    
<<<<<<< HEAD
    private func setApproachCard() {
        let homeVCStr = "HomeViewController"
        let backgroundClassName = GlobalVar.shared.backgroundClassName
        if backgroundClassName.firstIndex(of: homeVCStr) != nil {
            GlobalVar.shared.backgroundClassName = []
            let homeVC = HomeViewController()
            let cardApproachedUsers = GlobalVar.shared.cardApproachedUsers
            homeVC.setCard(users: cardApproachedUsers)
        }
    }
    
    // ドキュメント更新時のハンドラ
    private func handleApproachUpdatedDocumentChange(approachsDocumentChanges: DocumentChange, uid: String, lastDocumentID: String) {
        
        let changeApproach = Approach(document: approachsDocumentChanges.document)
        let approacheds = GlobalVar.shared.loginUser?.approached ?? [Approach]()
        
        guard let targetUID = changeApproach.target else { return }
        
        let approachDocumentID = changeApproach.document_id
        
        if targetUID == uid {
            // 自分がアプローチされた情報
            if let approachIndex = approacheds.firstIndex(where: { $0.document_id == approachDocumentID }), GlobalVar.shared.loginUser?.approached[safe: approachIndex] != nil {
                GlobalVar.shared.loginUser?.approached[approachIndex] = changeApproach
            }
            // アプローチされたタブの更新
            if approachDocumentID == lastDocumentID { setApproachedTabBadges() }
        }
    }
    
    // ドキュメント削除時のハンドラ
    private func handleApproachRemovedDocumentChange(approachsDocumentChanges: DocumentChange, uid: String, lastDocumentID: String) {
        
        let changeApproach = Approach(document: approachsDocumentChanges.document)
        let approacheds = GlobalVar.shared.loginUser?.approached ?? [Approach]()
        
        guard let targetUID = changeApproach.target else { return }
        
        let approachDocumentID = changeApproach.document_id
        
        if targetUID == uid {
            // 自分がアプローチされた情報
            if let approachIndex = approacheds.firstIndex(where: { $0.document_id == approachDocumentID }), GlobalVar.shared.loginUser?.approached[safe: approachIndex] != nil {
                GlobalVar.shared.loginUser?.approached.remove(at: approachIndex)
            }
            // アプローチされたタブの更新
            if approachDocumentID == lastDocumentID { setApproachedTabBadges() }
        }
    }
    
=======
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
    // フィルターをかける (ブロック、違反報告、一発停止、削除ユーザ)
    func commonFilter(creatorUID: String?, targetUID: String?) -> Bool {
        if let creator = creatorUID {
            if GlobalVar.shared.loginUser?.blocks.firstIndex(of: creator) != nil { return false }
            if GlobalVar.shared.loginUser?.violations.firstIndex(of: creator) != nil { return false }
            if GlobalVar.shared.loginUser?.stops.firstIndex(of: creator) != nil { return false }
            if GlobalVar.shared.loginUser?.deleteUsers.firstIndex(of: creator) != nil { return false }
        }
        if let target = targetUID {
            if GlobalVar.shared.loginUser?.blocks.firstIndex(of: target) != nil { return false }
            if GlobalVar.shared.loginUser?.violations.firstIndex(of: target) != nil { return false }
            if GlobalVar.shared.loginUser?.stops.firstIndex(of: target) != nil { return false }
            if GlobalVar.shared.loginUser?.deleteUsers.firstIndex(of: target) != nil { return false }
        }
        return true
    }
    
    // フィルターをかける (ブロック、一発停止、削除ユーザ)
    func exclusionCommonFilter(creatorUID: String?, targetUID: String?) -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        
        let blocks = loginUser.blocks
        let stops = loginUser.stops
        let deleteUsers = loginUser.deleteUsers
        
        if let creator = creatorUID {
            if blocks.firstIndex(of: creator) != nil { return false }
            if stops.firstIndex(of: creator) != nil { return false }
            if deleteUsers.firstIndex(of: creator) != nil { return false }
        }
        if let target = targetUID {
            if blocks.firstIndex(of: target) != nil { return false }
            if stops.firstIndex(of: target) != nil { return false }
            if deleteUsers.firstIndex(of: target) != nil { return false }
        }
        return true
    }
    
    // フィルターをかける (ブロック、違反報告、一発停止、削除ユーザ、アプローチする)
    func approachedCommonFilter(creatorUID: String?, targetUID: String?) -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        
        let blocks = loginUser.blocks
        let violations = loginUser.violations
        let stops = loginUser.stops
        let deleteUsers = loginUser.deleteUsers
        let approachs = loginUser.approaches
        let replyApproacheds = loginUser.reply_approacheds
        
        if let creator = creatorUID {
            if blocks.firstIndex(of: creator) != nil { return false }
            if violations.firstIndex(of: creator) != nil { return false }
            if stops.firstIndex(of: creator) != nil { return false }
            if deleteUsers.firstIndex(of: creator) != nil { return false }
            if approachs.firstIndex(of: creator) != nil { return false }
            if replyApproacheds.firstIndex(of: creator) != nil { return false }
        }
        if let target = targetUID {
            if blocks.firstIndex(of: target) != nil { return false }
            if violations.firstIndex(of: target) != nil { return false }
            if stops.firstIndex(of: target) != nil { return false }
            if deleteUsers.firstIndex(of: target) != nil { return false }
            if approachs.firstIndex(of: target) != nil { return false }
            if replyApproacheds.firstIndex(of: target) != nil { return false }
        }
        return true
    }
    
    // アプローチされたカードユーザのフィルタリング
    func filterApproachedMethod(user: User) -> Bool {
        // ログインユーザUIDを取得
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        
        let currentUID = loginUser.uid
        let blocks = loginUser.blocks
        let violations = loginUser.violations
        let stops = loginUser.stops
        let deleteUsers = loginUser.deleteUsers
        let deactivateUsers = loginUser.deactivateUsers
        let strApproaches = loginUser.approaches
        let strReplyApproacheds = loginUser.reply_approacheds
        // フィルター内容
        let isNotLoginUser = (user.uid != currentUID)
        let isActivedUser = (user.is_activated == true)
        let isNotDeletedUser = (user.is_deleted == false)
        let isNotRestUser = (user.is_rested == false)
        let isNotBlockUser = (blocks.firstIndex(of: user.uid) == nil)
        let isNotViolationUser = (violations.firstIndex(of: user.uid) == nil)
        let isNotStopUser = (stops.firstIndex(of: user.uid) == nil)
        let isNotDeleteUser = (deleteUsers.firstIndex(of: user.uid) == nil)
        let isNotDeactivateUser = (deactivateUsers.firstIndex(of: user.uid) == nil)
        let isNotApproachedsUser = (user.approacheds.firstIndex(of: currentUID) == nil)
        let isNotStrApproachesUser = (strApproaches.firstIndex(of: user.uid) == nil)
        let isNotStrReplyApproachedsUser = (strReplyApproacheds.firstIndex(of: user.uid) == nil)
        // ユーザフィルター判定
        let isSetUser = (
            isNotLoginUser &&
            isActivedUser &&
            isNotDeletedUser &&
            isNotRestUser &&
            isNotBlockUser &&
            isNotViolationUser &&
            isNotStopUser &&
            isNotDeleteUser &&
            isNotDeactivateUser &&
            isNotApproachedsUser &&
            isNotStrApproachesUser &&
            isNotStrReplyApproachedsUser
        )
        return isSetUser
    }
    
    // カードユーザのフィルタリング
    func filterMethod(user: User) -> Bool {
        // ログインユーザUIDを取得
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        let currentUID = loginUser.uid
        let blocks = loginUser.blocks
        let violations = loginUser.violations
        let stops = loginUser.stops
        let deleteUsers = loginUser.deleteUsers
        let deactivateUsers = loginUser.deactivateUsers
        let approacheds = loginUser.approached
        let strApproaches = loginUser.approaches
        let strApproacheds = loginUser.approacheds
        // フィルター内容
        let isNotLoginUser = (user.uid != currentUID)
        let isActivedUser = (user.is_activated == true)
        let isNotDeletedUser = (user.is_deleted == false)
        let isNotRestUser = (user.is_rested == false)
        let isNotBlockUser = (blocks.firstIndex(of: user.uid) == nil)
        let isNotViolationUser = (violations.firstIndex(of: user.uid) == nil)
        let isNotStopUser = (stops.firstIndex(of: user.uid) == nil)
        let isNotDeleteUser = (deleteUsers.firstIndex(of: user.uid) == nil)
        let isNotDeactivateUser = (deactivateUsers.firstIndex(of: user.uid) == nil)
        let isNotApproachedUser = (approacheds.firstIndex(where: {$0.creator == user.uid}) == nil)
        let isNotApproachedsUser = (user.approacheds.contains(currentUID) == false)
        let isNotStrApproachesUser = (strApproaches.contains(user.uid) == false)
        let isNotStrApproachedsUser = (strApproacheds.contains(user.uid) == false)
        // ユーザフィルター判定
        let isSetUser = (
            isNotLoginUser &&
            isActivedUser &&
            isNotDeletedUser &&
            isNotRestUser &&
            isNotBlockUser &&
            isNotViolationUser &&
            isNotStopUser &&
            isNotDeleteUser &&
            isNotDeactivateUser &&
            isNotApproachedUser &&
            isNotApproachedsUser &&
            isNotStrApproachesUser &&
            isNotStrApproachedsUser
        )
        return isSetUser
    }
    
    func profileFilterMethod(user: User) -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        
        let minAgeFilter = loginUser.min_age_filter
        let maxAgeFilter = loginUser.max_age_filter
        let addressFilter = loginUser.address_filter
        // フィルター状態を確認
        let checkFilter = checkFilter()
        if checkFilter {
            // 年齢絞り込みを入力している場合のみ年齢Filterを適用
            let calAge = user.birth_date.calcAgeForInt()
            var isNotFiltedByAge = true
            let isMinAgeFilter = (minAgeFilter != 12)
            let isMaxAgeFilter = (maxAgeFilter != 120)
            if isMinAgeFilter || isMaxAgeFilter {
                let isLessAge = (minAgeFilter <= calAge)
                let isMoreAge = (calAge <= maxAgeFilter)
                isNotFiltedByAge = ((isLessAge && isMoreAge) == true)
            }
            // 場所絞り込みを入力している場合のみ場所Filterを適用
            var isNotFiltedByAddress = true
            let isAddressFilter = (addressFilter.count != 0)
            if isAddressFilter {
                isNotFiltedByAddress = (addressFilter.firstIndex(where: { $0 == user.address }) != nil)
            }
            let isSetUser = (isNotFiltedByAge && isNotFiltedByAddress)
            return isSetUser
            
        } else {
            
            return true
        }
    }
    
    // カードユーザのソート
    func sortMethod(users: [User]) -> [User] {
        // 全てのユーザ
        var allUser = [User]()
        // ログインユーザの趣味を取得
        let ownHobbies = GlobalVar.shared.loginUser?.hobbies ?? [String]()
        // オンラインユーザを取得
        var onlineUsers = users.filter({ $0.is_logined == true })
        // オンラインユーザを趣味一致順に並べ替える
        onlineUsers = onlineUsers.sorted(by: {
            // ログインユーザとターゲットユーザの興味タグ一致率を計算
            let card1HobbyMatchingPercentage = hobbyMatchingRate(ownHobbyList: ownHobbies, targetHobbyList: $0.hobbies)
            let card2HobbyMatchingPercentage = hobbyMatchingRate(ownHobbyList: ownHobbies, targetHobbyList: $1.hobbies)
            return card1HobbyMatchingPercentage > card2HobbyMatchingPercentage
        })
        // オンラインユーザをログアウト順に並べ替える (最新ログイン状態のものから取得)
        onlineUsers = onlineUsers.sorted(by: {
            let card1Date = $0.logouted_at.dateValue()
            let card2Date = $1.logouted_at.dateValue()
            return card1Date > card2Date
        })
        // オフラインユーザを取得
        var offlineUsers = users.filter({ $0.is_logined == false })
        // ログアウトしてから4日以内のユーザを取得
        var offlineIn3DaysUsers = offlineUsers.filter({
            let now = Date()
            let logoutTime = $0.logouted_at.dateValue()
            let span = now.timeIntervalSince(logoutTime)
            let daySpan = Int(floor(span/60/60/24))
            let isOfflineIn3DaysUser = (daySpan < 5)
            return isOfflineIn3DaysUser
        })
        // ログアウトしてから4日以内のユーザを趣味一致順に並べ替える
        offlineIn3DaysUsers = offlineIn3DaysUsers.sorted(by: {
            // ログインユーザとターゲットユーザの興味タグ一致率を計算
            let card1HobbyMatchingPercentage = hobbyMatchingRate(ownHobbyList: ownHobbies, targetHobbyList: $0.hobbies)
            let card2HobbyMatchingPercentage = hobbyMatchingRate(ownHobbyList: ownHobbies, targetHobbyList: $1.hobbies)
            return card1HobbyMatchingPercentage > card2HobbyMatchingPercentage
        })
        // ログアウト順に並べ替える (最新ログイン状態のものから取得)
        offlineIn3DaysUsers = offlineIn3DaysUsers.sorted(by: {
            return $0.logouted_at.dateValue() > $1.logouted_at.dateValue()
        })
        // ログアウトしてから5日以上のユーザを取得
        var offlineOver3DaysUsers = offlineUsers.filter({
            let now = Date()
            let logoutTime = $0.logouted_at.dateValue()
            let span = now.timeIntervalSince(logoutTime)
            let daySpan = Int(floor(span/60/60/24))
            let isOfflineOver3DaysUser = (daySpan > 4)
            return isOfflineOver3DaysUser
        })
        // ログアウト順に並べ替える (最新ログイン状態のものから取得)
        offlineOver3DaysUsers = offlineOver3DaysUsers.sorted(by: {
            return $0.logouted_at.dateValue() > $1.logouted_at.dateValue()
        })
        // ソートしたユーザをマージ
        offlineUsers = offlineIn3DaysUsers + offlineOver3DaysUsers
        // 全てのユーザ
        allUser = onlineUsers + offlineUsers
        
        return allUser
    }
    
    // 興味タグの一致率を算出
    func hobbyMatchingRate(ownHobbyList: [String], targetHobbyList: [String]) -> Double {
        let ownHobbiesCount = ownHobbyList.count
        let targetHobbyListFilter = targetHobbyList.filter({ ownHobbyList.contains($0) })
        let targetHobbyListFilterCount = targetHobbyListFilter.count
        let hobbyMatchingRate = Double(targetHobbyListFilterCount) / Double(ownHobbiesCount)
        return hobbyMatchingRate
    }
    
    func pickUpUserSort(showUserNum: Int, users: [User]) -> [User] {
        // 全てのユーザ
        var allUser: [User] = []
        // ログインユーザのよく行く場所を取得
        let ownAddress = GlobalVar.shared.loginUser?.address ?? ""

        allUser = users.filter({ $0.address == ownAddress })
        
        allUser = allUser.sorted(by: {
            let user1Date = $0.created_at.dateValue()
            let user2Date = $1.created_at.dateValue()
            return user1Date > user2Date
        })
        
        let isOverShowUser = (allUser.count > showUserNum)
        if isOverShowUser {
            allUser = Array(allUser.safeRange(range: 0..<showUserNum))
        }
        
        return allUser
    }
    
    func priorityUserSort(users: [User], filterUsers: [User]) -> [User] {
        // 全てのユーザ
        var allUser: [User] = []
        // 重複したユーザの排除
        let duplicateFilterUsers = users.filter({
            let specificUID = $0.uid
            let checkFilterUsers = filterUsers.filter({ $0.uid == specificUID }).count
            let isNotExistFilterUsers = (checkFilterUsers == 0)
            return isNotExistFilterUsers
        })
        // よく行く場所でフィルターがついていない場合
        allUser = userByLoginStatus(users: duplicateFilterUsers)
        
        return allUser
    }
    
    func userByLoginStatus(users: [User]) -> [User] {
        // 全てのユーザ
        var allUser: [User] = []
        // オンラインユーザを取得
        var onlineUsers = users.filter({ $0.is_logined == true })
        // オンラインユーザをログアウト順に並べ替える (最新ログイン状態のものから取得)
        onlineUsers = onlineUsers.sorted(by: {
            let card1Date = $0.logouted_at.dateValue()
            let card2Date = $1.logouted_at.dateValue()
            return card1Date > card2Date
        })
        // オフラインユーザを取得
        var offlineUsers = users.filter({ $0.is_logined == false })
        // ログアウトしてから4日以内のユーザを取得
        var offlineIn3DaysUsers = offlineUsers.filter({
            let now = Date()
            let logoutTime = $0.logouted_at.dateValue()
            let span = now.timeIntervalSince(logoutTime)
            let daySpan = Int(floor(span/60/60/24))
            let isOfflineIn3DaysUser = (daySpan < 5)
            return isOfflineIn3DaysUser
        })
        // ログアウト順に並べ替える (最新ログイン状態のものから取得)
        offlineIn3DaysUsers = offlineIn3DaysUsers.sorted(by: {
            return $0.logouted_at.dateValue() > $1.logouted_at.dateValue()
        })
        // ログアウトしてから5日以上のユーザを取得
        var offlineOver3DaysUsers = offlineUsers.filter({
            let now = Date()
            let logoutTime = $0.logouted_at.dateValue()
            let span = now.timeIntervalSince(logoutTime)
            let daySpan = Int(floor(span/60/60/24))
            let isOfflineOver3DaysUser = (daySpan > 4)
            return isOfflineOver3DaysUser
        })
        // ログアウト順に並べ替える (最新ログイン状態のものから取得)
        offlineOver3DaysUsers = offlineOver3DaysUsers.sorted(by: {
            return $0.logouted_at.dateValue() > $1.logouted_at.dateValue()
        })
        // ソートしたユーザをマージ
        offlineUsers = offlineIn3DaysUsers + offlineOver3DaysUsers
        
        allUser = onlineUsers + offlineUsers
        
        return allUser
    }
    
    func checkFilter() -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        
        let defaultMinAgeFilter = 12
        let defaultMaxAgeFilter = 120
        let defaultAddressFilter = [String]()
        let defaultHobbyFilter = [String]()
        
        let minAgeFilter = loginUser.min_age_filter
        let maxAgeFilter = loginUser.max_age_filter
        let addressFilter = loginUser.address_filter
        let hobbyFilter = loginUser.hobby_filter
        
        let isMinAgeFilter = (defaultMinAgeFilter == minAgeFilter)
        let isMaxAgeFilter = (defaultMaxAgeFilter == maxAgeFilter)
        let isAddressFilter = (defaultAddressFilter == addressFilter)
        let isHobbyFilter = (defaultHobbyFilter == hobbyFilter)
        let notSetFilter = (isMinAgeFilter && isMaxAgeFilter && isAddressFilter && isHobbyFilter)
        
        if notSetFilter { return false }
        
        return true
    }
    
    func saveFilterCondition() {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        let currentUID = loginUser.uid
        
        let minAgeFilter = loginUser.min_age_filter
        let maxAgeFilter = loginUser.max_age_filter
        let addressFilter = loginUser.address_filter
        let hobbyFilter = loginUser.hobby_filter
        let updateTime = Timestamp()
        let updateData = [
            "min_age_filter": minAgeFilter,
            "max_age_filter": maxAgeFilter,
            "address_filter": addressFilter,
            "hobby_filter": hobbyFilter,
            "updated_at": updateTime
        ] as [String : Any]
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUID).updateData(updateData)
    }
    
    func checkApproachRelated(user: User) -> Bool {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return false }
        let uid = user.uid
        
        let approachs = loginUser.approaches
        let approached = loginUser.approacheds + loginUser.reply_approacheds
        let approachRelated = approachs + approached
        
        let approachRelatedContains = (approachRelated.contains(uid) == true)
        if approachRelatedContains { return true }
        
        return false
    }
    // タブバーの動的表示
    func barButtonViewRect(hidden: Bool) {

        let barButtonView = ScreenManagerViewController.barButtonView
        let selectedBar = barButtonView?.selectedBar
        
        let height = (hidden ? CGFloat(0) : CGFloat(40))
        
        let originX = barButtonView?.frame.origin.x ?? CGFloat(0)
        let originY = barButtonView?.frame.origin.y ?? CGFloat(0)
        
        let navigationHeight = navigationController?.navigationBar.frame.height ?? CGFloat(0)
        let navigationWidth = navigationController?.navigationBar.frame.width ?? CGFloat(0)
        
        let selectedBarOriginX = selectedBar?.frame.origin.x ?? CGFloat(0)
        let selectedBarOriginY = selectedBar?.frame.origin.y ?? CGFloat(0)
        let selectedBarWidth = selectedBar?.frame.width ?? CGFloat(0)
        let selectedBarHeight = selectedBar?.frame.height ?? CGFloat(0)
        
        let isHidden = barButtonView?.isHidden

        if isHidden != hidden {
            let y = (hidden ? originY : originY + navigationHeight)
            ScreenManagerViewController.barButtonView?.frame = CGRect(x: originX, y: y, width: navigationWidth, height: height)
            ScreenManagerViewController.barButtonView?.isHidden = hidden

            if let bar = selectedBar, let selectedIndex = barButtonView?.selectedIndex {
                let isSetSelectedBar = (selectedBarOriginX.isZero == false)
                if isSetSelectedBar {
                    ScreenManagerViewController.barButtonViewSelectedBar[selectedIndex] = bar.frame.origin.x
                } else { // 表示位置がおかしい時の制御
                    if let beforeSelectedBarOriginX = ScreenManagerViewController.barButtonViewSelectedBar[selectedIndex] {
                        let selectedBarFrame = CGRect(x: beforeSelectedBarOriginX, y: selectedBarOriginY, width: selectedBarWidth, height: selectedBarHeight)
                        ScreenManagerViewController.barButtonView?.selectedBar.frame = selectedBarFrame
                    }
                }
            }
            navigationController?.setNavigationBarHidden(hidden, animated: true)
        }
    }
}

/** お誘い関連の処理 **/
extension UIViewController {
    
    func autoInvitationDeleteCheck() {
        
        let ownInvitations = GlobalVar.shared.loginUser?.invitations ?? [Invitation]()
        if ownInvitations.isEmpty { return }
        
        guard let ownInvitation = ownInvitations.first else { return }
        let isDeleteAlert = (ownInvitation.is_delete_alert == 1)
        if isDeleteAlert {
            let title = "お誘いの募集が自動削除されます"
            let subTitle = "お誘いの募集が4日以上更新(編集)されていません。更新がない場合、24時間以内に募集が削除されますが、ただちに更新しますか？"
            let confirmTitle = "OK"
            dialog(title: title, subTitle: subTitle, confirmTitle: confirmTitle, completion: { [weak self] confirm in
                guard let weakSelf = self else { return }
                if confirm {
                    weakSelf.specificInvitationUpdate(invitation: ownInvitation, isDeleteAlert: 2)
                } else {
                    weakSelf.specificInvitationUpdate(invitation: ownInvitation, isDeleteAlert: 3)
                }
            })
        }
    }
    
    func specificInvitationUpdate(invitation: Invitation, isDeleteAlert: Int) {
        
        guard let invitationID = invitation.document_id else { return }
        
        let updateTime = Timestamp()
        
        var updateData = [:] as [String:Any]
        // 自動削除NG (お誘いを更新)
        if isDeleteAlert == 2 {
            updateData = [
                "is_delete_alert": isDeleteAlert,
                "updated_at": updateTime
            ]
        }
        // 自動削除OK (お誘いのステータスのみを更新)
        if isDeleteAlert == 3 {
            updateData = [
                "is_delete_alert": isDeleteAlert
            ]
        }
        
        let db = Firestore.firestore()
        db.collection("invitations").document(invitationID).updateData(updateData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                print("お誘い状態の更新に失敗しました: \(err)")
                weakSelf.alert(title: "更新失敗", message: "お誘いの更新ができませんでした。アプリを再起動して再度実行してください", actiontitle: "OK")
                return
            }
            print("お誘い状態の更新に成功しました")
            // 自動削除NG (お誘いを更新)
            if isDeleteAlert == 2 {
                weakSelf.alert(title: "更新完了", message: "お誘いを更新したため、お誘いは自動削除されません", actiontitle: "OK")
            }
            // 自動削除OK (お誘いのステータスのみを更新)
            if isDeleteAlert == 3 {
                weakSelf.alert(title: "お誘いの募集が自動削除されます", message: "お誘いは24時間以内に自動で削除されますので、削除されたのち再度募集をしてください。又は自分で削除してください", actiontitle: "OK")
            }
            
            let logEventData = [
                "is_delete_alert": isDeleteAlert
            ] as [String : Any]
            Log.event(name: "alertInvitationDelete", logEventData: logEventData)
        }
    }
    
    private func invitationDataReset() {
        
        Task {
            var invitationes = GlobalVar.shared.loginUser?.invitations ?? [Invitation]()
            invitationes = invitationes.filter({ $0.is_deleted == false })
            GlobalVar.shared.loginUser?.invitations = invitationes
            
            var originInvitationeds = GlobalVar.shared.loginUser?.invitationeds ?? [Invitation]()
            originInvitationeds = originInvitationeds.filter({ commonFilter(creatorUID: $0.creator, targetUID: nil) })
            originInvitationeds = originInvitationeds.filter({ $0.is_deleted == false })
            var invitationeds = [Invitation]()
            await originInvitationeds.asyncForEach { originInvitationed in
                let notFindInvitation = (invitationeds.firstIndex(where: { originInvitationed.document_id == $0.document_id }) == nil)
                if notFindInvitation { invitationeds.append(originInvitationed) }
            }
            invitationeds.sort{ (m1, m2) -> Bool in
                let m1Date = m1.updated_at?.dateValue() ?? Date()
                let m2Date = m2.updated_at?.dateValue() ?? Date()
                return m1Date > m2Date
            }
            GlobalVar.shared.loginUser?.invitationeds = invitationeds
            GlobalVar.shared.invitationListTableView.reloadData()
            // お誘いを統合 (自分が出したお誘い + 自分以外が出したお誘い)
            let invitationList = invitationes + invitationeds
            var invitations = [Int:Invitation]()
            for (index, _invitation) in invitationList.enumerated() {
                invitations[index] = _invitation
                if index == invitationList.count - 1 {
                    GlobalVar.shared.globalInvitationList = invitationes + invitationeds
                    GlobalVar.shared.globalInvitations = invitations
                    GlobalVar.shared.invitationListTableView.reloadData()
                    
                    filterAreaInvitation()
                }
            }
        }
    }
    // お誘いをエリアでフィルター
    func filterAreaInvitation() {
        
        var invitations = GlobalVar.shared.globalInvitations
        let invitationList = GlobalVar.shared.globalInvitationList
        let selectArea = GlobalVar.shared.invitationSelectArea
        
        // お誘い配列の初期化
        invitations = [Int:Invitation]()
        
        if selectArea.contains("全て") {
            if invitationList.isEmpty {
                GlobalVar.shared.globalFilterInvitations = invitations
                GlobalVar.shared.invitationListTableView.reloadData()
                
            } else {
                for (index, _invitation) in invitationList.enumerated() {
                    invitations[index] = _invitation
                    if _invitation.document_id == invitationList.last?.document_id {
                        GlobalVar.shared.globalFilterInvitations = invitations
                        GlobalVar.shared.invitationListTableView.reloadData()
                    }
                }
            }
            
        } else {
            let invitationFilterList = invitationList.filter({ $0.area == selectArea })
            if invitationFilterList.isEmpty {
                GlobalVar.shared.globalFilterInvitations = invitations
                GlobalVar.shared.invitationListTableView.reloadData()
                
            } else {
                for (index, _invitation) in invitationFilterList.enumerated() {
                    invitations[index] = _invitation
                    if _invitation.document_id == invitationFilterList.last?.document_id {
                        GlobalVar.shared.globalFilterInvitations = invitations
                        GlobalVar.shared.invitationListTableView.reloadData()
                    }
                }
            }
        }
    }
}

/** メッセージ関連の処理 **/
extension UIViewController {
    
    // 連続記録を取得して⌛️アイコン表示の制約に使う。ルーム一覧画面が表示される前に事前取得しておく。
    private func fetchConsectiveCount(_ room: Room, document: QueryDocumentSnapshot) async {
        guard let roomId = room.document_id else { return }
        guard let count = document["consective_count"] as? Int else { return }
        
        GlobalVar.shared.consectiveCountDictionary[roomId] = count
        GlobalVar.shared.messageListTableView.reloadData()
    }
    
//    func fetchMessageRoomInfoFromTypesense(page: Int = 1) {
//
//        guard let loginUser = GlobalVar.shared.loginUser else { return }
//
//        let typesenseClient = GlobalVar.shared.typesenseClient
//
//        let loginUID = loginUser.uid
//        let loginUserRooms = loginUser.rooms
//
//        let searchFilterBy = "members: \(loginUID) && removed_user:!= \(loginUID)"
//        let searchSortBy = "updated_at:desc"
//
//        let perPage = 200
//        let searchParams = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, perPage: perPage)
//
//        Task {
//            do {
//                let start = Date()
//
//                let (searchResult, _) = try await typesenseClient.collection(name: "rooms").documents().search(searchParams, for: RoomQuery.self)
//
//                let elapsed = Date().timeIntervalSince(start)
//                print("\n get room time : \(elapsed)")
//
//                guard let hits = searchResult?.hits else { return }
//
//                let isEmptyHits = (hits.count == 0)
//                if isEmptyHits { return }
//
////                var rooms = hits.map({ Room(roomQuery: $0) })
////                rooms = rooms.filter({
////                    let roomID = $0.document_id
////                    let isNotContain = (loginUserRooms.firstIndex(where: { $0.document_id == roomID }) == nil)
////                    return isNotContain
////                })
////                // メッセージルームの追加
////                GlobalVar.shared.loginUser?.rooms.append(room)
////                // メッセージタブの更新 (事前処理)
////                if roomID == lastDocumentID { setMessageTabBadges() }
////                // 自分以外のルーム内のユーザー情報を取得
////                room.partnerUser = try await fetchUserInfo(uid: partnerUID)
////                // ルームの重複を取得
////                if let roomIndex = GlobalVar.shared.loginUser?.rooms.firstIndex(where: { $0.document_id == roomID }), GlobalVar.shared.loginUser?.rooms[safe: roomIndex] != nil {
////                    GlobalVar.shared.loginUser?.rooms[roomIndex].partnerUser = room.partnerUser
////                }
////                // メッセージタブの更新 (ユーザ取得後、再処理)
////                if roomID == lastDocumentID { setMessageTabBadges() }
//            }
//            catch {
//                print("try TypesenseSearch エラー\(error)")
//            }
//        }
//    }
    
    // メッセージルームの監視
    private func fetchMessageListInfoFromFirestore(uid: String) {
        
        getMessageRooms()
        
        GlobalVar.shared.lastRoomDocument = nil
        
        let db = Firestore.firestore()
        let collection = db.collection("users").document(uid).collection("rooms")
        let query = collection.order(by: "updated_at", descending: true).limit(to: 30)
        
        GlobalVar.shared.messageListListener = query.addSnapshotListener { [weak self] (snapshots, err) in
            guard let weakSelf = self else { return }
            if let err = err {
                print("ルーム情報の取得失敗: \(err)")
                return
            }
            guard let documentChanges = snapshots?.documentChanges else {
                return
            }
            guard let lastDocument = documentChanges.last?.document else {
                return
            }
            print("メッセージルームドキュメント数 : \(documentChanges.count)")
            let lastDocumentID = lastDocument.documentID
            
            GlobalVar.shared.lastRoomDocument = lastDocument
            
            documentChanges.forEach({
                weakSelf.messageRoomDocumentSnapShotListener(documentChange: $0, currentUID: uid, lastDocumentID: lastDocumentID)
<<<<<<< HEAD

                let documentID = $0.document.documentID
                if documentID == lastDocumentID {
                    GlobalVar.shared.messageListTableView.reloadData()
                    GlobalVar.shared.recomMsgCollectionView.reloadData()
                }
=======
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
            })

            GlobalVar.shared.messageListTableView.reloadData()
            GlobalVar.shared.newMatchCollectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let cell = GlobalVar.shared.messageListTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? MessageListTableViewCell else {
                    return
                }
                guard let room = cell.room else {
                    return
                }
                
                if GlobalVar.shared.currentLatestRoomId == nil || GlobalVar.shared.unReadCountForCurrentLatestRoom == nil {
                    print("最新のRoomIDと未既読数をclassに保存")
                    GlobalVar.shared.currentLatestRoomId = room.document_id
                    GlobalVar.shared.unReadCountForCurrentLatestRoom = room.unreadCount
                    return
                }
                
                guard let latestUnReadCount = GlobalVar.shared.unReadCountForCurrentLatestRoom else {
                    return
                }
                
                if GlobalVar.shared.currentLatestRoomId != room.document_id || latestUnReadCount < room.unreadCount {
                    print("最新のデータが更新されたので通知鳴らす")
                    
                    let thisClassName = GlobalVar.shared.thisClassName ?? ""
                    if thisClassName == "MessageListViewController" {
                        GlobalVar.shared.currentLatestRoomId = room.document_id
                        GlobalVar.shared.unReadCountForCurrentLatestRoom = room.unreadCount
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        AudioServicesPlaySystemSound(1005)
                    }
                }
            }
        }
    }
    
    private func messageRoomDocumentSnapShotListener(documentChange: DocumentChange, currentUID: String, lastDocumentID: String) {
        if documentChange.type == .added {
            handleMessageRoomAddedDocumentChange(roomsDocumentChanges: documentChange, lastDocumentID: lastDocumentID)
        }
        if documentChange.type == .modified {
            handleMessageRoomUpdatedDocumentChange(roomsDocumentChanges: documentChange, lastDocumentID: lastDocumentID)
        }
        if documentChange.type == .removed {
            handleMessageRoomDeletedDocumentChange(roomsDocumentChanges: documentChange, lastDocumentID: lastDocumentID)
        }
    }

    // ドキュメント追加時のハンドラー
    private func handleMessageRoomAddedDocumentChange(roomsDocumentChanges: DocumentChange, lastDocumentID: String) {
        addRoom(roomDocument: roomsDocumentChanges.document, lastDocumentID: lastDocumentID)
    }
    
    func addRoom(roomDocument: QueryDocumentSnapshot, lastDocumentID: String) {
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        let uid = loginUser.uid
        let rooms = loginUser.rooms
        let room = Room(document: roomDocument)
        guard let roomID = room.document_id else { return }
        // ルームやりとりユーザが存在しない場合、これ以降の処理をさせない
        guard let partnerUID = room.members.filter({ $0 != uid }).first else { return }
        // ルームが既に追加されていた場合、これ以降の処理をさせない
        if rooms.firstIndex(where: { $0.document_id == roomID }) != nil { return }
        // ログインユーザのルームの削除ステータスを取得
        if room.removed_user.firstIndex(of: uid) != nil { return }
        
        Task {
            // メッセージ未読数を初期化
            room.unreadCount = room.unread
            // メッセージルームの追加
            GlobalVar.shared.loginUser?.rooms.append(room)
            // メッセージタブの更新 (事前処理)
            if roomID == lastDocumentID { setMessageTabBadges() }
            // 自分以外のルーム内のユーザー情報を取得
            room.partnerUser = try await fetchUserInfo(uid: partnerUID)
            // ⌛️アイコンで必要な連続記録を事前取得して保存
            await fetchConsectiveCount(room, document: roomDocument)
            // ルームの重複を取得
            if let roomIndex = GlobalVar.shared.loginUser?.rooms.firstIndex(where: { $0.document_id == roomID }), GlobalVar.shared.loginUser?.rooms[safe: roomIndex] != nil {
                GlobalVar.shared.loginUser?.rooms[roomIndex].partnerUser = room.partnerUser
            }
            // メッセージタブの更新 (ユーザ取得後、再処理)
            if roomID == lastDocumentID { setMessageTabBadges() }
        }
    }
    
    // ドキュメント更新時のハンドラ
    private func handleMessageRoomUpdatedDocumentChange(roomsDocumentChanges: DocumentChange, lastDocumentID: String) {
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        let uid = loginUser.uid
        let rooms = loginUser.rooms
        let room = Room(document: roomsDocumentChanges.document)
        guard let roomID = room.document_id else { return }
        
        Task {
            // 更新対象のRoomのIndexを取得
            if let roomIndex = rooms.firstIndex(where: { $0.document_id == roomID }), GlobalVar.shared.loginUser?.rooms[safe: roomIndex] != nil {
                // 自分以外のルーム内のユーザー情報を取得
                room.partnerUser = GlobalVar.shared.loginUser?.rooms[roomIndex].partnerUser
                // メッセージ未読数
                room.unreadCount = room.unread
                // ログインユーザのルームの削除ステータスを取得
                let removeUserRoomIndex = room.removed_user.firstIndex(of: uid)
                if removeUserRoomIndex != nil {
                    GlobalVar.shared.loginUser?.rooms.remove(at: roomIndex)
                } else {
                    GlobalVar.shared.loginUser?.rooms[roomIndex] = room
                }
            }
            // メッセージタブの更新
            if roomID == lastDocumentID { setMessageTabBadges() }
        }
    }
    
    // ドキュメント 削除時のハンドラ
    private func handleMessageRoomDeletedDocumentChange(roomsDocumentChanges: DocumentChange, lastDocumentID: String) {
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        let rooms = loginUser.rooms
        let room = Room(document: roomsDocumentChanges.document)
        if let roomIndex = rooms.firstIndex(where: { $0.document_id == room.document_id }), GlobalVar.shared.loginUser?.rooms[safe: roomIndex] != nil {
            GlobalVar.shared.loginUser?.rooms.remove(at: roomIndex)
        }
        // メッセージタブの更新
        let roomDocumentID = room.document_id
        if roomDocumentID == lastDocumentID { setMessageTabBadges() }
    }
    
    func messageRoomStatusUpdate(statusFlg: Bool, saveTextFlg: Bool = false, saveText: String = "") {
        
        guard let currentUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let roomID = GlobalVar.shared.specificRoom?.document_id else { return }
        
        let db = Firestore.firestore()
        
        var updateRoomData = ["unread_\(currentUID)": 0] as [String:Any]
        
        if statusFlg { // ルームオンライン状態の場合
            updateRoomData["is_room_opened_\(currentUID)"] = true
            updateRoomData["online_user"] = FieldValue.arrayUnion([currentUID])
        } else { // ルームオフライン状態の場合
            updateRoomData["online_user"] = FieldValue.arrayRemove([currentUID])
        }
        if saveTextFlg { // テキスト状態を保存する場合
            updateRoomData["send_message_\(currentUID)"] = saveText
        }
        
        db.collection("rooms").document(roomID).updateData(updateRoomData)
    }
    
    func showTalkGuideDisplayRanking() {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let isDisplayRankingTalkGuide = (loginUser.is_display_ranking_talkguide == true)
        if isDisplayRankingTalkGuide {
            let storyboard = UIStoryboard(name: "TalkGuideDisplayRankingView", bundle: nil)
            let viewcontroller = storyboard.instantiateViewController(withIdentifier: "TalkGuideDisplayRankingView")
            viewcontroller.transitioningDelegate = self
            viewcontroller.modalPresentationStyle = .popover
            present(viewcontroller, animated: true)
        }
    }
}

/** ルーム関連の処理 **/
extension UIViewController {
    
    private func getMessageRoomsSearchParameters() -> SearchParameters {
        
        let perPage = 50
        let searchSortBy = "updated_at:desc"
        var searchParameters = SearchParameters(q: "*", queryBy: "", sortBy: searchSortBy, perPage: perPage)
        
        guard let loginUser = GlobalVar.shared.loginUser else { return searchParameters }
        
        let loginUID = loginUser.uid
        let searchFilterBy = "members: \(loginUID)"
        
        searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, perPage: perPage)

        return searchParameters
    }
    
    private func getMessageRooms() {
        
        Task {
            do {
                // let start = Date()
                
                let searchParameters = getMessageRoomsSearchParameters()
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "rooms").documents().search(searchParameters, for: RoomQuery.self)
                // let elapsed = Date().timeIntervalSince(start)
                // print("rooms全文検索の取得時間を計測 : \(elapsed)\n")
                
                searchResultMessageRooms(searchResult: searchResult)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func searchResultMessageRooms(searchResult: SearchResult<RoomQuery>?) {
        
        guard let hits = searchResult?.hits else { setMessageRooms(); return }
        
        let isEmptyHits = (hits.count == 0)
        if isEmptyHits { setMessageRooms(); return }

        let messageRooms = hits.map({ Room(roomQuery: $0) })
        
        let loginUID = GlobalVar.shared.loginUser?.uid ?? ""
        
        let filterMessageRooms = messageRooms.filter({
            let messageRoom = $0
            let containRemovedUser = (messageRoom.removed_user.firstIndex(of: loginUID) == nil)
            return containRemovedUser
        })
        
//        filterMessageRooms.forEach({
//            let roomID = $0.document_id ?? ""
//            let sendMessage = $0.send_message ?? ""
//            let isRoomOpened = $0.is_room_opened
//            let unread = $0.unread
//            let updatedAt = $0.updated_at
//            print(
//                "messageRoom : \(roomID),",
//                "send_message : \(sendMessage),",
//                "is_room_opened : \(isRoomOpened),",
//                "unread : \(unread),",
//                "updatedAt : \(updatedAt.dateValue())"
//            )
//        })
//
//        print(
//            "ルーム取得数 : \(messageRooms.count), ",
//            "フィルター ルーム取得数 : \(filterMessageRooms.count)"
//        )
        
        let roomPartnerUsers = filterMessageRooms.map({ $0.members.filter({ $0 != loginUID }).first ?? "" }).filter({ $0 != "" })
        getUsers(partnerUsers: roomPartnerUsers, rooms: filterMessageRooms)
    }
    
    private func getUsers(partnerUsers: [String], rooms: [Room]) {
        
        Task {
            do {
                let perPage = 50
                let searchFilterBy = "uid: \(partnerUsers)"
                let searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, perPage: perPage)
                
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParameters, for: CardUserQuery.self)
                
                guard let hits = searchResult?.hits else { return }
                
                let isEmptyHits = (hits.count == 0)
                if isEmptyHits { return }
                    
                let users = hits.map({ User(cardUserQuery: $0) })
                
                let partnerUserRooms = rooms.map({
                    let room = $0
                    if let partnerUser = users.filter({ room.members.firstIndex(of: $0.uid) != nil }).first {
                        room.partnerUser = partnerUser
                    }
                    return room
                })
                setMessageRooms(rooms: partnerUserRooms)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func setMessageRooms(rooms: [Room] = []) {
        
        let globalRooms = GlobalVar.shared.loginUser?.rooms ?? [Room]()

        let updateGlobalRooms = globalRooms.map({
            let globalRoom = $0
            if let room = rooms.filter({ $0.document_id == globalRoom.document_id }).first { return room }
            return globalRoom
        })
        let duplicateRooms = rooms.filter({
            let specificID = $0.document_id
            let checkFilterRooms = (updateGlobalRooms.firstIndex(where: { $0.document_id == specificID }) == nil)
            return checkFilterRooms
        })
        let mergeRooms = updateGlobalRooms + duplicateRooms
        
        GlobalVar.shared.loginUser?.rooms = mergeRooms
        
        // print("setMessageRooms ルーム数 : \(globalRoomNum), マージ後 : \(mergeRoomNum)")
        
        setMessageTabBadges()
    }
}

/** 特定のメッセージルーム関連の処理 **/
extension UIViewController {
    
    func isHiddenTalkView(room: Room, initFlg: Bool = false) -> Bool {
        guard let partnerUser = room.partnerUser else { return false }
        let partnerUID = partnerUser.uid
        
        if initFlg { GlobalVar.shared.talkView.isHidden = false }
        
        let loginUser = GlobalVar.shared.loginUser
        let blocks = loginUser?.blocks ?? [String]()
        let violations = loginUser?.violations ?? [String]()
        let stops = loginUser?.stops ?? [String]()
        let deleteUsers = loginUser?.deleteUsers ?? [String]()
        // メッセージやりとりしているユーザがブロック・違反報告・一発停止・退会されている場合
        let isBlockUser = (blocks.firstIndex(of: partnerUID) != nil)
        let isViolationUser = (violations.firstIndex(of: partnerUID) != nil)
        let isStopUser = (stops.firstIndex(of: partnerUID) != nil)
        let isDeleteUser = (deleteUsers.firstIndex(of: partnerUID) != nil)
        let isNotActivatedForPartner = (partnerUser.is_activated == false)
        let isDeletedForPartner = (partnerUser.is_deleted == true)
        let isHiddenTalkView = (
            isBlockUser || isViolationUser ||
            isStopUser || isDeleteUser ||
            isNotActivatedForPartner || isDeletedForPartner
        )
        if isHiddenTalkView { return true }
        
        return false
    }
    
    private func messageRoomHeaderAndFooterCustom() {
        if let specificRoom = GlobalVar.shared.specificRoom, let messageInputView = GlobalVar.shared.messageInputView {
            let isSetMessageInputView = setMessageInputBar(room: specificRoom, messageInputView: messageInputView)
            if isSetMessageInputView == false {
                messageRoomCustom(room: specificRoom, limitIconEnabled: false, consectiveCount: nil)
            }
        }
    }
    
    private func roomHeaderAndFooterCustom() {
        if let specificRoom = GlobalVar.shared.specificRoom, checkRoomActive(room: specificRoom) == false {
            messageRoomCustom(room: specificRoom, limitIconEnabled: false, consectiveCount: nil)
            GlobalVar.shared.talkView.isHidden = true
        }
    }
    
    func checkRoomActive(room: Room?) -> Bool {
        guard let partnerUser = room?.partnerUser else { return false }
        let partnerUID = partnerUser.uid
        // メッセージやりとりしているユーザがブロック・違反報告・一発停止されている場合
        let loginUser = GlobalVar.shared.loginUser
        let blocks = loginUser?.blocks ?? [String]()
        let violations = loginUser?.violations ?? [String]()
        let stops = loginUser?.stops ?? [String]()
        let isBlockUser = (blocks.firstIndex(of: partnerUID) != nil)
        let isViolationUser = (violations.firstIndex(of: partnerUID) != nil)
        let isStopUser = (stops.firstIndex(of: partnerUID) != nil)
        let isNotActivatedForPartner = (partnerUser.is_activated == false)
        let isNotActivated = (isBlockUser || isViolationUser || isStopUser || isNotActivatedForPartner)
        if isNotActivated { return false }

        let deleteUsers = loginUser?.deleteUsers ?? [String]()
        let isDeleteUser = (deleteUsers.firstIndex(of: partnerUID) != nil)
        let isDeletedForPartner = (partnerUser.is_deleted == true)
        let isDeleted = (isDeleteUser || isDeletedForPartner)
        if isDeleted { return false }

        return true
    }
    
    func talkGuideStatus() -> Bool {
        
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return false }
        guard let room = GlobalVar.shared.specificRoom else { return false }
        
        let topicReplyReceived = room.topic_reply_received
        let isTopicReplyReceived = (topicReplyReceived.contains(loginUID) == true)
        
        let topicReplyReceivedRead = room.topic_reply_received_read
        let isTopicReplyReceivedUnread = (topicReplyReceivedRead.contains(loginUID) == false)
        
        let unreadTopicReplyReceived = (isTopicReplyReceived && isTopicReplyReceivedUnread)
        
        let leaveMessageReceived = room.leave_message_received
        let isLeaveMessageReceived = (leaveMessageReceived.contains(loginUID) == true)
        
        let leaveMessageReceivedRead = room.leave_message_received_read
        let isLeaveMessageReceivedUnread = (leaveMessageReceivedRead.contains(loginUID) == false)
        
        let unreadLeaveReplyReceived = (isLeaveMessageReceived && isLeaveMessageReceivedUnread)
        
        if unreadTopicReplyReceived || unreadLeaveReplyReceived {
            return true
        }
        return false
    }
}

/** タイムライン関連の処理 **/
extension UIViewController {
    // タイムラインの監視
    func fetchBoardInfoFromFirestore(uid: String) {
        // print("タイムラインリスト監視リスナーのアタッチ")
        let db = Firestore.firestore()
        GlobalVar.shared.boardListener = db.collection("boards").order(by: "created_at", descending: true).limit(to: 1).addSnapshotListener { [weak self] (querySnapshot, err) in
            if let err = err { print("タイムライン情報の取得失敗: \(err)"); return }
            guard let documentChanges = querySnapshot?.documentChanges else { return }
            print("タイムラインドキュメント数 : \(documentChanges.count)")
            documentChanges.forEach({
                let board = Board(document: $0.document)
                self?.setBoardTabBadges(board: board)
                
                // print("globalBoards : \(GlobalVar.shared.globalBoardList)")
            })
        }
    }

    private func setBoardTabBadges(board: Board) {

        let globalBoards = GlobalVar.shared.globalBoardList
        
        if globalBoards.isEmpty {

            if let logoutedAt = GlobalVar.shared.loginUser?.logouted_at {

                let logoutedAtDate = logoutedAt.dateValue()
                let boardCreatedAtDate = board.created_at.dateValue()

                if logoutedAtDate < boardCreatedAtDate {
                    GlobalVar.shared.tabBarVC?.tabBar.items?[3].badgeValue = ""
                } else {
                    GlobalVar.shared.tabBarVC?.tabBar.items?[3].badgeValue = nil
                }

            } else {
                GlobalVar.shared.tabBarVC?.tabBar.items?[3].badgeValue = nil
            }

        } else {

            let index = globalBoards.firstIndex(where: { $0.document_id == board.document_id })
            if index == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    GlobalVar.shared.tabBarVC?.tabBar.items?[3].badgeValue = ""
                 }
            } else {
                GlobalVar.shared.tabBarVC?.tabBar.items?[3].badgeValue = nil
            }
        }
    }
}

/** 足あと関連の処理 **/
extension UIViewController {
    // 足あとの監視
    func fetchVisitorInfoFromFirestore(uid: String) {
        // print("足あとリスト監視リスナーのアタッチ")
        
        getVisitors()
        
        let nowDay = Date()
        let nowModifiedDate = Calendar.current.date(byAdding: .day, value: -4, to: nowDay) ?? nowDay

        let db = Firestore.firestore()
        GlobalVar.shared.visitorListener = db.collection("users").document(uid).collection("visitors").whereField("updated_at", isGreaterThanOrEqualTo: nowModifiedDate).addSnapshotListener { [weak self] (querySnapshot, err) in
            guard let weakSelf = self else { return }
            if let err = err { print("足あと情報の取得失敗: \(err)"); return }
            guard let documentChanges = querySnapshot?.documentChanges else { return }
            guard let lastDocumentID = documentChanges.last?.document.documentID else { return }
            print("足あとドキュメント数 : \(documentChanges.count)")
            documentChanges.forEach({

                weakSelf.visitorDocumentSnapShotListener(documentChange: $0, currentUID: uid, lastDocumentID: lastDocumentID)

                let documentID = $0.document.documentID
                if documentID == lastDocumentID {
                    GlobalVar.shared.visitorTableView.reloadData()
                }
            })
        }
    }
    
    private func visitorDocumentSnapShotListener(documentChange: DocumentChange, currentUID: String, lastDocumentID: String) {
        if documentChange.type == .added {
            handleVisitorAddedDocumentChange(visitorsDocumentChanges: documentChange, lastDocumentID: lastDocumentID)
        }
        if documentChange.type == .modified {
            handleVisitorUpdatedDocumentChange(visitorsDocumentChanges: documentChange, lastDocumentID: lastDocumentID)
        }
        if documentChange.type == .removed {
            handleVisitorDeletedDocumentChange(visitorsDocumentChanges: documentChange, lastDocumentID: lastDocumentID)
        }
    }

    // ドキュメント追加時のハンドラー
    private func handleVisitorAddedDocumentChange(visitorsDocumentChanges: DocumentChange, lastDocumentID: String) {
       
        guard let loginUser = GlobalVar.shared.loginUser else { return }
       
        let visitors = loginUser.visitors
        let visitor = Visitor(document: visitorsDocumentChanges.document)
        let visitorID = visitor.document_id
        let visitorCreator = visitor.creator
        // 足あとが既に追加されていた場合、これ以降の処理をさせない
        if visitors.firstIndex(where: { $0.document_id == visitorID }) != nil { return }
        
        Task {
            // 足あとの追加
            GlobalVar.shared.loginUser?.visitors.append(visitor)
            // 足あとタブの更新 (事前処理)
            if visitorID == lastDocumentID { setVisitorTabBadges() }
            // 自分以外のルーム内のユーザー情報を取得
            visitor.userInfo = try await fetchUserInfo(uid: visitorCreator)
            // 足あと重複を取得
            if let visitorIndex = GlobalVar.shared.loginUser?.visitors.firstIndex(where: { $0.document_id == visitorID }), GlobalVar.shared.loginUser?.visitors[safe: visitorIndex] != nil {
                GlobalVar.shared.loginUser?.visitors[visitorIndex].userInfo = visitor.userInfo
            }
            // 足あとタブの更新 (ユーザ取得後、再処理)
            if visitorID == lastDocumentID { setVisitorTabBadges() }
        }
    }
    
    // ドキュメント更新時のハンドラ
    private func handleVisitorUpdatedDocumentChange(visitorsDocumentChanges: DocumentChange, lastDocumentID: String) {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let visitors = loginUser.visitors
        let visitor = Visitor(document: visitorsDocumentChanges.document)
        let visitorID = visitor.document_id
        
        Task {
            // 更新対象のVisitorのIndexを取得
            if let visitorIndex = visitors.firstIndex(where: { $0.document_id == visitorID }), GlobalVar.shared.loginUser?.visitors[safe: visitorIndex] != nil {
                // 自分以外の足あと内のユーザー情報を取得
                visitor.userInfo = GlobalVar.shared.loginUser?.visitors[visitorIndex].userInfo
                // 自分の足あと更新
                GlobalVar.shared.loginUser?.visitors[visitorIndex] = visitor
            }
            // メッセージタブの更新
            if visitorID == lastDocumentID { setVisitorTabBadges() }
        }
    }
    
    // ドキュメント 削除時のハンドラ
    private func handleVisitorDeletedDocumentChange(visitorsDocumentChanges: DocumentChange, lastDocumentID: String) {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let visitors = loginUser.visitors
        let visitor = Visitor(document: visitorsDocumentChanges.document)
        let visitorID = visitor.document_id
        
        if let visitorIndex = visitors.firstIndex(where: { $0.document_id == visitorID }), GlobalVar.shared.loginUser?.visitors[safe: visitorIndex] != nil {
            GlobalVar.shared.loginUser?.visitors.remove(at: visitorIndex)
        }
        // 足あとタブの更新
        if visitorID == lastDocumentID { setVisitorTabBadges() }
    }
    
    private func getInvitationsSearchParameters() -> SearchParameters {
        
        let perPage = 50
        let searchSortBy = "updated_at:desc"
        var searchParameters = SearchParameters(q: "*", queryBy: "", sortBy: searchSortBy, perPage: perPage)
        
        guard let loginUser = GlobalVar.shared.loginUser else { return searchParameters }
        
        let loginUID = loginUser.uid
        
        let nowDate = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -4, to: nowDate) ?? nowDate
        let unixtime: Int = Int(modifiedDate.timeIntervalSince1970)
        
        let searchFilterBy = "target: \(loginUID) && updated_at:>= \(unixtime)"
        
        searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, perPage: perPage)

        return searchParameters
    }
    
    private func getVisitors() {
        
        Task {
            do {
                
                let searchParameters = getInvitationsSearchParameters()
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "visitors").documents().search(searchParameters, for: VisitorQuery.self)
                
                searchResultVisitors(searchResult: searchResult)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func searchResultVisitors(searchResult: SearchResult<VisitorQuery>?) {
        
        guard let hits = searchResult?.hits else { setVisitors(); return }
        
        let isEmptyHits = (hits.count == 0)
        if isEmptyHits { setVisitors(); return }

        let visitors = hits.map({ Visitor(visitorQuery: $0) })
        let visitorCreators = visitors.map({ $0.creator })
        getVisitorCreators(visitorCreators: visitorCreators, visitors: visitors)
    }
    
    private func getVisitorCreators(visitorCreators: [String], visitors: [Visitor]) {
        
        Task {
            do {
                let perPage = 50
                let searchFilterBy = "uid: \(visitorCreators) && is_activated:= true && is_deleted:= false"
                let searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, perPage: perPage)
                
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParameters, for: CardUserQuery.self)
                
                guard let hits = searchResult?.hits else { return }
                
                let isEmptyHits = (hits.count == 0)
                if isEmptyHits { return }
                    
                let users = hits.map({ User(cardUserQuery: $0) })
                
                let visitorsWithUserInfo = visitors.map({
                    let visitor = $0
                    if let visitorCreator = users.filter({ visitor.creator == $0.uid }).first {
                        visitor.userInfo = visitorCreator
                    }
                    return visitor
                })
                setVisitors(visitors: visitorsWithUserInfo)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func setVisitors(visitors: [Visitor] = []) {
        
        let globalVisitors = GlobalVar.shared.loginUser?.visitors ?? [Visitor]()
        
        let updateGlobalVisitors = globalVisitors.map({
            let globalVisitor = $0
            if let visitor = visitors.filter({ $0.document_id == globalVisitor.document_id }).first { return visitor }
            return globalVisitor
        })
        let duplicateVisitors = visitors.filter({
            let specificID = $0.document_id
            let checkFilterVisitors = (updateGlobalVisitors.firstIndex(where: { $0.document_id == specificID }) == nil)
            return checkFilterVisitors
        })
        let mergeVisitors = updateGlobalVisitors + duplicateVisitors
        
        GlobalVar.shared.loginUser?.visitors = mergeVisitors
        
        setVisitorTabBadges()
    }
}

/** 掲示板関連の処理 **/
extension UIViewController {
    // 投稿をカテゴリでフィルター
    func boardDataReset() {
        
        var globalBoardList = GlobalVar.shared.globalBoardList
        let selectCategory = GlobalVar.shared.boardSelectCategory
        
        let specificSelectCategory = (selectCategory.contains("全て") == false)
        if specificSelectCategory {
            globalBoardList = globalBoardList.filter({ $0.category == selectCategory })
        }
        
        var adminBoardList = globalBoardList.filter({ $0.is_admin == true })
        adminBoardList.sort{ (m1, m2) -> Bool in
            let m1Date = m1.created_at.dateValue()
            let m2Date = m2.created_at.dateValue()
            return m1Date > m2Date
        }
        
        var otherBoardList = globalBoardList.filter({ $0.is_admin == false })
        otherBoardList.sort{ (m1, m2) -> Bool in
            let m1Date = m1.created_at.dateValue()
            let m2Date = m2.created_at.dateValue()
            return m1Date > m2Date
        }
        
        let mergeBoardList = adminBoardList + otherBoardList
        GlobalVar.shared.boardList = mergeBoardList
        GlobalVar.shared.boardTableView.reloadData()
    }
}

// カード関連の制御
extension UIViewController {
    
    func resetHomeCard() {
        let homeVC = HomeViewController()
        // 相手からユーザ (アプローチされたユーザ)の場合
        let cardApproachedUsers = GlobalVar.shared.cardApproachedUsers
        homeVC.setCard(users: cardApproachedUsers)
    }
}

/** ユーザアクティブ関連の処理 **/
extension UIViewController {
    // ユーザアクティブ情報の監視
    func fetchUserDeactiveInfoFromFirestore(uid: String) {
        // ユーザアクティブの監視
        let db = Firestore.firestore()
        GlobalVar.shared.userDeactiveListener = db.collection("deactivated_users").order(by: "updated_at", descending: true).limit(to: 1).addSnapshotListener { [weak self] (querySnapshot, err) in
            if let err = err { print("ユーザ非アクティブ関連情報の取得失敗: \(err)"); return }
            guard let documents = querySnapshot?.documents else { return }
            let deactivatedUsers = GlobalVar.shared.loginUser?.deactivateUsers ?? [String]()
            print("非アクティブドキュメント数 : \(documents.count)")
            documents.forEach({
                let user = User(document: $0)
                print("ログインユーザID : \(uid), ユーザID : \(user.uid)")
                // 新規ユーザ非アクティブ/削除判定
                let isDeactivatedUser = (deactivatedUsers.first(where: { $0 == user.uid }) == nil)
                if isDeactivatedUser {
                    GlobalVar.shared.loginUser?.deactivateUsers.append(user.uid)
                    // ログインユーザ非アクティブ/削除判定
                    let isLoginUser = (uid == user.uid)
                    if isLoginUser {
                        self?.checkActiveConditionsUser(user: user)
                    }
                }
            })
            // 削除したユーザのフィルター
            self?.userDeactivateFilter()
        }
    }
    
    // ユーザ強制非アクティブ情報の監視
    func fetchUserForceDeactiveInfoFromFirestore(uid: String) {
        // ユーザ強制非アクティブの監視
        let db = Firestore.firestore()
        let deactiveUserRef = db.collection("users").whereField("uid", isEqualTo: uid).whereField("is_activated", isEqualTo: false)
        GlobalVar.shared.userForceDeactiveListener = deactiveUserRef.addSnapshotListener { [weak self] (querySnapshot, err) in
            if let err = err { print("ログインユーザ非アクティブ関連情報の取得失敗: \(err)"); return }
            guard let documents = querySnapshot?.documents else { return }
            let deactivatedUsers = GlobalVar.shared.loginUser?.deactivateUsers ?? [String]()
            print("ログインユーザ非アクティブドキュメント数 : \(documents.count)")
            documents.forEach({
                let user = User(document: $0)
                print("ログインユーザID : \(uid), ユーザID : \(user.uid)")
                // 新規ユーザ非アクティブ/削除判定
                let isDeactivatedUser = (deactivatedUsers.first(where: { $0 == user.uid }) == nil)
                if isDeactivatedUser {
                    GlobalVar.shared.loginUser?.deactivateUsers.append(user.uid)
                    // ログインユーザ非アクティブ/削除判定
                    let isLoginUser = (uid == user.uid)
                    if isLoginUser {
                        self?.checkActiveConditionsUser(user: user)
                    }
                }
            })
            // 削除したユーザのフィルター
            self?.userDeactivateFilter()
        }
    }
    
    private func checkActiveConditionsUser(user: User) {
        // ログインユーザの非アクティブ
        let isNotActivated = (user.is_activated == false)
        if isNotActivated { userDeactivateAction(); return }
        // ログインユーザの削除
        let isDeleted = (user.is_deleted == true)
        if isDeleted { logoutAction(); return }
    }
    
    private func userDeactivateAction() {
        let storyboard = UIStoryboard(name: "StoppedView", bundle: nil)
        let stoppedVC = storyboard.instantiateViewController(withIdentifier: "StoppedView") as! StoppedViewController
        stoppedVC.modalPresentationStyle = .fullScreen
        present(stoppedVC, animated: true)
        // 全てを初期化
        removeListener(initFlg: false)
    }
    
    private func userDeactivateFilter() {
        let deactivateUsers = GlobalVar.shared.loginUser?.deactivateUsers ?? [String]()
        reloadGlobalData(users: deactivateUsers)
    }
}

/** ブロック関連の処理 **/
extension UIViewController {
    // ブロック情報の監視
    func fetchBlockInfoFromFirestore(uid: String) {
        let db = Firestore.firestore()
        
        // ブロック情報の監視
        let collection = db.collection("users").document(uid).collection("blocks")
        GlobalVar.shared.blockListener = collection.addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("ブロックされた情報の取得失敗: \(err)")
                return
            }
            
            guard let documentChanges = querySnapshot?.documentChanges else {
                return
            }
            print("ブロックドキュメント数 : \(documentChanges.count)")
            documentChanges.forEach { documentChange in
                self.blockDocumentSnapShotListener(documentChange: documentChange, currentUID: uid)
                
                guard let documentLastID = documentChanges.last?.document.documentID else {
                    return
                }
                let documentChangeID = documentChange.document.documentID
                
                if documentLastID == documentChangeID {
                    self.blockUserFilter()
                }
            }
            
        }
    }
    
    private func blockDocumentSnapShotListener(documentChange: DocumentChange, currentUID: String) {
        if documentChange.type == .added {
            handleBlockAddedDocumentChange(blocksDocumentChanges: documentChange, uid: currentUID)
        }
        if documentChange.type == .modified {
            print("管理者ブロック情報確認済み")
        }
        if documentChange.type == .removed {
            print("ブロックを削除する")
        }
    }
    
    // ドキュメント追加時のハンドラー
    private func handleBlockAddedDocumentChange(blocksDocumentChanges: DocumentChange, uid: String) {
        // ユーザのブロック状態を取得
        let block = Block(document: blocksDocumentChanges.document)

        guard let creatorUID = block.creator else { return }
        guard let targetUID = block.target else { return }
        
        if targetUID == uid {
            // ユーザがブロックリストに追加されていない場合
            if GlobalVar.shared.loginUser?.blocks.firstIndex(of: creatorUID) == nil {
                // 自分をブロックしたユーザを配列に登録
                GlobalVar.shared.loginUser?.blocks.append(creatorUID)
            }
        } else if creatorUID == uid {
            // ユーザがブロックリストに追加されていない場合
            if GlobalVar.shared.loginUser?.blocks.firstIndex(of: targetUID) == nil {
                // 自分がブロックしたユーザを配列に登録
                GlobalVar.shared.loginUser?.blocks.append(targetUID)
            }
        }
    }

    // ブロックユーザのフィルター
    private func blockUserFilter() {
        let blocks = GlobalVar.shared.loginUser?.blocks ?? [String]()
        reloadGlobalData(users: blocks)
    }
}

/** 違反報告関連の処理 **/
extension UIViewController {
    // 違反報告情報の監視
    func fetchViolationInfoFromFirestore(uid: String) {
        let db = Firestore.firestore()
        // 違反報告したユーザの監視
        // print("違反報告監視リスナーのアタッチ")
        GlobalVar.shared.violationListener = db.collection("users").document(uid).collection("violations").addSnapshotListener { [weak self] (querySnapshot, err) in
            guard let weakSelf = self else { return }
            if let err = err { print("違反報告情報の取得失敗: \(err)"); return }
            guard let documentChanges = querySnapshot?.documentChanges else { return }
            print("違反報告ドキュメント数 : \(documentChanges.count)")
            documentChanges.forEach({
                weakSelf.violationDocumentSnapShotListener(documentChange: $0, currentUID: uid)
                
                guard let documentLastID = querySnapshot?.documentChanges.last?.document.documentID else { return }
                let documentChangeID = $0.document.documentID
                if documentLastID == documentChangeID {
                    weakSelf.violationUserFilter()
                }
            })
        }
    }
    
    private func violationDocumentSnapShotListener(documentChange: DocumentChange, currentUID: String) {
        if documentChange.type == .added {
            handleViolationAddedDocumentChange(violationsDocumentChanges: documentChange, uid: currentUID)
        }
        if documentChange.type == .modified {
            print("違反報告の監視OK")
        }
        if documentChange.type == .removed {
            print("違反報告を削除する")
        }
    }
    
    // ドキュメント追加時のハンドラー
    private func handleViolationAddedDocumentChange(violationsDocumentChanges: DocumentChange, uid: String) {
        // ユーザの違反報告状態を取得
        let violation = Violation(document: violationsDocumentChanges.document)

        guard let creatorUID = violation.creator else { return }
        guard let targetUID = violation.target else { return }
        
        if targetUID == uid {
            // ユーザが違反報告リストに追加されていない場合
            if GlobalVar.shared.loginUser?.violations.firstIndex(of: creatorUID) == nil {
                // 自分を違反報告したユーザを配列に登録
                GlobalVar.shared.loginUser?.violations.append(creatorUID)
            }
        } else if creatorUID == uid {
            // ユーザが違反報告リストに追加されていない場合
            if GlobalVar.shared.loginUser?.violations.firstIndex(of: targetUID) == nil {
                // 自分が違反報告したユーザを配列に登録
                GlobalVar.shared.loginUser?.violations.append(targetUID)
            }
        }
    }
    
    // 違反報告ユーザのフィルター
    private func violationUserFilter() {
        let violations = GlobalVar.shared.loginUser?.violations ?? [String]()
        reloadGlobalData(users: violations, boardFilter: false)
    }
}

/** 一発停止関連の処理 **/
extension UIViewController {
    // 一発停止情報の監視
    func fetchStopInfoFromFirestore(uid: String) {
        let db = Firestore.firestore()
        // 一発停止したユーザの監視
        // print("一発停止監視リスナーのアタッチ")
        GlobalVar.shared.stopListener = db.collection("users").document(uid).collection("stops").addSnapshotListener { [weak self] (querySnapshot, err) in
            guard let weakSelf = self else { return }
            if let err = err { print("一発停止した情報の取得失敗: \(err)"); return }
            guard let documentChanges = querySnapshot?.documentChanges else { return }
            print("一発停止ドキュメント数 : \(documentChanges.count)")
            documentChanges.forEach({
                weakSelf.stopDocumentSnapShotListener(documentChange: $0, currentUID: uid)
                
                guard let documentLastID = querySnapshot?.documentChanges.last?.document.documentID else { return }
                let documentChangeID = $0.document.documentID
                if documentLastID == documentChangeID {
                    weakSelf.stopUserFilter()
                }
            })
        }
    }
    
    private func stopDocumentSnapShotListener(documentChange: DocumentChange, currentUID: String) {
        if documentChange.type == .added {
            handleStopAddedDocumentChange(stopsDocumentChanges: documentChange, uid: currentUID)
        }
        if documentChange.type == .modified {
            print("一発停止の監視OK")
        }
        if documentChange.type == .removed {
            print("一発停止を削除する")
        }
    }
    
    // ドキュメント追加時のハンドラー
    private func handleStopAddedDocumentChange(stopsDocumentChanges: DocumentChange, uid: String) {
        // 一発停止状態を取得
        let stop = Stop(document: stopsDocumentChanges.document)

        guard let creatorUID = stop.creator else { return }
        guard let targetUID = stop.target else { return }
        
        if targetUID == uid {
            // ユーザが一発停止リストに追加されていない場合
            if GlobalVar.shared.loginUser?.stops.firstIndex(of: creatorUID) == nil {
                // 自分を一発停止したユーザを配列に登録
                GlobalVar.shared.loginUser?.stops.append(creatorUID)
            }
        } else if creatorUID == uid {
            // ユーザが一発停止リストに追加されていない場合
            if GlobalVar.shared.loginUser?.stops.firstIndex(of: targetUID) == nil {
                // 自分が一発停止したユーザを配列に登録
                GlobalVar.shared.loginUser?.stops.append(targetUID)
            }
        }
    }
    
    // 一発停止したユーザのフィルター
    private func stopUserFilter() {
        let stops = GlobalVar.shared.loginUser?.stops ?? [String]()
        reloadGlobalData(users: stops)
    }
}

/** 削除ユーザ関連の処理 **/
extension UIViewController {
    // 削除ユーザ情報の監視
    func fetchDeleteUserInfoFromFirestore(uid: String) {
//        let db = Firestore.firestore()
//        // 削除ユーザの監視
//        // print("削除したユーザ監視リスナーのアタッチ")
//        GlobalVar.shared.deleteUserListener = db.collection("delete_users").addSnapshotListener { [weak self] (querySnapshot, err) in
//            guard let weakSelf = self else { return }
//            if let err = err { print("削除したユーザ情報の取得失敗: \(err)"); return }
//            guard let documentChanges = querySnapshot?.documentChanges else { return }
//            print("削除したユーザドキュメント数 : \(documentChanges.count)")
//            GlobalVar.shared.loginUser?.deleteUsers = documentChanges.map({
//                let deleteUser = DeleteUser(document: $0.document)
//                return deleteUser.uid ?? ""
//            })
//            // 削除したユーザのフィルター
//            weakSelf.deleteUserFilter()
//        }
    }
    
    // 削除したユーザのフィルター
    private func deleteUserFilter() {
        let deleteUsers = GlobalVar.shared.loginUser?.deleteUsers ?? [String]()
        reloadGlobalData(users: deleteUsers)
    }
    
    private func reloadGlobalData(users: [String] = [], boardFilter: Bool = true) {
        // 足あとユーザのフィルタリング
        GlobalVar.shared.loginUser?.visitors = GlobalVar.shared.loginUser?.visitors.filter({ users.firstIndex(of: $0.creator) == nil }) ?? [Visitor]()
        // お誘いしたユーザのフィルタリング
        GlobalVar.shared.loginUser?.invitationeds = GlobalVar.shared.loginUser?.invitationeds.filter({ users.firstIndex(of: $0.creator ?? "") == nil }) ?? [Invitation]()
        // 投稿のフィルタリング
        if boardFilter { GlobalVar.shared.globalBoardList = GlobalVar.shared.globalBoardList.filter({ users.firstIndex(of: $0.creator) == nil }) }
        // アプローチカードのフィルタリング
        GlobalVar.shared.searchCardRecommendUsers = GlobalVar.shared.searchCardRecommendUsers.filter({ users.firstIndex(of: $0.uid) == nil })
        GlobalVar.shared.pickupCardRecommendUsers = GlobalVar.shared.pickupCardRecommendUsers.filter({ users.firstIndex(of: $0.uid) == nil })
        GlobalVar.shared.priorityCardRecommendUsers = GlobalVar.shared.priorityCardRecommendUsers.filter({ users.firstIndex(of: $0.uid) == nil })
        // アプローチされたカードのフィルタリング
        GlobalVar.shared.cardApproachedUsers = GlobalVar.shared.cardApproachedUsers.filter({ users.firstIndex(of: $0.uid) == nil })
        // 趣味カードユーザのフィルタリング
        GlobalVar.shared.likeCardUsers = GlobalVar.shared.likeCardUsers.filter({ users.firstIndex(of: $0.uid) == nil })
        // カードリセット
        resetHomeCard()
        // テーブルをリロード
        GlobalVar.shared.messageListTableView.reloadData()
<<<<<<< HEAD
        GlobalVar.shared.recomMsgCollectionView.reloadData()
        GlobalVar.shared.messagesCollectionView.reloadData()
=======
        GlobalVar.shared.newMatchCollectionView.reloadData()
        GlobalVar.shared.visitorTableView.reloadData()
>>>>>>> e840e3341c121ef02d513bc1a63e29173b50fce8
        GlobalVar.shared.invitationListTableView.reloadData()
        GlobalVar.shared.likeCardTableView.reloadData()
        GlobalVar.shared.likeCardDetailTableView.reloadData()
        
        GlobalVar.shared.messageCollectionView?.reloadData()
        
        setApproachedTabBadges()
        setVisitorTabBadges()
        boardDataReset()
        messageRoomHeaderAndFooterCustom()
        roomHeaderAndFooterCustom()
    }
}

/** 趣味カード関連の処理 **/
extension UIViewController {
    // 趣味カード情報の監視
    func fetchHobbyCardInfoFromFirestore() {
        let db = Firestore.firestore()
        // print("趣味カード監視リスナーのアタッチ")
        GlobalVar.shared.hobbyCardListener = db.collection("hobby_cards").order(by: "created_at", descending: true).limit(to: 30).addSnapshotListener { [weak self] (querySnapshot, err) in
            guard let _ = self else { return }
            if let err = err { print("趣味カード情報の取得失敗: \(err)"); return }
            guard let documents = querySnapshot?.documents else { return }
            print("趣味カードドキュメント数 : \(documents.count)")
            documents.forEach({
                let hobbyCard = HobbyCard(document: $0)
                let hobbyCardID = hobbyCard.document_id
                let globalHobbyCards = GlobalVar.shared.globalHobbyCards
                let isNotHobbyCard = (
                    globalHobbyCards.first(where: { $0.document_id == hobbyCardID }) == nil
                )
                if isNotHobbyCard {
                    GlobalVar.shared.globalHobbyCards.append(hobbyCard)
                }
            })
        }
    }
    
    func fetchHobbyCardInfoFromTypesense(page: Int = 1) {
        
        let perPage = 200
        let typesenseClient = GlobalVar.shared.typesenseClient
        let searchFilterBy = "approval_flg:= true"
        let searchParams = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, page: page, perPage: perPage)
        
        if page == 1 { GlobalVar.shared.globalHobbyCards = [] }
        
        Task {
            do {
                let start = Date()
                
                let (searchResult, _) = try await typesenseClient.collection(name: "hobby_cards").documents().search(searchParams, for: HobbyCardQuery.self)
                
                let elapsed = Date().timeIntervalSince(start)
                print("\n趣味カードの取得完了 : \(elapsed)")
                
                guard let hits = searchResult?.hits else { return }
                
                let isEmptyHits = (hits.count == 0)
                if isEmptyHits { return }
                
                let hobbyCards = hits.map({ HobbyCard(hobbyCardQuery: $0) })
                let globalHobbyCards = GlobalVar.shared.globalHobbyCards
                
                let mergedHobbyCards = mergeHobbyCards(hobbyCards: hobbyCards, mergedHobbyCards: globalHobbyCards)
                
                if globalHobbyCards.count == mergedHobbyCards.count { return }
                
                GlobalVar.shared.globalHobbyCards = mergedHobbyCards
                
                fetchHobbyCardInfoFromTypesense(page: page + 1)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func mergeHobbyCards(hobbyCards: [HobbyCard], mergedHobbyCards: [HobbyCard]) -> [HobbyCard] {
    
        let duplicateHobbyCards = mergedHobbyCards.filter({
            let specificID = $0.id
            let checkFilterHobbyCards = hobbyCards.filter({ $0.id == specificID }).count
            let isNotExistFilterHobbyCards = (checkFilterHobbyCards == 0)
            return isNotExistFilterHobbyCards
        })
        
        let mergeHobbyCards = hobbyCards + duplicateHobbyCards
        
        return mergeHobbyCards
    }
}

extension UIViewController {
    
    func addMessage(messageData: [String:Any]) {
        
        lazy var functions = Functions.functions()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageData, options: [])
            if let jsonStr = String(bytes: jsonData, encoding: .utf8) {
                functions.httpsCallable("addMessage").call(jsonStr) { [weak self] result, error in
                    if let error = error as NSError? {
                        if error.domain == FunctionsErrorDomain {
                            let code = FunctionsErrorCode(rawValue: error.code)
                            let message = error.localizedDescription
                            let details = error.userInfo[FunctionsErrorDetailsKey]
                            print("code : \(String(describing: code)), message : \(message), details : \(String(describing: details))")
                        }
                    }
                    if let messageID = result?.data as? String, messageID != "", let sender = messageData["creator"] as? String, let members = messageData["members"] as? [String], let roomID = messageData["room_id"] as? String {
                        
                        self?.registNotificationEachUser(creator: sender, members: members, roomID: roomID, messageID: messageID)
                    }
                }
            }
            
        } catch let error {
            print(error)
        }
    }
    
    // ユーザごとに通知登録 (自分を除くメンバーに通知を登録)
    func registNotificationEachUser(creator: String, members: Array<String>, roomID: String, messageID: String) {
        // 自分を除くメンバーに通知を登録
        for member in members {
            if member != creator {
                let messageCategory = 6
                messageNotificationAction(category: messageCategory, creator: creator, notificatedUserID: member, roomID: roomID, messageID: messageID)
            }
        }
    }
    
    // 通知の登録
    func messageNotificationAction(category: Int, creator: String, notificatedUserID: String, roomID: String, messageID: String) {
        // ログインユーザが自分自身に対して通知を出そうとしている時は処理をさせない
        if creator == notificatedUserID { return }
        
        let notificationTime = Timestamp()
        let notificationData = [
            "category": category,
            "room_id": roomID,
            "message_id": messageID,
            "creator": creator,
            "read": false,
            "created_at": notificationTime,
            "updated_at": notificationTime
        ] as [String : Any]
        // 通知の追加
        let db = Firestore.firestore()
        db.collection("users").document(notificatedUserID).collection("notices").addDocument(data: notificationData)
        
        let logEventData = [
            "category": category,
            "room_id": roomID,
            "message_id": messageID,
            "target": notificatedUserID
        ] as [String : Any]
        Log.event(name: "messageNotification", logEventData: logEventData)
    }
}

extension UIViewController {
// ----- 通話機能をRoom型に変更したので一旦コメントアウト -----
//    func pushVoIPNotification(notificationData: [String:Any], onSuccess: @escaping() -> Void, onFailer: @escaping() -> Void) {
//        lazy var functions = Functions.functions()
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: notificationData, options: [])
//            if let jsonStr = String(bytes: jsonData, encoding: .utf8) {
//                functions.httpsCallable("pushVoIPNotification").call(jsonStr) { [weak self] result, error in
//                    guard let _ = self else {
//                        onFailer()
//                        return
//                    }
//
//                    if let error = error as NSError? {
//                        if error.domain == FunctionsErrorDomain {
//                            let code = FunctionsErrorCode(rawValue: error.code)
//                            let message = error.localizedDescription
//                            let details = error.userInfo[FunctionsErrorDetailsKey]
//
//                            print("Fail pushVoIPNotification.")
//                            print("Error code:", code.debugDescription)
//                            print("Error message:", message)
//                            print("details:", details.debugDescription)
//                        }
//                        onFailer()
//                    } else {
//                         if let resultReturn = result?.data as? String, resultReturn.isEmpty == false {
//                            onSuccess()
//                         } else {
//                            onFailer()
//                        }
//                    }
//                    }
//                }
//            } else {
//                onFailer()
//            }
//        } catch let error {
//            print("Fail pushVoIPNotification:", error)
//            onFailer()
//        }
//    }
  
    func launchFunctionsHttpsCallable(functionName: String) {
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        switch functionName {
        case "generateSkyWayAuthToken":
            let data = [:] as [String : Any]
            functionsHttpsCallable(functionName: "generateSkyWayAuthToken", data: data, completion: { result in
                print("exec generateSkyWayAuthToken : \(result)")
            })
            break
        case "pushVoIPNotification":
            // 本番環境にあげる時のみtrue, 手元でテストする時はfalse
            let production = false
            let data = [
                "nickName": loginUser.nick_name,
                "profileIconImg": loginUser.profile_icon_img,
                "deviceToken": loginUser.deviceToken,
                "skywayToken": "generateSkyWayAuthToken",
                "production": production,
                "roomName": "roomName",
            ] as [String : Any]
            functionsHttpsCallable(functionName: "pushVoIPNotification", data: data, completion: { result in
                print("exec pushVoIPNotification : \(result)")
            })
            break
        default:
            break
        }
    }
    
    func functionsHttpsCallable(functionName: String, data: [String:Any], completion: @escaping (Bool) -> Void) {
        lazy var functions = Functions.functions()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let jsonStr = String(bytes: jsonData, encoding: .utf8) {
                functions.httpsCallable(functionName).call(jsonStr) { [weak self] result, error in
                    guard let _ = self else {
                        completion(false);
                        return
                    }
                    
                    if let error = error as NSError? {
                        if error.domain == FunctionsErrorDomain {
                            let code = FunctionsErrorCode(rawValue: error.code)
                            let message = error.localizedDescription
                            let details = error.userInfo[FunctionsErrorDetailsKey]
                            
                            print("Fail pushVoIPNotification.")
                            print("Error code:", code.debugDescription)
                            print("Error message:", message)
                            print("details:", details.debugDescription)
                        }
                        completion(false)
                    } else {
                        if let resultReturn = result?.data as? String {
                            if resultReturn == "failed" || resultReturn == "error" {
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
                }
            }
        } catch {
            print("\(functionName) Error : \(error)")
            completion(false)
        }
    }
    
    // オーディオのチェック
    func checkPermissionAudio() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .denied:
            alertWithAction(title: "マイクの許可", message: "アプリの設定画面からマイクの使用を許可してください", actiontitle: "OK", type: "settings")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { result in
                print("getAudioPermission: \(result)")
            }
        case .restricted:
            alertWithAction(title: "マイクの制限", message: "マイクの使用が制限されています（通話することができません）", actiontitle: "OK", type: "settings")
        @unknown default:
            break
        }
    }
    
    func checkPermissionCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { result in
                print("Video permission request:", result)
            }
        case .restricted:
            alertWithAction(title: "カメラの制限", message: "カメラの使用が制限されています（通話することができません）", actiontitle: "OK", type: "settings")
        case .denied:
            alertWithAction(title: "カメラの許可", message: "アプリの設定画面からカメラの使用を許可してください", actiontitle: "OK", type: "settings")
        case .authorized:
            break
        @unknown default:
            break
        }
    }
}

extension UIViewController {
    
    func reviewAlert(alertType: String = "") {
        
        guard let userID = GlobalVar.shared.loginUser?.uid else { return }
        guard let mail = GlobalVar.shared.loginUser?.email else { return }
        
        let isInitReviewed = GlobalVar.shared.loginUser?.is_init_reviewed ?? false
        let isReviewed = GlobalVar.shared.loginUser?.is_reviewed ?? false
        
        let isNotReviewed = (isReviewed == false)

        switch alertType {
        case "message":
            let isNotInitReviewed = (isInitReviewed == false)
            let isActiveAppReviewed = (isNotInitReviewed && isNotReviewed)
            if isActiveAppReviewed {
                appReview(userID: userID, mail: mail, initReviewed: true)
            }
            break
        default:
            // あまりを考慮して割り算の分母にするのは21に設定
            let launchedTimes = UserDefaults.standard.integer(forKey: "launchedTimes")
            let isMultipleOfTwenty = ((launchedTimes % 21) == 0)
            let isActiveAppReviewed = (isNotReviewed && isMultipleOfTwenty)
            if isActiveAppReviewed {
                appReview(userID: userID, mail: mail)
                UserDefaults.standard.set(1, forKey: "launchedTimes")
            }
            break
        }
    }
    
    private func appReview(userID: String, mail: String, initReviewed: Bool = false) {
        
        let firebaseController = FirebaseController()
        let db = Firestore.firestore()
        
        let alert = UIAlertController(title: "Touchを気に入っていただけましたか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: .default) { [weak self] _ in
            guard let weakSelf = self else { return }
            let notSatisfiedAlert = UIAlertController(title: "意見をお聞かせください", message: "良いアプリになるよう日々改善をしています。お客様の感想をお聞かせください！", preferredStyle: .alert)
            notSatisfiedAlert.addTextField()
            notSatisfiedAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            notSatisfiedAlert.addAction(UIAlertAction(title: "送信", style: .default) { [weak self] _ in
                guard let _ = self else { return }
                let content = notSatisfiedAlert.textFields?[0].text ?? ""
                if content.isEmpty == false {
                    firebaseController.addAppReview(userID: userID, mail: mail, content: content)
                }
            })
            weakSelf.present(notSatisfiedAlert, animated: true)
        })
        alert.addAction(UIAlertAction(title: "はい！", style: .default) { [weak self] _ in
            guard let weakSelf = self else { return }
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            SKStoreReviewController.requestReview(in: scene)
            GlobalVar.shared.loginUser?.is_reviewed = true
            db.collection("users").document(userID).updateData(["is_reviewed": true])
            let logEventData = [
               "mail": mail,
               "content": "satisfied"
            ] as [String : Any]
            Log.event(name: "appReview", logEventData: logEventData)
        })
        present(alert, animated: true)
        
        if initReviewed {
            GlobalVar.shared.loginUser?.is_init_reviewed = true
            db.collection("users").document(userID).updateData(["is_init_reviewed": true])
        }
    }
}

extension UIViewController {
    
    func moveLikeCardDetail(title: String, imageURL: String) {
        
        let storyboard = UIStoryboard(name: "LikeCardDetailView", bundle: nil)
        let likeCardDetailVC = storyboard.instantiateViewController(withIdentifier: "LikeCardDetailView") as! LikeCardDetailViewController
        
        likeCardDetailVC.hobby = title
        likeCardDetailVC.hobbyImageURL = imageURL
        
        navigationController?.pushViewController(likeCardDetailVC, animated: true)
    }
}

//MARK: - Talk Guide

extension UIViewController {
    func receiveTalkGuide(uid: String, bool: Bool) {
        let db = Firestore.firestore()
        let updatedData = ["receive_talk_guide": bool]
        db.collection("users").document(uid).updateData(updatedData)
    }
}
