//
//  ProfileViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/21.
//

import UIKit
import TagListView
import FirebaseFirestore

class ProfileViewController: UIBaseViewController {

    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var holidayField: UITextField!
    @IBOutlet weak var businessField: UITextField!
    @IBOutlet weak var incomeField: UITextField!
    @IBOutlet weak var exampleButton: UIButton!
    @IBOutlet weak var tagEditButton: UIButton!
    @IBOutlet weak var statusTextCountLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var address2Field: UITextField!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var iconEditButton: UIButton!
    @IBOutlet var iconDeleteButton: [UIButton]!
    @IBOutlet var profileIcon: [UIImageView]!
    @IBOutlet var profileIconBackground: [UIView]!
    @IBOutlet var profileIconPlus: [UIImageView]!
    @IBOutlet weak var tagListViewWidth: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeight: NSLayoutConstraint!
    
    let typeArray = ["気軽に誘ってください", "メッセージを重ねてから", "メッセージのみ希望"]
    let holidayArray = ["土日休み", "平日休み", "不定期"]
    let incomeArray = ([Int])(0...7)
    let businessArray = ["大手企業", "公務員", "受付", "事務員", "看護師", "保育士", "客室乗務員", "秘書", "教育関連", "福祉・介護", "調理師・栄養士", "アパレル・ショップ", "美容関係", "ブライダル", "金融", "保険", "マスコミ", "WEB業界", "上場企業", "経営者・役員", "医師", "薬剤師", "弁護士", "公認会計士", "パイロット", "大手商社", "コンサル", "大手外資", "外資金融", "IT関連", "クリエイター", "アナウンサー", "芸能・モデル", "イベントコンパニオン", "スポーツ選手", "接客業", "不動産", "建築関連", "通信", "流通", "製薬", "食品関連", "旅行関係", "エンターテイメント", "会社員", "学生", "自由業", "税理士", "エンジニア", "建築士", "美容師", "歯科医師", "歯科衛生士", "その他"]
    let profileImagePicker = UIImagePickerController()
    var beforeSelectProfileImage: UIImage?
    var addressPickerView = UIPickerView()
    var address2PickerView = UIPickerView()
    let typePickerView = UIPickerView()
    let holidayPickerView = UIPickerView()
    let businessPickerView = UIPickerView()
    let incomePickerView = UIPickerView()
    var areas = GlobalVar.shared.areas
    var municipalities = GlobalVar.shared.municipalities
    var tagEditFlg = false
    var iconEditFlg = false
    var beforeImages = [UIImage]()
    var iconUrls = [String]()
    var selectedIncome = 0
    var plusIndex = 1 {
        didSet {
            profileIcon[plusIndex - 1].isUserInteractionEnabled = false
            if plusIndex > 1 {
                iconDeleteButton[plusIndex - 2].isHidden = false
            }
            if plusIndex < 5 {
                profileIconPlus[plusIndex + 1].isHidden = true
            }
            if plusIndex < 6 {
                profileIconPlus[plusIndex].isHidden = false
                profileIcon[plusIndex].isUserInteractionEnabled = true
            }
        }
    }
    // キーボードが登場する前のスクロール量
    private var lastOffsetY: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // タグ編集ページに遷移
        if tagEditFlg {
            moveTagEdit()
            tagEditFlg = false
        }
        // ナビゲーションバーの設定
        setUpNavigationBar()
        // delegate
        typeField.delegate = self
        holidayField.delegate = self
        incomeField.delegate = self
        nameField.delegate = self
        businessField.delegate = self
        addressPickerView.delegate = self
        addressPickerView.dataSource = self
        address2PickerView.delegate = self
        address2PickerView.dataSource = self
        typePickerView.delegate = self
        typePickerView.dataSource = self
        holidayPickerView.delegate = self
        holidayPickerView.dataSource = self
        businessPickerView.delegate = self
        businessPickerView.dataSource = self
        incomePickerView.delegate = self
        incomePickerView.dataSource = self
        addressField.delegate = self
        address2Field.delegate = self
        statusTextView.delegate = self
        profileImagePicker.delegate = self
        statusTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 30, right: 10)
        nameField.layer.cornerRadius = 10
        typeField.layer.cornerRadius = 10
        holidayField.layer.cornerRadius = 10
        businessField.layer.cornerRadius = 10
        incomeField.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 35
        addressField.layer.cornerRadius = 10
        address2Field.layer.cornerRadius = 10
        exampleButton.layer.cornerRadius = 12.5
        statusTextView.layer.cornerRadius = 10
        tagEditButton.layer.cornerRadius = 12.5
        iconEditButton.layer.cornerRadius = 15
        profileIcon.forEach{ $0.layer.cornerRadius = 10 }
        iconDeleteButton.forEach{ $0.layer.cornerRadius = 12 }
        profileIconBackground.forEach{ $0.layer.cornerRadius = 10 }
        nameField.setLeftPadding()
        typeField.setLeftPadding()
        addressField.setLeftPadding()
        address2Field.setLeftPadding()
        businessField.setLeftPadding()
        holidayField.setLeftPadding()
        incomeField.setLeftPadding()
        saveButton.setShadow()
        exampleButton.setShadow()
        tagEditButton.setShadow()
        statusTextView.setToolbar(action: #selector(closeKeyboard))
        addressField.setToolbar(action: #selector(doneAddress))
        address2Field.setToolbar(action: #selector(doneAddress2))
        typeField.setToolbar(action: #selector(doneType))
        holidayField.setToolbar(action: #selector(doneHoliday))
        incomeField.setToolbar(action: #selector(doneIncome))
        businessField.setToolbar(action: #selector(doneBusiness))
        addressField.inputView = addressPickerView
        address2Field.inputView = address2PickerView
        typeField.inputView = typePickerView
        holidayField.inputView = holidayPickerView
        incomeField.inputView = incomePickerView
        businessField.inputView = businessPickerView
        tagListView.textFont = .boldSystemFont(ofSize: 14)
        
        let previewButton = UIButton(type: .custom)
        previewButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        previewButton.setTitle("プレビュー", for: .normal)
        previewButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        previewButton.tintColor = .white
        previewButton.sizeToFit()
        previewButton.titleLabel?.textColor = .white
        previewButton.backgroundColor = UIColor(named: "AccentColor")
        previewButton.layer.cornerRadius = 10
        previewButton.addTarget(self, action: #selector(previewAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: previewButton)
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        previewButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        //キーボードの開閉時に通知を取得
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // 画像
        profileIcon.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addIconAction))) }
        //情報の反映
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            guard let user = GlobalVar.shared.loginUser else { return }
            weakSelf.iconUrls.append(user.profile_icon_img)
            user.profile_icon_sub_imgs.forEach {
                weakSelf.iconUrls.append($0)
            }
            // プロフィール画像を設定
            for i in 0..<weakSelf.iconUrls.count {
                if let iconImageView = weakSelf.profileIcon[safe: i], let url = weakSelf.iconUrls[safe: i] {
                    iconImageView.setImage(withURLString: url)
                }
            }
            // プロフィールサブ画像を設定
            weakSelf.profileIcon.forEach {
                if $0.tag > user.profile_icon_sub_imgs.count {
                    if let iconDeleteBtn = weakSelf.iconDeleteButton[safe: $0.tag - 1] {
                        iconDeleteBtn.isHidden = true
                    }
                    if $0.tag < 5 {
                        if let iconPlus = weakSelf.profileIconPlus[safe: $0.tag + 1] {
                            iconPlus.isHidden = true
                        }
                        if let icon = weakSelf.profileIcon[safe: $0.tag + 1] {
                            icon.isUserInteractionEnabled = false
                        }
                    }
                } else {
                    weakSelf.plusIndex = $0.tag + 1
                }
            }
            if let selectAddressIndex = weakSelf.areas.firstIndex(of: user.address) {
                weakSelf.addressPickerView.selectRow(selectAddressIndex, inComponent: 0, animated: false)
            }
            if user.address2 != "" {
                weakSelf.address2Field.text = user.address2
            } else if weakSelf.getMunicipalities(prefecture: user.address) == ["未選択"] {
                weakSelf.address2Field.text = "未選択"
                weakSelf.address2Field.isUserInteractionEnabled = false
            }
            weakSelf.selectedIncome = user.income
            weakSelf.incomeField.text = user.income.getIncome()
            weakSelf.nameField.text = user.nick_name
            weakSelf.businessField.text = user.business
            weakSelf.addressField.text = user.address
            weakSelf.typeField.text = user.type
            weakSelf.holidayField.text = user.holiday
            weakSelf.setTags(selectedTags: user.hobbies)
            weakSelf.statusTextView.text = user.profile_status
            weakSelf.statusTextCountLabel.text = "\(user.profile_status.count)"
            weakSelf.saveButton.disable()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //UI調整
        hideNavigationBarBorderAndShowTabBarBorder()
        tabBarController?.tabBar.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white

        guard let hobbies = GlobalVar.shared.loginUser?.hobbies else { return }
        DispatchQueue.main.async { self.setTags(selectedTags: hobbies) }
    }
    
    private func setUpNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = true

        let backImage = UIImage(systemName: "chevron.backward")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem?.tintColor = .fontColor
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.title = "プロフィール"
    }
    
    @objc func back() {
        if saveButton.isUserInteractionEnabled {
            let alert = UIAlertController(title: "編集が保存されていません", message: "本当にこの画面を離れてもよろしいですか？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            alert.addAction(UIAlertAction(title: "離れる", style: .destructive) { [self] _ in
                navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func previewAction() {
        let previewStoryboard = UIStoryboard(name: "ProfileDetailView", bundle: nil)
        let previewVC = previewStoryboard.instantiateViewController(withIdentifier: "ProfileDetailView") as! ProfileDetailViewController
        previewVC.isViolation = false
        previewVC.profileVC = self
        present(previewVC, animated: true)
    }
    // キーボードが表示された時
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        
        if statusTextView.isFirstResponder {
            // キーボードが登場する前のスクロール量を保存
            lastOffsetY = profileScrollView.contentOffset.y
            // キーボードの表示サイズ変更
            keyboardChangeFrame(notification)
        }
    }
    // キーボードが閉じられた時
    @objc private func keyboardWillHide(_ notification: NSNotification) {

        if statusTextView.isFirstResponder {
            // スクロール量をキーボードが登場する前の位置に戻す。
            profileScrollView.setContentOffset(CGPoint(x: 0, y: lastOffsetY), animated: true)
        }
    }
    
    private func keyboardChangeFrame(_ notification: NSNotification) {
        // キーボードのframeを調べる。
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        // テキストビューのframeをキーボードと同じウィンドウの座標系にする。
        guard let textViewFrame = view.window?.convert(statusTextView.frame, from: statusTextView.superview) else { return }
        // テキストビューとキーボードの間の余白(自由に変更してください。)
        let spaceBetweenTextViewAndKeyboard: CGFloat = 8
        // テキストビューがキーボードと重なっていないか調べる。
        // 重なり = (テキストビューの下端 + 余白) - キーボードの上端
        var overlap = (textViewFrame.maxY + spaceBetweenTextViewAndKeyboard) - keyboardFrame.minY
        if overlap > 0 {
            // 重なっている場合、キーボードが隠れている分だけスクロールする。
            overlap = overlap + profileScrollView.contentOffset.y
            profileScrollView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
        }
    }
    //自己紹介文完了ボタン
    @objc private func closeKeyboard() {
        statusTextView.resignFirstResponder()
    }
    
    @objc private func addIconAction() {
        iconEditFlg = false
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            profileImagePicker.sourceType = sourceType
            profileImagePicker.delegate = self
            profileImagePicker.allowsEditing = true
            self.present(profileImagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func iconDeleteAction(_ sender: UIButton) {
        saveBeforeImages()
        iconEditFlg = false
        if sender.tag == plusIndex - 1 {
            profileIcon[sender.tag].image = nil
            profileIconPlus[sender.tag].isHidden = false
            sender.isHidden = true
            plusIndex -= 1
        } else {
            for i in sender.tag..<5 {
                profileIcon[i].image = profileIcon[i + 1].image
            }
            profileIcon[plusIndex - 1].image = nil
            profileIconPlus[plusIndex - 1].isHidden = false
            iconDeleteButton[plusIndex - 2].isHidden = true
            if plusIndex < 6 {
                profileIconPlus[plusIndex].isHidden = true
            }
            plusIndex -= 1
        }
        enableButtonIfFilled()
    }
    
    @IBAction func iconEditAction(_ sender: UIButton) {
        iconEditFlg = true
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            profileImagePicker.sourceType = sourceType
            profileImagePicker.delegate = self
            profileImagePicker.allowsEditing = true
            self.present(profileImagePicker, animated: true, completion: nil)
        }
    }
    //タグ編集
    @IBAction func tagAction(_ sender: UIButton) {
        moveTagEdit()
    }
    // プロフィール編集内容を保存
    @IBAction func saveProfile(_ sender: Any) {
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        guard let type = typeField.text else { return }
        guard let nickName = nameField.text else { return }
        guard let business = businessField.text else { return }
        guard let holiday = holidayField.text else { return }
        guard let address = addressField.text else { return }
        guard let status = statusTextView.text else { return }
        guard let address2Text = address2Field.text else { return }
        let address2 = (address2Text == "未選択" ? "" : address2Text)
        // ローディング画面を表示させる
        showLoadingView(loadingView, text: "アップロード中...")
        
        db.collection("users").document(uid).updateData([
            "type": type,
            "holiday": holiday,
            "business": business,
            "income": selectedIncome,
            "address": address,
            "address2": address2,
            "nick_name": nickName,
            "profile_status": status,
            "updated_at": Timestamp()
        ]) { [weak self] err in
            
            guard let weakSelf = self else { return }
            if let err = err {
                weakSelf.loadingView.removeFromSuperview()
                weakSelf.alert(title: "プロフィール登録エラー", message: "正常にプロフィール登録されませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
                print("Error Log : \(err)")
                return
            }
            
            GlobalVar.shared.loginUser?.type = type
            GlobalVar.shared.loginUser?.holiday = holiday
            GlobalVar.shared.loginUser?.income = weakSelf.selectedIncome
            GlobalVar.shared.loginUser?.address = address
            GlobalVar.shared.loginUser?.address2 = address2
            GlobalVar.shared.loginUser?.nick_name = nickName
            GlobalVar.shared.loginUser?.business = business
            GlobalVar.shared.loginUser?.profile_status = status
            
            weakSelf.uploadIcon(uid: uid)
       }
    }
    // プロフィール画像アップロード
    private func uploadIcon(uid: String) {

        var images = [UIImage]()
        profileIcon.forEach {
            if let image = $0.image {
                images.append(image)
            }
        }

        firebaseController.uploadIconsToFireStorage(currentUID: uid, beforeImages: beforeImages, afterImages: images) { [weak self] urls in
            guard let weakSelf = self else { return }

            var subIconUrls = urls
            subIconUrls.removeFirst()

            DispatchQueue.main.async {
                weakSelf.loadingView.removeFromSuperview()
                weakSelf.saved()
            }

            weakSelf.db.collection("users").document(uid).updateData([
                "profile_icon_img": urls[0],
                "profile_icon_sub_imgs": subIconUrls,
                "updated_at": Timestamp()
            ]) { [weak self] err in
                guard let weakSubSelf = self else { return }
                if let _ = err {
                    weakSubSelf.alert(title: "プロフィール画像更新エラー", message: "正常に画像が更新されませんでした。\n不具合の報告から運営に報告してください", actiontitle: "OK")
                    return
                }
                GlobalVar.shared.loginUser?.profile_icon_img = urls[0]
                GlobalVar.shared.loginUser?.profile_icon_sub_imgs = subIconUrls
                weakSelf.saved()
            }
        }
    }
    // 自己紹介例文
    @IBAction func exampleAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "使う例文を選択してください", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "上京したて", style: .default) { [weak self] action in
            guard let weakSelf = self else { return }
            weakSelf.setIntroduce(example: 0)
        })
        alert.addAction(UIAlertAction(title: "趣味友達作り", style: .default) { [weak self] action in
            guard let weakSelf = self else { return }
            weakSelf.setIntroduce(example: 1)
        })
        alert.addAction(UIAlertAction(title: "気軽にお出かけ", style: .default) { [weak self] action in
            guard let weakSelf = self else { return }
            weakSelf.setIntroduce(example: 2)
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }
    
    private func saved() {
        let alert = UIAlertController(title: "保存しました", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [self] _ in
            saveButton.disable()
        })
        present(alert, animated: true)
    }
    
    private func moveTagEdit() {
        let storyboard = UIStoryboard(name: "TagEditView", bundle: nil)
        let tagVC = storyboard.instantiateViewController(withIdentifier: "TagEditView") as! TagEditViewController
        tagVC.profileVC = self
        navigationController?.pushViewController(tagVC, animated: true)
    }
    // 例文挿入
    private func setIntroduce(example: Int) {
        let exampleAlert = UIAlertController(title: "以下の例文に上書きしますがよろしいですか？", message:Introduce.example[example], preferredStyle: .alert)
        exampleAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        exampleAlert.addAction(UIAlertAction(title: "上書きする", style: .default) { [weak self] action in
            guard let weakSelf = self else { return }
            weakSelf.statusTextView.text = Introduce.example[example]
            weakSelf.enableButtonIfFilled()
        })
        self.present(exampleAlert, animated: true)
    }
    //入力内容が有効ならボタンを有効化する
    private func enableButtonIfFilled() {
        let notEmptyNickName = (nameField.text?.isEmpty == false)
        let notEmptyProfileStatus = (statusTextView.text.isEmpty == false)
        let minProfileStatus = (statusTextView.text.count >= 70)
        let regexProfileStatus = (statusTextView.text.contains("〇") == false)
        let selectAddress2 = (address2Field.text?.contains("未選択") == false)
        let enableSaveBtn = (
            notEmptyNickName && notEmptyProfileStatus &&
            minProfileStatus && regexProfileStatus &&
            selectAddress2
        )
        if enableSaveBtn {
            saveButton.enable()
        } else {
            saveButton.disable()
        }
    }

    private func getMunicipalities(prefecture: String) -> [String] {
        return municipalities[prefecture] ?? ["未設定"]
    }
    
    private func saveBeforeImages() {
        if beforeImages == [] {
            profileIcon.forEach {
                if let icon = $0.image {
                    beforeImages.append(icon)
                }
            }
        }
    }

    func setTags(selectedTags: [String]) {
        tagListView.removeAllTags()
        tagListView.addTags(selectedTags)
        let hobbyCount = selectedTags.count
        var hobbyTotalString = 0
        selectedTags.forEach { hobby in
            hobbyTotalString += hobby.count
        }
        if hobbyCount*40 + hobbyTotalString*14 < Int(UIScreen.main.bounds.width - 40) {
            tagListViewWidth.constant = UIScreen.main.bounds.width - 40
            tagListViewHeight.constant = 30
        } else {
            tagListViewWidth.constant = CGFloat(hobbyCount*22 + hobbyTotalString*7)
            tagListViewHeight.constant = 55
        }
    }
    // 自己紹介文の入力文字数を動的に変更、70文字以上かつ例文の「◯」を使わせないようにバリデーション
    func textViewDidChangeSelection(_ textView: UITextView) {
        statusTextCountLabel.text = String(statusTextView.text.count)
        if statusTextView.text.count < 70 {
            statusTextCountLabel.textColor = .red
        } else {
            statusTextCountLabel.textColor = .fontColor
        }
        if statusTextView.text.contains("〇") {
            statusTextCountLabel.textColor = .red
            statusTextCountLabel.text = "〇を取り除いてください"
        }
        enableButtonIfFilled()
    }
    // 名前を10文字以上入力させない
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let name = nameField.text else { return }
        if name.count > 10 {
            nameField.text = String(name.prefix(10))
        }
        enableButtonIfFilled()
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.editedImage] as? UIImage else { return }
        let resizedImage = pickedImage.resized(size: CGSize(width: 400, height: 400))
        let compressedImage = resizedImage?.compress()
        saveBeforeImages()

        if iconEditFlg {
            profileIcon[0].image = compressedImage
        } else {
            profileIcon[plusIndex].image = compressedImage
            plusIndex += 1
        }

        enableButtonIfFilled()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}

extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == addressPickerView {
            return areas.count
        } else if pickerView == address2PickerView {
            let selectAddress = areas[addressPickerView.selectedRow(inComponent: 0)]
            let municipalityList = municipalities[selectAddress] ?? ["未設定"]
            return municipalityList.count
        } else if pickerView == typePickerView {
            return typeArray.count
        } else if pickerView == holidayPickerView {
            return holidayArray.count
        } else if pickerView == incomePickerView {
            return incomeArray.count
        } else {
            return businessArray.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == addressPickerView {
            return areas[row]
        } else if pickerView == address2PickerView {
            let selectAddress = areas[addressPickerView.selectedRow(inComponent: 0)]
            let municipalityList = municipalities[selectAddress] ?? ["未設定"]
            return municipalityList[row]
        } else if pickerView == typePickerView {
            return typeArray[row]
        } else if pickerView == holidayPickerView {
            return holidayArray[row]
        } else if pickerView == incomePickerView {
            return incomeArray[row].getIncome()
        } else {
            return businessArray[row]
        }
    }
    
    @objc private func doneAddress() {
        addressField.text = areas[addressPickerView.selectedRow(inComponent: 0)]
        address2Field.isUserInteractionEnabled = true
        address2Field.text = "未選択"
        enableButtonIfFilled()
        addressField.endEditing(true)
        address2Field.becomeFirstResponder()
    }
    
    @objc private func doneAddress2() {
        let selectArea = areas[addressPickerView.selectedRow(inComponent: 0)]
        let selectAddress2 = address2PickerView.selectedRow(inComponent: 0)
        if let municipality = municipalities[selectArea] {
            address2Field.text = municipality[selectAddress2]
            enableButtonIfFilled()
            address2Field.endEditing(true)
        }
    }
    
    @objc private func doneType() {
        typeField.text = typeArray[typePickerView.selectedRow(inComponent: 0)]
        enableButtonIfFilled()
        typeField.endEditing(true)
    }
    
    @objc private func doneHoliday() {
        holidayField.text = holidayArray[holidayPickerView.selectedRow(inComponent: 0)]
        enableButtonIfFilled()
        holidayField.endEditing(true)
    }
    
    @objc private func doneIncome() {
        incomeField.text = incomeArray[incomePickerView.selectedRow(inComponent: 0)].getIncome()
        selectedIncome = incomeArray[incomePickerView.selectedRow(inComponent: 0)]
        enableButtonIfFilled()
        incomeField.endEditing(true)
    }
    
    @objc private func doneBusiness() {
        businessField.text = businessArray[businessPickerView.selectedRow(inComponent: 0)]
        enableButtonIfFilled()
        businessField.endEditing(true)
    }
}
