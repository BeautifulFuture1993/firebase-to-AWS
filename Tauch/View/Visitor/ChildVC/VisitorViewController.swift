//
//  VisitorViewController.swift
//  Tauch
//
//  Created by Apple on 2023/05/29.
//

import UIKit

class VisitorViewController: UIBaseViewController {
    
    static let nibName = "VisitorView"
    
    var itemInfo: IndicatorInfo = "足あと"
    
    @IBOutlet weak var visitorTableView: UITableView!
    
    //MARK: - Lifecycle
    var visitorUnreadList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visitorTableView.delegate = self
        visitorTableView.dataSource = self
        
        visitorTableView.isPrefetchingEnabled = true
        visitorTableView.prefetchDataSource = self
        
        visitorTableView.register(HistoryTableViewCell.nib, forCellReuseIdentifier: HistoryTableViewCell.cellIdentifier)
        visitorTableView.register(VisitorHeaderTableViewCell.nib, forCellReuseIdentifier: VisitorHeaderTableViewCell.cellIdentifier)
        
        visitorTableView.separatorInset = UIEdgeInsets.zero
        visitorTableView.sectionHeaderTopPadding = 0.0
        
        let tableFooterView = UIView(frame: CGRectMake(0, 0, visitorTableView.frame.width, 130))
        visitorTableView.tableFooterView = tableFooterView
        
        GlobalVar.shared.visitorTableView = visitorTableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setVisitorNavigation()
        setVisitorUnreadList()
        readVisitors()
        
        prefetcher.isPaused = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        readVisitors()
        
