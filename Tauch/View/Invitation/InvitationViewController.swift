//
//  GoOutViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/05/24.
//

import UIKit
import Nuke

class InvitationViewController: UIBaseViewController {

    @IBOutlet weak var invitationTableView: UITableView!
    
    let invitationButton = UIButton()
    let placePicker = UIPickerView()
    let categoryPicker = UIPickerView()
    var areas: [String] = {
        var invitationAreas = GlobalVar.shared.areas
        invitationAreas.insert("オンライン", at: 0)
        invitationAreas.insert("全て", at: 0)
        return invitationAreas
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初期セットアップ
        setUpComponent()
    }
    
    private func setUpComponent() {
        invitationTableView.delegate = self
        invitationTableView.dataSource = self
        let tableFooterViewRect = CGRect(x: 0, y: 0, width: invitationTableView.frame.width, height: 50)
        invitationTableView.tableFooterView = UIView(frame: tableFooterViewRect)
        invitationTableView.sectionHeaderHeight = 30
        
        // prefetch
        invitationTableView.isPrefetchingEnabled = true
        invitationTableView.prefetchDataSource = self

        placePicker.delegate = self
        placePicker.dataSource = self
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        configureRefreshControl()
        GlobalVar.shared.invitationListTableView = invitationTableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ナビゲーションセットアップ
        navigationWithSetUp(navigationTitle: "お誘い")
        tabBarController?.tabBar.backgroundColor = .white
        // テーブルをリロード
        GlobalVar.shared.globalFilterInvitations = GlobalVar.shared.globalInvitations
        GlobalVar.shared.invitationListTableView.reloadData()
        // お誘いをセット
        setInvitations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 本人確認状態に応じてボタンの表示を変更
        setCustomForAdminCheckStatus()
        // チュートリアル
        playTutorial(key: "isShowedInvitationTutorial", type: "invitation")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // ロード画面、募集ボタン削除
        invitationButton.removeFromSuperview()
    }
    
    func configureRefreshControl () {
        invitationTableView.refreshControl = UIRefreshControl()
        invitationTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.invitationTableView.reloadData()
            weakSelf.invitationTableView.refreshControl?.endRefreshing()
            Log.event(name: "reloadInvitationList")
        }
    }
    
    // お誘いをセット
    private func setInvitations() {
        // ログインユーザに紐づくお誘いをセット
        var invitationes = GlobalVar.shared.loginUser?.invitations ?? [Invitation]()
        invitationes = invitationes.filter({
            let isNotDeleted = ($0.is_deleted == false)
            return isNotDeleted
        })
        // ログインユーザ以外のお誘いをセット
        var invitationeds = GlobalVar.shared.loginUser?.invitationeds ?? [Invitation]()
        invitationeds = invitationeds.filter({
            let creator = $0.creator ?? ""
            return commonFilter(creatorUID: creator, targetUID: nil)
        })
        invitationeds.sort{ (m1, m2) -> Bool in
            let m1Date = m1.updated_at?.dateValue() ?? Date()
            let m2Date = m2.updated_at?.dateValue() ?? Date()
            return m1Date > m2Date
        }
        // お誘いを統合 (自分が出したお誘い + 自分以外が出したお誘い)
        let invitationList = invitationes + invitationeds
        var invitations = [Int:Invitation]()
        for (index, _invitation) in invitationList.enumerated() {
            invitations[index] = _invitation
            if index == invitationList.count - 1 {
                GlobalVar.shared.invitationListTableView.reloadData()
            }
        }
        GlobalVar.shared.globalInvitationList = invitationes + invitationeds
        GlobalVar.shared.globalInvitations = invitations
        // フィルターエリアの設定
        filterAreaInvitation()
    }
    
    // +募集するボタンをセット
    func setInvitationButton() {
        invitationButton.removeFromSuperview()
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let safeAreaBottom = window?.safeAreaInsets.bottom ?? 0
        invitationButton.frame = CGRect(x: UIScreen.main.bounds.width - 160, y: UIScreen.main.bounds.height - safeAreaBottom - 120, width: 140, height: 60)
        invitationButton.setTitle("+ 募集する", for: .normal)
        invitationButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        invitationButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        invitationButton.backgroundColor = .white
        invitationButton.layer.cornerRadius = 30
        invitationButton.setShadow(opacity: 0.1)
        window?.addSubview(invitationButton)
        invitationButton.addTarget(self, action: #selector(invitationAction), for: .touchUpInside)
    }
    
    //募集を追加する
    @objc func invitationAction() {
        let storyboard = UIStoryboard(name: "InvitationCreateView", bundle: nil)
        let invitationCreateVC = storyboard.instantiateViewController(withIdentifier: "InvitationCreateView") as! InvitationCreateViewController
        invitationCreateVC.invitationPageType = ""
        self.navigationController?.pushViewController(invitationCreateVC, animated: true)
    }
    
    // 本人確認状態に応じてボタンの表示を変更
    func setCustomForAdminCheckStatus() {
        // 本人確認状態を取得
        let adminCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status ?? 0
        // お誘いを取得
        let invitationes = GlobalVar.shared.loginUser?.invitations.filter({
            $0.is_deleted == false
        }) ?? [Invitation]()
        let invitationCount = invitationes.count
        // 本人確認状態
        if adminCheckStatus == 1 && invitationCount == 0 {
            // +募集するボタン
            setInvitationButton()
        } else {
            // お誘い募集ボタン削除
            invitationButton.removeFromSuperview()
        }
    }
}

