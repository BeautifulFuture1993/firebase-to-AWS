//
//  BoardViewController.swift
//  Tauch
//
//  Created by Apple on 2023/06/06.
//

import UIKit
import FirebaseFirestore
import Typesense

class BoardViewController: UIBaseViewController {

    @IBOutlet weak var boardTableView: UITableView!
    @IBOutlet weak var boardButton: UIButton!
    
    static let storyboardName = "BoardView"
    static let storyboardId = "BoardView"
    
    let categoryPicker = UIPickerView()
    let boardCategory = GlobalVar.shared.boardCategories
    
    var boardPage = 1
    var boardEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpBoardComponent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getBoards(initBoard: true)
        reloadBoardComponent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playTutorial(key: "isShowedBoardTutorial", type: "board")
    }
    
    // 作成したカスタムセルを登録
    private func registerCustomCell(nibName: String, cellIdentifier: String) {
        boardTableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    private func setUpBoardComponent() {
        
        boardTableView.delegate = self
        boardTableView.dataSource = self
        
        registerCustomCell(nibName: BoardInfoTableViewCell.nibName, cellIdentifier: BoardInfoTableViewCell.cellIdentifier)

        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        boardButton.layer.cornerRadius = boardButton.frame.height / 2
        boardButton.setShadow()
        boardButton.addTarget(self, action: #selector(moveBoardCreate), for: .touchUpInside)
        
        configureRefreshControl()
        
        GlobalVar.shared.boardTableView = boardTableView
    }
    
    func configureRefreshControl () {
        boardTableView.refreshControl = UIRefreshControl()
        boardTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        DispatchQueue.main.async { [weak self] in
            self?.getBoards(initBoard: true)
            self?.boardTableView.refreshControl?.endRefreshing()
            self?.logEvent(name: "reloadBoard")
        }
    }
    
    private func reloadBoardComponent() {
        navigationWithSetUp(navigationTitle: "みんなのタイムライン")
        
        tabBarController?.tabBar.backgroundColor = .white
        
        GlobalVar.shared.boardTableView.reloadData()
        
        view.bringSubviewToFront(boardButton)
    }
    
    @objc func moveBoardCreate() {
        DispatchQueue.main.async {
            self.screenTransition(storyboardName: BoardCreateViewController.storyboardName, storyboardID: BoardCreateViewController.storyboardId)
        }
    }
}

extension BoardViewController: UITableViewDataSource {
    
//    // お誘いヘッダー生成
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let tableViewCGRect = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height)
//        let categoryView: UIView = UIView(frame: tableViewCGRect)
//
//        let categoryLabel: UILabel = UILabel()
//        categoryLabel.text = "カテゴリー"
//        categoryLabel.textColor = UIColor().setColor(colorType: "fontColor", alpha: 1.0)
//        categoryLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 14)
//
//        categoryView.addSubview(categoryLabel)
//        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
//        categoryLabel.leftAnchor.constraint(equalTo: categoryView.leftAnchor, constant: 30).isActive = true
//        categoryLabel.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor).isActive = true
//        categoryLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        categoryLabel.clipsToBounds = true
//
//        let categoryTextFieldCGRect = CGRect(x: 0, y: 0, width: 100, height: 20)
//        let categoryTextField: CustomTextField = CustomTextField(frame: categoryTextFieldCGRect)
//        categoryTextField.delegate = self
//
//        categoryTextField.text = GlobalVar.shared.boardSelectCategory
//        categoryTextField.resignFirstResponder()
//        categoryTextField.textColor = UIColor().setColor(colorType: "accentColor", alpha: 1.0)
//        categoryTextField.textAlignment = .center
//        categoryTextField.backgroundColor = .white
//        categoryTextField.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 14)
//        categoryTextField.layer.cornerRadius = categoryTextField.frame.height / 2
//
//        categoryTextField.inputView = categoryPicker
//
//        let doneAction = UIAction() { [weak self] _ in
//            guard let weakSelf = self else { return }
//            let selectRow = weakSelf.categoryPicker.selectedRow(inComponent: 0)
//            if let category = weakSelf.boardCategory[safe: selectRow] {
//                categoryTextField.text = category
//                categoryTextField.resignFirstResponder()
//            }
//        }
//
//        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
//        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
//
//        doneItem.primaryAction = doneAction
//        toolbar.setItems([spacelItem, doneItem], animated: true)
//        categoryTextField.inputAccessoryView = toolbar
//
//        categoryView.addSubview(categoryTextField)
//        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
//        categoryTextField.leftAnchor.constraint(equalTo: categoryLabel.rightAnchor, constant: 10).isActive = true
//        categoryTextField.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor).isActive = true
//        categoryTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        categoryTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        categoryTextField.clipsToBounds = true
//
//        // オブジェクトを追加した後に影をつける
//        categoryTextField.layer.masksToBounds = false
//        categoryTextField.layer.shadowRadius = 3.0
//        categoryTextField.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        categoryTextField.layer.shadowColor = UIColor.black.cgColor
//        categoryTextField.layer.shadowOpacity = 0.1
//
//        return categoryView
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let boardList = GlobalVar.shared.boardList
        let boardNum = boardList.count
        return boardNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BoardInfoTableViewCell.cellIdentifier, for: indexPath) as! BoardInfoTableViewCell
        cell.delegate = self
        cell.boardIndexPath = indexPath
        cell.tag = indexPath.row
        
        let boardList = GlobalVar.shared.boardList
        guard let board = boardList[safe: indexPath.row] else { return cell }
        
        cell.configure(board: board)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        let boardNum = GlobalVar.shared.boardList.count
        let preBoardIndex = boardNum - 3
        let isPreBoardIndex = (index == preBoardIndex)
        
        let isBoardEnd = (boardEnd == true)
        
        if isBoardEnd { return }
        
        if isPreBoardIndex { boardPage += 1; getBoards(page: boardPage) }
    }
}

