//
//  AutoMessageViewController.swift
//  Tauch
//
//  Created by Apple on 2023/05/19.
//

import UIKit

class AutoMessageViewController: UIViewController {

    static let storyboardName = "AutoMessageView"
    static let storyboardId = "AutoMessageViewController"

    @IBOutlet weak var autoMessageStopBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoMessageStopBtn.layer.cornerRadius = autoMessageStopBtn.frame.height / 2
        autoMessageStopBtn.layer.borderColor = UIColor().setColor(colorType: "fontColor", alpha: 1.0).cgColor
        autoMessageStopBtn.layer.borderWidth = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationWithModalBackBtnSetUp(navigationTitle: "自動メッセージ送信")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func autoMessageSettingButtonTap(_ sender: Any) { settingAction() }

    @objc private func settingAction() {
        //トークガイド画面に遷移
        let storyboard = UIStoryboard.init(name: "AutoMessageSettingView", bundle: nil)
        let settingVC = storyboard.instantiateViewController(withIdentifier: "AutoMessageSettingView") as! AutoMessageSettingViewController
        present(settingVC, animated: true, completion: nil)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}
