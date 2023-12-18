//
//  LoginImageViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/02.
//

import UIKit
import FirebaseFirestore

class LoginImageViewController: UIBaseViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet var iconImages: [UIImageView]!
    @IBOutlet var deleteButtons: [UIButton]!
    @IBOutlet var plusImages: [UIImageView]!
    @IBOutlet var iconBackgrounds: [UIView]!
    
    var parentVC: LoginPageViewController?
    
    let imagePicker = UIImagePickerController()
    var iconEditFlg = false
    var plusIndex = 0 {
        didSet {
            iconImages[plusIndex - 1].isUserInteractionEnabled = false
            if plusIndex > 1 {
                deleteButtons[plusIndex - 2].isHidden = false
            }
            if plusIndex < 5 {
                plusImages[plusIndex + 1].isHidden = true
            }
            if plusIndex < 6 {
                plusImages[plusIndex].isHidden = false
                iconImages[plusIndex].isUserInteractionEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentVC = self.parent as? LoginPageViewController
        
        nextButton.isUserInteractionEnabled = false
        nextButton.layer.cornerRadius = 35
        nextButton.setShadow()
        
        imagePicker.delegate = self
        editButton.layer.cornerRadius = 15
        iconImages.forEach{ $0.layer.cornerRadius = 10 }
        deleteButtons.forEach{ $0.layer.cornerRadius = 12 }
        iconBackgrounds.forEach{ $0.layer.cornerRadius = 10 }
        iconImages.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addAction))) }
        
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            guard let user = GlobalVar.shared.loginUser else { return }
            // プロフィール画像を設定
            weakSelf.iconImages[0].setImage(withURLString: user.profile_icon_img)
            for i in 0..<user.profile_icon_sub_imgs.count {
                weakSelf.iconImages[i + 1].setImage(withURLString: user.profile_icon_sub_imgs[i])
            }
            
            weakSelf.iconImages.forEach {
                if $0.tag > user.profile_icon_sub_imgs.count {
                    weakSelf.deleteButtons[$0.tag - 1].isHidden = true
                    if $0.tag < 5 {
                        weakSelf.plusImages[$0.tag + 1].isHidden = true
                        weakSelf.iconImages[$0.tag + 1].isUserInteractionEnabled = false
                    }
                } else {
                    weakSelf.plusIndex = $0.tag + 1
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }

    @IBAction func nextAction(_ sender: UIButton) {
        guard let nextPage = parentVC?.controllers[5] else { return }
        parentVC?.setViewControllers([nextPage], direction: .forward, animated: true)
        parentVC?.progressBar.setProgress(6/7, animated: true)
        saveIcons()
    }

    @IBAction func backAction(_ sender: UIButton) {
        guard let backPage = parentVC?.controllers[3] else { return }
        parentVC?.setViewControllers([backPage], direction: .reverse, animated: true)
        parentVC?.progressBar.setProgress(4/7, animated: true)
    }
    
    @objc private func addAction() {
        iconEditFlg = false
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func deleteAction(_ sender: UIButton) {
        iconEditFlg = false
        if sender.tag == plusIndex - 1 {
            iconImages[sender.tag].image = nil
            plusImages[sender.tag].isHidden = false
            sender.isHidden = true
            plusIndex -= 1
        } else {
            for i in sender.tag..<5 {
                iconImages[i].image = iconImages[i + 1].image
            }
            iconImages[plusIndex - 1].image = nil
            plusImages[plusIndex - 1].isHidden = false
            deleteButtons[plusIndex - 2].isHidden = true
            if plusIndex < 6 {
                plusImages[plusIndex].isHidden = true
            }
            plusIndex -= 1
        }
    }

    @IBAction func editAction(_ sender: UIButton) {
        iconEditFlg = true
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    private func saveIcons() {
        guard let uid = GlobalVar.shared.currentUID else { return }
        
        var images = [UIImage]()
        iconImages.forEach {
            if let image = $0.image {
                images.append(image)
            }
        }
        
        firebaseController.uploadIconsToFireStorage(currentUID: uid, beforeImages: images, afterImages: images) { [weak self] urls in
            guard let weakSelf = self else { return }
            var subIconUrls = urls
            subIconUrls.removeFirst()
            
            let registTime = Timestamp()
            weakSelf.db.collection("users").document(uid).setData([
                "profile_icon_img": urls[0],
                "profile_icon_sub_imgs": subIconUrls,
                "created_at": registTime,
                "updated_at": registTime
            ]) { [weak self] error in
                guard let _ = self else { return }
                guard error == nil else { return }
                GlobalVar.shared.loginUser?.profile_icon_img = urls[0]
                GlobalVar.shared.loginUser?.profile_icon_sub_imgs = subIconUrls
            }
        }
    }
}

extension LoginImageViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.editedImage] as? UIImage else { return }
        let resizedImage = pickedImage.resized(size: CGSize(width: 400, height: 400))
        let compressedImage = resizedImage?.compress()
        
        if iconEditFlg {
            iconImages[0].image = compressedImage
        } else {
            iconImages[plusIndex].image = compressedImage
            plusIndex += 1
        }
        nextButton.backgroundColor = UIColor(named: "AccentColor")
        nextButton.isUserInteractionEnabled = true
        editButton.isHidden = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}