extension BoardViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return boardCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return boardCategory[safe: row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let selectBoardCategory = boardCategory[safe: row] {
            GlobalVar.shared.boardSelectCategory = selectBoardCategory
            boardDataReset()
            logEvent(name: "filterBoardList")
        }
    }
}

extension BoardViewController: BoardInfoTableViewCellDelegate {
    
    func didTapProfileDetail(cell: BoardInfoTableViewCell) {
        if let user = cell.board?.userInfo { profileDetailMove(user: user) }
    }
    
    func didTapBoardMenu(cell: BoardInfoTableViewCell) {
        if let board = cell.board, let user = board.userInfo, let loginUID = GlobalVar.shared.loginUser?.uid {
            let targetUID = board.creator
            let own = (targetUID == loginUID)
            boardContact(cell: cell, own: own, board: board, user: user, loginUID: loginUID)
        }
    }
    
    func didTapBoardVisitor(cell: BoardInfoTableViewCell) {
        
        let adminCheck = adminCheckStatus()
        if adminCheck == false { return }
        
        if let board = cell.board, let user = board.userInfo, let loginUID = GlobalVar.shared.loginUser?.uid {
            
            let targetUID = user.uid
            
            let isBoardVisited = (cell.boardVisitorButton.tintColor == .accentColor)
            if isBoardVisited { print("すでに足あと済みです"); return }
            
            DispatchQueue.main.async {
                self.boardVisitorUpdate(cell: cell, board: board, loginUID: loginUID, targetID: targetUID)
            }
        }
    }
    
    private func boardVisitorUpdate(cell: BoardInfoTableViewCell, board: Board, loginUID: String, targetID: String) {
        
        let impact = UIImpactFeedbackGenerator(style: .heavy); impact.impactOccurred()
        
        let boardData = ["visitors" : FieldValue.arrayUnion([loginUID])]
        
        let boardID = board.document_id
        db.collection("boards").document(boardID).updateData(boardData)
        
        cell.boardVisitorButton.tintColor = .accentColor
        cell.boardVisitorButton.setImage(UIImage(systemName: "pawprint.fill"), for: .normal)
        
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
    
    private func boardContact(cell: BoardInfoTableViewCell, own: Bool, board: Board, user: User, loginUID: String) {
        if own { // 自分の投稿の場合
            ownShowAlertList(cell: cell, board: board)
        } else { // 自分以外の投稿の場合
            otherShowAlertList(board: board, user: user, loginUID: loginUID)
        }
    }
    
    private func ownShowAlertList(cell: BoardInfoTableViewCell, board: Board) {
        
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
    private func deleteAction(cell: BoardInfoTableViewCell, board: Board) {
        
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
    
    private func boardTableDelete(cell: BoardInfoTableViewCell) {
        
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
        let searchSortBy = "updated_at:desc"
        let searchParameters = SearchParameters(q: "*", queryBy: "", sortBy: searchSortBy, page: page, perPage: perPage)

        return searchParameters
    }
    
    private func getBoards(page: Int = 1, initBoard: Bool = false) {
        
        if initBoard { boardPage = 1; boardEnd = false }
        
        Task {
            do {
                let searchParameters = getBoardSearchParameters(page: page)
                let typesenseClient = GlobalVar.shared.typesenseClient
                let (searchResult, _) = try await typesenseClient.collection(name: "boards").documents().search(searchParameters, for: BoardQuery.self)
                
                searchResultBoards(searchResult: searchResult, page: page)
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
                let searchFilterBy = "uid: \(boardCreators)"
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
        
        if globalBoards.count == mergeBoards.count { boardEnd = true }
        
        print(
            "globalBoards : \(globalBoards.count)",
            "mergeBoards : \(mergeBoards.count)",
            "page : \(page)",
            "boardEnd : \(boardEnd)"
        )
        
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
