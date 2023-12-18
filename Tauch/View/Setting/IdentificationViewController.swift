//
//  IdentificationViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/16.
//

import UIKit
import FirebaseFirestore

class IdentificationViewController: UIBaseViewController {

    @IBOutlet weak var idImageView: UIImageView!
    @IBOutlet weak var idSendBtn: UIButton!
    @IBOutlet weak var noteBackground: UIView!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    
    let idCardPicker = UIImagePickerController()
    var datePicker = UIDatePicker()
    var uploadImageFlg: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        idImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectFile)))
        noteBackground.layer.cornerRadius = 10
        birthTextField.layer.cornerRadius = 10
        cameraButton.layer.cornerRadius = 10
        idImageView.layer.cornerRadius = 10
        idSendBtn.layer.cornerRadius = 35
        idSendBtn.setShadow()
        cameraButton.setShadow()
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        datePicker.ageLimitDate()
        birthTextField.inputView = datePicker
        birthTextField.inputAccessoryView = toolbar
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        birthTextField.text = GlobalVar.shared.loginUser?.birth_date
        
        GlobalVar.shared.messageInputView?.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        GlobalVar.shared.messageInputView?.isHidden = false
    }
    
    @objc func done() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        birthTextField.text = formatter.string(from: datePicker.date)
        GlobalVar.shared.loginUser?.birth_date = birthTextField.text!
        enableButtonIfFilled()
        self.view.endEditing(true)
    }
    
    @IBAction func back(_ sender: Any) { dismiss(animated: true, completion: nil) }
    
    @objc func selectFile() {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            idCardPicker.sourceType = sourceType
            idCardPicker.delegate = self
            idCardPicker.allowsEditing = true
            present(idCardPicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraAction(_ sender: UIButton) {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            idCardPicker.sourceType = sourceType
            idCardPicker.delegate = self
            idCardPicker.allowsEditing = true
            present(idCardPicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendID(_ sender: Any) {
        
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        
        let idCard = idImageView
        let birthDate = birthTextField.text ?? ""
        let isBirthDateEmpty = (birthDate == "")
        let isIdentificationImageEmpty = (idCard?.image == UIImage(systemName: "photo.fill"))
        // 生年月日が入力されている・画像が選択されている場合
        if !isBirthDateEmpty && !isIdentificationImageEmpty {
            updateBirthDate(uid: uid, birthDate: birthDate)
        } else {
            self.alert(title: "身分証登録エラー", message: "画像が選択されていない、または生年月日が入力されておりません", actiontitle: "OK")
        }
    }
    // FireStoreに生年月日を更新
    private func updateBirthDate(uid: String, birthDate: String) {
        // ローディング画面を表示させる
        showLoadingView(loadingView)
        // 生年月日を更新
        let updateTime = Timestamp()
        let updateData = [
            "birth_date": birthDate,
            "updated_at": updateTime
        ] as [String : Any]
        // プロフィールデータ更新
        db.collection("users").document(uid).updateData(updateData)
        
        GlobalVar.shared.loginUser?.birth_date = birthDate
        // 画像アップロード
        uploadImageFlg = true
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(cancelUploadImage), userInfo: nil, repeats: false)
        
        uploadIdentificationImgStrage(userID: uid, birthDate: birthDate, completion: { [weak self] result in
            
            if self?.uploadImageFlg == true {
                
                self?.loadingView.removeFromSuperview()
                self?.uploadImageFlg = false
                
                guard let weakSelf = self else { return }
                if result {
                    let title = "本人確認を提出しました"
                    let message = "結果は12時間以内に通知およびメールにてご連絡します"
                    weakSelf.customAlertAction(title: title, message: message)
                    
                } else {
                    let title = "身分証登録エラー"
                    let message = "正常に画像が登録されませんでした。\n不具合の報告からシステムエラーを報告してください"
                    weakSelf.customAlertAction(title: title, message: message)
                }
            }
        })
    }
    // FireStoreに身分証画像をアップロード
    private func uploadIdentificationImgStrage(userID: String, birthDate: String, completion: @escaping (Bool) -> Void) {
        
        guard let idImage = idImageView.image, let resizedImage = idImage.resized(size: CGSize(width: 400, height: 400)) else { completion(false); return }
        
        let refName = "users"
        let folderName = "id"
        let fileName = "img_\(userID).jpg"
        
        let customMetadata = ["type": "identification"]
        
        firebaseController.uploadImageToFireStorage(image: resizedImage, referenceName: refName, folderName: folderName, fileName: fileName, customMetadata: customMetadata, completion: { [weak self] result in
            guard let weakSelf = self else { completion(false); return }
            if result == "" { completion(false); return }
            print("身分証のアップロードに成功しました")
            // イベント登録
            let logEventData = ["birth_date": birthDate] as [String : Any]
            Log.event(name: "uploadIdentificationImg", logEventData: logEventData)
            // 本人確認登録
            let registTime = Timestamp()
            let adminCheckData = [
                "identification": result,
                "admin_id_check_status": 0,
                "created_at": registTime,
                "updated_at": registTime
            ] as [String : Any]
            
            weakSelf.db.collection("users").document(userID).collection("admin_checks").document(userID).setData(adminCheckData) { [weak self] error in
                guard let _ = self else { completion(false); return }
                if let err = error { print("本人確認の追加に失敗: \(err)"); completion(false); return }
                print("本人確認追加完了しました")
                completion(true)
            }
        })
    }
    @objc private func cancelUploadImage() {
        
        if uploadImageFlg {
            
            uploadImageFlg = false
            loadingView.removeFromSuperview()
            
            let title = "画像登録時間の超過"
            let message = "画像の登録に時間がかかり過ぎているため\n正常に画像が登録されていない可能性があります。\nアプリを再起動して再度提出を試してください"
            customAlertAction(title: title, message: message)
        }
    }
    //入力項目が埋まっていたらボタン有効化
    private func enableButtonIfFilled() {
        guard let birthDate = birthTextField.text else { return }
        if idImageView.image != nil && birthDate.isEmpty == false {
            idSendBtn.enable()
        } else {
            idSendBtn.disable()
        }
    }
    
    func customAlertAction(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in self?.dismiss(animated: true) }))
        present(alert, animated: true)
    }
}

extension IdentificationViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            let compressedImage = pickedImage.compress()
            idImageView.image = compressedImage
            enableButtonIfFilled()
            picker.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}
