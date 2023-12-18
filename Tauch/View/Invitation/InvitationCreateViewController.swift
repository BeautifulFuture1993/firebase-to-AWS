//
//  CreateInvitationViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/05/26.
//

import UIKit
import KMPlaceholderTextView

class InvitationCreateViewController: UIBaseViewController {
    
    @IBOutlet var itemView: [UIView]!
    @IBOutlet weak var inviteBtn: UIButton!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var invitationTextView: KMPlaceholderTextView!
    @IBOutlet weak var countLabel: UILabel!
    
    let categories = GlobalVar.shared.invitationCategories
    var areas: [String] = {
        var invitationAreas = GlobalVar.shared.areas
        invitationAreas.insert("オンライン", at: 0)
        return invitationAreas
    }()
    let days = GlobalVar.shared.invitationDays
    
    var specificInvitation: Invitation!

    let categoryPicker = UIPickerView()
    let placePicker = UIPickerView()
    var invitationPageType = ""
    var selectDays = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバーの設定
        navigationWithBackBtnSetUp(navigationTitle: "お誘いを作成")
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        //カテゴリpicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.tag = 0
        categoryField.inputView = categoryPicker
        let categoryDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(selectCategory))
        toolbar.setItems([spacelItem, categoryDoneItem], animated: true)
        categoryField.inputAccessoryView = toolbar
        //日程
        dateCollectionView.delegate = self
        dateCollectionView.dataSource = self
        //場所picker
        placePicker.delegate = self
        placePicker.dataSource = self
        placePicker.tag = 1
        placeField.inputView = placePicker
        let placeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let placeDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(selectPlace))
        placeToolbar.setItems([spacelItem, placeDoneItem], animated: true)
        placeField.inputView = placePicker
        placeField.inputAccessoryView = placeToolbar
        //募集文完了ボタン
        let invitationToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let invitationDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeKeyboard))
        invitationToolbar.setItems([spacelItem, invitationDoneItem], animated: true)
        invitationTextView.inputAccessoryView = invitationToolbar
        inviteBtn.layer.cornerRadius = 35
        inviteBtn.setShadow()
        categoryField.layer.cornerRadius = 10
        placeField.layer.cornerRadius = 10
        invitationTextView.layer.cornerRadius = 10
        itemView.forEach {
            $0.setShadow()
            $0.layer.cornerRadius = 20
        }
        //募集文文字制限
        invitationTextView.delegate = self
        invitationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 15)
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        //キーボードの開閉時に通知を取得
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if invitationPageType == "edit" {
            let ownInivtaion = GlobalVar.shared.ownSpecificInvitation
            if let category = ownInivtaion["category"] as? String {
                categoryField.text = category
            } else {
                categoryField.text = specificInvitation.category
            }
            if let date = ownInivtaion["date"] as? [String] {
                selectDays = date
            } else {
                selectDays = specificInvitation.date
            }
            if let area = ownInivtaion["area"] as? String {
                placeField.text = area
            } else {
                placeField.text = specificInvitation.area
            }
            if let content = ownInivtaion["content"] as? String {
                invitationTextView.text = content
            } else {
                invitationTextView.text = specificInvitation.content
            }
            inviteBtn.enable()
            dateCollectionView.reloadData()
            inviteBtn.setTitle("保存する", for: .normal)
            inviteBtn.configuration = nil
            inviteBtn.titleLabel?.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 20)
            //ナビゲーションアイテムのタイトルを設定
            self.navigationItem.title = "お誘いを編集"
            
        } else {
            let ownInivtaion = GlobalVar.shared.ownSpecificInvitation
            if let category = ownInivtaion["category"] as? String {
                categoryField.text = category
            }
            if let date = ownInivtaion["date"] as? [String] {
                selectDays = date
            }
            if let area = ownInivtaion["area"] as? String {
                placeField.text = area
            }
            if let content = ownInivtaion["content"] as? String {
                invitationTextView.text = content
            }
            dateCollectionView.reloadData()
            inviteBtn.setTitle("募集する", for: .normal)
            inviteBtn.configuration = nil
            inviteBtn.titleLabel?.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 20)
            inviteBtn.disable()
            //ナビゲーションアイテムのタイトルを設定
            self.navigationItem.title = "お誘いを作成"
        }
        
        hideNavigationBarBorderAndShowTabBarBorder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GlobalVar.shared.specificInvitation = specificInvitation
    }
    
    // キーボードが表示された時
    @objc private func keyboardWillShow(sender: NSNotification) {
        if invitationTextView.isFirstResponder {
            guard let userInfo = sender.userInfo else { return }
            let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                let transform = CGAffineTransform(translationX: 0, y: -200)
                self.view.transform = transform
            })
            // ナビゲーションバーの表示
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    // キーボードが閉じられた時
    @objc private func keyboardWillHide(sender: NSNotification) {
        guard let userInfo = sender.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
        // ナビゲーションバーの非表示
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setOwnInvitation() {
        var ownInivtaion = GlobalVar.shared.ownSpecificInvitation
        let category = categoryField.text ?? ""
        if category.count != 0 {
            ownInivtaion.updateValue(category, forKey: "category")
        }
        if selectDays.count != 0 {
            ownInivtaion.updateValue(selectDays, forKey: "date")
        }
        let area = placeField.text ?? ""
        if area.count != 0 {
            ownInivtaion.updateValue(area, forKey: "area")
        }
        let content = invitationTextView.text ?? ""
        if content.count != 0 {
            ownInivtaion.updateValue(content, forKey: "content")
        }
        GlobalVar.shared.ownSpecificInvitation = ownInivtaion
    }
    //カテゴリ完了ボタン
    @objc func selectCategory() {
        let selectCategoryRow = categoryPicker.selectedRow(inComponent: 0)
        if let category = categories[safe: selectCategoryRow] {
            categoryField.text = category
            setOwnInvitation()
            enableButtonIfFilled()
            categoryField.resignFirstResponder()
        }
    }
    //場所完了ボタン
    @objc func selectPlace() {
        let selectPlaceRow = placePicker.selectedRow(inComponent: 0)
        if let area = areas[safe: selectPlaceRow] {
            placeField.text = area
            setOwnInvitation()
            enableButtonIfFilled()
            placeField.resignFirstResponder()
        }
    }
    //募集文完了ボタン
    @objc func closeKeyboard() {
        invitationTextView.resignFirstResponder()
    }
    // 150文字以上入力させない
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 150
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        countLabel.text = "\(150 - invitationTextView.text.count)"
        enableButtonIfFilled()
        setOwnInvitation()
    }
    //募集作成
    @IBAction func invitationAction(_ sender: UIButton) {
        
        guard let currentUID = GlobalVar.shared.loginUser?.uid else { return }
        
        let isCategoryEmpty = (categoryField.text?.isEmpty == true)
        let isDateEmpty = (selectDays.isEmpty == true)
        let isPlaceEmpty = (placeField.text?.isEmpty == true)
        let isInvitationTextEmpty = (invitationTextView.text.isEmpty == true)
        
        let alertMessage = "入力内容を確認の上、再度登録をしてください。"
        let alertActionTitle = "OK"
        //空欄がないかチェック
        if isCategoryEmpty {
            let alertTitle = "カテゴリが入力されていません"
            alert(title: alertTitle, message: alertMessage, actiontitle: alertActionTitle)
            
        } else if isDateEmpty {
            let alertTitle = "日程が選択されていません"
            alert(title: alertTitle, message: alertMessage, actiontitle: alertActionTitle)
            
        } else if isPlaceEmpty {
            let alertTitle = "場所が入力されていません"
            alert(title: alertTitle, message: alertMessage, actiontitle: alertActionTitle)
            
        } else if isInvitationTextEmpty {
            let alertTitle = "募集文が入力されていません"
            alert(title: alertTitle, message: alertMessage, actiontitle: alertActionTitle)
            
        } else {
            
            let categoryText = categoryField.text ?? ""
            let date = selectDays
            let placeText = placeField.text ?? ""
            let invitationText = invitationTextView.text ?? ""
            
            if invitationPageType.isEmpty {
                //空欄がなければ注意アラート表示
                let alertTitle = "注意！"
                let alertMessage = "ホスト、相席屋、合コン、交流会の募集は禁止しております。アカウントの停止になる可能性があるのでご注意ください。"
                let alertActionTitle = "募集する"
                dialog(title: alertTitle, subTitle: alertMessage, confirmTitle: alertActionTitle, completion: { [weak self] alertResult in
                    guard let weakSelf = self else { return }
                    if alertResult {
                        weakSelf.firebaseController.invitation(loginUID: currentUID, category: categoryText, date: date, area: placeText, content: invitationText) { [weak self] result in
                            guard let weakSubSelf = self else { return }
                            if result {
                                weakSubSelf.alertWithAction(title: "募集を開始しました！", message: "募集がユーザに公開されました。通知をONにして募集をお待ちください", actiontitle: "OK", type: "back")
                                GlobalVar.shared.ownSpecificInvitation = [:]
                                return
                            }
                            weakSubSelf.alert(title: "募集の作成に失敗しました..", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
                            return
                        }
                    }
                })
                
            } else {
                 
                guard let invitationUID = specificInvitation.document_id else { return }
                specificInvitation.category = categoryText
                specificInvitation.date = date
                specificInvitation.area = placeText
                specificInvitation.content = invitationText
                // 編集する場合
                firebaseController.invitationEdit(invitationUID: invitationUID, loginUID: currentUID, category: categoryText, date: date, area: placeText, content: invitationText) { [weak self] result in
                    guard let weakSelf = self else { return }
                    if result {
                        weakSelf.alertWithAction(title: "保存しました", message: "", actiontitle: "OK", type: "back")
                        GlobalVar.shared.ownSpecificInvitation = [:]
                        return
                    }
                    weakSelf.alert(title: "お誘いの編集に失敗しました..", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
                    return
                }
            }
        }
    }
    //全て入力されていたらボタンを有効化
    private func enableButtonIfFilled() {
        let isNotEmptyCategory = (categoryField.text?.isEmpty == false)
        let isNotEmptyDay = (selectDays.isEmpty == false)
        let isNotEmptyPlace = (placeField.text?.isEmpty == false)
        let isNotEmptyInvitationText = (invitationTextView.text.isEmpty == false)
        let regexInvitationText = (invitationTextView.text.count <= 150)
        let isNotEmptyForAll = (
            isNotEmptyCategory && isNotEmptyDay &&
            isNotEmptyPlace && isNotEmptyInvitationText &&
            regexInvitationText
        )
        if isNotEmptyForAll {
            inviteBtn.enable()
        } else {
            inviteBtn.disable()
        }
    }
}
//Picker
extension InvitationCreateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //Pickerの列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //pickerの行
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // カテゴリ選択
        if pickerView.tag == 0 {
            return categories.count
        }
        // エリア選択
        if pickerView.tag == 1 {
            return areas.count
        }
        return 0
    }
    //pickerの選択肢
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // カテゴリ選択
        if pickerView.tag == 0 {
            return categories[safe: row]
        }
        // エリア選択
        if pickerView.tag == 1 {
            return areas[safe: row]
        }
        return "未設定"
    }
}

