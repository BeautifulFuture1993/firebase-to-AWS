//
//  ViewController.swift
//  LikeCardProfileSample
//
//  Created by adachitakehiro2 on 2023/03/17.
//

import UIKit
import TagListView

class LikeCardProfileSampleViewController: UIBaseViewController, TagListViewDelegate {
    
    @IBOutlet weak var bgcolorView: UIView!
    @IBOutlet weak var userPhotoCollectionView: UICollectionView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var photoComment: UILabel!
    @IBOutlet weak var commonTagList: TagListView!
    @IBOutlet weak var regedLikeCardCollectionView: UICollectionView!
    @IBOutlet weak var selfIntroText: UILabel!
    @IBOutlet weak var userInfoTableView: UITableView!
    @IBOutlet weak var triangleImage: UIImageView!
    @IBOutlet weak var goodButton: UIButton!
    
    var isGood: Bool = false
    var user: User?
    
    //ユーザーの写真のサンプル配列
    var userPhotoDatas = [
        userPhotoInfo(userphoto: "01", photocomment: "こんにちは！", isSelected: true),
        userPhotoInfo(userphoto: "01", photocomment: "", isSelected: false),
        userPhotoInfo(userphoto: "hasebe_makoto", photocomment: "", isSelected: false),
        userPhotoInfo(userphoto: "01", photocomment: "こんにちは", isSelected: false),
        userPhotoInfo(userphoto: "01", photocomment: "こんにちは", isSelected: false),
        userPhotoInfo(userphoto: "01", photocomment: "こんにちは", isSelected: false),
        userPhotoInfo(userphoto: "01", photocomment: "こんにちは", isSelected: false),
        userPhotoInfo(userphoto: "hasebe_makoto", photocomment: "", isSelected: false),
        userPhotoInfo(userphoto: "hasebe_makoto", photocomment: "こんばんは", isSelected: false),
        userPhotoInfo(userphoto: "hasebe_makoto", photocomment: "ああああ", isSelected: false),
        userPhotoInfo(userphoto: "hasebe_makoto", photocomment: "ううううう", isSelected: false),
        userPhotoInfo(userphoto: "hasebe_makoto", photocomment: "おおおおお", isSelected: false),
    ]
    //趣味カードのサンプル配列
    var commonTags = ["友達作り","アニメ","海外ドラマ","ゲーム","イヌ好き","戦場主婦","焼肉","プロ野球"]
    //登録している趣味カードのサンプル配列
    var registeredLikeCardList = [
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き"),
        ProfileLikeCardData(icon: "hasebe_makoto", title: "サッカーが好き")
    ]
    //ユーザーの基本情報情報のサンプル配列
    var userInfo = [
        BasicInfo(item: "年齢", userInfo: "23"),
        BasicInfo(item: "年齢", userInfo: "23"),
        BasicInfo(item: "年齢", userInfo: "23"),
        BasicInfo(item: "年齢", userInfo: "23"),
        BasicInfo(item: "年齢", userInfo: "23"),
//        BasicInfo(item: "年齢", userInfo: "23"),
//        BasicInfo(item: "年齢", userInfo: "23"),
//        BasicInfo(item: "年齢", userInfo: "23"),
//        BasicInfo(item: "年齢", userInfo: "23"),
//        BasicInfo(item: "年齢", userInfo: "23"),
//        BasicInfo(item: "年齢", userInfo: "23"),
//        BasicInfo(item: "年齢", userInfo: "23"),
//        BasicInfo(item: "年齢", userInfo: "23"),
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setGradient()
        setPhoto()
        setSelfIntroduceStatement()
        
        userPhotoCollectionView.delegate = self
        userPhotoCollectionView.dataSource = self
        
        regedLikeCardCollectionView.delegate = self
        regedLikeCardCollectionView.dataSource = self
        
        userInfoTableView.dataSource = self
        userInfoTableView.delegate = self
        
        //タグリスト生成、エラーが出るのでコメントアウト中
//        setTagList(tagListView: commonTagList, tagList: commonTags)
    }

    func setGradient() {
        //グラデーションをつける
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bgcolorView.bounds
        //グラデーションさせるカラーの設定 (徐々に色を濃くしていく)
        let color1 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1).cgColor
        let color2 = UIColor(red: 255/255, green: 153/255, blue: 12/255, alpha: 0.47).cgColor
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1, color2]
        //グラデーションの開始地点・終了地点の設定
        gradientLayer.startPoint = CGPoint.init(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0.5 , y:1)
        //ViewControllerのViewレイヤーにグラデーションレイヤーを挿入する
        bgcolorView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setPhoto() {
        
        userImg.image = UIImage(named: userPhotoDatas[0].userphoto)
        if userPhotoDatas[0].photocomment.isEmpty {
            photoComment.isHidden = true
        } else {
            photoComment.text = userPhotoDatas[0].photocomment
        }
    }
    
    func setSelfIntroduceStatement() {
        selfIntroText.text = "こんにちは！プロフィールをご覧いただきありがとうございます。東京に住んでいる美子と言います。"
        selfIntroText.sizeToFit()
    }
    
    @IBAction func goodButtonTapped(_ sender: Any) {
        if isGood == false {
            goodButton.setTitle("いいね！済み", for: .normal)
            goodButton.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        }
    }
    //    // タグリスト設定、エラーが出るためコメントアウト中
