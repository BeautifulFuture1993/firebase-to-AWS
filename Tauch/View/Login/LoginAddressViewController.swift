//
//  LoginAddressViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/02.
//

import UIKit

class LoginAddressViewController: UIBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var address2TextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var parentVC: LoginPageViewController?
    var areas = GlobalVar.shared.areas
    var municipalities = GlobalVar.shared.municipalities
    let addressPickerView = UIPickerView()
    let addressPickerView2 = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        areas = GlobalVar.shared.areas
        municipalities = GlobalVar.shared.municipalities
        // 親VCの取得
        parentVC = self.parent as? LoginPageViewController
        // UI調整
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        let leftPadding2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        addressTextField.leftView = leftPadding
        address2TextField.leftView = leftPadding2
        addressTextField.leftViewMode = .always
        address2TextField.leftViewMode = .always
        addressTextField.layer.cornerRadius = 10
        address2TextField.layer.cornerRadius = 10
        nextButton.layer.cornerRadius = 35
        nextButton.setShadow()
        // delegate
        addressPickerView.delegate = self
        addressPickerView2.delegate = self
        addressPickerView.dataSource = self
        addressPickerView2.dataSource = self
        addressTextField.delegate = self
        address2TextField.delegate = self
        // 完了ボタン
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let toolbar2 = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let doneItem2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done2))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        toolbar2.setItems([spacelItem, doneItem2], animated: true)
        addressTextField.inputView = addressPickerView
        address2TextField.inputView = addressPickerView2
        addressTextField.inputAccessoryView = toolbar
        address2TextField.inputAccessoryView = toolbar2
        // 背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        // ボタン無効化
        nextButton.isUserInteractionEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
    }
    // 自動フォーカス
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.addressTextField.becomeFirstResponder()
        }
    }
    // 完了ボタン
    @objc private func done() {
        addressTextField.endEditing(true)
        addressTextField.text = areas[addressPickerView.selectedRow(inComponent: 0)]
        address2TextField.text = "選択してください"
        address2TextField.isUserInteractionEnabled = true
        address2TextField.becomeFirstResponder()
        nextButton.disable()
    }
    // 完了ボタン2
    @objc private func done2() {
        
        let selectArea = areas[addressPickerView.selectedRow(inComponent: 0)]
        let selectAddress2 = addressPickerView2.selectedRow(inComponent: 0)
        if let municipality = municipalities[selectArea] {
            address2TextField.text = municipality[selectAddress2]
            address2TextField.resignFirstResponder()
            nextButton.enable()
        }
    }
    // 次に進む
    @IBAction func nextAction(_ sender: UIButton) {
        guard let address = addressTextField.text else { return }
        guard let address2 = address2TextField.text else { return }
        guard let nextPage = parentVC?.controllers[3] else { return }
        parentVC?.address = address
        parentVC?.address2 = address2
        parentVC?.setViewControllers([nextPage], direction: .forward, animated: true)
        parentVC?.progressBar.setProgress(4/7, animated: true)
    }
    // 前に戻る
    @IBAction func backAction(_ sender: UIButton) {
        guard let backPage = parentVC?.controllers[1] else { return }
        parentVC?.setViewControllers([backPage], direction: .reverse, animated: true)
        parentVC?.progressBar.setProgress(2/7, animated: true)
    }
    // Picker設定
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == addressPickerView {
            return areas.count
        } else {
            let selectArea = areas[addressPickerView.selectedRow(inComponent: 0)]
            let municipalityList = municipalities[selectArea] ?? ["未設定"]
            return municipalityList.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == addressPickerView {
            return areas[row]
        } else {
            let selectArea = areas[addressPickerView.selectedRow(inComponent: 0)]
            let municipalityList = municipalities[selectArea] ?? ["未設定"]
            return municipalityList[row]
        }
    }
}