extension InvitationCreateViewController: UICollectionViewDataSource {
    //曜日数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    //曜日の生成
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCollectionViewCell", for: indexPath) as! InvitationDateCollectionViewCell
        let day = days[indexPath.row]
        cell.dateLabel.text = day
        cell.tag = indexPath.row
        cell.delegate = self
        cell.rounded()
        let daysIndex = selectDays.firstIndex(of: day)
        if daysIndex != nil {
            // すでに選択されていた曜日の場合
            cell.dateLabel.backgroundColor = UIColor(named: "AccentColor")
            cell.dateLabel.textColor = .white
        } else {
            // 選択されていない曜日の場合
            cell.dateLabel.backgroundColor = .systemGray6
            cell.dateLabel.textColor = .lightGray
        }
        return cell
    }
}

extension InvitationCreateViewController: InvitationDateCollectionCellDelegate {
    func didTapDayAction(cell: InvitationDateCollectionViewCell) {
        let day = days[cell.tag]
        let daysIndex = selectDays.firstIndex(of: day)
        if let index = daysIndex {
            selectDays.remove(at: index)
            cell.dateLabel.backgroundColor = .systemGray6
            cell.dateLabel.textColor = .lightGray
        } else {
            selectDays.append(day)
            cell.dateLabel.backgroundColor = UIColor(named: "AccentColor")
            cell.dateLabel.textColor = .white
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
        setOwnInvitation()
        enableButtonIfFilled()
    }
}

protocol InvitationDateCollectionCellDelegate: AnyObject {
    func didTapDayAction(cell: InvitationDateCollectionViewCell)
}

class InvitationDateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
   
    weak var delegate : InvitationDateCollectionCellDelegate?
    
    // カスタムセルを初期化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //セルタップ時に曜日を選択する
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDayAction))
        dateView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // お誘い曜日を選択
    @objc func didTapDayAction() {
        delegate?.didTapDayAction(cell: self)
    }
}
