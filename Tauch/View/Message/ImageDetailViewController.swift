//
//  ImageDetailViewController.swift
//  Tauch
//
//  Created by Apple on 2022/08/15.
//

import UIKit

class ImageDetailViewController: UIBaseViewController {
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var pickedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap))
        recognizer.numberOfTapsRequired = 2
        imageScrollView.addGestureRecognizer(recognizer)
        imageScrollView.delegate = self
        imageScrollView.maximumZoomScale = 2

        saveButton.rounded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickedImageView.image = pickedImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pickedImageView
    }
    
    @objc func onDoubleTap(_ sender: UITapGestureRecognizer) {
        let scale = min(imageScrollView.zoomScale * 2, imageScrollView.maximumZoomScale)
        
        if scale != imageScrollView.zoomScale {
            let tapPoint = sender.location(in: pickedImageView)
            let size = CGSize(width: imageScrollView.bounds.width / scale, height: imageScrollView.bounds.height / scale)
            let origin = CGPoint(x: tapPoint.x - size.width / 2, y: tapPoint.y - size.height / 2)
            imageScrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        } else {
            imageScrollView.zoom(to: imageScrollView.frame, animated: true)
        }
        Log.event(name: "messageImageZoom")
    }
    
    @objc func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Failed to save photo: \(error)")
            alert(title: "画像の保存に失敗しました", message: "再度ダウンロードをしてください。\nうまくいかない場合は、アプリを再起動して再度実行してください", actiontitle: "OK")
        } else {
            alert(title: "画像を保存しました", message: "", actiontitle: "OK")
            Log.event(name: "messageImageSave")
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(pickedImage, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
}
