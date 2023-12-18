//
//  SelectCategoryViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/04/01.
//

import UIKit

class SelectCategoryViewController: UIBaseViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectCategoryPickerView: UIPickerView!
    
    static let storyboardName = "SelectCategoryView"
    static let storyboardId = "SelectCategoryView"
    
    private var categoryList = GlobalVar.shared.hobbyCardCategory
    private var selectedCategory: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryList.insert("---", at: 0)
        selectCategoryPickerView.delegate = self
        selectCategoryPickerView.dataSource = self
        // UIPickerView - 初期値のセット
        selectCategoryPickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ownSpecificHobbyCard = GlobalVar.shared.ownSpecificHobbyCard
        if let specificHobbyCard = ownSpecificHobbyCard["SelectedHobbyCardCategory"] as? String {
            selectedCategory = specificHobbyCard
            
            if let categoryIndex = categoryList.firstIndex(of: specificHobbyCard) {
                selectCategoryPickerView.selectRow(categoryIndex, inComponent: 0, animated: false)
            }
        }
    }
    
    // 遷移元に破棄時の処理をさせる
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // 遷移元の破棄時の処理が先に行われるので、値を渡し終えるのを待ってから破棄する
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        // 何も選択していない場合はreturn
        if selectedCategory.isEmpty || selectedCategory == "---" { return }
        // 値を渡し終わるまで待つ
        GlobalVar.shared.ownSpecificHobbyCard["SelectedHobbyCardCategory"] = selectedCategory
        while GlobalVar.shared.ownSpecificHobbyCard["SelectedHobbyCardCategory"] as? String? == "" || GlobalVar.shared.ownSpecificHobbyCard["SelectedHobbyCardCategory"] == nil {
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension SelectCategoryViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categoryList[row]
    }
}

