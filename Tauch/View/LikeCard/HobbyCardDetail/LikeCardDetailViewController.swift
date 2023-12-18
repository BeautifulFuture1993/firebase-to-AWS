//
//  DetailViewController.swift
//  LikeCardDetail
//
//  Created by adachitakehiro2 on 2023/03/08.
//

import UIKit
import FirebaseFirestore
import Typesense
import Nuke

class LikeCardDetailViewController: UIBaseViewController {
    
    @IBOutlet weak var hobbyCardDetailTableView: UITableView!
    @IBOutlet weak var regButton: UIButton!
   
    var customNavigationTitleView: CustomNavigationTitleView!
    
    var hobby = ""
    var hobbyImageURL = ""
    var selectLikeCard: Bool = true
    
    let links = GlobalVar.shared.links
    let typesenseClient = GlobalVar.shared.typesenseClient
    
    var likeCardUserPage = 1
    var likeCardUserSearchEnd = false
    
    // header関連
    private let headerView = HobbyCardDetailHeaderView()
    private var scrollStartingPosition: CGFloat? = nil
    private var navBarIsTransparent: Bool = true
    
    //MARK: - Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hobbyCardDetailTableView.register(UINib(nibName: UserInfoTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: UserInfoTableViewCell.cellIdentifier)
        hobbyCardDetailTableView.register(UINib(nibName: LastIndexTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: LastIndexTableViewCell.cellIdentifier)
        hobbyCardDetailTableView.register(UINib(nibName: LoadingTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: LoadingTableViewCell.cellIdentifier)
        
        hobbyCardDetailTableView.delegate = self
        hobbyCardDetailTableView.dataSource = self
        
        hobbyCardDetailTableView.isPrefetchingEnabled = true
        hobbyCardDetailTableView.prefetchDataSource = self
        
        hobbyCardDetailTableView.register(HobbyCardDetailHeaderView.nib, forHeaderFooterViewReuseIdentifier: HobbyCardDetailHeaderView.headerIdentifier)
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let hobbies = loginUser.hobbies
        selectLikeCard = (hobbies.contains(hobby) == true)
        
        if selectLikeCard {
            regButton.backgroundColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
            regButton.setTitle("解除する", for: .normal)
            regButton.configuration = nil
            regButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            regButton.setCustomShadow()
        } else {
            regButton.backgroundColor = .accentColor
            regButton.setTitle("登録する", for: .normal)
            regButton.configuration = nil
            regButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            regButton.setCustomShadow()
        }
        
        GlobalVar.shared.likeCardDetailTableView = hobbyCardDetailTableView
        GlobalVar.shared.likeCardUsers = []
        
        configureNavBarTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationWithBackBtnSetUp(navigationTitle: "")
        setNavBarTransparent(true)
        
        tabBarController?.tabBar.isHidden = true
        
        setLoadingFooterCustomCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 見た目上の画面遷移を速く見せるため、スコープ内の処理をサブスレッドで行う
        DispatchQueue.global(qos: .userInteractive).async { self.getCardUsers() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction

    @IBAction func didTapChangeLikeCard(_ sender: Any) {
        let type = (selectLikeCard == true ? "remove" : "regist")
        changeLikeCard(type: type)
    }
    
    // 趣味カード登録/解除
    func changeLikeCard(type: String) {
        
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        
        var hobbies = GlobalVar.shared.loginUser?.hobbies ?? [String]()
        
        showLoadingView(loadingView)
        
        let updatedTime = Timestamp()
        let hobbyData = (
            type == "regist" ?
            [
                "hobbies": FieldValue.arrayUnion([hobby]),
                "updated_at": updatedTime
            ] : [
                "hobbies": FieldValue.arrayRemove([hobby]),
                "updated_at": updatedTime
            ]
        )
        
        switch type {
        case "regist":
            hobbies.append(hobby)
            break
        case "remove":
            hobbies = hobbies.filter({ $0 != hobby })
            break
        default:
            break
        }
        
        db.collection("users").document(uid).updateData(hobbyData) { [weak self] err in
            
            self?.loadingView.removeFromSuperview()
            
            guard let weakSelf = self else { return }
            if let err = err {
                weakSelf.alert(title: "趣味カード更新エラー", message: "正常に趣味カード更新されませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
                print("Error Log : \(err)")
                return
            }
            let logEventData = [
                "hobby": weakSelf.hobby
            ] as [String : Any]
            Log.event(name: "changeLikeCard", logEventData: logEventData)
            
            GlobalVar.shared.loginUser?.hobbies = hobbies
            
            switch type {
            case "regist":
                weakSelf.regButton.backgroundColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
                weakSelf.regButton.setTitle("解除する", for: .normal)
                break
            case "remove":
                weakSelf.regButton.backgroundColor = .accentColor
                weakSelf.regButton.setTitle("登録する", for: .normal)
                break
            default:
                break
            }
            
            weakSelf.selectLikeCard.toggle()
        }
    }
}

extension LikeCardDetailViewController {
    
    func getSearchParameters(type: String = "search", page: Int = 1) -> SearchParameters {
        
        let perPage = 100
        var searchFilterBy = "is_activated:= true && is_deleted:= false"
        let searchSortBy = "is_logined:desc, logouted_at:desc, created_at:desc"
        
        var searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, page: page, perPage: perPage)
        
        guard let loginUser = GlobalVar.shared.loginUser else { return searchParameters }
        
        let loginUID = loginUser.uid
        
        searchFilterBy = searchFilterBy + " && " + "uid:!= \(loginUID)"
        
        let minAgeFilter = loginUser.min_age_filter
        let maxAgeFilter = loginUser.max_age_filter
        let ageArray = ([Int])(minAgeFilter...maxAgeFilter)
        searchFilterBy = searchFilterBy + " && " + "age: \(ageArray)"
        
        let addressFilter = loginUser.address_filter
        let isSelectedAddressFilter = (addressFilter.isEmpty == false)
        if isSelectedAddressFilter { searchFilterBy = searchFilterBy + " && " + "address: \(addressFilter)" }
        
        searchFilterBy = searchFilterBy + " && " + "hobbies: \(hobby)"
        
        searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, page: page, perPage: perPage)
        
        return searchParameters
    }
    
    func getCardUsers(page: Int = 1) {
        
        Task {
            do {
                let start = Date()
                
                let searchParameters = getSearchParameters(page: page)
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParameters, for: CardUserQuery.self)
                
                let elapsed = Date().timeIntervalSince(start)
                print("users全文検索の取得時間を計測 : \(elapsed)\n")
                
                setCardUsers(searchResult: searchResult, page: page)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    func setCardUsers(searchResult: SearchResult<CardUserQuery>?, page: Int) {
        
        guard let hits = searchResult?.hits else { setLikeCardUsers(page: page); return }
        
        let isEmptyHits = (hits.count == 0)
        if isEmptyHits { setLikeCardUsers(page: page); return }
        
        let likeCardUsers = hits.map({ User(cardUserQuery: $0) })
        
        let filterLikeCardUsers = likeCardUsers.filter({ filterMethod(user: $0) })
        
        let isEmptyLikeCardUsers = (filterLikeCardUsers.count == 0)
        if isEmptyLikeCardUsers { getCardUsers(page: page + 1); return }
        
        let sortedLikeCardUsers = sortMethod(users: filterLikeCardUsers)
        
        print(
            "趣味 : \(hobby), ",
            "カード取得数 : \(likeCardUsers.count), ",
            "フィルター カード取得数 : \(filterLikeCardUsers.count)"
        )
        
        setLikeCardUsers(cardUsers: sortedLikeCardUsers, page: page)
    }
    
    private func setLikeCardUsers(cardUsers: [User] = [], page: Int = 1) {
        
        let globalLikeCardUsers = GlobalVar.shared.likeCardUsers
        let globalCardUserNum = globalLikeCardUsers.count
        
        let mergeLikeCardUsers = mergeUsers(users: globalLikeCardUsers, mergedUsers: cardUsers)
        let mergeLikeCardUserNum = mergeLikeCardUsers.count
        
        GlobalVar.shared.likeCardUsers = mergeLikeCardUsers
        
        likeCardUserPage = page
        
        print(
            "setLikeCardUsers ",
            "カードユーザ数 : \(globalCardUserNum), ",
            "マージ後 : \(mergeLikeCardUserNum)",
            "指定されたページ : \(page)",
            "保持されていたページ : \(likeCardUserPage)"
        )
        let isEmptyCardUsers = (cardUsers.count == 0)
        if isEmptyCardUsers { showLikeCardUsers(finishLoadData: true); return }
        
        let isNotEmptyLikeCardUserNum = (globalCardUserNum != mergeLikeCardUserNum)
        if isNotEmptyLikeCardUserNum { showLikeCardUsers(); return }
        
        showLikeCardUsers(finishLoadData: true)
    }
    
    private func showLikeCardUsers(finishLoadData: Bool = false) {
        
        likeCardUserSearchEnd = finishLoadData
        
        if finishLoadData { setLoadingFooterCustomCell(setFooter: false) }
        
        GlobalVar.shared.likeCardDetailTableView.reloadData()
    }
}

extension LikeCardDetailViewController {
    
    private func setLoadingFooterCustomCell(setFooter: Bool = true) {
        
        if setFooter {
            
            let tableFooterCell = GlobalVar.shared.likeCardDetailTableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.cellIdentifier) as! LoadingTableViewCell
            tableFooterCell.startAnimation()
            
            let tableFooterView: UIView = tableFooterCell.contentView
            GlobalVar.shared.likeCardDetailTableView.tableFooterView = tableFooterView
            
        } else {
            
            let tableFooterCell = GlobalVar.shared.likeCardDetailTableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.cellIdentifier) as! LoadingTableViewCell
            tableFooterCell.endAnimation()
            
            let tableFooterView: UIView = tableFooterCell.contentView
            GlobalVar.shared.likeCardDetailTableView.tableFooterView = tableFooterView
        }
    }
    
    private func filterLikeCardUsers() {
        
        let cardRecommendFilterFlg = GlobalVar.shared.cardRecommendFilterFlg
        if cardRecommendFilterFlg == false { return }
        
        filterInitGlobalData()
        setLoadingFooterCustomCell()
        getCardUsers()
        scrollToTop()
        saveFilterCondition()
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        tabBarController?.tabBar.isHidden = true
        
        setClass(className: className)
        
        filterLikeCardUsers()
        saveFilterCondition()
        
        presentationDidDismissMoveMessageRoomAction()
    }
    
    private func scrollToTop() {
        hobbyCardDetailTableView.setContentOffset(.zero, animated: true)
        hobbyCardDetailTableView.reloadData()
    }
}

//MARK: - NavigationBar, statusBar

extension LikeCardDetailViewController {
    
    private func configureNavBarTitle() {
        // frameを計算
        let screenWidth = UIScreen.main.bounds.size.width
        guard let navHeight = navigationController?.navigationBar.frame.height else { return }
        guard let navWidht = navigationController?.navigationBar.frame.width else { return }
        let rect = CGRect(x: ((screenWidth/2) - (navWidht/4)), y: 0, width: (navWidht/2), height: navHeight)
        
        customNavigationTitleView = CustomNavigationTitleView(frame: rect)
        customNavigationTitleView.configure(title: hobby, imageURL: hobbyImageURL)
        self.navigationItem.titleView = customNavigationTitleView
        
        // タップイベントを追加
        customNavigationTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navBarTapped)))
        
