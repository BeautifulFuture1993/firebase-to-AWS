//
//  BusinessSolicitationCrackdownViewController.swift
//  Tauch
//
//  Created by adachitakehiro2 on 2023/04/17.
//

import UIKit

class BusinessSolicitationCrackdownViewController: UIViewController {
    
    static let storyboardName = "BusinessSolicitationCrackdownView"
    static let storyboardId = "BusinessSolicitationCrackdownViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationWithBackBtnSetUp(navigationTitle: "Touch")
        showNavigationBarBorder()
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
