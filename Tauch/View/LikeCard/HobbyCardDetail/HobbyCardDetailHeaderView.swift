//
//  HobbyCardDetailHeaderView.swift
//  Tauch
//
//  Created by Adam Yoneda on 2023/05/28.
//

import UIKit

protocol HobbyCardDetailHeaderViewDelegate {
    func didTapAlertContactForm()
    func didTapFilter()
}

class HobbyCardDetailHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var likeCardTitle: UILabel!
    @IBOutlet weak var likeCardImage: UIImageView!
    
    static let nib: UINib = UINib(nibName: "HobbyCardDetailHeaderView", bundle: nil)
    static let headerIdentifier = "HobbyCardTableHeaderView"
    static let height: CGFloat = 168.0
    
    var headerViewDelegate: HobbyCardDetailHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let rgba = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
        searchButton.layer.borderWidth = 0.5
        searchButton.layer.borderColor = rgba.cgColor
        searchButton.layer.cornerRadius = 15.0
        searchButton.setTitleColor(.white, for: .normal)
    }
    
    func setHobby(title: String?, imageURL: String) {
        likeCardTitle.text = title
        likeCardImage.setImage(withURLString: imageURL)
    }
    
    func setSearchButton(_ checkFilter: Bool) {
        if checkFilter {
            searchButton.tintColor = .accentColor
            searchButton.layer.borderColor = UIColor.accentColor.cgColor
            searchButton.setTitleColor(.accentColor, for: .normal)
            searchButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
            searchButton.setTitle("絞り込み中", for: .normal)
        } else {
            let greyColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
            searchButton.tintColor = greyColor
            searchButton.layer.borderColor = greyColor.cgColor
            searchButton.setTitleColor(greyColor, for: .normal)
            searchButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
            searchButton.setTitle("絞り込み", for: .normal)
        }
    }
    
    @IBAction func didTapAlertContactForm(_ sender: UIButton) {
        headerViewDelegate?.didTapAlertContactForm()
    }
    
    @IBAction func didTapFilter(_ sender: UIButton) {
        headerViewDelegate?.didTapFilter()
    }
}
