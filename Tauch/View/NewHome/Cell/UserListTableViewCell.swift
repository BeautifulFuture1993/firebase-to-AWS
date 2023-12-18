//
//  UserListTableViewCell.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/03/31.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userListCollectionView: UICollectionView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    static let nibName = "UserListTableViewCell"
    static let cellIdentifier = "UserListTableViewCell"
    static let height: CGFloat = 152
    
    private var userLists: [User] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userListCollectionView.delegate = self
        userListCollectionView.dataSource = self
        userListCollectionView.register(UINib(nibName: UserListChildCell.nibName, bundle: nil), forCellWithReuseIdentifier: UserListChildCell.cellIdentifier)
    }
    
    func setUserData(with userData: [User]) {
        self.userLists = userData
        
        userListCollectionView.reloadData()
    }
}

//MARK: - UICollectionView - Delegate/DataSource/DelegateFlowLayout

extension UserListTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserListChildCell.cellIdentifier, for: indexPath) as! UserListChildCell
        cell.delegate = self
        
        let user = userLists[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UserListChildCell.width + 15, height: UserListChildCell.height)
    }
}

extension UserListTableViewCell: UserListChildCellDelegate {
    
    func didTapGoDetail(cell: UserListChildCell) {
        if let user = cell.user {
            let storyBoard = UIStoryboard.init(name: "ProfileDetailView", bundle: nil)
            let modalVC = storyBoard.instantiateViewController(withIdentifier: "ProfileDetailView") as! ProfileDetailViewController
            modalVC.user = user
            modalVC.transitioningDelegate = self
            if let parentVC = parentViewController() as? NewHomeViewController {
                parentVC.present(modalVC, animated: true, completion: nil)
            }
        }
    }
}

//cellから親viewControllerにアクセス
extension UserListTableViewCell {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }
}
