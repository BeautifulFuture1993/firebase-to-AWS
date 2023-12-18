//
//  TalkGuideDisplayRankingViewController.swift
//  Tauch
//
//  Created by Apple on 2023/05/06.
//

import UIKit

class TalkGuideDisplayRankingViewController: UIBaseViewController {

    @IBOutlet weak var displayAdviceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayAdviceLabelCustom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        talkGuideUpdate()
    }
    
    @IBAction func close(_ sender: Any) {
        
        setClass(className: "MessageListViewController")
        
        dismiss(animated: true)
    }
    
    private func displayAdviceLabelCustom() {
        
        guard let displayAdviceLabelText = displayAdviceLabel.text else { return }
        
        let attrDisplayAdviceLabelText = NSMutableAttributedString(string: displayAdviceLabelText)

        attrDisplayAdviceLabelText.addAttributes([
            .foregroundColor: UIColor(named: "defaultColor"),
            .font: UIFont.boldSystemFont(ofSize: 14)
        ], range: NSMakeRange(45, 17))

        displayAdviceLabel.attributedText = attrDisplayAdviceLabelText
    }
    
    private func talkGuideUpdate() {
        
        guard let loginUID = GlobalVar.shared.loginUser?.uid else { return }
        
        GlobalVar.shared.loginUser?.is_display_ranking_talkguide = false
        
        let updateData = ["is_display_ranking_talkguide": false]
        db.collection("users").document(loginUID).updateData(updateData)
    }
}
