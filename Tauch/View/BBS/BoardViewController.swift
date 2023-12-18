//
//  BoardViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/10.
//

import UIKit
import Typesense
import FirebaseFirestore

class BoardViewController: UIBaseViewController {
    
    static let storyboard_name_id = "BoardViewController"
    
    @IBOutlet weak var boardTableView: UITableView!
    @IBOutlet weak var showInputViewButton: UIButton!
    
    var boardPage = 1
    var boardEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureShowInputViewButton()
        
        navigationWithSetUp(navigationTitle: "みんなのタイムライン")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        customNavigationBarBorder()
        
        tabBarController?.tabBar.backgroundColor = .white
        
        GlobalVar.shared.boardTableView.reloadData()
        
        getBoards(resetBoard: true)
        
        prefetcher.isPaused = false
        
        GlobalVar.shared.tabBarVC?.tabBar.items?[3].badgeValue = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playTutorial(key: "isShowedBoardTutorial", type: "board")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        prefetcher.isPaused = true
    }
    
    @IBAction func moveToInput(_ sender: UIButton) {

        let adminCheck = adminCheckStatus()
        if adminCheck == false { return }
        
        screenTransition(storyboardName: BBSInputViewController.storyboard_name_id, storyboardID: BBSInputViewController.storyboard_name_id)
    }
}


//MARK: - Appearance

extension BoardViewController {
    
    private func configureTableView() {
        boardTableView.delegate = self
        boardTableView.dataSource = self
        
        boardTableView.isPrefetchingEnabled = true
        boardTableView.prefetchDataSource = self
        
        boardTableView.register(BBSTableViewCell.nib, forCellReuseIdentifier: BBSTableViewCell.cellIdentifier)
        
        boardTableView.estimatedRowHeight = 160
        boardTableView.rowHeight = UITableView.automaticDimension
        boardTableView.separatorInset = UIEdgeInsets.zero
        boardTableView.sectionHeaderTopPadding = 0.0
        boardTableView.allowsSelection = false
        boardTableView.separatorColor = .systemGray4
        
        configureRefreshControl()
        
        GlobalVar.shared.boardTableView = boardTableView
    }
    
    func configureRefreshControl () {
        boardTableView.refreshControl = UIRefreshControl()
        boardTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        
        let impact = UIImpactFeedbackGenerator(style: .light); impact.impactOccurred()
        
        DispatchQueue.main.async { [weak self] in
            self?.getBoards(initBoard: true)
            self?.boardTableView.refreshControl?.endRefreshing()
            Log.event(name: "reloadBoard")
        }
    }
    
    private func configureShowInputViewButton() {
        showInputViewButton.setShadow(opacity: 0.3, color: .black)
    }
}

//MARK: - UITableViewDataSource

extension BoardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let boardList = GlobalVar.shared.boardList
        let boardNum = boardList.count
        return boardNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BBSTableViewCell.cellIdentifier, for: indexPath) as! BBSTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        
        let boardList = GlobalVar.shared.boardList
        guard let board = boardList[safe: indexPath.row] else { return cell }
        
        cell.configure(board: board)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        let boardList = GlobalVar.shared.boardList
        let boardNum = boardList.count
        let preBoardIndex = boardNum - 3
        let isPreBoardIndex = (index == preBoardIndex)
        
        let isBoardEnd = (boardEnd == true)
        
        if isBoardEnd { return }
        
        if isPreBoardIndex { getBoards() }
    }
}

//MARK: - UITableViewDataSourcePrefetching

extension BoardViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // [Board]
        let boardList = GlobalVar.shared.boardList
        // [URL]
        let mainIconUrls = indexPaths.compactMap {
            guard let board = boardList[safe: $0.row] else { return URL(string: "") }
            let profileIconImg = board.userInfo?.profile_icon_img ?? ""
            return URL(string: profileIconImg)
        }
        let postImgUrls = indexPaths.compactMap {
            guard let board = boardList[safe: $0.row] else { return URL(string: "") }
            let photoImg = board.photos.first ?? ""
            return URL(string: photoImg)
        }
        let urls = mainIconUrls + postImgUrls
        // start prefetching
        prefetcher.startPrefetching(with: urls)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // [Board]
        let boardList = GlobalVar.shared.boardList
        // [URL]
        let mainIconUrls = indexPaths.compactMap {
            guard let board = boardList[safe: $0.row] else { return URL(string: "") }
            let profileIconImg = board.userInfo?.profile_icon_img ?? ""
            return URL(string: profileIconImg)
        }
        let postImgUrls = indexPaths.compactMap {
            guard let board = boardList[safe: $0.row] else { return URL(string: "") }
            let photoImg = board.photos.first ?? ""
            return URL(string: photoImg)
        }
        let urls = mainIconUrls + postImgUrls
        // stop prefetching
        prefetcher.stopPrefetching(with: urls)
    }
}

