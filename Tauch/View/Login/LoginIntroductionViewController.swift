//
//  LoginIntroductionViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/02.
//

import UIKit

class LoginIntroductionViewController: UIBaseViewController {

    @IBOutlet weak var exampleButton: UIButton!
    @IBOutlet weak var explainTextLabel: UILabel!
    @IBOutlet weak var introductionTextView: UITextView!
    @IBOutlet weak var introductionTextViewCount: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var parentVC: LoginPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //親VCの取得
        parentVC = self.parent as? LoginPageViewController
        //delegate
        introductionTextView.delegate = self
        //UI調整
        exampleButton.layer.cornerRadius = 10
        introductionTextView.layer.cornerRadius = 10
        introductionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
        nextButton.layer.cornerRadius = 35
        nextButton.setShadow()
        exampleButton.setShadow()
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        //完了ボタン追加
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeKeyboard))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        introductionTextView.inputAccessoryView = toolbar
        //ボタン無効化
        nextButton.isUserInteractionEnabled = false
        //自己紹介のデフォルト記載を定義
        introductionTextView.text = Introduce.example[0]
        // 自己紹介説明文
        explainTextLabel.addAccent(pattern: "アカウント停止", color: .red)
//        //キーボードの開閉時に通知を取得
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }
    //自動フォーカス
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.introductionTextView.becomeFirstResponder()
        }
    }
    // キーボードが表示された時
    @objc private func keyboardWillShow(sender: NSNotification) {
        if introductionTextView.isFirstResponder {
            guard let userInfo = sender.userInfo else { return }
            let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                let transform = CGAffineTransform(translationX: 0, y: -180)
                self.view.transform = transform
            })
        }
    }
    // キーボードが閉じられた時
    @objc private func keyboardWillHide(sender: NSNotification) {
        guard let userInfo = sender.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
    }
    //キーボードを閉じる
    @objc func closeKeyboard() {
        introductionTextView.resignFirstResponder()
    }
    //次に進む
    @IBAction func nextAction(_ sender: UIButton) {
        guard let nextPage = parentVC?.controllers[6] else { return }
        parentVC?.introduction = introductionTextView.text
        parentVC?.setViewControllers([nextPage], direction: .forward, animated: true)
        parentVC?.progressBar.setProgress(1, animated: true)
    }
    @IBAction func backAction(_ sender: UIButton) {
        guard let backPage = parentVC?.controllers[4] else { return }
        parentVC?.setViewControllers([backPage], direction: .reverse, animated: true)
        parentVC?.progressBar.setProgress(5/7, animated: true)
    }
    //自己紹介例文
    @IBAction func exampleAction(_ sender: Any) {
        Log.event(name: "pickupExampleIntroduce")
        let alert = UIAlertController(title: "使う例文を選択してください", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "上京したて", style: .default) { [weak self] action in
            self?.setIntroduce(example: 0)
        })
        alert.addAction(UIAlertAction(title: "趣味友達作り", style: .default) { [weak self] action in
            self?.setIntroduce(example: 1)
        })
        alert.addAction(UIAlertAction(title: "気軽にお出かけ", style: .default) { [weak self] action in
            self?.setIntroduce(example: 2)
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        introductionTextViewCount.text = String(introductionTextView.text.count)
        
        let minIntroduction = (introductionTextView.text.count >= 70)
        let regexIntroduction = (introductionTextView.text.contains("〇") == false)
        //内容入力が70文字以上かつ「〇」文言を入力されていなければボタン有効化
        if minIntroduction && regexIntroduction {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = UIColor(named: "AccentColor")
        } else {
            nextButton.isUserInteractionEnabled = false
            nextButton.backgroundColor = .lightGray
        }
    }
    //例文挿入
    private func setIntroduce(example: Int) {
        let exampleAlert = UIAlertController(title: "以下の例文に上書きしますがよろしいですか？", message:Introduce.example[example], preferredStyle: .alert)
        exampleAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        exampleAlert.addAction(UIAlertAction(title: "上書きする", style: .default) { [weak self] action in
            self?.introductionTextView.text = Introduce.example[example]
            let logEventData = [
               "example": example
            ] as [String : Any]
            Log.event(name: "selectExampleIntroduce", logEventData: logEventData)
        })
        self.present(exampleAlert, animated: true)
    }
}