        prefetcher.isPaused = true
    }
    
    private func setVisitorNavigation(hidden: Bool = false) {
        let navigationTitle = (hidden ? "" : "足あと")
        navigationWithSetUp(navigationTitle: navigationTitle)
    }
    
    private func setVisitorUnreadList() {
        
        let loginUser = GlobalVar.shared.loginUser
        let loginUID = loginUser?.uid ?? ""
        let visitors = loginUser?.visitors ?? [Visitor]()
        let unreadVisitors = visitors.filter({ $0.target == loginUID && $0.read == false })
        
        visitorUnreadList = unreadVisitors.map({ $0.document_id })
        
        GlobalVar.shared.visitorTableView.reloadData()
    }

    private func readVisitors() {
        
        let loginUser = GlobalVar.shared.loginUser
        let loginUID = loginUser?.uid ?? ""
        let visitors = loginUser?.visitors ?? [Visitor]()
        let unreadVisitors = visitors.filter({ $0.target == loginUID && $0.read == false })
        
        GlobalVar.shared.tabBarVC?.tabBar.items?[4].badgeValue = nil
        
        DispatchQueue.main.async { self.visitorReadUpdate(visitors: unreadVisitors) }
    }
    
    private func visitorReadUpdate(visitors: [Visitor]) {

        let loginUser = GlobalVar.shared.loginUser
        let loginVisitors = loginUser?.visitors ?? [Visitor]()
        
        let readLoginVisitors = loginVisitors.map({
            let visitor = $0
            visitor.read = true
            return visitor
        })
        
        GlobalVar.shared.loginUser?.visitors = readLoginVisitors
        
        if visitors.isEmpty { return }
        
        visitors.forEach({
            let visitorID = $0.document_id
            let visitorRef = db.collection("visitors").document(visitorID)
            visitorRef.updateData(["read": true])
        })
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension VisitorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 { return 1 }
        
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        
        guard let updatedAt = visitorsUpdatedAt[safe: section - 1] else { return 0 }
        
        let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
        return customVisitors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let headerView = tableView.dequeueReusableCell(withIdentifier: VisitorHeaderTableViewCell.cellIdentifier, for: indexPath) as? VisitorHeaderTableViewCell else {
                fatalError("カスタムセルの登録に失敗")
            }
            headerView.headerDelegate = self
            return headerView
        }
        
        let cellFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0)
        var cell = UITableViewCell(frame: cellFrame)
        cell.tag = indexPath.row
        
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        
        guard let updatedAt = visitorsUpdatedAt[safe: indexPath.section - 1] else { return cell }
        
        let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
                
        guard let customCell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.cellIdentifier, for: indexPath) as? HistoryTableViewCell else {
            fatalError("カスタムセルの登録に失敗")
        }
        customCell.cellDelegate = self
        customCell.tag = indexPath.row
        
        if let visitor = customVisitors[safe: indexPath.row], let user = visitor.userInfo {
            
            let globalVisitorUnreadList = GlobalVar.shared.loginUser?.visitorUnreadList ?? [String]()
            let duplicateVisitorLists = globalVisitorUnreadList.filter({
                let specificID = $0
                let checkFilterVisitorLists = (visitorUnreadList.firstIndex(where: { $0 == specificID }) == nil)
                return checkFilterVisitorLists
            })
            let mergeVisitorUnreadList = visitorUnreadList + duplicateVisitorLists
            customCell.configure(with: user, visitor: visitor, comment: true, visitorUnreadList: mergeVisitorUnreadList)
            customCell.setReactionButtonStatus(user: user)
        }
        
        cell = customCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 広告部分のセル
        if indexPath.section == 0 { return VisitorHeaderTableViewCell.height }
        
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        
        guard let updatedAt = visitorsUpdatedAt[safe: indexPath.section - 1] else { return 0 }
        
        let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
        
        if let visitor = customVisitors[safe: indexPath.row] {
            
            let comment = visitor.comment
            let commentImg = visitor.comment_img
            let isCommentView = (comment != "" && commentImg != "")
           
            let cellHeight = (isCommentView ? HistoryTableViewCell.heightWithComment : HistoryTableViewCell.height)
            return cellHeight
        }

        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        return 1 + visitorsUpdatedAt.count // ヘッダー分を考慮
    }
    // セクションheaderViewを設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 1番上は広告部分のため
        if section == 0 { return nil }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
        headerView.backgroundColor = .systemGray6
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        title.font = .systemFont(ofSize: 12.0, weight: .semibold)
        title.textColor = .systemGray
        
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        
        guard let updatedAt = visitorsUpdatedAt[safe: section - 1] else { return nil }
        title.text = updatedAt
        
        title.sizeToFit()
        headerView.addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        title.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 25
    }
    
    private func filterVisitors() -> [Visitor] {
        
        let loginUser = GlobalVar.shared.loginUser
        
        let loginUID = loginUser?.uid ?? ""
        let visitors = loginUser?.visitors ?? [Visitor]()
        let filterVisitors = visitors.filter({
            
            let user = $0.userInfo
            let isNotActivated = (user?.is_activated == false)
            let isDeleted = (user?.is_deleted == true)
            let isRested = (user?.is_rested == true)
            
            let isNotActive = (isNotActivated || isDeleted || isRested)
            if isNotActive { return false }
            
            let targetVisitors = ($0.target == loginUID && $0.creator != loginUID)
            return targetVisitors
        })
        
        return filterVisitors
    }
    
    private func visitorTimes(visitors: [Visitor]) -> [String] {
        let visitorsUpdatedAt = visitors.map({ elaspedTime.string(from: $0.updated_at.dateValue()) })
        let setVisitorsUpdatedAtDate = Set(visitorsUpdatedAt).map({ elaspedTime.date(from: $0) ?? Date() }).sorted(by: >)
        let setVisitorsUpdatedAt = setVisitorsUpdatedAtDate.map({ elaspedTime.string(from: $0) })
        return setVisitorsUpdatedAt
    }
    
    private func customVisitors(visitors: [Visitor], updatedAt: String) -> [Visitor] {
            
        let filterVisitors = visitors.filter({ elaspedTime.string(from: $0.updated_at.dateValue()) == updatedAt })
        let sortVisitors = filterVisitors.sorted(by: { $0.updated_at.dateValue() > $1.updated_at.dateValue() })
        
        return sortVisitors
    }
}

//MARK: - UITableViewDataSourcePrefetching

extension VisitorViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // [Visitor]
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        // [URL]
        let mainIconUrls = indexPaths.compactMap {
            guard let updatedAt = visitorsUpdatedAt[safe: $0.section - 1] else { return URL(string: "") }
            let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
            
            guard let visitor = customVisitors[safe: $0.row] else { return URL(string: "") }
            let profileIconImg = visitor.userInfo?.profile_icon_img ?? ""
            return URL(string: profileIconImg)
        }
        let commentUrls = indexPaths.compactMap {
            guard let updatedAt = visitorsUpdatedAt[safe: $0.section - 1] else { return URL(string: "") }
            let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
            
            guard let visitor = customVisitors[safe: $0.row] else { return URL(string: "") }
            let visitorCommentImg = visitor.comment_img
            return URL(string: visitorCommentImg)
        }
        let urls = mainIconUrls + commentUrls
        // start prefetching
        prefetcher.startPrefetching(with: urls)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // [Visitor]
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        // [URL]
        let mainIconUrls = indexPaths.compactMap {
            guard let updatedAt = visitorsUpdatedAt[safe: $0.section - 1] else { return URL(string: "") }
            let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
            
            guard let visitor = customVisitors[safe: $0.row] else { return URL(string: "") }
            let profileIconImg = visitor.userInfo?.profile_icon_img ?? ""
            return URL(string: profileIconImg)
        }
        let commentUrls = indexPaths.compactMap {
            guard let updatedAt = visitorsUpdatedAt[safe: $0.section - 1] else { return URL(string: "") }
            let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
            
            guard let visitor = customVisitors[safe: $0.row] else { return URL(string: "") }
            let visitorCommentImg = visitor.comment_img
            return URL(string: visitorCommentImg)
        }
        let urls = mainIconUrls + commentUrls
        // stop prefetching
        prefetcher.stopPrefetching(with: urls)
    }
}

