//
//  BoardCreateViewController.swift
//  Tauch
//
//  Created by Apple on 2023/06/08.
//

import UIKit
import KMPlaceholderTextView
import FirebaseFirestore

class BoardCreateViewController: UIBaseViewController {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var boardTextView: KMPlaceholderTextView!
    @IBOutlet weak var boardCountLabel: UILabel!
    @IBOutlet weak var boardImageBackgroundView: UIView!
    @IBOutlet weak var boardImageView: UIImageView!
    @IBOutlet weak var boardCommentLabel: UILabel!
    @IBOutlet weak var boardCreateButton: UIButton!
    
    static let storyboardName = "BoardCreateView"
    static let storyboardId = "BoardCreateView"
    
    let categoryPicker = UIPickerView()
    let categories = GlobalVar.shared.boardCategories
    
    let boardImagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpComponent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBarBorderAndShowTabBarBorder()
        tabBarController?.tabBar.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func boardCreate(_ sender: Any) {
        
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let category = categoryTextField.text else { return }
        guard let boardText = boardTextView.text else { return }
        
        // ローディング画面を表示させる
        showLoadingView(loadingView: loadingView, text: "アップロード中...")
        
        let boardID = UUID().uuidString
        
        if let boardImage = boardImageView.image { // 画像付きの投稿
            uploadBoardImage(boardImage: boardImage, boardID: boardID, category: category, text: boardText, creator: loginUID)
        } else { // 画像なしの投稿
            setBoardData(boardID: boardID, category: category, text: boardText, creator: loginUID)
        }
    }
    
    // 投稿画像アップロード
    private func uploadBoardImage(boardImage: UIImage, boardID: String, category: String, text: String, creator: String) {
    
        let refName = "boards"
        let folderName = "content"
        let fileName = "img_\(boardID).jpg"
        
        firebaseController.uploadImageToFireStorage(image: boardImage, referenceName: refName, folderName: folderName, fileName: fileName, completion: { [weak self] result in
            if result == "" { self?.boardCreateResult(title: "upload-error"); return }
            // イベント登録
            let boardImgUrl = result
            let logEventData = ["board_img": boardImgUrl] as [String : Any]
            self?.logEvent(name: "uploadBoardImg", logEventData: logEventData)
            
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
            if let err = err { self?.boardCreateResult(title: "error"); print("Error Log : \(err)"); return }
            self?.boardCreateResult(title: "success")
            
            boardData["document_id"] = boardID
            
            let board = Board(data: boardData)
            board.userInfo = GlobalVar.shared.loginUser
            
            GlobalVar.shared.globalBoardList.append(board)
       }
    }
    
    private func boardCreateResult(title: String) {
        
        loadingView.removeFromSuperview()
        
        switch title {
        case "upload-error":
            alert(title: "投稿エラー", message: "正常に画像付きの投稿が行えませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
            break
        case "error":
            alert(title: "投稿エラー", message: "正常に投稿されませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
            break
        default:
            navigationController?.popViewController(animated: true)
            break
        }
    }
    
    private func setUpComponent() {
        
        setUpNavigationBar()
        
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        // カテゴリ
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.tag = 0
        categoryTextField.inputView = categoryPicker
        let categoryToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let categoryDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(selectCategory))
        categoryToolbar.setItems([spacelItem, categoryDoneItem], animated: true)
        categoryTextField.inputAccessoryView = categoryToolbar
        categoryTextField.text = categories[0]
        // 投稿文
        boardTextView.delegate = self
        boardTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 15)
        let boardTextToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let boardTextDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeKeyboard))
        boardTextToolbar.setItems([spacelItem, boardTextDoneItem], animated: true)
        boardTextView.inputAccessoryView = boardTextToolbar
        // 投稿写真
        boardImagePicker.delegate = self
        let addBoardImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(addBoardImageAction))
        boardImageView.addGestureRecognizer(addBoardImageTapGesture)
        // 投稿作成注意
        let boardComment = boardCommentLabel.text ?? ""
        let boardCommentAttr = NSMutableAttributedString(string: boardComment)
        boardCommentAttr.addAttributes([
            .foregroundColor: UIColor.red,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ], range: NSMakeRange(0, 3))
        boardCommentLabel.attributedText = boardCommentAttr
        // 投稿作成ボタン
        boardCreateButton.disable()
        
        categoryTextField.layer.cornerRadius = 10
        boardTextView.layer.cornerRadius = 10
        boardImageView.layer.cornerRadius = 20
        boardImageView.setShadow()
        boardImageBackgroundView.layer.cornerRadius = 20
        boardImageBackgroundView.setShadow()
        boardCreateButton.layer.cornerRadius = boardCreateButton.frame.height / 2
        boardCreateButton.setShadow()
        // 背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }
    // ナビゲーション
    private func setUpNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = true

        let backImage = UIImage(systemName: "chevron.backward")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem?.tintColor = .fontColor
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.title = "投稿を作成"
    }
    
    @objc func back() {
        if boardCreateButton.isUserInteractionEnabled {
            let alert = UIAlertController(title: "投稿が作成途中です", message: "本当にこの画面を離れてもよろしいですか？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            alert.addAction(UIAlertAction(title: "離れる", style: .destructive) { [self] _ in
                navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    // カテゴリ完了ボタン
    @objc func selectCategory() {
        let selectCategoryRow = categoryPicker.selectedRow(inComponent: 0)
        if let category = categories[safe: selectCategoryRow] {
            categoryTextField.text = category
            enableButtonIfFilled()
            categoryTextField.resignFirstResponder()
        }
    }
    // 投稿文完了ボタン
    @objc func closeKeyboard() {
        boardTextView.resignFirstResponder()
    }
    // 投稿写真アイコン
    @objc private func addBoardImageAction() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            boardImagePicker.sourceType = sourceType
            boardImagePicker.delegate = self
            boardImagePicker.allowsEditing = true
            self.present(boardImagePicker, animated: true, completion: nil)
        }
    }
    //全て入力されていたらボタンを有効化
    private func enableButtonIfFilled() {
        let isNotEmptyCategory = (categoryTextField.text?.isEmpty == false)
        let isNotEmptyBoardText = (boardTextView.text.isEmpty == false)
        let regexBoardText = (boardTextView.text.count <= 140)
        let isNotEmptyForAll = (isNotEmptyCategory && isNotEmptyBoardText && regexBoardText)
        if isNotEmptyForAll {
            boardCreateButton.enable()
        } else {
            boardCreateButton.disable()
        }
    }
}

extension BoardCreateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //Pickerの列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //pickerの行
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // カテゴリ選択
        if pickerView.tag == 0 { return categories.count }
        return 0
    }
    //pickerの選択肢
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // カテゴリ選択
        if pickerView.tag == 0 { return categories[safe: row] }
        return "未設定"
    }
}

extension BoardCreateViewController {
    // 140文字以上入力させない
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 140
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        boardCountLabel.text = "\(140 - boardTextView.text.count)"
        enableButtonIfFilled()
    }
}

extension BoardCreateViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.editedImage] as? UIImage else { return }
        let resizedImage = pickedImage.resized(size: CGSize(width: 400, height: 400))
        let compressedImage = resizedImage?.compress()
        boardImageView.image = compressedImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}
