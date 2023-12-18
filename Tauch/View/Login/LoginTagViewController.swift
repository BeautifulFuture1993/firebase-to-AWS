//
//  LoginTagViewController.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/02.
//

import UIKit
import TagListView
import FBSDKLoginKit
import SafariServices
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

class LoginTagViewController: UIBaseViewController {

    @IBOutlet weak var scrollContainerStackView: UIStackView!
    @IBOutlet weak var nextButton: UIButton!
    
    var parentVC: LoginPageViewController?
    var selectedTagList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //親VCの取得
        parentVC = self.parent as? LoginPageViewController
        //UI調整
        nextButton.layer.cornerRadius = 35
        nextButton.setShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // タブバーを消す
        tabBarController?.tabBar.isHidden = true
        
        selectedTagList = parentVC?.hobbies ?? [String]()
        // 趣味カードの初期化
        scrollContainerStackView.removeAllSubviews()
        
        let globalHobbies = GlobalVar.shared.globalHobbyCards
        let hobbyCategories = GlobalVar.shared.hobbyCategories
        hobbyCategories.forEach { hobbyCategory in
            let hobbies = globalHobbies.filter({ $0.category == hobbyCategory }).map({ $0.title })
            let hobbyTagListView = HobbyTagListView(category: hobbyCategory, tagList: hobbies, selectedTagList: selectedTagList)
            configureTagListView(hobbyTagListView: hobbyTagListView)
        }
        
        enableNextButton()
    }
    private func configureTagListView(hobbyTagListView: HobbyTagListView) {
        
        hobbyTagListView.hobbyTagList.delegate = self
        
        scrollContainerStackView.addArrangedSubview(hobbyTagListView)
        
        hobbyTagListView.translatesAutoresizingMaskIntoConstraints = false
        hobbyTagListView.leftAnchor.constraint(equalTo: scrollContainerStackView.leftAnchor).isActive = true
        hobbyTagListView.rightAnchor.constraint(equalTo: scrollContainerStackView.rightAnchor).isActive = true
    }
    //アカウント情報を登録
    @IBAction func startAction(_ sender: UIButton) {
        registData()
    }
    //前に戻る
    @IBAction func backAction(_ sender: UIButton) {
        guard let backPage = parentVC?.controllers[5] else { return }
        parentVC?.hobbies = selectedTagList
        parentVC?.setViewControllers([backPage], direction: .reverse, animated: true)
        parentVC?.progressBar.setProgress(6/7, animated: true)
    }
    //アカウント情報を登録
    private func registData() {
        //プロフィール情報を登録
        guard let uid = GlobalVar.shared.currentUID else { return }
        // デフォルトはAppleログインで定義する
        var phoneNumber = "apple"
        // firebaseで電話番号ログインする場合
        if let firebasePhoneNumber = Auth.auth().currentUser?.phoneNumber {
            phoneNumber = firebasePhoneNumber
        }
        // facebookでログインする場合は電話番号なし
        if let token = AccessToken.current, !token.isExpired {
            phoneNumber = "facebook"
        }
        let nickName = parentVC?.name ?? ""
        let birthDate = parentVC?.birth ?? ""
        let address = parentVC?.address ?? ""
        let address2 = parentVC?.address2 ?? ""
        let email = parentVC?.email ?? ""
        let introduction = parentVC?.introduction ?? ""
        // ローディング画面を表示させる
        showLoadingView(loadingView)
        //登録する情報
        let approached = [String]()
        let registData = [
            "uid": uid,
            "phone_number": phoneNumber,
            "nick_name": nickName,
            "birth_date": birthDate,
            "gender": 1,
            "address": address,
            "address2": address2,
            "email": email,
            "notification_email": email,
            "profile_status": introduction,
            "hobbies": selectedTagList,
            "approached": approached,
            "is_approached_notification": true,
            "is_matching_notification": true,
            "is_message_notification": true,
            "is_visitor_notification": true,
            "is_invitationed_notification": true,
            "is_dating_notification": true,
            "is_approached_mail": true,
            "is_matching_mail": true,
            "is_message_mail": true,
            "is_visitor_mail": true,
            "is_invitationed_mail": true,
            "is_dating_mail": true,
            "is_vibration_notification": true,
            "is_identification_approval": false,
            "is_deleted": false,
            "is_activated": true,
            "is_talkguide": true,
            "is_auto_message": true,
            "is_friend_emoji": true,
            "is_tutorial": true,
            "created_at": Timestamp(),
            "updated_at": Timestamp()
        ] as [String : Any]

        db.collection("users").document(uid).setData(registData, merge: true){ [weak self] err in
            guard let weakSelf = self else { return }
            weakSelf.loadingView.removeFromSuperview()
            if let err = err {
                weakSelf.alert(title: "プロフィール登録エラー", message: "正常にプロフィール登録されませんでした。\n不具合の報告からシステムエラーを報告してください", actiontitle: "OK")
                print("Error Log : \(err)")
                return
            }
            
            UserDefaults.standard.set(false, forKey: "isShowedApproachTutorial")
            UserDefaults.standard.set(false, forKey: "isShowedApproachedTutorial")
            UserDefaults.standard.set(false, forKey: "isShowedMessageTutorial")
            UserDefaults.standard.set(false, forKey: "isShowedInvitationTutorial")
            UserDefaults.standard.set(false, forKey: "isShowedBoardTutorial")
            UserDefaults.standard.set(false, forKey: "isShowedPhoneTutorial")
            
            let logEventData = [
                "phone_number": phoneNumber,
                "nick_name": nickName,
                "birth_date": birthDate,
                "address": address,
                "address2": address2,
                "email": email,
                "profile_status": introduction,
                "hobbies": weakSelf.selectedTagList,
            ] as [String : Any]
            Log.event(name: "profileCreate", logEventData: logEventData)
            
            weakSelf.authInstance(uid: uid, bootFlg: true)
        }
    }
}

extension LoginTagViewController: TagListViewDelegate {
    //タグ選択時
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        //タグ選択解除
        if tagView.textColor == .white {
            // 趣味カードの削除
            if let selectIndex = selectedTagList.firstIndex(of: title) {
                selectedTagList.remove(at: selectIndex)
            }
            // 趣味カードの選択解除
            tagView.textColor = .fontColor
            tagView.tagBackgroundColor = .lightColor
        //タグ選択
        } else {
            //20個以上選択させない
            guard selectedTagList.count < 20 else { return }
            // 趣味カードの追加
            selectedTagList.append(title)
            // 趣味カードの選択状態
            tagView.textColor = .white
            tagView.tagBackgroundColor = .accentColor
        }
        
        enableNextButton()
    }
    
    private func enableNextButton() {
        // 趣味カードが3個以上の時ボタン有効化
        if selectedTagList.count >= selectedHobbyMin {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = .accentColor
        } else {
            nextButton.isUserInteractionEnabled = false
            nextButton.backgroundColor = .lightGray
        }
    }
}