//MARK: - HistoryTableViewDelegate

extension VisitorViewController: HistoryTableViewCellDelegate {
    
    func didTapGoDetail(cell: HistoryTableViewCell) {

        if let user = cell.user { 
            
            let comment = "あなたがつけた足あとから来ました！"
            let commentImg = "visitor"
            
            profileDetailMove(user: user, comment: comment, commentImg: commentImg)
        }
    }
    
    func didTapVisitorAction(cell: HistoryTableViewCell) {
        
        let adminCheck = adminCheckStatus()
        if adminCheck == false { return }
        
        if let user = cell.user, let actionType = cell.actionType {
            
            let impact = UIImpactFeedbackGenerator(style: .heavy); impact.impactOccurred()
            
            switch actionType {
            case "good": approach(user: user); break
            case "match": approachMatch(user: user); break
            case "message": message(user: user); break
            default: alert(title: "エラー", message: "正常に処理できませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK"); break
            }
        }
    }
    
    private func approach(user: User) {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let isNotApproachRelatedContains = (checkApproachRelated(user: user) == false)
        if isNotApproachRelatedContains {
            
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            
            // アプローチデータを追加
            let loginUID = loginUser.uid
            let targetUID = user.uid
            let targetNickName = user.nick_name
            let approachType = "approach"
            let approachStatus = 0
            let actionType = "visitorClick"
            
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
                
                weakSelf.visitorTableView.reloadData()
            })
        }
    }
    
    private func approachMatch(user: User) {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let targetUID = user.uid
        let targetNickName = user.nick_name
        let actionType = "visitorClick"
        
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
                    
                    weakSubSelf.visitorTableView.reloadData()
                    
                    if let roomID = subResult {
                        
                        let autoMessage = GlobalVar.shared.loginUser?.is_auto_message ?? true
                        if autoMessage {
                            
                            GlobalVar.shared.displayAutoMessage = true
                            weakSubSelf.moveMessageRoom(roomID: roomID, target: user)
                            
                        } else {
                            weakSubSelf.alert(title: "マッチングに成功しました!", message: "メッセージルームにてやりとりを開始してください!", actiontitle: "OK")
                        }
                        
                    } else {
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
    
    private func message(user: User) {
        
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        let targetUID = user.uid
        
        let rooms = loginUser.rooms
        
        if let room = rooms.filter({ $0.members.contains(targetUID) }).first, let roomID = room.document_id {
            
            GlobalVar.shared.specificRoom = room
            GlobalVar.shared.backgroundClassName = ["MessageListViewController", "MessageRoomView"]
            
            tabBarVCMove(selectedIndex: 2, setKey: "specificRoomID", setValue: roomID)
            
        } else {
            alert(title: "メッセージルーム遷移エラー", message: "正常にメッセージルームに遷移がされませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
        }
    }
}

extension VisitorViewController {
    
    public override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {

        visitorTableView.reloadData()
        
        presentationDidDismissMoveMessageRoomAction()
    }
}

//MARK: - UIScrollViewDelegate

extension VisitorViewController {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollBeginingPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 始点
        let scrollBeginingPoint = self.scrollBeginingPoint ?? CGPoint()
        // 現在地
        let currentPoint = scrollView.contentOffset
        // 判定
        let isScrollingDown: Bool = (scrollBeginingPoint.y < currentPoint.y)

        if isScrollingDown {
            self.navigationController?.isNavigationBarHidden = true
        } else {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
}


//MARK: - VisitorHeaderTableViewCellDelegate

extension VisitorViewController: VisitorHeaderTableViewCellwDelegate {
    
    func didTapped() {
        let storyBoard = UIStoryboard.init(name: VisitorPopupViewController.storyboardName, bundle: nil)
        let modalViewController = storyBoard.instantiateViewController(withIdentifier: VisitorPopupViewController.storyboardID)
        modalViewController.modalPresentationStyle = .custom
        modalViewController.transitioningDelegate = self
        present(modalViewController, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class ModalViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
    }
}

