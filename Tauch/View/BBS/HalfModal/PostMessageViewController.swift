//
//  PostMessageViewController.swift
//  Tauch
//
//  Created by Apple on 2023/06/23.
//

import UIKit
import KMPlaceholderTextView
import FirebaseFirestore

class PostMessageViewController: UIBaseViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryTagView: BBSCategoryTagView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageInputView: KMPlaceholderTextView!
    @IBOutlet weak var messageCountLabel: UILabel!
    
    var boardCell: BBSTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let cell = boardCell { setBoardInfo(cell: cell) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configure() {
        
        iconImageView.clipsToBounds = true
        iconImageView.rounded()
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.isUserInteractionEnabled = true
        
        nameLabel.font = .systemFont(ofSize: 14.0, weight: .bold)
        nameLabel.textColor = .fontColor
        
        categoryLabel.font = .systemFont(ofSize: 11.0, weight: .medium)
        categoryLabel.textColor = .white
        
        messageTextView.font = .systemFont(ofSize: 14.0)
        messageTextView.isScrollEnabled = false
        
        sendButton.rounded()
        sendButton.disable()
        
        messageInputView.delegate = self
        messageInputView.layer.cornerRadius = 10
        messageInputView.becomeFirstResponder()
        
        messageCountLabel.text = "0"
        messageCountLabel.textColor = .fontColor
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        messageInputView.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @IBAction func didTapSendMessage(_ sender: Any) {
        messageInputView.resignFirstResponder()
        postMessage()
    }
    
    private func setBoardInfo(cell: BBSTableViewCell) {
        iconImageView.image = cell.iconImageView.image
        nameLabel.text = cell.nameLabel.text
        categoryTagView.backgroundColor = cell.categoryTagView.backgroundColor
        categoryLabel.text = cell.categoryLabel.text
        messageTextView.text = cell.messageTextView.text
        
        let boardAdmin = cell.board?.is_admin ?? false
        let isAdmin = (boardAdmin == true)
        
        categoryLabel.isHidden = (isAdmin ? true : false)
        categoryTagView.isHidden = (isAdmin ? true : false)
    }
    // 投稿内容を140文字以上入力させない
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        let messageCount = messageInputView.text.count
        messageCountLabel.text = String(messageCount)
        
        if messageCount > 140 {
            messageCountLabel.textColor = .red
            sendButton.disable()
        } else if messageCount > 0 {
            messageCountLabel.textColor = .fontColor
            sendButton.enable()
        } else {
            messageCountLabel.textColor = .fontColor
            sendButton.disable()
        }
    }
    
    private func postMessage() {
        
        guard let board = boardCell?.board else { return }
        guard let target = board.userInfo else { return }
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        
        showLoadingView(loadingView)
        
        let ownRooms = [Room]()
        let loginUID = loginUser.uid
        var rooms = loginUser.rooms
        if rooms.isEmpty { rooms = ownRooms }
        let targetUID = target.uid
        let roomType = "board"
        let boardSendText = messageInputView.text
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        // アプローチ強制マッチ
        firebaseController.approachForceMatch(loginUID: loginUID, targetUID: targetUID, completion: { [weak self] result in
            
            switch result {
            case "already-approach": print("すでにアプローチ済みです"); break
            case "approached-match": print("アプローチされたマッチ"); break
            case "approached-match-error": print("アプローチされたマッチエラー"); break
            case "approach-match": print("アプローチマッチ"); break
            case "approach-match-error": print("アプローチマッチエラー"); break
            default: break
            }
            // メッセージルームを作成し画面遷移
            self?.firebaseController.messageRoomAction(roomType: roomType, rooms: rooms, board: board, boardSendText: boardSendText, loginUID: loginUID, targetUID: targetUID, completion: { [weak self] roomID in
                
                self?.loadingView.removeFromSuperview()
                
                if let _ = roomID {
                    self?.boardSendMessage(board: board, loginUID: loginUID)
                } else {
                    self?.customAlert(status: "send-message-error")
                }
            })
        })
    }
    
    private func boardSendMessage(board: Board, loginUID: String) {
        let title = "投稿へのメッセージ送信に成功しました!"
        let message = "メッセージルームにてやりとりしてください!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in self?.boardUpdate(board: board, loginUID: loginUID) })
        present(alert, animated: true)
    }
    
    private func boardUpdate(board: Board, loginUID: String) {
        
        let boardData = ["messangers" : FieldValue.arrayUnion([loginUID])]
        
        let boardID = board.document_id
        db.collection("boards").document(boardID).updateData(boardData)
        
        boardCell?.messageButton.tintColor = .accentColor
        boardCell?.messageButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
        
        let globalBoardList = GlobalVar.shared.globalBoardList
        if let globalBoardIndex = globalBoardList.firstIndex(where: { $0.document_id == boardID }) {
            GlobalVar.shared.globalBoardList[globalBoardIndex].messangers.append(loginUID)
        }
        
        dismiss(animated: true)
    }
    
    private func customAlert(status: String) {
        
        switch status {
        case "send-message-error":
            let title = "投稿へのメッセージ送信に失敗しました。。"
            let message = "アプリを再起動して再度実行してください。"
            alert(title: title, message: message, actiontitle: "OK")
            break
        default:
            dismiss(animated: true)
            break
        }
    }
}
