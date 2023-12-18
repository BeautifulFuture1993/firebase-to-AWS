//
//  LoginNameViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/02.
//

import UIKit

class LoginNameViewController: UIBaseViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var parentVC: LoginPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //親VCの取得
        parentVC = self.parent as? LoginPageViewController
        //UI調整
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        nameTextField.leftView = leftPadding
        nameTextField.leftViewMode = .always
        nameTextField.layer.cornerRadius = 10
        nextButton.layer.cornerRadius = 35
        nextButton.setShadow()
        //delegate
        nameTextField.delegate = self
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        //ボタン無効化
        nextButton.isUserInteractionEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
        //自動フォーカス
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.nameTextField.becomeFirstResponder()
        }
    }
    //returnでキーボードを閉じる
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    //textField更新時
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let name = nameTextField.text else { return }
        //10文字以上入力させない
        if name.count > 10 {
            nameTextField.text = String(name.prefix(10))
        }
        //内容が入力されたらボタン有効化
        if name.isEmpty {
            nextButton.isUserInteractionEnabled = false
            nextButton.backgroundColor = .lightGray
        } else {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = UIColor(named: "AccentColor")
        }
    }
    //次に進む
    @IBAction func nextAction(_ sender: UIButton) {
        guard let name = nameTextField.text else { return }
        guard let nextPage = parentVC?.controllers[1] else { return }
        parentVC?.name = name
        parentVC?.setViewControllers([nextPage], direction: .forward, animated: true)
        parentVC?.progressBar.setProgress(2/7, animated: true)
    }
}
