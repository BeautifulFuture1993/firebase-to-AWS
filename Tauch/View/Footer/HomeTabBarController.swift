//
//  HomeTabBarController.swift
//  Tatibanashi-MVP
//
//  Created by Apple on 2022/05/04.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    var roomID: String = ""
    
    deinit {
        // print("\(className)を解放しました")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        // 選択時の色
        UITabBar.appearance().tintColor = UIColor.fontColor
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.fontColor], for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeTabBarController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 選択時のアニメーション
        if let targetClass = NSClassFromString("UITabBarButton") {
            let tabBarViews = tabBar.subviews.filter{ $0.isKind(of: targetClass) }
            let tabBarImageViews = tabBarViews.map { $0.subviews.first as! UIImageView }
            UIView.animate(withDuration: 0.2, animations: {
                tabBarImageViews[item.tag].transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    tabBarImageViews[item.tag].transform = CGAffineTransform.identity
                }
            }
        }
         // 「さがす」にいる状態でタブバーの「さがす」を選択した時に一番上までスクロールする
        let isSearchList = (GlobalVar.shared.thisClassName == "NewHomeViewController")
        let isSearchTabBar = (item.title == "さがす")
        let isSearch = (isSearchList && isSearchTabBar)
        if isSearch { GlobalVar.shared.likeCardTableView.setContentOffset(.zero, animated: true) }
        // 「タイムライン」にいる状態でタブバーの「タイムライン」を選択した時に一番上までスクロールする
        let isBoardList = (GlobalVar.shared.thisClassName == "BoardViewController")
        let isBoardTabBar = (item.title == "タイムライン")
        let isBoard = (isBoardList && isBoardTabBar)
        if isBoard { GlobalVar.shared.boardTableView.setContentOffset(.zero, animated: true) }
    }
}