        // 初期状態は透明
        customNavigationTitleView.titleLabel.alpha = 0.0
        customNavigationTitleView.iconImageView.alpha = 0.0
    }
    
    @objc
    private func navBarTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        hobbyCardDetailTableView.setContentOffset(.zero, animated: true)
        hobbyCardDetailTableView.reloadData()
    }
    
    private func setNavBarTransparent(_ isTransparent: Bool) {
        
        if isTransparent {
            /* ---- 常にNavBarは透明 ----- */
            
            // 処理を行うか判定・不要ならスキップ
            if self.navBarIsTransparent { return }
            
            // navBar
            let appearance = UINavigationBarAppearance()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            appearance.backgroundImage = nil
            appearance.backgroundEffect = nil
            appearance.backgroundColor = .clear
            navigationController?.navigationBar.barTintColor = .clear
            navigationController?.navigationBar.backgroundColor = .clear
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            // titleViewの要素
            customNavigationTitleView.titleLabel.alpha = 0.0
            customNavigationTitleView.iconImageView.alpha = 0.0
            // Bool値切り替え
            self.navBarIsTransparent = true
            
        } else {
            /* ---- 常にNavBarは不透明 ----- */
            
            // 処理を行うか判定・不要ならスキップ
            if !(self.navBarIsTransparent) { return }
            
            // navBar
            let appearance = UINavigationBarAppearance()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .lightGray
            appearance.backgroundImage = nil
            appearance.backgroundEffect = nil
            appearance.backgroundColor = .systemBackground
            navigationController?.navigationBar.barTintColor = .clear
            navigationController?.navigationBar.backgroundColor = .systemBackground
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            // titleViewの要素
            customNavigationTitleView.titleLabel.alpha = 1.0
            customNavigationTitleView.iconImageView.alpha = 1.0
            // Bool値切り替え
            self.navBarIsTransparent = false
        }
    }
}

