//
//  ViewController.swift
//  LikeCardRecommend
//
//  Created by adachitakehiro2 on 2023/03/10.
//

import UIKit
import Nuke

class LikeCardRecommendViewController: UIBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var hobbyType = "recommend"
    var hobbyCards = [HobbyCard]()
    var navigationTitle = ""
    // カテゴリー
    let hobbyCardCategory = GlobalVar.shared.hobbyCardCategory
    var category: String?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // おすすめ・人気・新着
        navigationTitle = (hobbyType == "recommend" ? "あなたにおすすめ" : navigationTitle)
        navigationTitle = (hobbyType == "popularity" ? "人気" : navigationTitle)
        navigationTitle = (hobbyType == "new" ? "新着" : navigationTitle)
        // 各カテゴリー
        if let index = index, let category = hobbyCardCategory[safe: index] {
            navigationTitle = (hobbyType == "category" ? category : navigationTitle)
        }
        
        navigationWithBackBtnSetUp(navigationTitle: navigationTitle)

        collectionView.delegate = self
        collectionView.dataSource = self
        // Nuke - prefetch
        collectionView?.isPrefetchingEnabled = true
        collectionView?.prefetchDataSource = self
        
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBarBorderAndShowTabBarBorder()
        
        tabBarController?.tabBar.isHidden = true
        
        fetchEachCategoryCards()
        // Nuke - prefetch
        prefetcher.isPaused = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Nuke - prefetch
        prefetcher.isPaused = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func fetchEachCategoryCards() {
        // カテゴリー以外はここでreturn
        guard let category = category else { return }
        
        let hobbyCards = GlobalVar.shared.globalHobbyCards
        
        // 必要であればActivityIndicatorを表示
        let loadingView = UIView(frame: UIScreen.main.bounds)
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator.center = loadingView.center
        indicator.style = .large
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        loadingView.addSubview(indicator)
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        
        self.hobbyCards = [HobbyCard]()
        // カテゴリーでソート
        hobbyCards.forEach { hobbyCard in
            if hobbyCard.category == category { self.hobbyCards.append(hobbyCard) }
        }
        if category == "グルメ・お酒" {
            /* カテゴリー「グルメ・お酒」は「食事」から変更されたため */
            let oldCategory = "食事"
            hobbyCards.forEach { hobbyCard in
                if hobbyCard.category == oldCategory { self.hobbyCards.append(hobbyCard) }
            }
        }
        
        // ソート完了後の処理
        DispatchQueue.main.async {
            loadingView.removeFromSuperview()
            self.collectionView.reloadData()
        }
        
    }
}


//MARK: - UICollectionViewDataSource

extension LikeCardRecommendViewController: UICollectionViewDataSource {
    //セル数定義
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hobbyCards.count
    }
    //セル生成
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LikeCardRecommendCollectionViewCell
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


//MARK: - UICollectionViewDataSourcePrefetching

extension LikeCardRecommendViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let urls = indexPaths.map({ URL(string: self.hobbyCards[safe: $0.row]?.iconImageURL ?? "") }) as? [URL] else { return }
        prefetcher.startPrefetching(with: urls)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let urls = indexPaths.map({ URL(string: self.hobbyCards[safe: $0.row]?.iconImageURL ?? "") }) as? [URL] else { return }
        prefetcher.stopPrefetching(with: urls)
    }
}

class LikeCardRecommendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var likeCardImage: UIImageView!
    @IBOutlet weak var likeCardTitle: UILabel!
    
    func setData(imageURL: String, text: String) {
        likeCardTitle.text = text
        likeCardImage.setImage(withURLString: imageURL)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
