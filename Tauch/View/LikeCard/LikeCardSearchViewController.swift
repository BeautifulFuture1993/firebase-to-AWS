//
//  LikeCardSearchViewController.swift
//  Tauch
//
//  Created by Apple on 2023/05/10.
//

import UIKit

class LikeCardSearchViewController: UIBaseViewController {

    @IBOutlet weak var searchNoneView: UIView!
    @IBOutlet weak var searchEmptyView: UIView!
    @IBOutlet weak var generateHobbyCardBtn: UIButton!
    @IBOutlet weak var likeCardSearchCollectionView: UICollectionView!
    
    let searchBar: UISearchBar = UISearchBar()
    var hobbyCards = [HobbyCard]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationWithBackBtnAndSearchSetUp(placeHolder: "趣味カードを検索")
        
        likeCardSearchCollectionView.delegate = self
        likeCardSearchCollectionView.dataSource = self
        
        searchBar.becomeFirstResponder()
        
        toggleViewHidden()
        
        generateHobbyCardBtn.rounded()
        generateHobbyCardBtn.setShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBarBorderAndShowTabBarBorder()
        
        likeCardSearchCollectionView.reloadData()
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Backボタン付きの検索ナビゲーション
    func navigationWithBackBtnAndSearchSetUp(placeHolder: String) {
        // ナビゲーションバーを表示する
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // ナビゲーションの戻るボタンを消す
        self.navigationItem.setHidesBackButton(true, animated: true)
        // ナビゲーションバーの透過させる
        self.navigationController?.navigationBar.isTranslucent = true
        //ナビゲーションアイテムのタイトルを設定
        searchBar.delegate = self
        searchBar.placeholder = placeHolder
        searchBar.clipsToBounds = true
        searchBar.layer.cornerRadius = 50
        self.navigationItem.titleView = searchBar
        //ナビゲーションバー左ボタンを設定
        let backImage = UIImage(systemName: "chevron.backward")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action:#selector(self.popPage))
        self.navigationItem.leftBarButtonItem?.tintColor = .fontColor
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 一つ前の画面に戻る
    @objc private func popPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func hideKeyboard() {
        searchBar.endEditing(true)
    }
    
    private func toggleViewHidden(search: Bool = false, result: Bool = false) {
        
        if search {
            searchNoneView.isHidden = true
            
            if result {
                likeCardSearchCollectionView.isHidden = true
                searchEmptyView.isHidden = false
            } else {
                likeCardSearchCollectionView.isHidden = false
                searchEmptyView.isHidden = true
            }
            
        } else {
            searchNoneView.isHidden = false
            likeCardSearchCollectionView.isHidden = true
            searchEmptyView.isHidden = true
        }
    }
    
    @IBAction func didTapGenerateHobbyCard(_ sender: Any) {
        moveGenerateHobbyCard()
    }
}

extension LikeCardSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text { searchLikeCard(searchText: searchText) }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchLikeCard(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let _ = searchBar.text { hideKeyboard() }
    }
    
    private func searchLikeCard(searchText: String) {
        
        if searchText.isEmpty { toggleViewHidden(); return }
        
        let searchTextKatakana = searchText.toKatakana()
        let searchTextHiragana = searchText.toHiragana()
        
        hobbyCards = GlobalVar.shared.globalHobbyCards.filter({ $0.title.contains(searchTextKatakana) || $0.title.contains(searchTextHiragana) })
        likeCardSearchCollectionView.reloadData()
        
        if hobbyCards.isEmpty {
            toggleViewHidden(search: true, result: true)
        } else {
            toggleViewHidden(search: true)
        }
    }
}

extension LikeCardSearchViewController: UICollectionViewDataSource {
    //セル数定義
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hobbyCards.count
    }
    //セル生成
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "likeCardSearchCell", for: indexPath) as! LikeCardSearchCollectionViewCell
        if let hobbyCard = hobbyCards[safe: indexPath.row] {
            let hobbyCardTitle = hobbyCard.title
            let hobbyCardImgURL = hobbyCard.iconImageURL
            cell.setData(imageURL: hobbyCardImgURL, text: hobbyCardTitle)
        }
        return  cell
    }
    //Cellを押したときの画面遷移とCell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let hobbyCard = hobbyCards[safe: indexPath.row] {
            let hobbyCardTitle = hobbyCard.title
            let hobbyCardImgURL = hobbyCard.iconImageURL
            moveLikeCardDetail(title: hobbyCardTitle, imageURL: hobbyCardImgURL)
        }
    }
}

class LikeCardSearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var likeCardTitle: UILabel!
    @IBOutlet weak var likeCardImage: UIImageView!
    
    func setData(imageURL: String, text: String) {
        likeCardTitle.text = text
        likeCardImage.setImage(withURLString: imageURL)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

