//
//  VisitorPopupViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/08.
//

import UIKit

class VisitorPopupViewController: UIViewController {
    
    static let storyboardName = "VisitorPopupView"
    static let storyboardID = "VisitorPopupView"

    @IBOutlet weak var popupImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        closeButton.tintColor = .white
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
