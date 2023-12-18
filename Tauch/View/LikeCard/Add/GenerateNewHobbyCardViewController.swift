//
//  GenerateNewLikeCardViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/29.
//

import UIKit
import FirebaseFirestore

class GenerateNewHobbyCardViewController: UIBaseViewController {
    
    @IBOutlet weak var newCardNameContainerView: UIView!
    @IBOutlet weak var newCardNameTitleLabel: UILabel!
    @IBOutlet weak var newCardNameLabel: UILabel!
    @IBOutlet weak var newCardNameCellButton: UIButton!
    
    @IBOutlet weak var selectCategoryContainerView: UIView!
    @IBOutlet weak var selectCategoryTitleLabel: UILabel!
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var selectCategoryButtonLabel: UILabel!
    @IBOutlet weak var selectedCardCategoryLabel: UILabel!
    
    @IBOutlet weak var selectPicContainerView: UIView!
    @IBOutlet weak var selectPicTitleLabel: UILabel!
    @IBOutlet weak var selectPicButton: UIButton!
    @IBOutlet weak var createHobbyCardButton: UIButton!
    
    static let storyboardName = "GenerateNewHobbyCardView"
    static let storyboardId = "GenerateNewHobbyCardView"

    // createButtonのenable()/disable()を切り替え
    private var elementsAreEmpty = [true, true, true] {
        didSet {
            elementsAreEmpty.contains(true) ? createHobbyCardButton.disable() : createHobbyCardButton.enable()
        }
    }
    // 各値を保存するためのプロパティ
    private var newCardNameText: String = "" {
        didSet {
            elementsAreEmpty[0] = newCardNameText.isEmpty
            newCardNameLabel.text = newCardNameText
        }
    }
    private var selectedCategory: String = "" {
        didSet {
            elementsAreEmpty[1] = selectedCategory.isEmpty
            selectedCardCategoryLabel.text = selectedCategory
            selectCategoryButtonLabel.isHidden = true
        }
    }
    private var selectedImage: UIImage? {
        didSet { elementsAreEmpty[2] = (selectedImage == nil) }
    }
    var uploadImageFlg: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        customNavigationWithBackBtnSetUp(navigationTitle: "趣味カードを作成")
        configureScreenAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        let ownSpecificHobbyCard = GlobalVar.shared.ownSpecificHobbyCard
        if let hobbyCardTitle = ownSpecificHobbyCard["hobbyCardTitle"] as? String {
            newCardNameText = hobbyCardTitle
        }
    }
    
    @IBAction func newCardNameCellButtonPressed(_ sender: UIButton) {
        
        let inputNewHobbyCardTitleStoryboardName = InputNewHobbyCardTitleViewController.storyboardName
        let inputNewHobbyCardTitleStoryboardID = InputNewHobbyCardTitleViewController.storyboardId
        
        screenTransition(storyboardName: inputNewHobbyCardTitleStoryboardName, storyboardID: inputNewHobbyCardTitleStoryboardID)
    }
    
    @IBAction func selectCategoryButtonPressed(_ sender: UIButton) {
        
        let storyboardName = SelectCategoryViewController.storyboardName
        let storyboardID = SelectCategoryViewController.storyboardId
        let storyBoard = UIStoryboard.init(name: storyboardName, bundle: nil)
        let modalVC = storyBoard.instantiateViewController(withIdentifier: storyboardID) as! SelectCategoryViewController
        modalVC.transitioningDelegate = self
        modalVC.presentationController?.delegate = self
        modalVC.presentationController?.delegate = self
        
        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 0
        }
        present(modalVC, animated: true)
    }
    
    @IBAction func selectPicButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func createHobbyCardButtonPressed(_ sender: UIButton) {
        // 保存していたGlobalVarの解放
        GlobalVar.shared.ownSpecificHobbyCard = [:]
        // モデルの作成
        guard let selectedImage = selectedImage else { return }
        
        let title = newCardNameText
        let category = selectedCategory
        let iconImg = selectedImage
        uploadNewHobbyCard(title: title, category: category, iconImg: iconImg)
    }

}

extension GenerateNewHobbyCardViewController {
    