extension BoardViewController: BBSTableViewCellDelegate {
    
    func didTapMenuAction(cell: BBSTableViewCell) {
        if let board = cell.board, let user = board.userInfo, let loginUID = GlobalVar.shared.loginUser?.uid {
            let targetUID = board.creator
            let own = (targetUID == loginUID)
            boardContact(cell: cell, own: own, board: board, user: user, loginUID: loginUID)
        }
    }
    
    func didTapVisitorAction(cell: BBSTableViewCell) {
        
        let adminCheck = adminCheckStatus()
        if adminCheck == false { return }
        
        if let board = cell.board, let user = board.userInfo, let loginUID = GlobalVar.shared.loginUser?.uid {
            
            let targetUID = user.uid
            
            let isBoardVisited = (cell.visitorButton.tintColor == .accentColor)
            if isBoardVisited { print("すでに足あと済みです"); return }
            
            DispatchQueue.main.async {
                self.boardVisitorUpdate(cell: cell, board: board, loginUID: loginUID, targetID: targetUID)
            }
        }
    }
    
    func didTapMessageAction(cell: BBSTableViewCell) {
        
        let adminCheck = adminCheckStatus()
        if adminCheck == false { return }
        
        if let board = cell.board, let _ = board.userInfo { showBoardMessage(cell: cell) }
    }
    
    func didTapGoDetail(cell: BBSTableViewCell) {
        if let user = cell.board?.userInfo {
            
            let comment = "タイムラインの投稿から来ました！"
            let commentImg = "board"
            
            profileDetailMove(user: user, comment: comment, commentImg: commentImg)
        }
    }
    
    func didTapMessageImage(cell: BBSTableViewCell) {
        if let messageImageView = cell.messageImageView, let messageImage = messageImageView.image {
            if messageImageView.isHidden == false {
                DispatchQueue.main.async { [weak self] in self?.moveImageDetail(image: messageImage) }
            }
        }
    }
    
    private func moveImageDetail(image: UIImage) {
        let storyBoard = UIStoryboard.init(name: "ImageDetailView", bundle: nil)
        let imageVC = storyBoard.instantiateViewController(withIdentifier: "ImageDetailView") as! ImageDetailViewController
        imageVC.pickedImage = image
        present(imageVC, animated: true)
    }
    
    private func boardVisitorUpdate(cell: BBSTableViewCell, board: Board, loginUID: String, targetID: String) {
        
        let impact = UIImpactFeedbackGenerator(style: .light); impact.impactOccurred()
        
        let boardData = ["visitors" : FieldValue.arrayUnion([loginUID])]
        
        let boardID = board.document_id
        db.collection("boards").document(boardID).updateData(boardData)
        
        cell.visitorButton.tintColor = .accentColor
        cell.visitorButton.setImage(UIImage(systemName: "pawprint.fill"), for: .normal)
        
        let globalBoardList = GlobalVar.shared.globalBoardList
        if let globalBoardIndex = globalBoardList.firstIndex(where: { $0.document_id == boardID }) {
            GlobalVar.shared.globalBoardList[globalBoardIndex].visitors.append(loginUID)
        }
        
        let boardCount = 8
        let boardText = board.text
        let boardPrefixText = boardText.prefix(boardCount)
        let comment = (
            boardText.count > boardCount ? "「\(boardPrefixText)..」に足あとを貰いました！" : "「\(boardText)」に足あとを貰いました！"
        )
        let commentImg = "board"
        
        firebaseController.visitor(loginUID: loginUID, targetUID: targetID, comment: comment, commentImg: commentImg, forceUpdate: true)
    }
    