extension LikeCardDetailViewController: UserInfoTableViewCellDelegate {
    
    func didTapGoDetail(cell: UserInfoTableViewCell) {
        
        if let user = cell.user {
            
            let comment = "「" + hobby + "」から来ました！"
            let commentImg = hobbyImageURL
            
            profileDetailMove(user: user, comment: comment, commentImg: commentImg)
        }
    }
}

extension LikeCardDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let globalLikeCardUsers = GlobalVar.shared.likeCardUsers
        return globalLikeCardUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoTableViewCell.cellIdentifier) as! UserInfoTableViewCell
        cell.delegate = self
        
        let globalLikeCardUsers = GlobalVar.shared.likeCardUsers
        if let user = globalLikeCardUsers[safe: indexPath.row] { cell.configure(with: user) }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserInfoTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        let globalLikeCardUsers = GlobalVar.shared.likeCardUsers
        let likeCardUserLastIndex = globalLikeCardUsers.count - 1
        let isLastIndex = (index == likeCardUserLastIndex)
        
        let notSearchEnd = (likeCardUserSearchEnd == false)
        
        let reloadCardUserFetch = (isLastIndex && notSearchEnd)
        
        if reloadCardUserFetch == false { setLoadingFooterCustomCell(setFooter: false); return }
        
        getCardUsers(page: likeCardUserPage + 1)
    }
}


