//
//  LoadingTableViewCell.swift
//  Tauch
//
//  Created by Apple on 2023/04/14.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var IndicatoreView: UIActivityIndicatorView!
    
    static let cellIdentifier = "LoadingTableViewCell"
    static let nibName = "LoadingTableViewCell"
    
    static let height: CGFloat = 60
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func startAnimation(){
        IndicatoreView.isHidden = false
        IndicatoreView.startAnimating()
    }
    
    func endAnimation() {
        IndicatoreView.isHidden = true
        IndicatoreView.stopAnimating()
    }
}
