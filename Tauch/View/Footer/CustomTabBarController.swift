//
//  CustomTabBarController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/24.
//

import UIKit
import ESTabBarController

// ESTabBarItemの外観等の設定用class
class CustomContentView: ESTabBarItemContentView {

    private let duration = 0.2

    override init(frame: CGRect) {
        super.init(frame: frame)
        highlightTextColor = UIColor.fontColor
        highlightIconColor = UIColor.fontColor
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }

    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }

    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 , 0.9, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}

class CustomTabBarController: ESTabBarController, UITabBarControllerDelegate {
    
    var roomID: String = ""
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // print("\(className)を解放しました")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTab()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
//        print(
//            "CustomTabBarController",
//            "item.tag: \(item.tag)",
//            "selectedIndex: \(self.selectedIndex)",
//            "thisClassName : \(GlobalVar.shared.thisClassName)"
//        )
        // 「さがす」にいる状態でタブバーの「さがす」を選択した時に一番上までスクロールする
       let isSearchList = (GlobalVar.shared.thisClassName == "NewHomeViewController")
       let isSearchTabBar = (item.tag == 0)
       let isSearch = (isSearchList && isSearchTabBar)
       if isSearch { GlobalVar.shared.likeCardTableView.setContentOffset(.zero, animated: true) }
        // タイムラインいる状態でタブバーの「タイムライン」を選択した時に一番上までスクロールする
        let isBoardList = (GlobalVar.shared.thisClassName == "BoardViewController")
        let isBoardTabBar = (item.tag == 3)
        let isBoard = (isBoardList && isBoardTabBar)
        if isBoard { GlobalVar.shared.boardTableView.setContentOffset(.zero, animated: true) }
    }
    
    private func initTab() {
        // 「さがす」
        let screenManagerStoryboard = UIStoryboard(name: ScreenManagerViewController.storyboardName, bundle: nil)
        let screenManagerVC = screenManagerStoryboard.instantiateViewController(withIdentifier: ScreenManagerViewController.storyboardId)
        screenManagerVC.tabBarItem = ESTabBarItem.init(CustomContentView(), title: "さがす", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass"))
        screenManagerVC.tabBarItem.tag = 0
        // 「お相手から」
        let homeViewStoryboard = UIStoryboard(name: "HomeView", bundle: nil)
        let homeVC = homeViewStoryboard.instantiateViewController(withIdentifier: "HomeView")
        homeVC.tabBarItem = ESTabBarItem.init(CustomContentView(), title: "お相手から", image: UIImage(systemName: "hand.thumbsup"), selectedImage: UIImage(systemName: "hand.thumbsup.fill"))
        homeVC.tabBarItem.tag = 1
        // 「やりとり」
        let messageListStoryboard = UIStoryboard(name: "MessageListViewController", bundle: nil)
        let messageListVC = messageListStoryboard.instantiateViewController(withIdentifier: "MessageListViewController")
        messageListVC.tabBarItem = ESTabBarItem.init(CustomContentView(), title: "やりとり", image: UIImage(systemName: "message"), selectedImage: UIImage(systemName: "message.fill"))
        messageListVC.tabBarItem.tag = 2
        // 「タイムライン」
        let bbsStoryboard = UIStoryboard(name: BoardViewController.storyboard_name_id, bundle: nil)
        let bbsVC = bbsStoryboard.instantiateViewController(withIdentifier: BoardViewController.storyboard_name_id)
        bbsVC.tabBarItem = ESTabBarItem.init(CustomContentView(), title: "タイムライン", image: UIImage(systemName: "list.bullet.clipboard"), selectedImage: UIImage(systemName: "list.bullet.clipboard.fill"))
        bbsVC.tabBarItem.tag = 3
        // 「足あと」
        let visitorStoryboard = UIStoryboard(name: "VisitorView", bundle: nil)
        let visitorVC = visitorStoryboard.instantiateViewController(withIdentifier: "VisitorView")
        visitorVC.tabBarItem = ESTabBarItem.init(CustomContentView(), title: "足あと", image: UIImage(systemName: "pawprint.fill"), selectedImage: UIImage(systemName: "pawprint.fill"))
        visitorVC.tabBarItem.tag = 4
        
        /* バッジ */
        if let tabBarItem = bbsVC.tabBarItem as? ESTabBarItem {
            tabBarItem.badgeValue = ""
        }
        
        let vc1 = SwipeNavigationController(rootViewController: screenManagerVC)
        let vc2 = SwipeNavigationController(rootViewController: homeVC)
        let vc3 = SwipeNavigationController(rootViewController: messageListVC)
        let vc4 = SwipeNavigationController(rootViewController: bbsVC)
        let vc5 = SwipeNavigationController(rootViewController: visitorVC)
        self.viewControllers = [vc1, vc2, vc3, vc4, vc5]
    }
}