//MARK: - UITableView - HeaderView

extension LikeCardDetailViewController: HobbyCardDetailHeaderViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HobbyCardDetailHeaderView.height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HobbyCardDetailHeaderView.headerIdentifier) as? HobbyCardDetailHeaderView else { return nil }
        headerView.setHobby(title: hobby, imageURL: hobbyImageURL)
        headerView.headerViewDelegate = self
        let checkFilter = checkFilter()
        headerView.setSearchButton(checkFilter)
        return headerView
    }
    
    func didTapAlertContactForm() {
        let contactFormAction = UIAlertAction(title: "この趣味カードへの問い合わせ", style: .default) { [weak self] action in
            let bugReportLink = self?.links["bugReport"] ?? ""
            self?.openURLForSafari(url: bugReportLink, category: "bugReport")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel , handler: nil)
        showAlert(style: .actionSheet, title: nil, message: nil, actions: [contactFormAction, cancelAction], completion: nil)
    }
    
    func didTapFilter() { didTapFilterButton() }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerHeight = HobbyCardDetailHeaderView.height    // 閾値
        let offsetY = scrollView.contentOffset.y    // スクロール後のy座標
        
        // 1. 初期位置の有無の判定
        if let startingPosition = self.scrollStartingPosition {
            // 各パラメータ
            let headerIsShowing: Bool = (offsetY - startingPosition) < headerHeight
            let position = (offsetY - startingPosition) / headerHeight
            let transparency = (offsetY - startingPosition - (headerHeight * 0.8)) / (headerHeight * 0.2)
            
            // 2. 位置の判定
            if headerIsShowing {
                // searchButtonItemを非表示
                navigationItem.rightBarButtonItem?.isEnabled = false
                navigationItem.rightBarButtonItem?.tintColor = .clear
                // iconを非表示
                customNavigationTitleView.iconImageView.alpha = 0.0
                
                if position > 0.8 {
                    // 3-a. スクロール量に応じて透明度を変化
                    let appearance = UINavigationBarAppearance()
                    appearance.shadowImage = UIImage()
                    appearance.shadowColor = .lightColor.withAlphaComponent(transparency)
                    appearance.backgroundImage = nil
                    appearance.backgroundEffect = nil
                    appearance.backgroundColor = .systemBackground.withAlphaComponent(transparency)
                    navigationController?.navigationBar.barTintColor = .systemBackground.withAlphaComponent(transparency)
                    navigationController?.navigationBar.backgroundColor = .systemBackground.withAlphaComponent(transparency)
                    navigationController?.navigationBar.standardAppearance = appearance
                    navigationController?.navigationBar.compactAppearance = appearance
                    navigationController?.navigationBar.scrollEdgeAppearance = appearance
                    customNavigationTitleView.titleLabel.alpha = transparency
                } else {
                    // 3-b. 完全に透明
                    setNavBarTransparent(true)
                }
            } else {
                // 完全に不透明でBarButtonItem, titleView全て表示
                setNavBarTransparent(false)
            }
        } else {
            // 初期位置の設定（デバイス毎に異なる）
            self.scrollStartingPosition = offsetY
        }
    }
}
//MARK: - UITableViewDataSourcePrefetching

