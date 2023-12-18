//
//  ViewController.swift
//  ExplanationLikeCard
//
//  Created by adachitakehiro2 on 2023/03/19.
//

import UIKit

class ExplanationLikeCardViewController: UIBaseViewController {
    
    @IBOutlet weak var searchLikeCardBtn: UIButton!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var registerStep6Img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRegisterImg()
        searchLikeCardBtn.rounded()
        searchLikeCardBtn.setShadow()
        explanationLabelCustom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    //「自分の好きなものを...」のフォントカラー設定
    func explanationLabelCustom() {
        
        guard let explanationText = explanationLabel.text else { return }
        
        let attrText1 = NSMutableAttributedString(string: explanationText)
        guard let defaultColor = UIColor(named: "defaultColor") else { return }
        attrText1.addAttributes([
            .foregroundColor: defaultColor,
            .font: UIFont.systemFont(ofSize: 14)
        ], range: NSMakeRange(0, 8))

        explanationLabel.attributedText = attrText1
    }
    
    func setRegisterImg() {
        registerStep6Img.layer.cornerRadius = 6.0
        registerStep6Img.layer.borderWidth = 4.0
        guard let borderColor = UIColor(named: "BorderColor") else { return }
        registerStep6Img.layer.borderColor = borderColor.cgColor
    }
    
    @IBAction func pageBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


