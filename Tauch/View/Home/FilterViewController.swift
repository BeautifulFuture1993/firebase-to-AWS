//
//  FilterViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/28.
//

import UIKit
import TagListView

class FilterViewController: UIBaseViewController, TagListViewDelegate {

    @IBOutlet weak var birthView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var ageResetButton: UIButton!
    @IBOutlet weak var minAgePicker: UIPickerView!
    @IBOutlet weak var maxAgePicker: UIPickerView!
    @IBOutlet weak var addressResetButton: UIButton!
    @IBOutlet weak var addressListView: TagListView!
    @IBOutlet weak var hobbyView: UIView!
    @IBOutlet weak var hobbyLabel: UILabel!
    @IBOutlet weak var hobbyResetButton: UIButton!
    @IBOutlet weak var purposeTagTitle: UILabel!
    @IBOutlet weak var purposeTagList: TagListView!
    @IBOutlet weak var favoriteThingsTagTitle: UILabel!
    @IBOutlet weak var favoriteThingsTagList: TagListView!
    @IBOutlet weak var hobbyTagTitle: UILabel!
    @IBOutlet weak var hobbyTagList: TagListView!
    @IBOutlet weak var humanityAndValuesTagTitle: UILabel!
    @IBOutlet weak var humanityAndValuesTagList: TagListView!
    @IBOutlet weak var professionTagTitle: UILabel!
    @IBOutlet weak var professionTagList: TagListView!
    @IBOutlet weak var foodTagTitle: UILabel!
    @IBOutlet weak var foodTagList: TagListView!
    @IBOutlet weak var musicTagTitle: UILabel!
    @IBOutlet weak var musicTagList: TagListView!
    @IBOutlet weak var sportsTagTitle: UILabel!
    @IBOutlet weak var sportsTagList: TagListView!
    
    var selectedTagList: [String] = []
    let areas = GlobalVar.shared.areas
    let ageArray = ([Int])(12...120)
    var selectedHobbyTagList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバーをカスタマイズ
        navigationWithBackBtnSetUp(navigationTitle: "絞り込み条件")
        // UI調整
        birthView.layer.cornerRadius = 20
        addressView.layer.cornerRadius = 20
        hobbyView.layer.cornerRadius = 20
        filterButton.layer.cornerRadius = 35
        filterButton.setShadow()
        // 年齢設定
        minAgePicker.delegate = self
        maxAgePicker.delegate = self
        minAgePicker.dataSource = self
        maxAgePicker.dataSource = self
        minAgePicker.selectRow(0 , inComponent: 0, animated: true)
        maxAgePicker.selectRow(ageArray.count - 1 , inComponent: 0, animated: true)
        // よく行く/遊ぶ場所設定
        addressListView.delegate = self
        addressListView.textFont = .systemFont(ofSize: 20)
        // 趣味設定
        purposeTagList.delegate = self
        purposeTagList.textFont = .systemFont(ofSize: 20)
        favoriteThingsTagList.delegate = self
        favoriteThingsTagList.textFont = .systemFont(ofSize: 20)
        hobbyTagList.delegate = self
        hobbyTagList.textFont = .systemFont(ofSize: 20)
        humanityAndValuesTagList.delegate = self
        humanityAndValuesTagList.textFont = .systemFont(ofSize: 20)
        professionTagList.delegate = self
        professionTagList.textFont = .systemFont(ofSize: 20)
        foodTagList.delegate = self
        foodTagList.textFont = .systemFont(ofSize: 20)
        musicTagList.delegate = self
        musicTagList.textFont = .systemFont(ofSize: 20)
        sportsTagList.delegate = self
        sportsTagList.textFont = .systemFont(ofSize: 20)
        
