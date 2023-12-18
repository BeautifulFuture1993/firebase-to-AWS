//
//  StopViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/05/12.
//

import UIKit

class StopViewController: UIBaseViewController {

    @IBOutlet weak var stopContent1View: UITextView!
    @IBOutlet weak var textView2: UITextView!
    @IBOutlet weak var textView3: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var precautionView: UIView!
    
    var targetUser: User?
    var closure: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.layer.cornerRadius = 35
        precautionView.layer.cornerRadius = 10
        stopContent1View.layer.cornerRadius = 10
        textView2.layer.cornerRadius = 10
        textView3.layer.cornerRadius = 10
        
        stopContent1View.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView2.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView3.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        stopContent1View.delegate = self
        textView2.delegate = self
        textView3.delegate = self
        
        submitButton.setShadow()
        
        //背景タップ時にキーボード閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func submitAction(_ sender: UIButton) {

        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let targetUID = targetUser?.uid else { return }
        guard let targetNickName = targetUser?.nick_name else { return }
        
        if stopContent1View.text == "" || textView2.text == "" || textView3.text == "" {
            alert(title: "入力されていない項目があります", message: "全ての項目を入力してください。", actiontitle: "OK")
        } else {
            var isCheckResult = false
            let isCheckYes = (yesButton.imageView?.image == UIImage(systemName: "checkmark.square.fill"))
            if isCheckYes { isCheckResult = true }
            let isCheckNo = (noButton.imageView?.image == UIImage(systemName: "checkmark.square.fill"))
            if isCheckNo { isCheckResult = false }
            let solicitationContent   = stopContent1View.text ?? ""
            let purposeOfSolicitation = textView2.text ?? ""
            let unpleasantFeelings    = textView3.text ?? ""
            dialog(title: "本当に\(targetNickName)さんのアカウントの停止申請をしますか？", subTitle: "報告内容が虚偽だった場合、あなたのアカウントが停止されます。", confirmTitle: "申請する", completion: { [weak self] result in
                guard let weakSelf = self else { return }
                if result {
                    weakSelf.accountStop(loginUID: loginUID, targetUID: targetUID, status: isCheckResult, solicitationContent: solicitationContent, purposeOfSolicitation: purposeOfSolicitation, unpleasantFeelings: unpleasantFeelings)
                }
            })
        }
    }
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        toggleCheck(tapType: "yes")
    }
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        toggleCheck(tapType: "no")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        enableButtonIfFilled()
    }
    
    private func toggleCheck(tapType: String) {
        setToggleButtonImage(tapType: tapType)
        enableButtonIfFilled()
    }
    
    private func setToggleButtonImage(tapType: String) {
        let noCheckImg = UIImage(systemName: "square")
        let checkImg = UIImage(systemName: "checkmark.square.fill")
        
        if tapType == "yes" {
            yesButton.setImage(checkImg, for: .normal)
            noButton.setImage(noCheckImg, for: .normal)
        } else if tapType == "no" {
            yesButton.setImage(noCheckImg, for: .normal)
            noButton.setImage(checkImg, for: .normal)
        }
    }
    
    private func enableButtonIfFilled() {
        guard let stopContent1 = stopContent1View.text else { return }
        guard let stopContent2 = textView2.text else { return }
        guard let stopContent3 = textView3.text else { return }
        
        let checkImg = UIImage(systemName: "checkmark.square.fill")
        let checkYes = (yesButton.imageView?.image == checkImg)
        let checkNo = (noButton.imageView?.image == checkImg)
        let isCheckButtonTapped = (checkYes || checkNo)
        let notEmptyStopContent1 = (stopContent1.isEmpty == false)
        let notEmptyStopContent2 = (stopContent2.isEmpty == false)
        let notEmptyStopContent3 = (stopContent3.isEmpty == false)
        let allClear = (isCheckButtonTapped && notEmptyStopContent1 && notEmptyStopContent2 && notEmptyStopContent3)
        if allClear {
            submitButton.isUserInteractionEnabled = true
            submitButton.backgroundColor = .red
        } else {
            submitButton.isUserInteractionEnabled = false
            submitButton.backgroundColor = .lightGray
        }
    }
    
    // アカウント一発停止申請
    private func accountStop(loginUID: String, targetUID: String, status: Bool, solicitationContent: String, purposeOfSolicitation: String, unpleasantFeelings: String) {
        firebaseController.stop(loginUID: loginUID, targetUID: targetUID, status: status, solicitationContent: solicitationContent, purposeOfSolicitation: purposeOfSolicitation, unpleasantFeelings: unpleasantFeelings, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            if result {
                weakSelf.closure?(true)
                weakSelf.alertWithDismiss(title: "一発停止申請が完了しました👍", message: "このユーザを運営が即時確認いたしますので、今後も安心してご利用ください", actiontitle: "OK")
            } else {
                weakSelf.closure?(false)
                weakSelf.alertWithDismiss(title: "一発停止申請に失敗しました。。", message: "アプリを再起動して再度実行してください。", actiontitle: "OK")
            }
        })
    }
    
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}