    // Backボタン付きのナビゲーション
    private func customNavigationWithBackBtnSetUp(navigationTitle: String) {
        // ナビゲーションバーを表示する
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // ナビゲーションの戻るボタンを消す
        self.navigationItem.setHidesBackButton(true, animated: true)
        // ナビゲーションバーの透過させる
        self.navigationController?.navigationBar.isTranslucent = true
        //ナビゲーションアイテムのタイトルを設定
        self.navigationItem.title = navigationTitle
        //ナビゲーションバー左ボタンを設定
        let backImage = UIImage(systemName: "chevron.backward")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action:#selector(customPageBack))
        self.navigationItem.leftBarButtonItem?.tintColor = .fontColor
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 一つ前の画面に戻る
    @objc private func customPageBack() {
        GlobalVar.shared.ownSpecificHobbyCard = [:]
        navigationController?.popViewController(animated: true)
    }
    
    private func configureScreenAppearance() {
        // cardName
        configureLabelTextStyle(newCardNameTitleLabel, title: "カード名", fontSize: 10, textColor: UIColor.darkGray)
        configureLabelTextStyle(newCardNameLabel, title: newCardNameText, fontSize: 14, fontWeight: .medium, textColor: UIColor.accentColor)
        newCardNameLabel.adjustsFontSizeToFitWidth = true
        newCardNameLabel.numberOfLines = 1
        newCardNameCellButton.setTitle("", for: .normal)
        
        // category
        configureLabelTextStyle(selectCategoryTitleLabel, title: "カテゴリー", fontSize: 10, textColor: UIColor.darkGray)
        configureLabelTextStyle(selectCategoryButtonLabel, title: "カテゴリーを選択", fontSize: 10, textColor: UIColor.black)
        configureLabelTextStyle(selectedCardCategoryLabel, title: selectedCategory, fontSize: 12, fontWeight: .medium, textColor: UIColor.accentColor)
        var categoryButtonConfig = UIButton.Configuration.filled()
        categoryButtonConfig.baseBackgroundColor = .clear
        categoryButtonConfig.baseForegroundColor = .clear
        categoryButtonConfig.background.strokeColor = .gray
        categoryButtonConfig.background.strokeWidth = 1.0
        categoryButtonConfig.cornerStyle = .capsule
        categoryButtonConfig.title = ""
        selectCategoryButton.configuration = categoryButtonConfig
        
        // selectPic
        configureLabelTextStyle(selectPicTitleLabel, title: "写真を選択", fontSize: 10, textColor: UIColor.darkGray)
        selectPicButton.configuration = nil
        selectPicButton.layer.cornerRadius = 5.0
        
        // createButton
        createHobbyCardButton.configuration = nil
        createHobbyCardButton.layer.cornerRadius = 23
        createHobbyCardButton.setTitleColor(UIColor.white, for: .normal)
        createHobbyCardButton.setTitle("作成する", for: .normal)
        createHobbyCardButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        createHobbyCardButton.disable()
    }
    
    private func configureLabelTextStyle(_ label: UILabel, title: String, fontSize: CGFloat, fontWeight: UIFont.Weight = .regular, textColor: UIColor, textAlignment: NSTextAlignment = .left) {
        label.text = title
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.textColor = textColor
        label.textAlignment = textAlignment
    }
}


//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension GenerateNewHobbyCardViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 選択した画像をボタンのimageとしてセット, selectedImageに保存
        if let editedImage = info[.editedImage] as? UIImage {
            selectPicButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectPicButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            selectedImage = originalImage
        }
        selectPicButton.imageView?.contentMode = .scaleAspectFill
        selectPicButton.contentHorizontalAlignment = .fill
        selectPicButton.contentVerticalAlignment = .fill
        selectPicButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
}

extension GenerateNewHobbyCardViewController {
    
    override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        tabBarController?.tabBar.isHidden = true
        
        guard let category = GlobalVar.shared.ownSpecificHobbyCard["SelectedHobbyCardCategory"] as? String else { return }
        selectedCategory = category
    }
}

//MARK: - Firebaseへの保存

extension GenerateNewHobbyCardViewController {

    @objc private func cancelUploadImage() {
        
        if uploadImageFlg {
            
            uploadImageFlg = false
            loadingView.removeFromSuperview()
            
            popPageAlert(status: "upload-elasped-error")
        }
    }
    