extension InvitationViewController {
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentationDidDismissMoveMessageRoomAction()
    }
}

extension InvitationViewController: UITableViewDataSource {
    // お誘いスクロール
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= GlobalVar.shared.invitationListTableView.sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= GlobalVar.shared.invitationListTableView.sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsets(top: -GlobalVar.shared.invitationListTableView.sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
    }
    // お誘い数分のセル数を定義
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let invitations = GlobalVar.shared.globalFilterInvitations
        let invitationsNum = invitations.count
        return invitationsNum
    }
    //お誘いセル生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let invitations = GlobalVar.shared.globalFilterInvitations
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationCell", for: indexPath) as! InvitationCell
        cell.delegate = self
        cell.tag = indexPath.row
        // セルの情報を設定
        guard let invitation = invitations[indexPath.row] else { return cell }
        cell.invitation = invitation
        guard let currentUID = GlobalVar.shared.loginUser?.uid else { return cell }
        guard let creator = invitation.creator else { return cell }
        if creator == currentUID {
            // 自分が作成したお誘いの場合
            ownInvitationCell(cell: cell)
        } else {
            // 自分以外のお誘いの場合
            otherInvitationCell(cell: cell)
        }
        return cell
    }
    // お誘いヘッダー生成
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let placeViewCGRect = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height)
        let placeView: UIView = UIView(frame: placeViewCGRect)
        
        let placeLabel: UILabel = UILabel()
        placeLabel.text = "場所"
        placeLabel.textColor = UIColor().setColor(colorType: "fontColor", alpha: 1.0)
        placeLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 14)
        
        placeView.addSubview(placeLabel)
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.leftAnchor.constraint(equalTo: placeView.leftAnchor, constant: 30).isActive = true
        placeLabel.centerYAnchor.constraint(equalTo: placeView.centerYAnchor).isActive = true
        placeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        placeLabel.clipsToBounds = true
        
        let placeTextFieldCGRect = CGRect(x: 0, y: 0, width: 100, height: 20)
        let placeTextField: CustomTextField = CustomTextField(frame: placeTextFieldCGRect)
        placeTextField.delegate = self
        
        placeTextField.text = GlobalVar.shared.invitationSelectArea
        placeTextField.resignFirstResponder()
        placeTextField.textColor = UIColor().setColor(colorType: "accentColor", alpha: 1.0)
        placeTextField.textAlignment = .center
        placeTextField.backgroundColor = .white
        placeTextField.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 14)
        placeTextField.layer.cornerRadius = placeTextField.frame.height / 2
        
        placeTextField.inputView = placePicker
        
        let placeDoneAction = UIAction() { [weak self] _ in
            guard let weakSelf = self else { return }
            let selectPlaceRow = weakSelf.placePicker.selectedRow(inComponent: 0)
            if let area = weakSelf.areas[safe: selectPlaceRow] {
                placeTextField.text = area
                placeTextField.resignFirstResponder()
            }
        }
        
        let placeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let placeDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        placeDoneItem.primaryAction = placeDoneAction
        placeToolbar.setItems([spacelItem, placeDoneItem], animated: true)
        placeTextField.inputAccessoryView = placeToolbar
        
        placeView.addSubview(placeTextField)
        placeTextField.translatesAutoresizingMaskIntoConstraints = false
        placeTextField.leftAnchor.constraint(equalTo: placeLabel.rightAnchor, constant: 10).isActive = true
        placeTextField.centerYAnchor.constraint(equalTo: placeView.centerYAnchor).isActive = true
        placeTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        placeTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        placeTextField.clipsToBounds = true
        
        // オブジェクトを追加した後に影をつける
        placeTextField.layer.masksToBounds = false
        placeTextField.layer.shadowRadius = 3.0
        placeTextField.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        placeTextField.layer.shadowColor = UIColor.black.cgColor
        placeTextField.layer.shadowOpacity = 0.1
        
        return placeView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    // 自分が出したお誘いの場合のセルカスタム
    private func ownInvitationCell(cell: InvitationCell) {
        cell.invitationBtn.isHidden = false
        cell.invitationBtn.layer.opacity = 1.0
        cell.invitationBtn.setShadow()
        cell.goodBtn.isHidden = true
    }
    // 自分以外が出したお誘いの場合のセルカスタム
    private func otherInvitationCell(cell: InvitationCell) {
        cell.invitationBtn.isHidden = true
        cell.goodBtn.isHidden = false
        cell.goodBtn.layer.opacity = 1.0
        cell.goodBtn.setShadow(opacity: 0.1)
        // お誘いメンバーにログインユーザが含まれている場合
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        let isInvitationed = (cell.invitation?.members.contains(loginUID) == true)
        let isInvitationedMatch = (cell.invitation?.match_members.contains(loginUID) == true)
        let isInvitationedNG = (cell.invitation?.ng_members.contains(loginUID) == true)
        if isInvitationed || isInvitationedMatch || isInvitationedNG {
            // お誘いに「いいね」をしている場合
            cell.goodBtn.setTitle("送信済み", for: .normal)
            cell.goodBtn.backgroundColor = .lightGray
            cell.goodBtn.layer.shadowOpacity = 0
        } else {
            // お誘いに「いいね」をしていない場合
            cell.goodBtn.setTitle("興味あり", for: .normal)
            cell.goodBtn.backgroundColor = UIColor(named: "AccentColor")
        }
        cell.goodBtn.titleLabel?.font = .boldSystemFont(ofSize: 14)
    }
}


