//
//  NewHomeViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/30.
//

import UIKit
import FBSDKCoreKit
import FirebaseFirestore
import FirebaseAnalytics
import FirebaseFunctions
import Typesense
import SideMenu
import Nuke

class NewHomeViewController: UIBaseViewController, IndicatorInfoProvider {
    // XLPagerTabStrip - ボタンのタイトルになる
    var homeInfo: IndicatorInfo = "さがす"
    
    static let storyboardName = "NewHomeView"
    static let storyboardId = "NewHomeView"
  
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let now: Date = Date()
    let pickupUserNum = 12
    let typesenseClient = GlobalVar.shared.typesenseClient
    private var lastIndexTableViewCell: LastIndexTableViewCell?
    private var lastIndexTableViewCellIsShown: Bool = false
    private let userDefaults = UserDefaults.standard
    
    var reloadNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.isPrefetchingEnabled = true
        homeTableView.prefetchDataSource = self
        
        registerCustomCell(nibName: LastIndexTableViewCell.nibName, cellIdentifier: LastIndexTableViewCell.cellIdentifier)
        registerCustomCell(nibName: UserListTableViewCell.nibName, cellIdentifier: UserListTableViewCell.cellIdentifier)
        registerCustomCell(nibName: UserInfoTableViewCell.nibName, cellIdentifier: UserInfoTableViewCell.cellIdentifier)
        registerCustomCell(nibName: RecommendUsersTopTableViewCell.nibName, cellIdentifier: RecommendUsersTopTableViewCell.cellIdentifier)
        registerCustomCell(nibName: LoadingTableViewCell.nibName, cellIdentifier: LoadingTableViewCell.cellIdentifier)
        
        GlobalVar.shared.likeCardTableView = homeTableView
        
        setLoadingView()
        
        configSideMenu(currentView: view)
        
        // Appをアップデートした場合の処理
        appVersionUpdatedAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBarBorderAndShowTabBarBorder()
        tabBarController?.tabBar.backgroundColor = .white
        
        ScreenManagerViewController.filterBarButtonItem.target = self
        switchSearchButtonItemStatus()

        // Nuke - prefetch
        prefetcher.isPaused = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 見た目上の画面遷移を速く見せるため、スコープ内の処理をサブスレッドで行う
        DispatchQueue.global(qos: .userInteractive).async { self.getCardUsers() }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Nuke - prefetch
        prefetcher.isPaused = true
    }
}

// Appバージョンアップデート関連
extension NewHomeViewController {
    
    // Appをアップデートしたタイミングで必要な処理をする
    private func appVersionUpdatedAction() {
        let isVersionUpdated = userDefaults.bool(forKey: "app_version_updated")
        
        if isVersionUpdated {
            needToPresentNewTerms()
            userDefaults.set(false, forKey: "app_version_updated")
        }
    }
    
