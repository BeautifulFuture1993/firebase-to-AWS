//
//  ViewController.swift
//  LikeCardTopView
//
//  Created by adachitakehiro2 on 2023/03/07.
//

import Nuke
import UIKit

class LikeCardTopViewController: UIBaseViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var hobbyCardTopScrollView: UIScrollView!
    @IBOutlet weak var carouselView: ZKCarousel!
    @IBOutlet weak var recommendCollectionView: UICollectionView!
    @IBOutlet weak var popularityCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionView: UICollectionView!
    @IBOutlet weak var hobbyCardCreateButton: UIButton!
    @IBOutlet weak var recommendCellFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var popularityCellFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCellFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var categoryViews: [UIView]!
    
    static let storyboardName = "LikeCardTopViewSample"
    static let storyboardId = "LikeCardTopView"
    
    var likeCardInfo: IndicatorInfo = "趣味カード"
    
    let preferenceHobbies = ["恋バナ", "上京", "彼氏います", "ママ友作り"]
    var recommendHobbyCards = [HobbyCard]()
    var popularityHobbyCards = [HobbyCard]()
    var newHobbyCards = [HobbyCard]()
    let hobbyCardCategory = GlobalVar.shared.hobbyCardCategory
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationWithBackBtnSetUp(navigationTitle: "趣味カード")

        recommendCollectionView.delegate = self
        recommendCollectionView.dataSource = self
        recommendCollectionView.register(HobbyCardCollectionViewCell.nib, forCellWithReuseIdentifier: HobbyCardCollectionViewCell.cellIdentifier)
        
        popularityCollectionView.delegate = self
        popularityCollectionView.dataSource = self
        popularityCollectionView.register(HobbyCardCollectionViewCell.nib, forCellWithReuseIdentifier: HobbyCardCollectionViewCell.cellIdentifier)
        
        newCollectionView.delegate = self
        newCollectionView.dataSource = self
        newCollectionView.register(HobbyCardCollectionViewCell.nib, forCellWithReuseIdentifier: HobbyCardCollectionViewCell.cellIdentifier)
        
        hobbyCardTopScrollView.delegate = self
        
        setHobbyCardCreateButton()
        setupCarousel()
        
        categoryViews.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryViewTapped(_:)))) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBarBorderAndShowTabBarBorder()
        
        navigationController?.navigationBar.backgroundColor = .white
        // おすすめ・人気・新着を取得
        filterHobbyCards()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.scrollBeginingPoint = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Methods

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return likeCardInfo
    }
    
    private func setHobbyCardCreateButton() {
        hobbyCardCreateButton.layer.cornerRadius = hobbyCardCreateButton.frame.height / 2
        hobbyCardCreateButton.setShadow()
    }
    
    private func filterHobbyCards() {
        let hobbyCards = GlobalVar.shared.globalHobbyCards
        // オススメの趣味カードを取得
        let preferenceHobbyCards = hobbyCards.filter({ preferenceHobbies.contains($0.title) == true })
        let isNotPreferenceHobbyCards = hobbyCards.filter({ preferenceHobbies.contains($0.title) == false })
        recommendHobbyCards = preferenceHobbyCards + isNotPreferenceHobbyCards
        recommendCollectionView.reloadData()
        // 人気の趣味カードを取得
        popularityHobbyCards = hobbyCards.sorted(by: { $0.count > $1.count })
        popularityCollectionView.reloadData()
        // 新着の趣味カードを取得
        newHobbyCards = hobbyCards.sorted(by: {
            let hobbyCard1Date = $0.created_at.dateValue()
            let hobbyCard2Date = $1.created_at.dateValue()
            return hobbyCard1Date > hobbyCard2Date
        })
        newCollectionView.reloadData()
    }
    
    private func moveAllLikeCard(type: String) {
        
        let storyboard = UIStoryboard(name: "LikeCardRecommendView", bundle: nil)
        let likeCardRecommendVC = storyboard.instantiateViewController(withIdentifier: "LikeCardRecommendView") as! LikeCardRecommendViewController
        
        switch type {
        case "recommend":
            likeCardRecommendVC.hobbyType = "recommend"
            likeCardRecommendVC.hobbyCards = recommendHobbyCards
            break
        case "popularity":
            likeCardRecommendVC.hobbyType = "popularity"
            likeCardRecommendVC.hobbyCards = popularityHobbyCards
            break
        case "new":
            likeCardRecommendVC.hobbyType = "new"
            likeCardRecommendVC.hobbyCards = newHobbyCards
            break
        default:
            break
        }
        navigationController?.pushViewController(likeCardRecommendVC, animated: true)
    }
    
    @IBAction func showRecommend(_ sender: Any) {
        moveAllLikeCard(type: "recommend")
    }
    
    @IBAction func showPopular(_ sender: Any) {
        moveAllLikeCard(type: "popularity")
    }
    
    @IBAction func showNew(_ sender: Any) {
        moveAllLikeCard(type: "new")
    }
    
    @IBAction func hobbyCardCreate(_ sender: Any) {
        moveGenerateHobbyCard()
    }
    
    private func setupCarousel() {

        guard let descriptionImg = UIImage(named: "description") else { return }
        guard let alertImg = UIImage(named: "alert") else { return }
        
        carouselView.delegate = self
        
        carouselView.layer.cornerRadius = 10
        carouselView.clipsToBounds = true
        
        let slide = ZKCarouselSlide(image: descriptionImg, title: "", description: "")
        let slide1 = ZKCarouselSlide(image: alertImg, title: "", description: "")

        let slideList = [
            slide, slide1, slide, slide1, slide, slide1, slide, slide1, slide, slide1,
            slide, slide1, slide, slide1, slide, slide1, slide, slide1, slide, slide1,
            slide, slide1, slide, slide1, slide, slide1, slide, slide1, slide, slide1,
            slide, slide1, slide, slide1, slide, slide1, slide, slide1, slide, slide1,
            slide, slide1, slide, slide1, slide, slide1, slide, slide1, slide, slide1
        ]
        
        carouselView.slides = slideList
        
        carouselView.disableTap()
        
        carouselView.interval = 3

        carouselView.start()
    }
    
    private func moveToCategoryList(index: Int, category: String) {
        
        let storyboard = UIStoryboard(name: "LikeCardRecommendView", bundle: nil)
        let likeCardRecommendVC = storyboard.instantiateViewController(withIdentifier: "LikeCardRecommendView") as! LikeCardRecommendViewController
        
        likeCardRecommendVC.hobbyType = "category"
        likeCardRecommendVC.index = index
        likeCardRecommendVC.category = category
        likeCardRecommendVC.hobbyCards = []
        
        navigationController?.pushViewController(likeCardRecommendVC, animated: true)
    }
    
    @objc func categoryViewTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        guard let category = hobbyCardCategory[safe: index] else { return }
        moveToCategoryList(index: index, category: category)
    }
}

