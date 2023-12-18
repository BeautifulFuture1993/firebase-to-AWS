//
//  LoginAgeViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/28.
//

import UIKit

class LoginBirthViewController: UIBaseViewController {

    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var parentVC: LoginPageViewController?
    var datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        //親VCの取得
        parentVC = self.parent as? LoginPageViewController
        //UI調整
        birthTextField.layer.cornerRadius = 10
        nextButton.layer.cornerRadius = 35
        nextButton.setShadow()
        //picker
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        datePicker.ageLimitDate()
        birthTextField.inputView = datePicker
        birthTextField.inputAccessoryView = toolbar
        //delegate
        birthTextField.delegate = self
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        //ボタン無効化
        nextButton.isUserInteractionEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }
    //自動フォーカス
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.birthTextField.becomeFirstResponder()
        }
    }
    //完了ボタン
    @objc func done() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        birthTextField.text = formatter.string(from: datePicker.date)
        nextButton.enable()
        self.view.endEditing(true)
    }
    //次に進む
    @IBAction func nextAction(_ sender: UIButton) {
        guard let nextPage = parentVC?.controllers[2] else { return }
        parentVC?.birth = birthTextField.text
        parentVC?.setViewControllers([nextPage], direction: .forward, animated: true)
        parentVC?.progressBar.setProgress(3/7, animated: true)
    }
    //前に戻る
    @IBAction func backAction(_ sender: UIButton) {
        guard let backPage = parentVC?.controllers[0] else { return }
        parentVC?.setViewControllers([backPage], direction: .reverse, animated: true)
        parentVC?.progressBar.setProgress(1/7, animated: true)
    }
}
