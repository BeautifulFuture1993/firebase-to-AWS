//
//  ScreenManagerViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/31.
//

import UIKit

class ScreenManagerViewController: ButtonBarPagerTabStripViewController {
    
    static let storyboardName = "ScreenManagerView"
    static let storyboardId = "ScreenManagerView"
    
    static var filterBarButtonItem = UIBarButtonItem()
    static var searchBarButtonItem = UIBarButtonItem()
    
    static var barButtonView: ButtonBarView?
    static var barButtonViewSelectedBar: [Int:CGFloat] = [:]
    //MARK: - Lifecycle

    override func viewDidLoad() {
        
        configureButtonBarStyle()
        
        super.viewDidLoad()
        // 通知の設定ダイアログ表示
        userNotificationSettings()
        // アプリトラッキングダイアログ表示
        appTrackingAutorization()
        // ログインUIDを取得
        guard let currentUID = GlobalVar.shared.loginUser?.uid else { return }
        // FCM Token, DeviceTokenの更新
        tokenUpdate(uid: currentUID)
        // ログインユーザのインスタンスを生成
        authInstance(uid: currentUID, bootFlg: false)
        // ボタン設定
        setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBarBorderAndShowTabBarBorder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if PROD
        reviewAlert() // アプリを20回起動する毎にレビューアラートを表示
        #endif
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: - XLPagerTabStrip

    // XLPagerTabStrip - 管理されるViewControllerを返す処理
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let homeStoryboardName = NewHomeViewController.storyboardName
        let homeStoryboardID = NewHomeViewController.storyboardId
        let homeVC = UIStoryboard(name: homeStoryboardName, bundle: nil).instantiateViewController(withIdentifier: homeStoryboardID)
        
        let likeCardTopStoryboardInfo = getStoryboardInfo(name: "LikeCardTop")
        
        let likeCardTopStoryboardName = likeCardTopStoryboardInfo["storyboardName"] ?? ""
        let likeCardTopStoryboardID = likeCardTopStoryboardInfo["storyboardID"] ?? ""
        let likeCardTopVC = UIStoryboard(name: likeCardTopStoryboardName, bundle: nil).instantiateViewController(withIdentifier: likeCardTopStoryboardID)
        
        return [homeVC, likeCardTopVC]
    }
    
    @objc func didTapGoDetail() {
        screenTransition(storyboardName: "SettingView", storyboardID: "SettingView")
    }
    
    @objc private func didTapSearchButton() {
        screenTransition(storyboardName: "LikeCardSearchView", storyboardID: "LikeCardSearchView")
    }
}

//MARK: - Appearance

extension ScreenManagerViewController {
    
    func configureButtonBarStyle() {
        let screenWidth = UIScreen.main.bounds.width
        
        let selectedBarHeight: CGFloat = 4.0
        settings.style.buttonBarBackgroundColor = UIColor.systemBackground
        settings.style.buttonBarItemBackgroundColor = UIColor.systemBackground
        settings.style.buttonBarItemTitleColor = UIColor.lightGray
        settings.style.selectedBarBackgroundColor = UIColor.accentColor
        settings.style.selectedBarHeight = selectedBarHeight
        buttonBarView.selectedBar.layer.cornerRadius = (selectedBarHeight / 2)
        settings.style.buttonBarMinimumLineSpacing = screenWidth / 4
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarItemLeftRightMargin = 0
        settings.style.buttonBarLeftContentInset = screenWidth / 6
        settings.style.buttonBarRightContentInset = screenWidth / 6
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard let _ = self else { return }
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .lightGray
            newCell?.label.textColor = .fontColor
            
            let oldCellText = oldCell?.label.text
            let cellText: String = (oldCellText == nil || oldCellText == .homeTabLikeCard ? .homeTabSearch : .homeTabLikeCard)
            self?.customBtn(title: cellText)
        }
        
        ScreenManagerViewController.barButtonView = buttonBarView
    }
    
    private func customBtn(title: String) {
        let barButtonItem = (
            title == .homeTabSearch ? ScreenManagerViewController.filterBarButtonItem : ScreenManagerViewController.searchBarButtonItem
        )
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setNavigationBar() {
        
        navigationItem.hidesBackButton = true
        
        guard let navigation = navigationController else { return }
        // ナビゲーションタイトルを設定
        let navWidth = navigation.navigationBar.frame.width
        let navHeight = navigation.navigationBar.frame.height
        let rectX = ((view.frame.width / 2) - (navWidth / 4) - (navHeight - 6))
        let rect = CGRect(x: rectX, y: 0, width: navWidth / 2, height: navHeight)
        let homeTitleView = HomeNavigationTitleView(frame: rect)
        navigationItem.titleView = homeTitleView
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        // ナビゲーション左アイテムを設定
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: (navHeight - 6), height: (navHeight - 6)))
        DispatchQueue.main.async { iconView.setImage(withURLString: loginUser.profile_icon_img) }
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = iconView.frame.height / 2
        iconView.layer.borderWidth = 2.0
        iconView.layer.borderColor = UIColor.systemGray6.cgColor
        iconView.backgroundColor = .systemGray6
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSetting)))
        let leftBarButtonItem = UIBarButtonItem(customView: iconView)
        leftBarButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        leftBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: (navHeight - 6)).isActive = true
        leftBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: (navHeight - 6)).isActive = true
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        // ナビゲーション右アイテムを設定
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20.0))
        let filterIcon = UIImage(systemName: "slider.horizontal.3", withConfiguration: imageConfig)
        ScreenManagerViewController.filterBarButtonItem = UIBarButtonItem(image: filterIcon, style: .plain, target: self, action:#selector(didTapFilterButton))
        ScreenManagerViewController.filterBarButtonItem.tintColor = .lightGray

        let searchIcon = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfig)
        ScreenManagerViewController.searchBarButtonItem = UIBarButtonItem(image: searchIcon, style: .plain, target: self, action:#selector(didTapSearchButton))
        ScreenManagerViewController.searchBarButtonItem.tintColor = .lightGray
        
        self.navigationItem.rightBarButtonItem?.tintColor = .lightGray
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