    private func showBoardMessage(cell: BBSTableViewCell) {
        let storyBoard = UIStoryboard.init(name: "PostMessageView", bundle: nil)
        let postMessageVC = storyBoard.instantiateViewController(withIdentifier: "PostMessageView") as! PostMessageViewController
        postMessageVC.transitioningDelegate = self
        postMessageVC.presentationController?.delegate = self
        postMessageVC.boardCell = cell
        present(postMessageVC, animated: true)
    }
    
    private func boardContact(cell: BBSTableViewCell, own: Bool, board: Board, user: User, loginUID: String) {
        if own { // 自分の投稿の場合
            ownShowAlertList(cell: cell, board: board)
        } else { // 自分以外の投稿の場合
            otherShowAlertList(board: board, user: user, loginUID: loginUID)
        }
    }
    
    private func ownShowAlertList(cell: BBSTableViewCell, board: Board) {
        
        var deleteAction = UIAlertAction(title: "削除", style: .default) { [weak self] action in self?.deleteAction(cell: cell, board: board) }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel , handler: nil)
        
        deleteAction = customAlertController(action: deleteAction, imageName: "trash", color: .red)
        
        showAlert(style: .actionSheet, title: nil, message: nil, actions: [deleteAction, cancelAction], completion: nil)
    }
    
    private func otherShowAlertList(board: Board, user: User, loginUID: String) {
        
        var blockAction  = UIAlertAction(title: "ブロック（投稿を非表示）", style: .default) { [weak self] action in self?.blockAction(board: board, loginUID: loginUID) }
        var reportAction = UIAlertAction(title: "投稿を報告する", style: .default) { [weak self] action in self?.reportAction(board: board, user: user) }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel , handler: nil)
        
        blockAction  = customAlertController(action: blockAction, imageName: "nosign", color: .black)
        reportAction = customAlertController(action: reportAction, imageName: "megaphone", color: .black)
        
        let actionList = [blockAction, reportAction, cancelAction]
        showAlert(style: .actionSheet, title: nil, message: nil, actions: actionList, completion: nil)
    }
    
    private func customAlertController(action: UIAlertAction, imageName: String, color: UIColor) -> UIAlertAction {
        action.setValue(UIImage(systemName: imageName), forKey: "image")
        action.setValue(color, forKey: "imageTintColor")
        action.setValue(color, forKey: "titleTextColor")
        return action
    }
    // 削除
    private func deleteAction(cell: BBSTableViewCell, board: Board) {
        
        let boardID = board.document_id
        let targetUID = board.creator
        
        firebaseController.boardDelete(boardID: boardID, targetUID: targetUID, completion: { [weak self] result in
            if result {
                self?.boardTableDelete(cell: cell)
                self?.alert(title: "削除完了", message: "投稿の削除が完了しました！", actiontitle: "OK")
            } else {
                self?.alert(title: "削除失敗...", message: "投稿が正常に削除されませんでした。\nすでに投稿が削除されているかもしれません", actiontitle: "OK")
            }
        })
    }
    
    private func boardTableDelete(cell: BBSTableViewCell) {
        
        if let board = cell.board {
            GlobalVar.shared.globalBoardList = GlobalVar.shared.globalBoardList.filter({ $0.document_id != board.document_id })
            boardDataReset()
        }
    }
    // ブロック
    private func blockAction(board: Board, loginUID: String) {
        
        let targetUID = board.creator
        
        firebaseController.block(loginUID: loginUID, targetUID: targetUID, completion: { [weak self] result in
            if result {
                self?.alert(title: "ブロック完了", message: "ブロック完了しました！", actiontitle: "OK")
            } else {
                self?.alert(title: "ブロック失敗...", message: "ブロックが正常に行われませんでした。\n不具合を運営に報告してください。", actiontitle: "OK")
            }
        })
    }
    // 報告
    private func reportAction(board: Board, user: User) {
        // 違反報告画面に遷移
        let storyBoard = UIStoryboard.init(name: "ViolationView", bundle: nil)
        let violationVC = storyBoard.instantiateViewController(withIdentifier: "ViolationView") as! ViolationViewController
        violationVC.targetUser = user
        violationVC.category = "board"
        violationVC.violationedID = board.document_id
        violationVC.modalPresentationStyle = .popover
        violationVC.transitioningDelegate = self
        violationVC.presentationController?.delegate = self
        present(violationVC, animated: true, completion: nil)
    }
}

extension BoardViewController {
    
