//
//  BBSInputViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/09.
//

import UIKit
import FirebaseFirestore

class BBSInputViewController: UIBaseViewController {
    
    static let storyboard_name_id = "BBSInputViewController"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var selectedImageBaseView: UIView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var closeSelectedImageButton: UIButton!
    
    let loginUser = GlobalVar.shared.loginUser
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSelectCategoryButton()
        configureIconImage()
        configureInputAccessoryView()
        configureSelectedImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBarButtonItems()
        
        inputTextField.becomeFirstResponder() // 自動的にキーボードを表示
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - IBAction
    
    @IBAction func selectCategoryPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: SelectBBSCategoryViewController.storyboard_name_id, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: SelectBBSCategoryViewController.storyboard_name_id) as? SelectBBSCategoryViewController else { return }
        vc.closure = { [weak self] (category: String) -> Void in
            self?.selectCategoryButton.setTitle(category, for: .normal)
            self?.selectCategoryButtonColor(category: category)
        }
        vc.category = selectCategoryButton.currentTitle
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20.0
        }
        present(vc, animated: true)
    }
    
    @IBAction func closeImageButtonPressed(_ sender: UIButton) {
        selectedImageBaseView.isHidden = true
    }
}


//MARK: - @objc methods

extension BBSInputViewController {
    // 投稿キャンセル
    @objc private func didTapLeftBarButtonItem() { showCancel() }
    // 投稿する
    @objc private func didTapRightBarButtonItem() { checkPostMessage() }
    // カメラを起動
    @objc private func didTapTakePhoto() { showImagePickerController(sourceType: .camera) }
    // 画像を選択
    @objc private func didTapSelectImage() { showImagePickerController(sourceType: .photoLibrary) }
    
    private func showCancel() {
        
        let text = inputTextField.text ?? ""
        let isEmptyText = (text.isEmpty == true)
        let postNotWithImage = (selectedImageBaseView.isHidden == true)
        let isNotWrited = (isEmptyText && postNotWithImage)
        
        if isNotWrited { // 何も入力内容がない場合
            navigationController?.popViewController(animated: true)
        } else { // 何か入力内容がある場合
            let storyboard = UIStoryboard(name: InputCancelViewController.storyboard_name_id, bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: InputCancelViewController.storyboard_name_id) as? InputCancelViewController else { return }
            vc.closure = { [weak self] (result: Bool) -> Void in
                if result { self?.navigationController?.popViewController(animated: true) }
            }
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20.0
            }
            present(vc, animated: true)
        }
    }
    
    private func checkPostMessage() {
        
        let text = inputTextField.text ?? ""
        if text.isEmpty {
            customAlert(status: "input-error")
        } else {
            postBoard()
        }
    }
    
    private func postBoard() {
        
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let boardText = inputTextField.text else { return }
        
        let category = selectCategoryButton.currentTitle ?? .categoryFriend
        
        inputTextField.resignFirstResponder() // キーボードをOFF
        // ローディング画面を表示させる
        showLoadingView(loadingView, text: "投稿中...")
        
        let boardID = UUID().uuidString
        
        let postWithImage = (selectedImageBaseView.isHidden == false)
        if postWithImage { // 画像付きの投稿
            if let boardImage = selectedImageView.image { // 画像付きの投稿
                uploadBoardImage(boardImage: boardImage, boardID: boardID, category: category, text: boardText, creator: loginUID)
            } else { // 画像なしの投稿
                setBoardData(boardID: boardID, category: category, text: boardText, creator: loginUID)
            }
        } else { // 画像なしの投稿
            setBoardData(boardID: boardID, category: category, text: boardText, creator: loginUID)
        }
    }
    
    // 投稿画像アップロード
    private func uploadBoardImage(boardImage: UIImage, boardID: String, category: String, text: String, creator: String) {
    
        let refName = "boards"
        let folderName = "content"
        let fileName = "img_\(boardID).jpg"
        
        let customMetadata = ["type": "board", "id": boardID]
        
        firebaseController.uploadImageToFireStorage(image: boardImage, referenceName: refName, folderName: folderName, fileName: fileName, customMetadata: customMetadata, completion: { [weak self] result in
            if result == "" { self?.customAlert(status: "upload-error"); return }
            // イベント登録
            let boardImgUrl = result
            let logEventData = ["board_img": boardImgUrl] as [String : Any]
            Log.event(name: "uploadBoardImg", logEventData: logEventData)
            
            let photos = [boardImgUrl]
            self?.setBoardData(boardID: boardID, category: category, text: text, creator: creator, photos: photos)
        })
    }
    
    private func setBoardData(boardID: String, category: String, text: String, creator: String, photos: [String] = []) {
        
        let visitors = [String]()
        let registTime = Timestamp()
        var boardData = [
            "category": category,
            "text": text,
            "photos": photos,
            "creator": creator,
            "visitors": visitors,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]
        
        db.collection("boards").document(boardID).setData(boardData) { [weak self] err in
            if let err = err { self?.customAlert(status: "post-error"); print("Error Log : \(err)"); return }
            self?.customAlert(status: "success")
            
            boardData["document_id"] = boardID
            
            let board = Board(data: boardData)
            board.userInfo = GlobalVar.shared.loginUser
            
            GlobalVar.shared.globalBoardList.append(board)
       }
    }
    
    private func customAlert(status: String) {
        
        loadingView.removeFromSuperview()
        
        switch status {
        case "input-error":
            let title = "投稿エラー"
            let message = "テキストが入力されていないので、投稿できませんでした"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "upload-error":
            let title = "投稿エラー"
            let message = "正常に画像付きの投稿が行えませんでした。\n不具合の報告からシステムエラーを報告してください"
            alert(title: title, message: message, actiontitle: "OK")
            break
        case "post-error":
            let title = "投稿エラー"
            let message = "正常に投稿ができませんでした。\n不具合の報告から運営に報告してください"
            alert(title: title, message: message, actiontitle: "OK")
            break
        default:
            navigationController?.popViewController(animated: true)
            break
        }
    }
}