//MARK: - UITableViewDataSourcePrefetching

extension InvitationViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // [Invitation]
        let invitations = GlobalVar.shared.globalFilterInvitations
        // [User]
        let users = indexPaths.compactMap({ invitations[$0.section]?.userInfo })
        // [URL]
        let urls = indexPaths.compactMap { URL(string:users[safe: $0.section]?.profile_icon_img ?? "") }
        // start prefetching
        prefetcher.startPrefetching(with: urls)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // [Invitation]
        let invitations = GlobalVar.shared.globalFilterInvitations
        // [User]
        let users = indexPaths.compactMap({ invitations[$0.section]?.userInfo })
        // [URL]
        let urls = indexPaths.compactMap { URL(string:users[safe: $0.section]?.profile_icon_img ?? "") }
        // stop prefetching
        prefetcher.stopPrefetching(with: urls)
    }
}

extension InvitationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //場所絞り込みPicker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return areas[safe: row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択したエリア
        if let selectArea = areas[safe: row] {
            GlobalVar.shared.invitationSelectArea = selectArea
            filterAreaInvitation()
            Log.event(name: "filterInvitationList")
        }
    }
}

extension InvitationViewController: InvitationCellDelegate {
    
    // アイコンタップ時の画面遷移
    func didTapGoProfileDetail(cell: InvitationCell) {
        if let user = cell.invitation?.userInfo { profileDetailMove(user: user) }
    }
    