    private func getBoardSearchParameters(page: Int = 1) -> SearchParameters {
        
        let perPage = 100
        let searchSortBy = "is_admin:desc, updated_at:desc"
        let searchParameters = SearchParameters(q: "*", queryBy: "", sortBy: searchSortBy, page: page, perPage: perPage)

        return searchParameters
    }
    
    private func getBoards(initBoard: Bool = false, resetBoard: Bool = false) {
        // print("\ngetBoards", "boardPage :", boardPage, "initBoard :", initBoard, "boardEnd :", boardEnd)
        let isInitPage = (boardPage == 1)
        let isResetBoard = (isInitPage && resetBoard)
        
        if initBoard {
            boardPage = 1; boardEnd = false
        } else if isResetBoard {
            boardEnd = false
        } else {
            boardPage = boardPage + 1
        }
        
        Task {
            do {
                let searchParameters = getBoardSearchParameters(page: boardPage)
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "boards").documents().search(searchParameters, for: BoardQuery.self)
                
                searchResultBoards(searchResult: searchResult, page: boardPage)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func searchResultBoards(searchResult: SearchResult<BoardQuery>?, page: Int) {
        
        guard let hits = searchResult?.hits else { setBoards(page: page); return }
        
        let isEmptyHits = (hits.count == 0)
        if isEmptyHits { setBoards(page: page); return }

        let boards = hits.map({ Board(boardQuery: $0) })
        let boardCreators = boards.map({ $0.creator })
        
        getBoardCreators(boardCreators: boardCreators, boards: boards, page: page)
    }
    
    private func getBoardCreators(boardCreators: [String], boards: [Board], page: Int) {
        
        Task {
            do {
                let perPage = 100
                let searchFilterBy = "uid: \(boardCreators) && is_activated:= true && is_deleted:= false"
                let searchParameters = SearchParameters(q: "*", queryBy: "", filterBy: searchFilterBy, perPage: perPage)
                
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "users").documents().search(searchParameters, for: CardUserQuery.self)
                
                guard let hits = searchResult?.hits else { setBoards(page: page); return }
                
                let isEmptyHits = (hits.count == 0)
                if isEmptyHits { setBoards(page: page); return }
                    
                let users = hits.map({ User(cardUserQuery: $0) })
                
                let boardsWithUserInfo = boards.map({
                    let board = $0
                    if let boardCreator = users.filter({ board.creator == $0.uid }).first {
                        board.userInfo = boardCreator
                    }
                    return board
                })
                setBoards(boards: boardsWithUserInfo, page: page)
            }
            catch {
                print("try TypesenseSearch エラー\(error)")
            }
        }
    }
    
    private func setBoards(boards: [Board] = [], page: Int) {
        
        let globalBoards = GlobalVar.shared.globalBoardList
        
        let updateGlobalBoards = globalBoards.map({
            let globalBoard = $0
            if let board = boards.filter({ $0.document_id == globalBoard.document_id }).first { return board }
            return globalBoard
        })
        let duplicateBoards = boards.filter({
            let specificID = $0.document_id
            let checkFilterBoards = (updateGlobalBoards.firstIndex(where: { $0.document_id == specificID }) == nil)
            let exclusionCommonFilter = exclusionCommonFilter(creatorUID: $0.creator, targetUID: nil)
            return checkFilterBoards && exclusionCommonFilter
        })
        let mergeBoards = updateGlobalBoards + duplicateBoards
        
        let isSearchEnd = (globalBoards.count == mergeBoards.count)
        if isSearchEnd { boardEnd = true }
        
//        print(
//            "globalBoards : \(globalBoards.count)",
//            "mergeBoards : \(mergeBoards.count)",
//            "page : \(page)",
//            "isSearchEnd :", isSearchEnd,
//            "boardEnd : \(boardEnd)"
//        )
        
        GlobalVar.shared.globalBoardList = mergeBoards
        
        boardDataReset()
    }
}

extension BoardViewController {
    
    public override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {

        boardTableView.reloadData()
        
        presentationDidDismissMoveMessageRoomAction()
    }
}

//MARK: - UIScrollViewDelegate

extension BoardViewController {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollBeginingPoint = scrollView.contentOffset
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        let topScrollPoint = (currentPoint.y == 0.0)
        if topScrollPoint { self.navigationController?.setNavigationBarHidden(false, animated: true) }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
