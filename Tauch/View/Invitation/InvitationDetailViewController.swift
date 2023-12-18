//
//  InvitationDetailViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/05/27.
//

import UIKit

class InvitationDetailViewController: UIBaseViewController {

    @IBOutlet weak var invitationDetail: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var goodTableView: UITableView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var goodCount: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var specificInvitation: Invitation?
    var ownRooms = [Room]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goodTableView.delegate = self
        iconImage.layer.cornerRadius = 10
        // お誘いユーザを取得
        guard let invitation = specificInvitation else { return }
        invitation.goodUsers = fetchInvitationGoodUserInfo(invitation: invitation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationWithBackBtnSetUp(navigationTitle: "お誘いの詳細")
        hideNavigationBarBorderAndShowTabBarBorder()
        
        if GlobalVar.shared.specificInvitation != nil {
            specificInvitation = GlobalVar.shared.specificInvitation
        }
        guard let invitation = specificInvitation else { return }
        // お誘い状態に応じて表示を変更
        let isSpecificInvitationDeleted = invitation.is_deleted ?? false
        if isSpecificInvitationDeleted {
            // お誘い一覧画面に遷移
            self.navigationController?.popViewController(animated: true)
            
        } else {
            // お誘い情報を設定
            setInvitationInfo(invitation: invitation)
            // 既読
            readMemberCount(invitation: invitation)
        }
        //自分のお誘いの時のみ編集/削除ボタンを表示
        let currentUID = GlobalVar.shared.loginUser?.uid
        if currentUID == invitation.creator {
            deleteButton.isEnabled = true
            editButton.isEnabled = true
            deleteButton.tintColor = UIColor(named: "FontColor")
            editButton.tintColor = UIColor(named: "FontColor")
        } else {
            deleteButton.isEnabled = false
            editButton.isEnabled = false
            deleteButton.tintColor = .clear
            editButton.tintColor = .clear
        }
        GlobalVar.shared.specificInvitation = invitation
        GlobalVar.shared.goodTableView = goodTableView
        goodTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.set("", forKey: "specificInvitationID")
        UserDefaults.standard.synchronize()
    }
    
    func setInvitationInfo(invitation: Invitation) {
        // お誘い最新投稿日時 (オンライン)
        let onlineStatus = elapsedNewTime(registTime: invitation.updated_at?.dateValue() ?? Date())
        status.text = onlineStatus
        // お誘いカテゴリ
        category.text = invitation.category
        // お誘い日程
        day.text = invitation.date.joined(separator: ", ")
        // お誘いエリア
        area.text = invitation.area
        // 応募カウント
        goodCount.text = String(invitation.goodUsers.count)
        // お誘い詳細
        guard let invitationContent = invitation.content else { return }
        invitationDetail.text = invitationContent.components(separatedBy: .whitespacesAndNewlines).joined()
        // 画像設定
        guard let profileIcon = invitation.userInfo?.profile_icon_img else { return }
        iconImage.setImage(withURLString: profileIcon)
    }
    
    // お誘いメンバーを既読にする
    private func readMemberCount(invitation: Invitation) {
        guard let invitationUID = invitation.document_id else { return }
        let members = invitation.members
        let readMembers = invitation.read_members
        let unreadMembers = members.filter({ readMembers.firstIndex(of: $0) == nil })
        let unreadMembersCount = unreadMembers.count
        if unreadMembersCount == 0 { return }
        /// お誘い情報を更新
        let updateData = [
            "read_members": members
        ] as [String : Any]
        
        db.collection("invitations").document(invitationUID).updateData(updateData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err { print("お誘い状態の更新に失敗しました: \(err)"); return }
            weakSelf.tabBarController?.tabBar.items?[3].badgeValue = nil
        }
    }
    
    //募集編集画面に遷移
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        invitationEdit()
    }
    
    private func invitationEdit() {
        let storyboard = UIStoryboard(name: "InvitationCreateView", bundle: nil)
        let invitationCreateVC = storyboard.instantiateViewController(withIdentifier: "InvitationCreateView") as! InvitationCreateViewController
        invitationCreateVC.invitationPageType = "edit"
        invitationCreateVC.specificInvitation = specificInvitation
        navigationController?.pushViewController(invitationCreateVC, animated: true)
    }
    
    // お誘い削除
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        dialog(title: "この募集を削除しますか？", subTitle: "この操作は取り消しできません。", confirmTitle: "削除", completion: { [weak self] result in
            guard let weakSelf = self else { return }
            if result {
                weakSelf.invitationDelete()
            }
        })
    }
    
    private func invitationDelete() {
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let invitationUID = specificInvitation?.document_id else { return }
        // お誘い削除処理を実施
        firebaseController.invitationDelete(invitationUID: invitationUID, loginUID: loginUID, targetUID: loginUID, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            if result {
                weakSelf.specificInvitation?.is_deleted = true
                let alertTitle = "削除しました"
                let alertMessage = ""
                let alertActionTitle = "OK"
                weakSelf.alertWithAction(title: alertTitle, message: alertMessage, actiontitle: alertActionTitle, type: "back")
                GlobalVar.shared.ownSpecificInvitation = [:]
                
            } else {
                weakSelf.alert(title: "お誘い削除に失敗しました。。", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
            }
        })
    }
}