        filterButton.disable()
    }
    // 既存の設定を反映
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //UI調整
        hideNavigationBarBorderAndShowTabBarBorder()
        
        let minAgeFilter = GlobalVar.shared.loginUser?.min_age_filter ?? 12
        let maxAgeFilter = GlobalVar.shared.loginUser?.max_age_filter ?? 120
        minAgePicker.selectRow(minAgeFilter - 12, inComponent: 0, animated: true)
        maxAgePicker.selectRow(maxAgeFilter - 12, inComponent: 0, animated: true)
        setAgeLabel()
        
        let addressFilter = GlobalVar.shared.loginUser?.address_filter ?? [String]()
        selectedTagList = addressFilter
        setTagList(tagListView: addressListView, tagList: areas, type: "address")
        setAddressLabel()
        
        let hobbyFilter = GlobalVar.shared.loginUser?.hobby_filter ?? [String]()
        selectedHobbyTagList = hobbyFilter
        setHobbyTagList()
        setHobbyLabel()
    }
    // 画面表示終了時の処理
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingView.removeFromSuperview()
    }
    // 画面破棄時の処理 (遷移元に破棄後の処理をさせるために再定義)
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    private func setHobbyTagList() {
        let globalHobbies = GlobalVar.shared.globalHobbyCards
        let hobbyCategories = Set(globalHobbies.map({ $0.category }))
        hobbyCategories.forEach { hobbyCategory in
            let hobbies = globalHobbies.filter({ $0.category == hobbyCategory }).map({ $0.title })
            switch hobbyCategory {
            case "目的":
                purposeTagTitle.text = hobbyCategory
                setTagList(tagListView: purposeTagList, tagList: hobbies, type: "hobby")
                break
            case "好きなもの":
                favoriteThingsTagTitle.text = hobbyCategory
                setTagList(tagListView: favoriteThingsTagList, tagList: hobbies, type: "hobby")
                break
            case "趣味":
                hobbyTagTitle.text = hobbyCategory
                setTagList(tagListView: hobbyTagList, tagList: hobbies, type: "hobby")
                break
            case "人間性・価値観":
                humanityAndValuesTagTitle.text = hobbyCategory
                setTagList(tagListView: humanityAndValuesTagList, tagList: hobbies, type: "hobby")
                break
            case "職業":
                professionTagTitle.text = hobbyCategory
                setTagList(tagListView: professionTagList, tagList: hobbies, type: "hobby")
                break
            case "食事":
                foodTagTitle.text = hobbyCategory
                setTagList(tagListView: foodTagList, tagList: hobbies, type: "hobby")
                break
            case "音楽":
                musicTagTitle.text = hobbyCategory
                setTagList(tagListView: musicTagList, tagList: hobbies, type: "hobby")
                break
            case "スポーツ":
                sportsTagTitle.text = hobbyCategory
                setTagList(tagListView: sportsTagList, tagList: hobbies, type: "hobby")
                break
            default:
                break
            }
        }
    }
    // タグリスト設定
    private func setTagList(tagListView: TagListView, tagList: [String], type: String) {
        tagListView.removeAllTags()
        let tagViews = tagListView.addTags(tagList)
        tagViews.forEach { tagView in
            if let currentValue = tagView.currentTitle {
                if type == "address" {
                    if selectedTagList.firstIndex(of: currentValue) != nil {
                        tagView.textColor = .white
                        tagView.tagBackgroundColor = .accentColor
                    }
                } else if type == "hobby" {
                    if selectedHobbyTagList.firstIndex(of: currentValue) != nil {
                        tagView.textColor = .white
                        tagView.tagBackgroundColor = .accentColor
                    }
                }
            }
        }
    }
    // タグ選択時
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        if let _ = areas.firstIndex(of: title) { // よく行く/遊ぶ場所
            // タグ選択解除
            if tagView.textColor == .white {
                if let selectIndex = selectedTagList.firstIndex(of: title) {
                    selectedTagList.remove(at: selectIndex)
                }
                tagView.textColor = .fontColor
                tagView.tagBackgroundColor = .lightColor
            // タグ選択
            } else {
                selectedTagList.append(title)
                tagView.textColor = .white
                tagView.tagBackgroundColor = .accentColor
            }
            setAddressLabel()
            
        } else { // 趣味
            // タグ選択解除
            if tagView.textColor == .white {
                if let selectIndex = selectedHobbyTagList.firstIndex(of: title) {
                    selectedHobbyTagList.remove(at: selectIndex)
                }
                tagView.textColor = .fontColor
                tagView.tagBackgroundColor = .lightColor
            // タグ選択
            } else {
                selectedHobbyTagList.append(title)
                tagView.textColor = .white
                tagView.tagBackgroundColor = .accentColor
            }
            setHobbyLabel()
        }
    }
    // 年齢をクリア
    @IBAction func ageResetAction(_ sender: UIButton) {
        minAgePicker.selectRow(0 , inComponent: 0, animated: true)
        maxAgePicker.selectRow(ageArray.count - 1 , inComponent: 0, animated: true)
        ageLabel.text = "全て"
        sender.isHidden = true
        enableButtonIfFilled()
    }
    // 居住地をクリア
    @IBAction func addressResetAction(_ sender: UIButton) {
        addressListView.tagViews.forEach{
            $0.isSelected = false
            $0.textColor = .fontColor
            $0.tagBackgroundColor = .lightColor
        }
        selectedTagList = []
        addressLabel.text = "全て"
        sender.isHidden = true
        enableButtonIfFilled()
    }
    // 趣味をクリア
    @IBAction func hobbyResetAction(_ sender: UIButton) {
        
        let tagListViews = [
            purposeTagList, favoriteThingsTagList, hobbyTagList,
            humanityAndValuesTagList, professionTagList, foodTagList,
            musicTagList, sportsTagList
        ] as [TagListView]
        
        tagListViews.forEach { tagListView in
            tagListView.tagViews.forEach { tagView in
                tagView.isSelected = false
                tagView.textColor = .fontColor
                tagView.tagBackgroundColor = .lightColor
            }
        }
        
        selectedHobbyTagList = []
        hobbyLabel.text = "全て"
        sender.isHidden = true
        enableButtonIfFilled()
    }
    // 条件を適用する
    @IBAction func filterAction(_ sender: UIButton) {
        
        let selectMinAge = ageArray[minAgePicker.selectedRow(inComponent: 0)]
        let selectMaxAge = ageArray[maxAgePicker.selectedRow(inComponent: 0)]
        
        GlobalVar.shared.loginUser?.min_age_filter = selectMinAge
        GlobalVar.shared.loginUser?.max_age_filter = selectMaxAge
        GlobalVar.shared.loginUser?.address_filter = selectedTagList
        GlobalVar.shared.loginUser?.hobby_filter = selectedHobbyTagList
        
        GlobalVar.shared.cardRecommendFilterFlg = true
        
        Log.event(name: "filterApproachCardList")
        
        dismiss(animated: true, completion: nil)
    }
    // 年齢の選択状況を右上のLabelに反映
    private func setAgeLabel() {
        let selectMinAge = ageArray[minAgePicker.selectedRow(inComponent: 0)]
        let selectMaxAge = ageArray[maxAgePicker.selectedRow(inComponent: 0)]
        //　minがmaxより大きい時はminに合わせる
        if selectMinAge > selectMaxAge {
            maxAgePicker.selectRow(minAgePicker.selectedRow(inComponent: 0), inComponent: 0, animated: true)
        }
        ageLabel.text = "\(selectMinAge)歳〜\(selectMaxAge)歳"
        if ageLabel.text == "12歳〜120歳" {
            ageLabel.text = "全て"
            ageResetButton.isHidden = true
        } else {
            ageResetButton.isHidden = false
        }
        enableButtonIfFilled()
    }
    // 居住地の選択状況を右上のLabelに反映
    private func setAddressLabel() {
        addressLabel.text = ""
        var address = ""
        selectedTagList.forEach{
           address += $0 + " "
        }
        if selectedTagList == [] {
            addressLabel.text = "全て"
            addressResetButton.isHidden = true
        } else {
            addressLabel.text = address
            addressResetButton.isHidden = false
        }
        enableButtonIfFilled()
    }
    // 趣味の選択状況を右上のLabelに反映
    private func setHobbyLabel() {
        hobbyLabel.text = ""
        var hobby = ""
        selectedHobbyTagList.forEach{
           hobby += $0 + " "
        }
        if selectedHobbyTagList == [] {
            hobbyLabel.text = "全て"
            hobbyResetButton.isHidden = true
        } else {
            hobbyLabel.text = hobby
            hobbyResetButton.isHidden = false
        }
        enableButtonIfFilled()
    }
    //入力内容が有効ならボタンを有効化する
    private func enableButtonIfFilled() {
        // 年齢幅・タグ 前回と変更点が存在すればフィルター適用ボタンをアクティブ
        let minAgeFilter = GlobalVar.shared.loginUser?.min_age_filter ?? 12
        let maxAgeFilter = GlobalVar.shared.loginUser?.max_age_filter ?? 120
        
        let selectMinAgeFilter = ageArray[minAgePicker.selectedRow(inComponent: 0)]
        let selectMaxAgeFilter = ageArray[maxAgePicker.selectedRow(inComponent: 0)]
        
        let addressFilter = GlobalVar.shared.loginUser?.address_filter ?? [String]()
        let hobbyFilter = GlobalVar.shared.loginUser?.hobby_filter ?? [String]()
        
        let isNotSameMinAgeFilter = (minAgeFilter != selectMinAgeFilter)
        let isNotSameMaxAgeFilter = (maxAgeFilter != selectMaxAgeFilter)
        let isNotSameAddressTag = (addressFilter != selectedTagList)
        let isNotSameHobbyTag = (hobbyFilter != selectedHobbyTagList)
        let enableFilterBtn = (
            isNotSameMinAgeFilter || isNotSameMaxAgeFilter ||
            isNotSameAddressTag || isNotSameHobbyTag
        )
        if enableFilterBtn {
            filterButton.enable()
        } else {
            filterButton.disable()
        }
    }
}
// 年齢Picker
extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // 列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 行の数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageArray.count
    }
    // Pickerの選択項目
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let age = ageArray[safe: row] {
            return String(age) + "歳"
        }
        return nil
    }
    // Picker変更時に選択状況を右上のLabelに反映
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setAgeLabel()
    }
}
