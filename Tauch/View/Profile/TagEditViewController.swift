//
//  TagEditViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/09.
//

import UIKit
import FirebaseFirestore
import TagListView

class TagEditViewController: UIBaseViewController {

    @IBOutlet weak var scrollContainerStackView: UIStackView!
    @IBOutlet weak var changeButton: UIButton!
    
    var profileVC: ProfileViewController?
    var selectedTagList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバーの設定
        navigationWithBackBtnSetUp(navigationTitle: "タグを編集")
        // UI調整
        changeButton.layer.cornerRadius = 35
        changeButton.setShadow()
    }
    // 趣味カードの設定
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedTagList = GlobalVar.shared.loginUser?.hobbies ?? [String]()
        // 趣味カードの初期化
        scrollContainerStackView.removeAllSubviews()
        
        let globalHobbies = GlobalVar.shared.globalHobbyCards
        let hobbyCategories = GlobalVar.shared.hobbyCategories
        hobbyCategories.forEach { hobbyCategory in
            let hobbies = globalHobbies.filter({ $0.category == hobbyCategory }).map({ $0.title })
            let hobbyTagListView = HobbyTagListView(category: hobbyCategory, tagList: hobbies, selectedTagList: selectedTagList)
            configureTagListView(hobbyTagListView: hobbyTagListView)
        }
    }
    private func configureTagListView(hobbyTagListView: HobbyTagListView) {
        
        hobbyTagListView.hobbyTagList.delegate = self
        
        scrollContainerStackView.addArrangedSubview(hobbyTagListView)
        
        hobbyTagListView.translatesAutoresizingMaskIntoConstraints = false
        hobbyTagListView.leftAnchor.constraint(equalTo: scrollContainerStackView.leftAnchor).isActive = true
        hobbyTagListView.rightAnchor.constraint(equalTo: scrollContainerStackView.rightAnchor).isActive = true
    }
    //タグの更新
    @IBAction func changeAction(_ sender: UIButton) {
        guard let uid = GlobalVar.shared.loginUser?.uid else { return }
        // ローディング画面を表示させる
        showLoadingView(loadingView)
        
        let updatedAt = Timestamp()
        db.collection("users").document(uid).updateData(["hobbies": selectedTagList, "updated_at": updatedAt]) { [weak self] err in
            guard let weakSelf = self else { return }
            if let err = err {
                // ローディング画面を外す
                weakSelf.loadingView.removeFromSuperview()
                weakSelf.alert(title: "プロフィール登録エラー", message: "正常にプロフィール登録されませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
                print("Error Log : \(err)")
                return
            }
            let logEventData = [
                "hobbies": weakSelf.selectedTagList
            ] as [String : Any]
            Log.event(name: "changeProfileHobbies", logEventData: logEventData)
            
            GlobalVar.shared.loginUser?.hobbies = weakSelf.selectedTagList
            weakSelf.profileVC?.setTags(selectedTags: weakSelf.selectedTagList)
            weakSelf.loadingView.removeFromSuperview()
            weakSelf.navigationController?.popViewController(animated: true)
       }
    }
}

extension TagEditViewController: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        //タグ選択解除
        if tagView.textColor == .white {
            // 趣味タグの削除
            if let selectIndex = selectedTagList.firstIndex(of: title) {
                selectedTagList.remove(at: selectIndex)
            }
            // 趣味タグの選択解除
            tagView.textColor = .fontColor
            tagView.tagBackgroundColor = .lightColor
        //タグ選択
        } else {
            //20個以上選択させない
            guard selectedTagList.count < 20 else { return }
            // 趣味タグの追加
            selectedTagList.append(title)
            // 趣味タグの選択状態
            tagView.textColor = .white
            tagView.tagBackgroundColor = .accentColor
        }
        // 趣味タグが3個以上の時ボタン有効化
        if selectedTagList.count >= selectedHobbyMin {
            changeButton.enable()
        } else {
            changeButton.disable()
        }
    }
}
