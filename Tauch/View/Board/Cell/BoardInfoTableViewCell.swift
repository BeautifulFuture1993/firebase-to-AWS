//
//  BoardInfoTableViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/06/06.
//

import UIKit

protocol BoardInfoTableViewCellDelegate: AnyObject {
    func didTapProfileDetail(cell: BoardInfoTableViewCell)
    func didTapBoardMenu(cell: BoardInfoTableViewCell)
    func didTapBoardVisitor(cell: BoardInfoTableViewCell)
}

class BoardInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var boardCategoryLabel: UILabel!
    @IBOutlet weak var boardMenuButton: UIButton!
    @IBOutlet weak var boardCreatedLabel: UILabel!
    @IBOutlet weak var boardTextLabel: UILabel!
    @IBOutlet weak var boardVisitorView: UIView!
    @IBOutlet weak var boardVisitorButton: UIButton!
    
    static let nibName = "BoardInfoTableViewCell"
    static let cellIdentifier = "BoardInfoTableViewCell"
    
    var boardIndexPath: IndexPath?
    var board: Board?
    weak var delegate: BoardInfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        iconImageView.setShadow(opacity: 0.1, color: UIColor.darkGray)
        
        nickNameLabel.setShadow()
        
        boardVisitorButton.layer.cornerRadius = boardVisitorButton.frame.height / 2
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapProfileDetail))
        iconImageView.addGestureRecognizer(tapGestureRecognizer)
        
        boardMenuButton.addTarget(self, action: #selector(didTapBoardMenu), for: .touchUpInside)
        boardVisitorButton.addTarget(self, action: #selector(didTapBoardVisitor), for: .touchUpInside)
    }
    // プロフィール詳細ページに移動
    @objc func didTapProfileDetail() {
        delegate?.didTapProfileDetail(cell: self)
    }
    // メニューを開く
    @objc func didTapBoardMenu() {
        delegate?.didTapBoardMenu(cell: self)
    }
    // 足あとをつける
    @objc func didTapBoardVisitor() {
        delegate?.didTapBoardVisitor(cell: self)
    }
    
    func configure(board: Board) {
        
        self.board = board
        
        let boardTime = board.created_at.dateValue()
        let boardCategory = board.category
        let boardText = board.text
        let boardVisitors = board.visitors
        let boardCreator = board.creator
        
        boardCreatedLabel.text = ElapsedTime.elapsedTime(from: boardTime)
        boardCategoryLabel.text = boardCategory
        boardTextLabel.text = boardText
        
        let loginUID = GlobalVar.shared.loginUser?.uid ?? ""
        boardVisitorView.isHidden = (loginUID == boardCreator ? true : false)
        boardVisitorButton.isHidden = (loginUID == boardCreator ? true : false)
        boardVisitorButton.tintColor = (boardVisitors.contains(loginUID) ? .accentColor : .lightGray)
        
        if let boardVisitorButtonImage = (
            boardVisitors.contains(loginUID) ? UIImage(systemName: "pawprint.fill") : UIImage(systemName: "pawprint")
        ) {
            boardVisitorButton.setImage(boardVisitorButtonImage, for: .normal)
        }
        
        if let user = board.userInfo {
            
            let nickName = user.nick_name
            let profileIconImg = user.profile_icon_img
            
            iconImageView.setImage(withURLString: profileIconImg)
            nickNameLabel.text = nickName
        }
    }
}