extension LikeCardDetailViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // [User]
        let globalLikeCardUsers = GlobalVar.shared.likeCardUsers
        // [URL]
        let mainIconUrls = indexPaths.compactMap { URL(string: globalLikeCardUsers[safe: $0.section]?.profile_icon_img ?? "") }
        var subIconUrls: [URL] = []
        for i in 0...1 {
            subIconUrls.append(contentsOf: indexPaths.compactMap { URL(string: globalLikeCardUsers[safe: $0.section]?.profile_icon_sub_imgs[safe: i] ?? "") })
        }
        let urls = mainIconUrls + subIconUrls
        // start prefetching
        prefetcher.startPrefetching(with: urls)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // [User]
        let globalLikeCardUsers = GlobalVar.shared.likeCardUsers
        // [URL]
        let mainIconUrls = indexPaths.compactMap { URL(string: globalLikeCardUsers[safe: $0.section]?.profile_icon_img ?? "") }
        var subIconUrls: [URL] = []
        for i in 0...1 {
            subIconUrls.append(contentsOf: indexPaths.compactMap { URL(string: globalLikeCardUsers[safe: $0.section]?.profile_icon_sub_imgs[safe: i] ?? "") })
        }
        let urls = mainIconUrls + subIconUrls
        // stop prefetching
        prefetcher.stopPrefetching(with: urls)
    }
}
