//
//  RestViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/09/27.
//

import UIKit

class RestViewController: UIBaseViewController {
    
    @IBOutlet weak var restView: UIView!
    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var restButton: UIButton!
    @IBOutlet weak var withdrawalButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.backgroundColor = .white
        tabBarController?.tabBar.backgroundColor = .white
        navigationWithBackBtnSetUp(navigationTitle: "退会するその前に...")
        restView.layer.cornerRadius = 20
        hiddenView.rounded()
        restButton.rounded()
        restButton.setShadow()
        withdrawalButton.rounded()
        withdrawalButton.setShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func didTapRestButton(_ sender: UIButton) {
        guard let userID = GlobalVar.shared.loginUser?.uid else { return }
        let alert = UIAlertController(title: "休憩モードが有効になりました", message: "\nあなたのアカウントが非表示になりました。\n\n休憩モードは設定から解除できます。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let weakSelf = self else { return }
            GlobalVar.shared.loginUser?.is_rested = true
            weakSelf.db.collection("users").document(userID).updateData(["is_rested": true])
            if let viewControllers = weakSelf.navigationController?.viewControllers {
                weakSelf.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            }
            Log.event(name: "restModeValid")
        })
        present(alert, animated: true)
    }
    
    @IBAction func didTapwithdrawalButton(_ sender: UIButton) {
        let storyBoard = UIStoryboard.init(name: "WithdrawalView", bundle: nil)
        let modalVC = storyBoard.instantiateViewController(withIdentifier: "WithdrawalView") as! WithdrawalViewController
        modalVC.user = GlobalVar.shared.loginUser
        modalVC.transitioningDelegate = self
        modalVC.presentationController?.delegate = self
        modalVC.closure = { [weak self] (flag: Bool) -> Void in
            guard let weakSelf = self else { return }
            if flag { weakSelf.loginScreenTransition() }
        }
        present(modalVC, animated: true)
    }
}