extension InvitationDetailViewController {
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentationDidDismissMoveMessageRoomAction()
    }
}

extension InvitationDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let globalInvitation = GlobalVar.shared.specificInvitation {
            let globalGoodUsers = globalInvitation.goodUsers
            goodCount.text = String(globalGoodUsers.count)
            return globalGoodUsers.count
            
        } else {
            let goodUsers = specificInvitation?.goodUsers ?? [User]()
            goodCount.text = String(goodUsers.count)
            return goodUsers.count
        }
    }
    //あなたをGoodをした人セル生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentUID = GlobalVar.shared.loginUser?.uid
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoodCell") as! GoodCell
        cell.delegate = self
        if let globalInvitation = GlobalVar.shared.specificInvitation {
            let globalGoodUsers = globalInvitation.goodUsers
            cell.goodUser = globalGoodUsers[safe: indexPath.row]
            if currentUID != globalInvitation.creator {
                cell.goodButton.isHidden = true
            }
            
        } else {
            let goodUsers = specificInvitation?.goodUsers ?? [User]()
            cell.goodUser = goodUsers[safe: indexPath.row]
            if currentUID != specificInvitation?.creator {
                cell.goodButton.isHidden = true
            }
        }
        return cell
    }
}

extension InvitationDetailViewController: GoodCellDelegate {
    
    func didTapGoProfileDetail(cell: GoodCell) {
        if let user = cell.goodUser { profileDetailMove(user: user) }
    }
    
    func didInvitationMatching(cell: GoodCell) {
        guard let target = cell.goodUser else { return }
        dialog(title: "この人とマッチしますか？", subTitle: "goodを押すとマッチングが成立して相手とのトークルームが作成されます。", confirmTitle: "マッチする", completion: { [weak self] result in
            guard let weakSelf = self else { return }
            if result {
                weakSelf.applicationOK(target: target)
            }
        })
    }
    
    func didInvitationNg(cell: GoodCell) {
        guard let target = cell.goodUser else { return }
        dialog(title: "この人の応募をお断りしますか？", subTitle: "badを押すと応募一覧から相手の応募がなくなります。", confirmTitle: "お断り", completion: { [weak self] result in
            guard let weakSelf = self else { return }
            if result {
                weakSelf.applicationNG(target: target)
            }
        })
    }
    
    // マッチング時の動作
    private func applicationOK(target: User) {
        guard let loginUser = GlobalVar.shared.loginUser else { return }
        guard let invitation = GlobalVar.shared.specificInvitation else { return }
        let loginUID = loginUser.uid
        var rooms = loginUser.rooms
        if rooms.isEmpty { rooms = ownRooms }
        let targetUID = target.uid
        let roomType = "invitation"
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        // メッセージルームを作成し画面遷移
        firebaseController.messageRoomAction(roomType: roomType, rooms: rooms, invitation: specificInvitation, loginUID: loginUID, targetUID: targetUID, completion: { [weak self] roomID in
            guard let weakSelf = self else { return }
            if let roomId = roomID {
                let alert = UIAlertController(title: "お誘いマッチングに成功しました!", message: "詳細なお誘い情報をメッセージルームにてやりとりしてください!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    guard let weakSubSelf = self else { return }
                    let approachStatus = 0
                    weakSubSelf.invitationUpdate(invitation: invitation, targetUID: targetUID, approachStatus: approachStatus)
                    weakSubSelf.moveMessageRoom(roomID: roomId, target: target)
                })
                weakSelf.present(alert, animated: true)
                
            } else {
                weakSelf.alert(title: "お誘いマッチングに失敗しました。。", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
            }
        })
    }
    
    // NG時の動作
    private func applicationNG(target: User) {
        guard let invitation = GlobalVar.shared.specificInvitation else { return }
        let targetUID = target.uid
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        // お誘いメンバーの更新
        let approachStatus = 1
        invitationUpdate(invitation: invitation, targetUID: targetUID, approachStatus: approachStatus)
    }
    