    // 募集タップ時の画面遷移
    func didTapGoDetail(cell: InvitationCell) {
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        let isLoginUser = (loginUID == cell.invitation?.creator)
        if isLoginUser {
            invitationDetailMove(cell: cell)
        }
    }
    // お誘い詳細ページへの遷移
    private func invitationDetailMove(cell: InvitationCell) {
        let storyBoard = UIStoryboard.init(name: "InvitationDetailView", bundle: nil)
        let invitationDetailVC = storyBoard.instantiateViewController(withIdentifier: "InvitationDetailView") as! InvitationDetailViewController
        invitationDetailVC.specificInvitation = cell.invitation
        GlobalVar.shared.specificInvitation = cell.invitation
        // お誘い詳細画面に遷移
        navigationController?.pushViewController(invitationDetailVC, animated: true)
    }
    // お誘いにいいねをした動作
    func didTapGoodAction(cell: InvitationCell) {
        let invitation = cell.invitation
        let invitationID = invitation?.document_id ?? ""
        let invitationCreator = invitation?.creator ?? ""
        let logEventData = [
            "invitationID": invitationID,
            "target": invitationCreator
        ] as [String : Any]
        Log.event(name: "clickInvitationApplication", logEventData: logEventData)
        //本人確認していない場合は確認ページを表示
        guard let adminIDCheckStatus = GlobalVar.shared.loginUser?.admin_checks?.admin_id_check_status else {
            popUpIdentificationView()
            return
        }
        if adminIDCheckStatus == 1 {
            //本人確認済みの場合
            guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
            guard let invitationUID = cell.invitation?.document_id else { return }
            guard let invitationMembers = cell.invitation?.members else { return }
            guard let targetUID = cell.invitation?.creator else { return }
            
            // すでにいいねしているお誘いの場合
            let isInvitationed = (invitationMembers.contains(loginUID) == true)
            if isInvitationed { return }
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()

            goodBtnCustom(cell: cell, loginUID: loginUID)
            
            firebaseController.application(invitationUID: invitationUID, invitationMembers: invitationMembers, loginUID: loginUID, targetUID: targetUID, completion: { [weak self] result in
                guard let weakSelf = self else { return }
                if result {
                    return
                }
                weakSelf.alert(title: "お誘いいいねに失敗しました..", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
                return
            })

        } else if adminIDCheckStatus == 2 {
            dialog(title: "本人確認失敗しました", subTitle: "提出していただいた写真又は生年月日に不備がありました\n再度本人確認書類を提出してください", confirmTitle: "OK", completion: { [weak self] confirm in
                guard let weakSelf = self else { return }
                if confirm { weakSelf.popUpIdentificationView() }
            })
        } else {
            alert(title: "本人確認中です", message: "現在本人確認中\n（12時間以内に承認が完了します）", actiontitle: "OK")
        }
    }
    // お誘いいいねボタンをカスタム
    private func goodBtnCustom(cell: InvitationCell, loginUID: String) {
        var invitations = GlobalVar.shared.globalInvitations
        cell.goodBtn.setTitle("送信済み", for: .normal)
        cell.goodBtn.tintColor = .white
        cell.goodBtn.backgroundColor = .lightGray
        cell.goodBtn.layer.shadowOpacity = 0
        cell.invitation?.members.append(loginUID)
        invitations[cell.tag] = cell.invitation
    }
}

protocol InvitationCellDelegate: AnyObject {
    func didTapGoProfileDetail(cell: InvitationCell)
    func didTapGoDetail(cell: InvitationCell)
    func didTapGoodAction(cell: InvitationCell)
}

class InvitationCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    @IBOutlet weak var invitationBtn: UIButton!
    @IBOutlet weak var goodBtn: UIButton!
    
    weak var delegate : InvitationCellDelegate?
    
    let categories = GlobalVar.shared.invitationCategories
    let categoryImgs = GlobalVar.shared.invitationCategoriesWithImg
    let days = GlobalVar.shared.invitationDays
    