    private func needToPresentNewTerms() {
        let isAfterNewTermsUser = userDefaults.bool(forKey: "after_new_terms_user")
        
        if isAfterNewTermsUser {
            return
        }
        
        if let uid = GlobalVar.shared.loginUser?.uid {
            let document = db.collection("users").document(uid).collection("new_terms_agree").document(uid)
            
            document.getDocument { [weak self] document, error in
                guard let weakSelf = self else { return }
                
                if error != nil {
                    print("新利用規約の同意記録の取得に失敗")
                    return
                }
                
                if let document = document {
                    let newTermsAgree = NewTermsAgree(document: document)
                    if let isAgree = newTermsAgree.updated_for_2023_11_17 {
                        if isAgree {
                            print("新利用規約に同意済み")
                        } else {
                            let viewController = TermsWebViewController()
                            viewController.modalPresentationStyle = .fullScreen
                            weakSelf.present(viewController, animated: true)
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Fetch Users

extension NewHomeViewController {
    
    func logCardUser(users: [User]) {
        let ownHobbies = GlobalVar.shared.loginUser?.hobbies ?? [String]()
        users.forEach({
            print(
                "uid:", $0.uid,
                "address:", $0.address,
                "age:", $0.birth_date.calcAge(),
                "is_logined:", $0.is_logined,
                "logouted_at:", $0.logouted_at.dateValue(),
                "created_at:", $0.created_at.dateValue(),
                "nick_name:", $0.nick_name,
                "hobby matching:", hobbyMatchingRate(ownHobbyList: ownHobbies, targetHobbyList: $0.hobbies)
            )
        })
    }
    
    func getSearchParameters(type: String = "search", page: Int = 1) -> SearchParameters {
        
        var perPage = 100
        var searchFilterBy = "is_activated:= true && is_deleted:= false"
        var searchSortBy = "is_logined:desc, created_at:desc"
        
        var searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, page: page, perPage: perPage)
        
        guard let loginUser = GlobalVar.shared.loginUser else { return searchParameters }
        
        let loginUID = loginUser.uid
        let address = loginUser.address
        
        searchFilterBy = searchFilterBy + " && " + "uid:!= \(loginUID)"
        
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
        let unixtime: Int = Int(modifiedDate.timeIntervalSince1970)
        
        switch type {
        case "pickup":
            searchSortBy = "created_at:desc, is_logined:desc"
            perPage = 12
            
            searchParameters = SearchParameters(q: address, queryBy: "address", filterBy: searchFilterBy, sortBy: searchSortBy, page: page, perPage: perPage)
            break
        case "priority":
            if now != modifiedDate { searchFilterBy = searchFilterBy + " && " + "(is_logined:= true || (is_logined:= false && logouted_at:>= \(unixtime)))" }
            
            searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, page: page, perPage: perPage)
            break
        default:
            let minAgeFilter = loginUser.min_age_filter
            let maxAgeFilter = loginUser.max_age_filter
            let ageArray = ([Int])(minAgeFilter...maxAgeFilter)
            searchFilterBy = searchFilterBy + " && " + "age: \(ageArray)"
            
            let addressFilter = loginUser.address_filter
            let isSelectedAddressFilter = (addressFilter.isEmpty == false)
            if isSelectedAddressFilter { searchFilterBy = searchFilterBy + " && " + "address: \(addressFilter)" }
            
            if now != modifiedDate { searchFilterBy = searchFilterBy + " && " + "(is_logined:= true || (is_logined:= false && logouted_at:>= \(unixtime)))" }
            
            searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, sortBy: searchSortBy, page: page, perPage: perPage)
            break
        }
        
        return searchParameters
    }
    
    func getCardUsers(page: Int = 1, type: String = "") {
        
//        print("\n##############################################")
        switch type {
        case "priority": // おすすめユーザの取得
            getSpecificCardUsers(page: page, type: "priority")
            break
        case "pickup": // 新着ユーザの取得
            getSpecificCardUsers(page: page, type: "pickup")
            break
        case "search": // 検索ユーザの取得
            getSpecificCardUsers(page: page, type: "search")
            break
        default:
            getSpecificCardUsers(type: "pickup")
            getSpecificCardUsers(type: "priority")
            getSpecificCardUsers(type: "search")
            break
        }
    }
    
    func getSpecificCardUsers(page: Int = 1, type: String) {
        
        Task {
            do {
                // let start = Date()
                
                let searchParams = getSearchParameters(type: type, page: page)
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParams, for: CardUserQuery.self)
                
                 // let elapsed = Date().timeIntervalSince(start)
                 // print("\n\(type) ページ数: \(page) ユーザの取得完了 : \(elapsed)")
                
                setCardUsers(searchResult: searchResult, page: page, type: type)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    func setCardUsers(searchResult: SearchResult<CardUserQuery>?, page: Int, type: String) {
            
        guard let hits = searchResult?.hits else { setCardRecommendUsers(page: page, type: type); return }
        
        let isEmptyHits = (hits.count == 0)
        if isEmptyHits { setCardRecommendUsers(page: page, type: type); return }
        
        let cardUsers = hits.map({ User(cardUserQuery: $0) })
        
        let filterCardUsers = cardUsers.filter({ filterMethod(user: $0) })
 
        let isEmptyCardRecommendUsers = (filterCardUsers.count == 0)
        if isEmptyCardRecommendUsers { getCardUsers(page: page + 1, type: type); return }
    
        let sortedCardUsers = sortMethod(users: filterCardUsers)
        
        // print("カード取得数 : \(cardUsers.count), フィルター カード取得数 : \(filterCardUsers.count)")
        
        setCardRecommendUsers(cardUsers: sortedCardUsers, page: page, type: type)
    }
    
    private func setCardRecommendUsers(cardUsers: [User] = [], page: Int = 1, type: String = "search") {
        
        var globalCardUserNum = 0
        var mergeCardUserNum = 0
        
        switch type {
        case "search":
            GlobalVar.shared.cardSearchUserPage = page
            
            let globalSearchCardRecommendUsers = GlobalVar.shared.searchCardRecommendUsers
            globalCardUserNum = globalSearchCardRecommendUsers.count
            
            let mergeSearchCardRecommendUsers = mergeUsers(users: globalSearchCardRecommendUsers, mergedUsers: cardUsers)
            mergeCardUserNum = mergeSearchCardRecommendUsers.count
            
            GlobalVar.shared.searchCardRecommendUsers = mergeSearchCardRecommendUsers
            break
        case "pickup":
            GlobalVar.shared.pickupCardRecommendUsers = cardUsers
            break
        case "priority":
            GlobalVar.shared.cardPriorityUserPage = page
            
            let globalPriorityCardRecommendUsers = GlobalVar.shared.priorityCardRecommendUsers
            globalCardUserNum = globalPriorityCardRecommendUsers.count
            
            let mergePriorityCardRecommendUsers = mergeUsers(users: globalPriorityCardRecommendUsers, mergedUsers: cardUsers)
            mergeCardUserNum = mergePriorityCardRecommendUsers.count
            
            GlobalVar.shared.priorityCardRecommendUsers = mergePriorityCardRecommendUsers
            break
        default:
            break
        }
        
        if type == "pickup" { return }

        let isEmptyCardUsers = (cardUsers.count == 0)
        if isEmptyCardUsers { showRecommendUsers(finishLoadData: true); return }
        
        let isNotEmptyCardRecommendUserNum = (globalCardUserNum != mergeCardUserNum)
        if isNotEmptyCardRecommendUserNum { showRecommendUsers(); return }
        
        showRecommendUsers(finishLoadData: true)
    }
    
    private func showRecommendUsers(finishLoadData: Bool = false) {
        
        let searchCardUserEnd = GlobalVar.shared.searchCardUserEnd
        let priorityCardUserEnd = GlobalVar.shared.priorityCardUserEnd
        
        let searchNotReloadEnd = (searchCardUserEnd == true && priorityCardUserEnd == false)
        if searchNotReloadEnd { GlobalVar.shared.priorityCardUserEnd = finishLoadData }
        
        let notSearchEnd = (searchCardUserEnd == false)
        if notSearchEnd { GlobalVar.shared.searchCardUserEnd = finishLoadData }
        
        resortLikeCardTable()
    }
    
    private func resortLikeCardTable() {
        
        if GlobalVar.shared.likeCardTableView.refreshControl != nil {
            
            GlobalVar.shared.likeCardTableView.refreshControl?.endRefreshing()
            GlobalVar.shared.likeCardTableView.refreshControl = nil
            
            Log.event(name: "reloadLikeCardList")
            
            let searchCardRecommendUsers = GlobalVar.shared.searchCardRecommendUsers
            
            let filterUsers = searchCardRecommendUsers.filter({ timeFilter(user: $0, minHour: 0, maxHour: 6, onlineLimit: false) == true })
            let restUsers = searchCardRecommendUsers.filter({ timeFilter(user: $0, minHour: 0, maxHour: 6, onlineLimit: false) == false })
            
            let firstReload  = (reloadNum == 1)
            let secondReload = (reloadNum == 2)
            let thirdReload  = (reloadNum == 3)
            
            var minHour = 0
            var maxHour = 0
            
            minHour = (firstReload  ? 0 : minHour) // 2時間以内のユーザを6時間以内のユーザの後に追加
            minHour = (secondReload ? 2 : minHour) // 4時間以内のユーザを6時間以内のユーザの後に追加
            minHour = (thirdReload  ? 4 : minHour) // 6時間以内のユーザを6時間以内のユーザの後に追加
            
            maxHour = (firstReload  ? 2 : maxHour) // 2時間以内のユーザを6時間以内のユーザの後に追加
            maxHour = (secondReload ? 4 : maxHour) // 4時間以内のユーザを6時間以内のユーザの後に追加
            maxHour = (thirdReload  ? 6 : maxHour) // 6時間以内のユーザを6時間以内のユーザの後に追加
            
            let reload = (minHour == 0 && maxHour == 0)
            
            reloadNum = (reload ? 0 : reloadNum)
            
            print("minHour : \(minHour), maxHour : \(maxHour), reloadNum : \(reloadNum)")
            
            let sortUsers = (
                reload ?
                sortMethod(users: searchCardRecommendUsers) :
                resortUsers(filterUsers: filterUsers, restUsers: restUsers, minHour: minHour, maxHour: maxHour, onlineLimit: false)
            )
            GlobalVar.shared.searchCardRecommendUsers = sortUsers
            
            GlobalVar.shared.likeCardTableView.reloadData()
            let impact = UIImpactFeedbackGenerator(style: .rigid); impact.impactOccurred()
            
        } else {
            GlobalVar.shared.likeCardTableView.reloadData()
        }
    }
    
    private func resortUsers(filterUsers: [User], restUsers: [User], minHour: Int, maxHour: Int, onlineLimit: Bool) -> [User] {
        
        let reFilterUsers = filterUsers.filter({ timeFilter(user: $0, minHour: minHour, maxHour: maxHour, onlineLimit: onlineLimit) == true })
        let reFilterRestUsers = filterUsers.filter({ timeFilter(user: $0, minHour: minHour, maxHour: maxHour, onlineLimit: onlineLimit) == false })
        
        let sortReFilterUsers = sortMethod(users: reFilterUsers)
        let sortReFilterRestUsers = sortMethod(users: reFilterRestUsers)
        let sortRestUsers = sortMethod(users: restUsers)
        
        let mergeUsers = sortReFilterUsers + sortReFilterRestUsers + sortRestUsers
        
        return mergeUsers
    }
    
    private func timeFilter(user: User, minHour: Int, maxHour: Int, onlineLimit: Bool) -> Bool {
        
        let isOnline = (user.is_logined == true)
        let isOffline = (user.is_logined == false)
        
        let now = Date()
        let logoutedAt = user.logouted_at.dateValue()
        let span = now.timeIntervalSince(logoutedAt)
        let hourSpan = Int(floor(span/60/60))
        let inHourSpan = (minHour <= hourSpan && hourSpan < maxHour)
        
        let timeFilter = (onlineLimit ? (isOnline || inHourSpan) : (isOffline && inHourSpan))
        
        return timeFilter
    }
    
    func reloadLikeCardTable() {
        reloadNum += 1
        GlobalVar.shared.likeCardTableView.refreshControl = UIRefreshControl()
        GlobalVar.shared.likeCardTableView.refreshControl?.beginRefreshing()
        let impact = UIImpactFeedbackGenerator(style: .light); impact.impactOccurred()
        DispatchQueue.global(qos: .userInteractive).async { self.getCardUsers() }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // スクロール終了タイミングで再読み込み位置の場合
        if 0 > scrollView.contentOffset.y { reloadLikeCardTable() }
    }
}


//MARK: - UserInfoTableViewCellDelegate

extension NewHomeViewController: UserInfoTableViewCellDelegate {
    
    func didTapGoDetail(cell: UserInfoTableViewCell) {
        if let user = cell.user { profileDetailMove(user: user) }
    }
}


//MARK: - UITableViewDataSource

extension NewHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let searchCardRecommendUserNum = GlobalVar.shared.searchCardRecommendUsers.count
        let priorityCardRecommendUserNum = GlobalVar.shared.priorityCardRecommendUsers.count

        return searchCardRecommendUserNum + priorityCardRecommendUserNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let indexWithType = getIndexWithType(index: index)
    
        let isLastSearch = (indexWithType[index] == "lastSearch")
        let isPickup     = (indexWithType[index] == "pickup")
        let isPriority   = (indexWithType[index] == "priority")
        
        let searchCardRecommendUsers = GlobalVar.shared.searchCardRecommendUsers
        let priorityCardRecommendUsers = GlobalVar.shared.priorityCardRecommendUsers
        let cardRecommendUsers = searchCardRecommendUsers + priorityCardRecommendUsers

        if isLastSearch {
            
            lastIndexTableViewCell = (tableView.dequeueReusableCell(withIdentifier: LastIndexTableViewCell.cellIdentifier) as! LastIndexTableViewCell)
            guard let cell = lastIndexTableViewCell else { fatalError() }
            if lastIndexTableViewCellIsShown == false { cell.cellIsTransParent() }
            return cell
            
        } else if isPickup {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.cellIdentifier) as! UserListTableViewCell
            cell.setUserData(with: GlobalVar.shared.pickupCardRecommendUsers)
            return cell
            
        } else if isPriority {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: RecommendUsersTopTableViewCell.cellIdentifier) as! RecommendUsersTopTableViewCell
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoTableViewCell.cellIdentifier) as! UserInfoTableViewCell
            cell.delegate = self
            
            if let user = cardRecommendUsers[safe: index] { cell.configure(with: user) }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let index = indexPath.row
        let indexWithType = getIndexWithType(index: index)
        
        let isLastSearch = (indexWithType[index] == "lastSearch")
        let isPickup     = (indexWithType[index] == "pickup")
        let isPriority   = (indexWithType[index] == "priority")
        
        if isLastSearch {
            
            return LastIndexTableViewCell.height
            
        } else if isPickup {
            
            let isExistPickupCardRecommendUsers = (GlobalVar.shared.pickupCardRecommendUsers.count != 0)
            if isExistPickupCardRecommendUsers { return UserListTableViewCell.height }
            
            return 0
            
        } else if isPriority {
            
            return RecommendUsersTopTableViewCell.height
            
        } else {
            
            return UserInfoTableViewCell.height
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let _ = GlobalVar.shared.loginUser?.uid else { return }
        
        let index = indexPath.row
        
        let checkFilter = checkFilter()
        
        let searchCardRecommendUserNum = GlobalVar.shared.searchCardRecommendUsers.count
        let preSearchCardIndex = searchCardRecommendUserNum - 5
        let isPreSearchCardIndex = (index == preSearchCardIndex && checkFilter)
        
        let priorityCardRecommendUserNum = GlobalVar.shared.priorityCardRecommendUsers.count
        let prePriorityCardIndex = searchCardRecommendUserNum + priorityCardRecommendUserNum - 5
        let isPrePriorityCardIndex = (index == prePriorityCardIndex && checkFilter)
        
        let notSearchEnd = (GlobalVar.shared.searchCardUserEnd == false)
        let notReloadEnd = (GlobalVar.shared.priorityCardUserEnd == false)
        
        let searchReloadCardUserFetch = (isPreSearchCardIndex && notSearchEnd)
        let reloadCardUserFetch = (isPrePriorityCardIndex && notReloadEnd)
        
        // セルのアニメーションをトリガー
        let isAnimationTrigerIndex = (
            index == (searchCardRecommendUserNum + 1) &&
            checkFilter
        )
        if isAnimationTrigerIndex {
            if let cell = lastIndexTableViewCell {
                cell.showCell()
                lastIndexTableViewCellIsShown = true
            }
        }
        
        let hiddenLoading = (searchReloadCardUserFetch == false && reloadCardUserFetch == false)
        if hiddenLoading { setLoadingView(isLoading: false); return }
        
        if notSearchEnd {
            let cardSearchUserPage = GlobalVar.shared.cardSearchUserPage
            getCardUsers(page: cardSearchUserPage + 1, type: "search")
        }
        let searchNotReloadEnd = (notSearchEnd == false && notReloadEnd)
        if searchNotReloadEnd {
            let cardPriorityUserPage = GlobalVar.shared.cardPriorityUserPage
            getCardUsers(page: cardPriorityUserPage + 1, type: "priority")
        }
    }
    
    private func getIndexWithType(index: Int) -> [Int:String] {
        
        var indexWithType: [Int:String] = [index : "default"]
        
        let searchCardRecommendUserNum = GlobalVar.shared.searchCardRecommendUsers.count
        let priorityCardRecommendUserNum = GlobalVar.shared.priorityCardRecommendUsers.count
        
        let checkFilter = checkFilter()
        
        let lastSearchCardIndex = searchCardRecommendUserNum - 1
        let isLastSearchCardIndex = (
            index == lastSearchCardIndex &&
            checkFilter
        )
        if isLastSearchCardIndex { indexWithType[index] = "lastSearch"; return indexWithType }
        
        let isPriorityUserIndex = (
            index == searchCardRecommendUserNum &&
            index != 0 &&
            priorityCardRecommendUserNum != 0 &&
            checkFilter
        )
        if isPriorityUserIndex { indexWithType[index] = "priority"; return indexWithType }
        
        var pickupUserIndex = GlobalVar.shared.pickupUserIndex
        let diffSearchToPickUpIndex = (searchCardRecommendUserNum - pickupUserIndex)
        if (diffSearchToPickUpIndex >= -1 && diffSearchToPickUpIndex <= 1) {
            pickupUserIndex = pickupUserIndex + diffSearchToPickUpIndex + 2
            GlobalVar.shared.pickupUserIndex = pickupUserIndex
        }
        let isPickupUserIndex = (
            index == pickupUserIndex
        )
        if isPickupUserIndex { indexWithType[index] = "pickup"; return indexWithType }
        
        return indexWithType
    }
}


//MARK: - UITableViewDataSourcePrefetching

extension NewHomeViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // [User]
        let searchCardRecommendUsers = GlobalVar.shared.searchCardRecommendUsers
        let priorityCardRecommendUsers = GlobalVar.shared.priorityCardRecommendUsers
        let cardRecommendUsers = searchCardRecommendUsers + priorityCardRecommendUsers
        // [URL]
        let mainIconUrls = indexPaths.compactMap { URL(string: cardRecommendUsers[safe: $0.section]?.profile_icon_img ?? "") }
        var subIconUrls: [URL] = []
        for i in 0...1 {
            subIconUrls.append(contentsOf: indexPaths.compactMap { URL(string: cardRecommendUsers[safe: $0.section]?.profile_icon_sub_imgs[safe: i] ?? "") })
        }
        let urls = mainIconUrls + subIconUrls
        // start prefetching
        prefetcher.startPrefetching(with: urls)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // [User]
        let searchCardRecommendUsers = GlobalVar.shared.searchCardRecommendUsers
        let priorityCardRecommendUsers = GlobalVar.shared.priorityCardRecommendUsers
        let cardRecommendUsers = searchCardRecommendUsers + priorityCardRecommendUsers
        // [URL]
        let mainIconUrls = indexPaths.compactMap { URL(string: cardRecommendUsers[safe: $0.section]?.profile_icon_img ?? "") }
        var subIconUrls: [URL] = []
        for i in 0...1 {
            subIconUrls.append(contentsOf: indexPaths.compactMap { URL(string: cardRecommendUsers[safe: $0.section]?.profile_icon_sub_imgs[safe: i] ?? "") })
        }
        let urls = mainIconUrls + subIconUrls
        // stop prefetching
        prefetcher.stopPrefetching(with: urls)
    }
}

//MARK: - Other Setting Methods

extension NewHomeViewController {
    
