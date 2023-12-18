//
//  NewFilterViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/04/01.
//

import UIKit

class NewFilterViewController: UIViewController {
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var ageContainerView: UIView!
    @IBOutlet weak var ageIcon: UIImageView!
    @IBOutlet weak var ageTitleLabel: UILabel!
    @IBOutlet weak var ageConditionLabel: UILabel!
    @IBOutlet weak var agePickerView: UIPickerView!
    @IBOutlet weak var areaContainerView: UIView!
    @IBOutlet weak var areaIcon: UIImageView!
    @IBOutlet weak var areaTitleLabel: UILabel!
    @IBOutlet weak var areaConditionLabel: UILabel!
    @IBOutlet weak var areaPickerView: UIPickerView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    static let storyboardName = "NewFilterView"
    static let storyboardId = "NewFilterView"
    
    private let ageArray: [Int] = [Int](18...100)
    private var minAge: Int?
    private var maxAge: Int?
    private var pickedArea: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        agePickerView.delegate = self
        agePickerView.dataSource = self
        areaPickerView.delegate = self
        areaPickerView.dataSource = self
        
        configureAppearance()
    }

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        
    }
    
}

extension NewFilterViewController {
    private func configureAppearance() {
        resetButton.configuration?.cornerStyle = .capsule
        acceptButton.configuration?.cornerStyle = .capsule
        ageConditionLabel.text = ""
        areaConditionLabel.text = ""
        
        agePickerView.selectRow(1, inComponent: 0, animated: true)
        agePickerView.selectRow(2, inComponent: 1, animated: true)
        areaPickerView.selectRow(1, inComponent: 0, animated: true)
    }
}

extension NewFilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == agePickerView { return 2 }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == agePickerView {
            return ageArray.count
        }
        // areaPickerView
        return GlobalVar.shared.areas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == agePickerView {
            return String(ageArray[row])
        }
        if pickerView == areaPickerView {
            return GlobalVar.shared.areas[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == agePickerView {
            minAge = ageArray[pickerView.selectedRow(inComponent: 0)]
            maxAge = ageArray[pickerView.selectedRow(inComponent: 1)]
            if let minAge = minAge, let maxAge = maxAge {
                ageConditionLabel.text = "\(minAge)〜\(maxAge) 歳"
            }
        }
        if pickerView == areaPickerView {
            pickedArea = GlobalVar.shared.areas[pickerView.selectedRow(inComponent: 0)]
            if let pickedArea = pickedArea {
                areaConditionLabel.text = pickedArea
            }
        }
    }
    
}