//    private func setTagList(tagListView: TagListView, tagList: [String]) {
//        tagListView.removeAllTags()
//        let tagViews = tagListView.addTags(tagList)
//        tagViews.forEach { tagView in
//            if let currentValue = tagView.currentTitle {
//                if commonTags.firstIndex(of: currentValue) != nil {
//                    tagView.textColor = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0)
//                    tagView.tagBackgroundColor = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 0.45) //accentcolor
//                }
//            }
//        }
//    }
}

extension LikeCardProfileSampleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    //写真と趣味カードのセル数定義
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == userPhotoCollectionView {
            return userPhotoDatas.count
        } else {
            return registeredLikeCardList.count
        }
    }
    
    //写真と趣味カードのセル生成
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == userPhotoCollectionView {
            let data = userPhotoDatas[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! UserPhotoCollectionViewCell
            cell.setData(data: data)
//            // 選択時にセルの背景を変えようとしたがうまくいかず、ので後ろにlabelをおいてbool値で背景を決めるようにした
//                let selectedBGView = UIView(frame: cell.frame)
//                selectedBGView.backgroundColor = .blue
//                cell.selectedBackgroundView = selectedBGView
            return cell
        } else {
            let data = registeredLikeCardList[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! RegedLikeCardCollectionViewCell
            cell.setData(data: data)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        //写真コメントの表示切り替え
        if collectionView == userPhotoCollectionView {
            collectionView.deselectItem(at: indexPath, animated: true)
            self.userImg.image = UIImage(named: userPhotoDatas[indexPath[1]].userphoto)
            
            if userPhotoDatas[indexPath[1]].photocomment.isEmpty {
                photoComment.isHidden = true
                triangleImage.isHidden = true
            } else {
                photoComment.isHidden = false
                triangleImage.isHidden = false
                photoComment.text = userPhotoDatas[indexPath[1]].photocomment
            }
            for num in 0 ..< userPhotoDatas.count {
                userPhotoDatas[num].isSelected = false
            }
            userPhotoDatas[indexPath[1]].isSelected = true
            collectionView.reloadData()
        }
    }
}

extension LikeCardProfileSampleViewController: UICollectionViewDelegateFlowLayout {
    //collectionviewの中央揃え、スクロールできなくなるためコメントアウト
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if collectionView == userPhotoCollectionView {
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//            let cellWidth = Int(flowLayout.itemSize.width)
//            let cellSpacing = Int(flowLayout.minimumInteritemSpacing)
//            let cellCount = userPhotoDatas.count
//
//            let totalCellWidth = cellWidth * cellCount
//            let totalSpacingWidth = cellSpacing * (cellCount - 1)
//
//            let inset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//
//            print(collectionView.bounds.width)
//            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
//        }else {
//            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
//
//    }
}

extension LikeCardProfileSampleViewController: UITableViewDataSource {
    //基本情報セル数定義
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfo.count
    }
    
    //基本情報セル生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = userInfo[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! LikeCardProfileDetailCell
        cell.setData(data: data)
        return cell
    }
}

class UserPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var photoCommentImg: UIImageView!
    
    func setData(data: userPhotoInfo) {
        userPhoto.image = UIImage(named: data.userphoto)
        //コメントがない時は、imageを消す
        if data.photocomment.isEmpty {
            photoCommentImg.image = UIImage(named: "")
        }
        //写真の後ろの四角の表示切り替え
        if data.isSelected {
            bgLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            bgLabel.layer.cornerRadius = 8
            bgLabel.clipsToBounds = true
        } else {
            bgLabel.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            bgLabel.layer.cornerRadius = 8
            bgLabel.clipsToBounds = true
        }
    }
    
    // ============ ヨネダが追加 =============
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(bgLabel)
        contentView.addSubview(userPhoto)
        contentView.addSubview(photoCommentImg)

        bgLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        bgLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        bgLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bgLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        userPhoto.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3).isActive = true
        userPhoto.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 3).isActive = true
        userPhoto.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3).isActive = true
        userPhoto.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 3).isActive = true
        photoCommentImg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        photoCommentImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 3).isActive = true
        photoCommentImg.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        photoCommentImg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 3).isActive = true
    }
    
}

class RegedLikeCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var iconTitle: UILabel!
    func setData(data: ProfileLikeCardData) {
        iconImg.image = UIImage(named: data.icon)
        iconTitle.text = data.title
    }
    // ============ ヨネダが追加 =============
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(iconImg)
        contentView.addSubview(iconTitle)
        
        iconImg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        iconImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        iconImg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        iconImg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 40).isActive = true
        iconTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        iconTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        iconTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 92).isActive = true
        iconTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 11).isActive = true
    }
}

class LikeCardProfileDetailCell: UITableViewCell {
    
    @IBOutlet weak var item: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    
    func setData(data: BasicInfo) {
        self.item.text = data.item
        self.userInfo.text = data.userInfo
    }
    // ============ ヨネダが追加 =============
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(item)
        contentView.addSubview(userInfo)
        // Auto Layoutで位置・サイズを決定
        NSLayoutConstraint.activate([
            item.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            item.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 257),
            item.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            item.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            userInfo.leadingAnchor.constraint(equalTo: item.trailingAnchor, constant: 181),
            userInfo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            userInfo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            userInfo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
}

//写真データの型
struct userPhotoInfo: Identifiable {
    var id = UUID()
    var userphoto: String
    var photocomment: String
    var isSelected: Bool
}

//趣味カードの型
struct ProfileLikeCardData: Identifiable{
    var id = UUID()
    var icon: String
    var title: String
}

//基本情報の型
struct BasicInfo: Identifiable {
    var id = UUID()
    var item: String
    var userInfo: String
}