    // XLPagerTabStrip - 必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return homeInfo
    }
    
    // 作成したカスタムセルを登録
    private func registerCustomCell(nibName: String, cellIdentifier: String) {
        homeTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        setClass(className: className)
        
        if GlobalVar.shared.searchCardRecommendUsers.count != 0 { setLoadingView(isLoading: false) }
        violationCardRecommendUsers()
        filterCardRecommendUsers()
        switchSearchButtonItemStatus()
        
        presentationDidDismissMoveMessageRoomAction()
    }
    
    private func switchSearchButtonItemStatus() {
        let checkFilter = checkFilter()
        ScreenManagerViewController.filterBarButtonItem.tintColor = (
            checkFilter == true ? .accentColor : .lightGray
        )
    }
    
    private func setLoadingView(isLoading: Bool = true) {
        loadingView.removeFromSuperview()
        if isLoading { showLoadingView(loadingView, color: .gray) }
    }
    
    private func violationCardRecommendUsers() {
        
        if let cardViolationUser = GlobalVar.shared.cardViolationUser {
            
            GlobalVar.shared.cardViolationUser = nil
            
            var searchCardRecommendUsers = GlobalVar.shared.searchCardRecommendUsers
            var pickupCardRecommendUsers = GlobalVar.shared.pickupCardRecommendUsers
            var priorityCardRecommendUsers = GlobalVar.shared.priorityCardRecommendUsers
            
            if let searchCardIndex = searchCardRecommendUsers.firstIndex(where: { $0.uid == cardViolationUser.uid }) {
                searchCardRecommendUsers.remove(at: searchCardIndex)
            }
            if let pickupCardIndex = pickupCardRecommendUsers.firstIndex(where: { $0.uid == cardViolationUser.uid }) {
                pickupCardRecommendUsers.remove(at: pickupCardIndex)
            }
            if let priorityCardIndex = priorityCardRecommendUsers.firstIndex(where: { $0.uid == cardViolationUser.uid }) {
                priorityCardRecommendUsers.remove(at: priorityCardIndex)
            }
            
            GlobalVar.shared.searchCardRecommendUsers = searchCardRecommendUsers
            GlobalVar.shared.pickupCardRecommendUsers = pickupCardRecommendUsers
            GlobalVar.shared.priorityCardRecommendUsers = priorityCardRecommendUsers
            
            showRecommendUsers()
        }
    }
    
    private func filterCardRecommendUsers() {
        
        let cardRecommendFilterFlg = GlobalVar.shared.cardRecommendFilterFlg
        if cardRecommendFilterFlg == false { return }
        
        setLoadingView()
        filterInitGlobalData()
        getCardUsers()
        scrollToTop()
        saveFilterCondition()
    }
    
    private func scrollToTop() {
        homeTableView.setContentOffset(.zero, animated: true)
        homeTableView.reloadData()
    }
}

//MARK: - UIScrollViewDelegate

extension NewHomeViewController {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // スクロール開始位置の設定
        self.scrollBeginingPoint = scrollView.contentOffset
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        let topScrollPoint = (currentPoint.y == 0.0)
        if topScrollPoint { barButtonViewRect(hidden: false) }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロール開始点（読み込まれた時点ではreturn）
        let scrollBeginingPoint = self.scrollBeginingPoint ?? CGPoint()
        // 現在地
        let currentPoint = scrollView.contentOffset
        // 判定
        let isScrollingDown: Bool = (scrollBeginingPoint.y < currentPoint.y)
        // スクロール方向判定
        if isScrollingDown {
            barButtonViewRect(hidden: true)
        } else {
            barButtonViewRect(hidden: false)
        }
    }
}