//MARK: - Appearance

extension BBSInputViewController {
    
    private func configureBarButtonItems() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapLeftBarButtonItem))
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .accentColor
        config.buttonSize = .medium
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 16.0, weight: .regular)
        config.attributedTitle = AttributedString("投稿", attributes: container)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16.0, weight: .regular)
            return outgoing
        }
        let rightButton = UIButton(configuration: config, primaryAction: nil)
        rightButton.addTarget(self, action: #selector(didTapRightBarButtonItem), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
    
    private func configureSelectCategoryButton() {
        var config = UIButton.Configuration.plain()
        config.cornerStyle = .capsule
        config.baseForegroundColor = .categoryFriendColor
        config.buttonSize = .medium
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13.0, weight: .bold)
        config.attributedTitle = AttributedString("友達募集", attributes: container)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13.0, weight: .bold)
            return outgoing
        }
        config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        config.imagePadding = 3.0
        config.imagePlacement = .trailing
        config.contentInsets = .init(top: 1.0, leading: 10.0, bottom: 1.0, trailing: 10.0)
        // 背景の設定
        var backgroundConfig = UIBackgroundConfiguration.clear()
        backgroundConfig.strokeColor = .categoryFriendColor
        backgroundConfig.strokeWidth = 1.0
        config.background = backgroundConfig
        selectCategoryButton.configuration = config
        
        if let category = selectCategoryButton.currentTitle { selectCategoryButtonColor(category: category) }
    }
    
    private func selectCategoryButtonColor(category: String) {
        
        var selectCategoryColor = selectCategoryButton.currentTitleColor
        selectCategoryColor = (category == .categoryFriend  ? .categoryFriendColor  : selectCategoryColor)
        selectCategoryColor = (category == .categoryWorries ? .categoryWorriesColor : selectCategoryColor)
        selectCategoryColor = (category == .categoryTeaser  ? .categoryTeaserColor  : selectCategoryColor)
        selectCategoryColor = (category == .categoryTweet  ? .categoryTweetColor  : selectCategoryColor)

        selectCategoryButton.configuration?.baseForegroundColor = selectCategoryColor
        selectCategoryButton.configuration?.background.strokeColor = selectCategoryColor
    }
    
    private func configureIconImage() {
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = .systemGray5
        guard let loginUser = loginUser else { return }
        iconImageView.setImage(withURLString: loginUser.profile_icon_img)
    }
    
    private func configureInputAccessoryView() {
        
        let stackViewWidth = view.frame.width - 20
        let stackViewItemHeight = CGFloat(30)
        
        let commentTitle = "注意！ビジネス勧誘,ホスト,相席,合コン,交流会の募集は禁止しております。アカウント停止に繋がりますのでご注意下さい。"
        
        let commentButton: UIButton = UIButton(frame: CGRect(x: 10, y: 0, width: stackViewWidth, height: stackViewItemHeight))
        
        var commentConfig = UIButton.Configuration.plain()
        commentConfig.buttonSize = .medium

        var commentContainer = AttributeContainer()
        commentContainer.font = .systemFont(ofSize: 10.0, weight: .bold)

        let attributedTitle = AttributedString(commentTitle, attributes: commentContainer)
        commentConfig.attributedTitle = attributedTitle
        commentConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 10.0, weight: .bold)
            return outgoing
        }
        commentConfig.image = UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
        commentConfig.imagePadding = 5.0
        commentConfig.baseForegroundColor = .systemRed

        commentButton.configuration = commentConfig
        
        let cameraButton: UIButton = UIButton(frame: CGRect(x: 10, y: 0, width: stackViewItemHeight, height: stackViewItemHeight))
        
        var cameraConfig = UIButton.Configuration.plain()
        cameraConfig.buttonSize = .medium
        cameraConfig.image = UIImage(systemName: "camera", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
        cameraButton.configuration = cameraConfig
        cameraButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        
        let photoButton: UIButton = UIButton(frame: CGRect(x: 10, y: 0, width: stackViewItemHeight, height: stackViewItemHeight))
        
        var photoConfig = UIButton.Configuration.plain()
        photoConfig.buttonSize = .medium
        photoConfig.image = UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
        photoButton.configuration = photoConfig
        photoButton.addTarget(self, action: #selector(didTapSelectImage), for: .touchUpInside)
        
        let subInputStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: stackViewWidth, height: stackViewItemHeight))
        subInputStackView.axis = .horizontal
        subInputStackView.alignment = .leading
        
        subInputStackView.addArrangedSubview(cameraButton)
        subInputStackView.addArrangedSubview(photoButton)

        let stackHeight = subInputStackView.frame.height + commentButton.frame.height
        
        let inputStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: stackViewWidth, height: stackHeight))
        inputStackView.axis = .vertical
        inputStackView.alignment = .leading
        
        inputStackView.addArrangedSubview(commentButton)
        inputStackView.addArrangedSubview(subInputStackView)
        
        inputTextField.delegate = self
        inputTextField.inputAccessoryView = inputStackView
        inputTextField.inputAccessoryView?.backgroundColor = .white
    }
    
    private func configureSelectedImage() {
        
        selectedImageView.clipsToBounds = true
        selectedImageView.layer.cornerRadius = 15.0
        if let profileIconImg = loginUser?.profile_icon_img {
            selectedImageView.setImage(withURLString: profileIconImg)
        }
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .darkGray
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        closeSelectedImageButton.configuration = config
        closeSelectedImageButton.setImage(UIImage(systemName: "multiply", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        
        selectedImageBaseView.isHidden = true
    }
}

extension BBSInputViewController : UIImagePickerControllerDelegate {
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = sourceType
        imgPicker.allowsEditing = true
        imgPicker.presentationController?.delegate = self
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let resizedImage = image.resized(size: CGSize(width: 400, height: 400)) {
                selectedImageView.image = resizedImage
            } else {
                selectedImageView.image = image
            }
            selectedImageBaseView.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