    var invitation: Invitation? {
        didSet {
            if let _invitation = invitation {
                // 相手の名前を表示
                nickName.text = "..."
                // 相手の画像を設定
                iconImage.image = UIImage()
                // お誘い最新投稿日時 (オンライン)
                let onlineStatus = elapsedOnlineTime(registTime: _invitation.updated_at?.dateValue() ?? Date())
                status.text = onlineStatus
                if onlineStatus.contains("新着") {
                    // お誘いが新着の場合
                    statusLabel.textColor = .green
                } else {
                    // お誘いが新着以外の場合
                    statusLabel.textColor = UIColor(named: "FontColor")
                }
                // お誘いエリア
                if let _area = _invitation.area {
                    area.text = _area
                }
                // お誘いカテゴリ
                let otherCategory = categories[categories.count - 1]
                categoryName.text = otherCategory
                categoryImgView.image = categoryImgs[otherCategory]
                if let _category = _invitation.category {
                    if _category.isEmpty == false {
                        categoryName.text = _category
                        categoryImgView.image = categoryImgs[_category]
                    }
                }
                // お誘い日程
                dateCollectionView.reloadData()
                // お誘い文言（改行無効化）
                let invitationContent = _invitation.content ?? ""
                content.text = invitationContent.components(separatedBy: .whitespacesAndNewlines).joined()
                
                if let user = _invitation.userInfo {
                    let userNickName = user.nick_name
                    let userProfileIconImg = user.profile_icon_img
                    if userNickName.isEmpty == false {
                        // お誘いユーザのニックネーム
                        nickName.text = userNickName
                    }
                    let isNotMember = (nickName.text != "...")
                    if isNotMember && userProfileIconImg.isEmpty == false {
                        // お誘いユーザのアイコン画像
                        iconImage.setImage(withURLString: userProfileIconImg)
                    }
                    // お誘いユーザのプロフィール詳細
                    age.text = user.birth_date.calcAge()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //UI調整
        cellView.layer.cornerRadius = 20
        goodBtn.layer.cornerRadius = 17.5
        invitationBtn.layer.cornerRadius = 17.5
        categoryView.layer.cornerRadius = 5
        categoryImgView.layer.cornerRadius = 5
        categoryImgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        categoryName.layer.cornerRadius = 5
        categoryName.clipsToBounds = true
        categoryName.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        cellView.setShadow()
        iconImage.rounded()
        goodBtn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        // アイコンタップ時にプロフィール詳細に行く
        iconBtn.addTarget(self, action: #selector(didTapGoProfileDetail), for: .touchUpInside)
        // セルタップ時に詳細に行く（実際は自分の募集だけ）
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGoDetail))
        cellView.addGestureRecognizer(tapGestureRecognizer)
        // お誘いをした時の動作を定義
        goodBtn.addTarget(self, action: #selector(didTapGoodAction), for: .touchUpInside)
        dateCollectionView.delegate = self
        dateCollectionView.dataSource = self
    }
    // プロフィール詳細ページに移動
    @objc func didTapGoProfileDetail() {
        delegate?.didTapGoProfileDetail(cell: self)
    }
    // お誘い詳細ページに移動
    @objc func didTapGoDetail() {
        delegate?.didTapGoDetail(cell: self)
    }
    // お誘いをいいねした
    @objc func didTapGoodAction() {
        delegate?.didTapGoodAction(cell: self)
    }
}

// 曜日
extension InvitationCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! InvitationDateCollectionCell
        let day = days[indexPath.row]
        cell.tag = indexPath.row
        cell.dateView.layer.cornerRadius = 12.5
        cell.dateName.layer.cornerRadius = 12.5
        cell.dateName.text = day
        let selectDays = invitation?.date ?? [String]()
        let daysIndex = selectDays.firstIndex(of: day)
        if daysIndex != nil {
            // すでに選択されていた曜日の場合
            cell.dateName.backgroundColor = UIColor(named: "AccentColor")
            cell.dateName.textColor = .white
        } else {
            // 選択されていない曜日の場合
            cell.dateName.backgroundColor = .systemGray6
            cell.dateName.textColor = .systemGray
        }
        return cell
    }
}

class InvitationDateCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateName: UILabel!
    
    // カスタムセルを初期化
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
