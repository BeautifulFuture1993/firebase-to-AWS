//
//  UsageTableViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/09/15.
//

import UIKit

class UsageTableViewController: UIBaseTableViewController {
    
    @IBOutlet var iconBackground: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconBackground.forEach { $0.layer.cornerRadius = 10 }        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

         navigationWithBackBtnSetUp(navigationTitle: "チュートリアル", color: .systemGray6)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let windowFirst = Window.first else { return }
        switch indexPath.row {
        case 0:
            let type = "approachMatch"
            let tutorialView = TutorialView(frame: windowFirst.frame, type: type)
            windowFirst.addSubview(tutorialView)
            tutorialLogEvent(type: type)
        case 1:
            let type = "message"
            let tutorialView = TutorialView(frame: windowFirst.frame, type: type)
            windowFirst.addSubview(tutorialView)
            tutorialLogEvent(type: type)
        case 2:
            let type = "invitation"
            let tutorialView = TutorialView(frame: windowFirst.frame, type: type)
            windowFirst.addSubview(tutorialView)
            tutorialLogEvent(type: type)
        case 3:
            let type = "phone"
            let tutorialView = TutorialView(frame: windowFirst.frame, type: type)
            windowFirst.addSubview(tutorialView)
            tutorialLogEvent(type: type)
        default: return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