    func uploadNewHobbyCard(title: String, category: String, iconImg: UIImage) {
        // ローディング画面を表示させる
        showLoadingView(loadingView)
        // 画像アップロード
        uploadImageFlg = true
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(cancelUploadImage), userInfo: nil, repeats: false)
        
        let hobbyCardID = UUID().uuidString
        uploadCategoryImgStrage(hobbyCardID: hobbyCardID, title: title, category: category, iconImg: iconImg, completion: { [weak self] result in
            
            if self?.uploadImageFlg == true {
                
                self?.uploadImageFlg = false
                
                guard let weakSelf = self else { return }
                if result == "" {
                    weakSelf.loadingView.removeFromSuperview()
                    weakSelf.popPageAlert(status: "upload-error")
                    return
                }
                let iconImageURL = result
                weakSelf.createHobbyCard(hobbyCardID: hobbyCardID, title: title, category: category, iconImageURL: iconImageURL)
            }
        })
    }
    // FireStoreに趣味カード画像をアップロード
    private func uploadCategoryImgStrage(hobbyCardID: String, title: String, category: String, iconImg: UIImage, completion: @escaping (String) -> Void) {
        
        guard let resizedImage = iconImg.resized(size: CGSize(width: 400, height: 400)) else { completion(""); return }
        
        let refName = "hobby_cards"
        let folderName = "categories"
        let fileName = "img_\(hobbyCardID).jpg"
        
        let customMetadata = ["type": "hobby_card", "id": hobbyCardID]
        
        firebaseController.uploadImageToFireStorage(image: resizedImage, referenceName: refName, folderName: folderName, fileName: fileName, customMetadata: customMetadata, completion: { [weak self] result in
            guard let weakSelf = self else { completion(""); return }
            if result == "" { completion(""); return }
            print("カテゴリ写真のアップロードに成功しました")
            // イベント登録
            let hobbyCardImgUrl = result
            let logEventData = ["hobby_card_img": hobbyCardImgUrl] as [String : Any]
            Log.event(name: "uploadHobbyCardCategoryImg", logEventData: logEventData)

            completion(result)
        })
    }
    
    func createHobbyCard(hobbyCardID: String, title: String, category: String, iconImageURL: String) {
        
        let registTime = Timestamp()
        let hobbyCardData = [
            "title": title,
            "category": category,
            "image": iconImageURL,
            "approval_flg": true,
            "created_at": registTime,
            "updated_at": registTime
        ] as [String : Any]
        
        db.collection("hobby_cards").document(hobbyCardID).setData(hobbyCardData) { [weak self] error in
            guard let weakSelf = self else { return }
            
            weakSelf.loadingView.removeFromSuperview()
            
            if let err = error {
                print("趣味カードのデータの追加に失敗: \(err)")
                weakSelf.popPageAlert(status: "regist-error")
                return
            }
            weakSelf.updateHobbyCard(hobby: title)
            weakSelf.popPageAlert(status: "complete")
        }
    }
    
    private func updateHobbyCard(hobby: String) {
        
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        
        let updatedTime = Timestamp()
        let hobbyData = [
            "hobbies": FieldValue.arrayUnion([hobby]),
            "updated_at": updatedTime
        ]
        
        db.collection("users").document(uid).updateData(hobbyData)
            
        GlobalVar.shared.loginUser?.hobbies.append(hobby)
    }
    
    private func popPageAlert(status: String) {
        
        var title = ""
        var message = ""
        
        switch status {
        case "upload-error":
            title = "カテゴリ画像登録エラー"
            message = "正常に画像が登録されませんでした。\n不具合の報告からシステムエラーを報告してください"
            break
        case "upload-elasped-error":
            title = "画像登録時間の超過"
            message = "画像の登録に時間がかかり過ぎているため\n正常に画像が登録されていない可能性があります。\nアプリを再起動して再度提出を試してください"
            break
        case "regist-error":
            title = "趣味カード登録エラー"
            message = "正常に趣味カードが登録されませんでした。\n不具合の報告からシステムエラーを報告してください"
            break
        case "complete":
            title = "趣味カード登録完了"
            message = "趣味カードの登録が完了しました。"
            break
        default:
            break
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            self?.customPageBack()
        }))
        present(alert, animated: true)
    }
}
