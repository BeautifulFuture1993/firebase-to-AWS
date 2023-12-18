//
//  NewMatchTableViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/06/16.
//

import UIKit

class NewMatchTableViewCell: UITableViewCell {

    @IBOutlet weak var newMatchTitle: UILabel!
    @IBOutlet weak var newMatchCollectionView: UICollectionView!
    
    static let nibName = "NewMatchTableViewCell"
    static let cellIdentifier = "NewMatchTableViewCell"
    static let height: CGFloat = 150
    
    private var rooms: [Room] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        newMatchCollectionView.delegate = self
        newMatchCollectionView.dataSource = self
        newMatchCollectionView.register(UINib(nibName: NewMatchChildCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: NewMatchChildCollectionViewCell.cellIdentifier)
        
        GlobalVar.shared.newMatchCollectionView = newMatchCollectionView
        
        newMatchTitleCustom()
    }
    
    func configure(with rooms: [Room]) {
        
        self.rooms = rooms
        
        newMatchCollectionView.reloadData()
    }
    
    private func newMatchTitleCustom() {
        
        guard let newMatchTitleText = newMatchTitle.text else { return }
        
        let attrText = NSMutableAttributedString(string: newMatchTitleText)
        
        attrText.addAttributes([
            .foregroundColor: UIColor(.black),
            .font: UIFont.boldSystemFont(ofSize: 14)
        ], range: NSMakeRange(6, 6))
        
        newMatchTitle.attributedText = attrText
    }
}

extension NewMatchTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewMatchChildCollectionViewCell.cellIdentifier, for: indexPath) as! NewMatchChildCollectionViewCell
        cell.delegate = self
        
        if let room = rooms[safe: indexPath.row] { cell.configure(with: room) }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = NewMatchChildCollectionViewCell.width
        let height = NewMatchChildCollectionViewCell.height
        let cgSize = CGSize(width: width, height: height)
        return cgSize
    }
}

extension NewMatchTableViewCell: NewMatchChildCollectionViewCellDelegate {
    
    func didTapGoRoom(cell: NewMatchChildCollectionViewCell) {
        if let room = cell.room { newMatchRoomMove(room: room) }
    }
    
    private func newMatchRoomMove(room: Room) {
        
        let roomID = room.document_id ?? ""
        let logEventData = [
            "roomID": roomID
        ] as [String : Any]
        Log.event(name: "selectNewMatchRoom", logEventData: logEventData)

        if let parentVC = parentViewController() as? MessageListViewController {
            //本人確認していない場合は確認ページを表示
            guard let adminIDCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status else {
                parentVC.popUpIdentificationView()
                return
            }
            if adminIDCheckStatus == 1 {
                parentVC.specificMessageRoomMove(specificRoom: room)
                
            } else if adminIDCheckStatus == 2 {
                let title = "本人確認失敗しました"
                let subTitle = "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください"
               
                parentVC.dialog(title: title, subTitle: subTitle, confirmTitle: "OK", completion: { confirm in
                    if confirm { parentVC.popUpIdentificationView() }
                })

           } else {
               let title = "本人確認中です"
               let message = "現在本人確認中\n（12時間以内に承認が完了します）"
               
               parentVC.alert(title: title, message: message, actiontitle: "OK")
           }
        }
    }
}

//cellから親viewControllerにアクセス
extension NewMatchTableViewCell {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }
}