    private func invitationUpdate(invitation: Invitation, targetUID: String, approachStatus: Int) {
        
        guard let invitationID = invitation.document_id else { return }
        
        var invitationMembers = invitation.members
        var invitationMatchMembers = invitation.match_members
        var invitationNgMembers = invitation.ng_members
        // 応募マッチ状態の時
        if approachStatus == 0 { invitationMatchMembers.append(targetUID) }
        // 応募NGの場合
        if approachStatus == 1 { invitationNgMembers.append(targetUID) }
        
        invitationMembers = invitationMembers.filter({ $0 != targetUID })
        let updateData = [
            "members": invitationMembers,
            "read_members": invitationMembers,
            "match_members": invitationMatchMembers,
            "ng_members": invitationNgMembers
        ] as [String : Any]
        
        db.collection("invitations").document(invitationID).updateData(updateData) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                print("お誘い状態の更新に失敗しました: \(err)")
                return
            }
            print("お誘い状態の更新に成功しました")
            let logEventData = [
                "target": targetUID
            ] as [String : Any]
            
            switch approachStatus {
            case 0: // 応募OK
                Log.event(name: "invitationApplicationOK", logEventData: logEventData)
                break
            case 1: // 応募NG
                Log.event(name: "invitationApplicationNG", logEventData: logEventData)
                break
            default:
                break
            }
            GlobalVar.shared.specificInvitation?.members = invitationMembers
            GlobalVar.shared.specificInvitation?.read_members = invitationMembers
            GlobalVar.shared.specificInvitation?.match_members = invitationMatchMembers
            GlobalVar.shared.specificInvitation?.ng_members = invitationNgMembers
            guard var goodUsers = GlobalVar.shared.specificInvitation?.goodUsers else { return }
            goodUsers = goodUsers.filter({ $0.uid != targetUID })
            GlobalVar.shared.specificInvitation?.goodUsers = goodUsers
            weakSelf.goodTableView.reloadData()
        }
    }
}

protocol GoodCellDelegate: AnyObject {
    func didTapGoProfileDetail(cell: GoodCell)
    func didInvitationMatching(cell: GoodCell)
    func didInvitationNg(cell: GoodCell)
}

class GoodCell: UITableViewCell {
    
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var profileDetail: UILabel!
    
    var goodUser: User? {
        didSet {
            if let goodUser = goodUser {
                // 相手の名前を表示
                nickName.text = "..."
                // 相手の画像を設定
                iconImage.image = UIImage()
                let goodUserNickName = goodUser.nick_name
                let goodUserProfileIconImg = goodUser.profile_icon_img
                let goodUserBirthDate = goodUser.birth_date
                let goodUserAddress = goodUser.address
                let goodUserAddress2 = goodUser.address2
                // ニックネーム
                if goodUserNickName.isEmpty == false {
                    // 相手の名前を表示
                    nickName.text = goodUserNickName
                }
                // 画像
                let isNotMember = (nickName.text != "...")
                if isNotMember && goodUserProfileIconImg.isEmpty == false {
                    iconImage.setImage(withURLString: goodUserProfileIconImg)
                }
                // 年齢
                var age = ""
                if goodUserBirthDate.isEmpty == false {
                    age = goodUserBirthDate.calcAge()
                }
                // 現住所
                var mergeAddress = ""
                if goodUserAddress.isEmpty == false && goodUserAddress2.isEmpty == false {
                    mergeAddress = "\(goodUserAddress)\(goodUserAddress2)"
                } else if goodUserAddress.isEmpty == false && goodUserAddress2.isEmpty == true {
                    mergeAddress = "\(goodUserAddress)"
                } else if goodUserAddress.isEmpty == true && goodUserAddress2.isEmpty == false {
                    mergeAddress = "\(goodUserAddress2)"
                }
                // プロフィール詳細
                if age.isEmpty == false && mergeAddress.isEmpty == false {
                    profileDetail.text = age + " ・ " + mergeAddress
                } else if age.isEmpty == false && mergeAddress.isEmpty == true {
                    profileDetail.text = age
                } else if age.isEmpty == true && mergeAddress.isEmpty == false {
                    profileDetail.text = mergeAddress
                } else {
                    profileDetail.text = ""
                }
            }
        }
    }
    
    weak var delegate: GoodCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImage.layer.cornerRadius = 25
        iconBtn.addTarget(self, action: #selector(didTapGoProfileDetail), for: .touchUpInside)
        goodButton.layer.cornerRadius = goodButton.frame.height / 2
        goodButton.setShadow()
        goodButton.addTarget(self, action: #selector(didInvitationMatching), for: .touchUpInside)
        badButton.layer.cornerRadius = badButton.frame.height / 2
        badButton.setShadow()
        badButton.addTarget(self, action: #selector(didInvitationNg), for: .touchUpInside)
    }
    // プロフィール詳細ページに移動
    @objc func didTapGoProfileDetail() {
        delegate?.didTapGoProfileDetail(cell: self)
    }
    // マッチング処理
    @objc func didInvitationMatching() {
        delegate?.didInvitationMatching(cell: self)
    }
    // NG処理
    @objc func didInvitationNg() {
        delegate?.didInvitationNg(cell: self)
    }
}
