//
//  ViewController.swift
//  EditCommentViewSample
//
//  Created by adachitakehiro2 on 2023/03/20.
//

import UIKit

class EditCommentViewSampleViewController: UIViewController {
    @IBOutlet weak var textLengthLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    var maxTextLength = 59
    var textLength: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        setTextView()
        
    }
    //textviewの設定
    func setTextView() {
        textLengthLabel.text = "\(textLength)/60"
        textView.delegate = self
        textView.text = "写真についてコメントする"
        textView.textColor = UIColor.lightGray
    }
    //ナビゲーションバーの完了ボタンの設定
    func setButton() {
        let rightBarCancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 24))

        rightBarCancelButton.setTitle("完了", for: .normal)

        rightBarCancelButton.layer.cornerRadius = 16
        rightBarCancelButton.backgroundColor = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0)
        
        let rightBarButton = UIBarButtonItem(customView: rightBarCancelButton)
        navigationItem.rightBarButtonItem = rightBarButton
            rightBarCancelButton.addTarget(self, action: #selector(self.completeButtonTapped(_:)), for: UIControl.Event.touchUpInside)
    }

    @objc func completeButtonTapped(_ sender: UIBarButtonItem) {
      //完了ボタンが押された時の処理
        print("aaaaaa")
    }
}

//プレースホルダーと文字数制限・表示
extension EditCommentViewSampleViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "写真についてコメントする"
            textView.textColor = UIColor.lightGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 60
    }
    func textViewDidChange(_ textView: UITextView) {
        self.textLengthLabel.text = "\(textView.text.count)/60"
    }
}

