//
//  VisitorManagerViewController.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/06/05.
//

import UIKit

class VisitorManagerViewController: BaseButtonBarPagerTabStripViewController<VisitorButtonBarCell> {
    
    static let storyboardName = "VisitorManagerView"
    static let storyboardID = "VisitorManagerView"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: VisitorButtonBarCell.nibName, bundle: Bundle(for: VisitorButtonBarCell.self), width: { _ in
                return 40
        })
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        configureButtonBarStyle()
        super.viewDidLoad()
        
        configureContainerView()
        configureNavigationBar()
    }
    
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        // let profileVisitorsVC = VisitorViewController(style: .plain, itemInfo: IndicatorInfo(title: "足あと", image: UIImage(systemName: "pawprint.fill")))
        let homeStoryboardName = NewHomeViewController.storyboardName
        let homeStoryboardID = NewHomeViewController.storyboardId
        let homeVC = UIStoryboard(name: homeStoryboardName, bundle: nil).instantiateViewController(withIdentifier: homeStoryboardID)
        
        let myHistoryVC = MyHistoryViewController(style: .plain, itemInfo: IndicatorInfo(title: "自分の足あと", image: nil))
        
        return [homeVC, myHistoryVC]
    }
    
    override func configure(cell: VisitorButtonBarCell, for indicatorInfo: IndicatorInfo) {
        if let image = indicatorInfo.image?.withRenderingMode(.alwaysTemplate) {
            cell.iconImageView.image = image
        } else {
            cell.iconImageView.isHidden = true
        }
        cell.iconLabel.text = indicatorInfo.title?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        if indexWasChanged && toIndex > -1 && toIndex < viewControllers.count {
            let child = viewControllers[toIndex] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            UIView.performWithoutAnimation({ [weak self] () -> Void in
                guard let me = self else { return }
                me.navigationItem.leftBarButtonItem?.title =  child.indicatorInfo(for: me).title
            })
        }
    }
}


//MARK: - Appearance

extension VisitorManagerViewController {
    
    private func configureContainerView() {
        // containerViewの制約は全てSafeArea
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func configureNavigationBar() {
        // buttonBarView
        buttonBarView.removeFromSuperview()
        navigationItem.titleView = self.buttonBarView
        
        navigationController?.navigationItem.hidesBackButton = true
        
        let appearance = UINavigationBarAppearance()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .lightGray
        appearance.backgroundImage = UIImage()
        appearance.backgroundColor = .white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func configureButtonBarStyle() {
        let screenWidth = UIScreen.main.bounds.width
        
        settings.style.buttonBarBackgroundColor = .systemBackground
        settings.style.buttonBarItemBackgroundColor = .accentColor
        settings.style.buttonBarItemTitleColor = .accentColor
        settings.style.selectedBarBackgroundColor = .accentColor
        settings.style.selectedBarHeight = 4.0
        self.buttonBarView.selectedBar.layer.cornerRadius = 2.0
        settings.style.buttonBarMinimumLineSpacing = screenWidth / 4
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = screenWidth / 8
        settings.style.buttonBarRightContentInset = screenWidth / 8
        
        changeCurrentIndexProgressive = {
            [weak self] (oldCell: VisitorButtonBarCell?,
                         newCell: VisitorButtonBarCell?,
                         progressPercentage: CGFloat,
                         changeCurrentIndex: Bool,
                         animated: Bool) -> Void in
            
            guard let _ = self else { return }
            guard changeCurrentIndex == true else { return }
            oldCell?.iconImageView.tintColor = .lightGray
            oldCell?.iconLabel.textColor = .lightGray
            newCell?.iconImageView.tintColor = .accentColor
            newCell?.iconLabel.textColor = .accentColor
        }
    }
}