extension LikeCardTopViewController: ZKCarouselDelegate {
    
    func carouselDidTap(cell: ZKCarouselCell) {
        let slideImg = cell.slide?.image
        if slideImg == UIImage(named: "description") {
            screenTransition(
                storyboardName: "ExplanationLikeCardView",
                storyboardID: "ExplanationLikeCardView"
            )
        }
        if slideImg == UIImage(named: "alert") {
            screenTransition(
                storyboardName: BusinessSolicitationCrackdownViewController.storyboardName,
                storyboardID: BusinessSolicitationCrackdownViewController.storyboardId
            )
        }
    }
}

//MARK: - UICollectionViewDataSource

extension LikeCardTopViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var cellNum = 0
        
        switch collectionView {
        // 各趣味カードの表示数
        case recommendCollectionView, popularityCollectionView, newCollectionView:
            cellNum = 4
        default:
            break
        }
        
        return cellNum
    }
    
    //横スクロールメニューバーのセル生成
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        switch collectionView {
        case recommendCollectionView: // オススメのセル生成
            guard let recommendCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: HobbyCardCollectionViewCell.cellIdentifier, for: indexPath) as? HobbyCardCollectionViewCell else {
                fatalError()
            }
            if let hobbyCard = recommendHobbyCards[safe: indexPath.row] {
                let hobbyCardImageURL = hobbyCard.iconImageURL
                let hobbyCardTitle = hobbyCard.title
                recommendCollectionViewCell.setData(imageURL: hobbyCardImageURL, text: hobbyCardTitle)
            }
            cell = recommendCollectionViewCell
            break
        case popularityCollectionView: // 人気のセル数生成
            guard let popularityCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: HobbyCardCollectionViewCell.cellIdentifier, for: indexPath) as? HobbyCardCollectionViewCell else {
                fatalError()
            }
            if let hobbyCard = popularityHobbyCards[safe: indexPath.row] {
                let hobbyCardImageURL = hobbyCard.iconImageURL
                let hobbyCardTitle = hobbyCard.title
                popularityCollectionViewCell.setData(imageURL: hobbyCardImageURL, text: hobbyCardTitle)
            }
            cell = popularityCollectionViewCell
            break
        case newCollectionView: // 新着のセル数生成
            guard let newCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: HobbyCardCollectionViewCell.cellIdentifier, for: indexPath) as? HobbyCardCollectionViewCell else {
                fatalError()
            }
            if let hobbyCard = newHobbyCards[safe: indexPath.row] {
                let hobbyCardImageURL = hobbyCard.iconImageURL
                let hobbyCardTitle = hobbyCard.title
                newCollectionViewCell.setData(imageURL: hobbyCardImageURL, text: hobbyCardTitle)
            }
            cell = newCollectionViewCell
            break
        default:
            break
        }
        
        return  cell
    }
    
    //Cellを押したときの画面遷移とCell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch collectionView {
        case recommendCollectionView: // オススメのセルタップ
            if let hobbyCard = recommendHobbyCards[safe: indexPath.row] {
                let hobbyCardTitle = hobbyCard.title
                let hobbyCardImageURL = hobbyCard.iconImageURL
                moveLikeCardDetail(title: hobbyCardTitle, imageURL: hobbyCardImageURL)
            }
            break
        case popularityCollectionView: // 人気のセルタップ
            if let hobbyCard = popularityHobbyCards[safe: indexPath.row] {
                let hobbyCardTitle = hobbyCard.title
                let hobbyCardImageURL = hobbyCard.iconImageURL
                moveLikeCardDetail(title: hobbyCardTitle, imageURL: hobbyCardImageURL)
            }
            break
        case newCollectionView: // 新着のセルタップ
            if let hobbyCard = newHobbyCards[safe: indexPath.row] {
                let hobbyCardTitle = hobbyCard.title
                let hobbyCardImageURL = hobbyCard.iconImageURL
                moveLikeCardDetail(title: hobbyCardTitle, imageURL: hobbyCardImageURL)
            }
            break
        default:
            break
        }
    }
}


extension LikeCardTopViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.bounds.width - (15.0 * 2) - (5.0 * 3)) / 4
        let cellHeight = cellWidth + 25.0
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    // 水平方向におけるセル間のマージン
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

    // 垂直方向におけるセル間のマージン
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


//MARK: - UIScrollViewDelegate

extension LikeCardTopViewController {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // スクロール開始位置の設定
        self.scrollBeginingPoint = scrollView.contentOffset
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        let topScrollPoint = (currentPoint.y == 0.0)
        if topScrollPoint { barButtonViewRect(hidden: false) }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロール開始点（読み込まれた時点ではreturn）
        let scrollBeginingPoint = self.scrollBeginingPoint ?? CGPoint()
        // 現在地
        let currentPoint = scrollView.contentOffset
        // 判定
        let isScrollingDown: Bool = (scrollBeginingPoint.y < currentPoint.y)
        // スクロール方向判定
        if isScrollingDown {
            barButtonViewRect(hidden: true)
        } else {
            barButtonViewRect(hidden: false)
        }
    }
}
