//
//  MyHistoryViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/05.
//

import UIKit

class MyHistoryViewController: UIBaseTableViewController, IndicatorInfoProvider {
    
    static let nibName = "MyHistoryView"
   
    var itemInfo: IndicatorInfo = "自分の足あと"
    
    var visitorElaspedTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "M月d日"
        return formatter
    }()
    
    init(style: UITableView.Style, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // XLPagerTabStrip - 必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HistoryTableViewCell.nib, forCellReuseIdentifier: HistoryTableViewCell.cellIdentifier)
        
        tableView.separatorInset = UIEdgeInsets.zero  //　区切り線を左まで伸ばす
        
        let tableFooterView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 130))
        tableView.tableFooterView = tableFooterView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension MyHistoryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        
        guard let updatedAt = visitorsUpdatedAt[safe: section - 1] else { return 0 }
        
        let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
        return customVisitors.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        
        guard let updatedAt = visitorsUpdatedAt[safe: indexPath.section - 1] else { return 0 }
        
        let customVisitors = customVisitors(visitors: visitors, updatedAt: updatedAt)
        
        if let _ = customVisitors[safe: indexPath.row] { return HistoryTableViewCell.height }

        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            customCell.configure(with: user, visitor: visitor, comment: false)
            customCell.setReactionButtonStatus(user: user)
        }
        
        cell = customCell
        
        return cell
    }
    
    private func filterVisitors() -> [Visitor] {
        
        let loginUser = GlobalVar.shared.loginUser
        
        let loginUID = loginUser?.uid ?? ""
        let visitors = loginUser?.visitors ?? [Visitor]()
        let filterVisitors = visitors.filter({ $0.creator == loginUID && $0.target != loginUID })
        
        return filterVisitors
    }
    
    private func visitorTimes(visitors: [Visitor]) -> [String] {
        let visitorsUpdatedAt = visitors.map({ visitorElaspedTime.string(from: $0.updated_at.dateValue()) })
        let setVisitorsUpdatedAtDate = Set(visitorsUpdatedAt).map({ visitorElaspedTime.date(from: $0) ?? Date() }).sorted(by: >)
        let setVisitorsUpdatedAt = setVisitorsUpdatedAtDate.map({ visitorElaspedTime.string(from: $0) })
        return setVisitorsUpdatedAt
    }
    
    private func customVisitors(visitors: [Visitor], updatedAt: String) -> [Visitor] {
            
        let filterVisitors = visitors.filter({ visitorElaspedTime.string(from: $0.updated_at.dateValue()) == updatedAt })
        let sortVisitors = filterVisitors.sorted(by: { $0.updated_at.dateValue() > $1.updated_at.dateValue() })
        
        return sortVisitors
    }
}


//MARK: - TableView - Section Header View

extension MyHistoryViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let visitors = filterVisitors()
        let visitorsUpdatedAt = visitorTimes(visitors: visitors)
        return visitorsUpdatedAt.count
    }
    
    // セクションheaderViewを設定
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        headerView.backgroundColor = .accentColor
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        title.font = .systemFont(ofSize: 12.0, weight: .semibold)
        title.textColor = .white
        
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}


//MARK: - HistoryTableViewDelegate

extension MyHistoryViewController: HistoryTableViewCellDelegate {
    
    func didTapGoDetail(cell: HistoryTableViewCell) {
        if let user = cell.user { profileDetailMove(user: user) }
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
                
                weakSelf.tableView.reloadData()
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
                    
                    weakSubSelf.tableView.reloadData()
                    
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

extension MyHistoryViewController {
    
    public override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {

        tableView.reloadData()
        
        presentationDidDismissMoveMessageRoomAction()
    }
}

//MARK: - UIScrollViewDelegate

extension MyHistoryViewController {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollBeginingPoint = scrollView.contentOffset
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 始点
        let scrollBeginingPoint = self.scrollBeginingPoint ?? CGPoint()
        // 現在地
        let currentPoint = scrollView.contentOffset
        // 判定
        let isScrollingDown: Bool = (scrollBeginingPoint.y < currentPoint.y)
        
        if isScrollingDown {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
