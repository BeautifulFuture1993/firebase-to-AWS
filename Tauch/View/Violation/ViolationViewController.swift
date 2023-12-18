//
//  ViolationViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/20.
//

import UIKit

class ViolationViewController: UIBaseViewController {

    @IBOutlet weak var violationTitle: UILabel!
    @IBOutlet weak var violationContent: UITextView!
    @IBOutlet weak var violationBtn: UIButton!
    
    var targetUser: User?
    
    var category: String = ""
    var violationedID: String = ""
    
    var closure: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // デリゲート設定
        violationContent.delegate = self
        // ボタンの加工
        violationBtn.layer.cornerRadius = 35
        violationContent.layer.cornerRadius = 10
        violationContent.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        violationBtn.setShadow()
        // ニックネームを設定
        let nickName = targetUser?.nick_name ?? "ノーネーム"
        violationTitle.text = nickName + "さんを通報"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    // モーダルを閉じる
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // 違反報告
    @IBAction func violation(_ sender: Any) {
        
        let violationContent = violationContent.text ?? ""
        
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        guard let targetUID = targetUser?.uid else { return }
        
        showLoadingView(loadingView)
        
        firebaseController.violation(loginUID: loginUID, targetUID: targetUID, content: violationContent, category: category, violationedID: violationedID, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            
            weakSelf.loadingView.removeFromSuperview()
            
            if result {
                
                GlobalVar.shared.cardViolationUser = weakSelf.targetUser
                
                weakSelf.violationContent.text = ""
                weakSelf.violationBtn.disable()
                
                weakSelf.closure?(true)
                weakSelf.alertWithDismiss(title: "通報が完了しました👍", message: "通報しました!\nこのユーザを運営が即時確認いたしますので、今後も安心してご利用ください", actiontitle: "OK")
            } else {
                weakSelf.closure?(false)
                weakSelf.alertWithDismiss(title: "違反報告に失敗しました。。", message: "すでに違反報告をされている可能性があります。\n運営にお問い合わせください。", actiontitle: "OK")
            }
        })
    }
    //文章が入力されていたらにボタン有効化
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        if text.isEmpty == false {
            violationBtn.enable()
        } else {
            violationBtn.disable()
        }
    }
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}
