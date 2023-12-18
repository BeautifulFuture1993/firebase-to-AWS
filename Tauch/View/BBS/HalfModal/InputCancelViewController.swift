//
//  InputCancelViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/12.
//

import UIKit

class InputCancelViewController: UIBaseViewController {
    
    static let storyboard_name_id = "InputCancelViewController"
    
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var saveDraftButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var closure: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func disCardButtonPressed(_ sender: UIButton) {
        closure?(true)
        dismiss(animated: true)
    }
    
    @IBAction func saveDraftButtonPressed(_ sender: UIButton) {
        print("saveDraftButtonPressed")
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        closure?(false)
        dismiss(animated: true)
    }
    
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}
