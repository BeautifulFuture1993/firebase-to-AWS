//
//  UIBaseTableViewController.swift
//  Tauch
//
//  Created by Apple on 2022/06/26.
//

import Nuke
import UIKit
import FirebaseFirestore

class UIBaseTableViewController: UITableViewController {

    let db = Firestore.firestore()
    let firebaseController = FirebaseController()
    let loadingView = UIView(frame: UIScreen.main.bounds)
    let backgroundView = UIView()
    
    var elaspedTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = "M月d日(E)" // default dateFormat
        return formatter
    }()
    
    var scrollBeginingPoint: CGPoint?
    
    let prefetcher = ImagePrefetcher()
    
    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.attachListener()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moveBackground()
        GlobalVar.shared.tabBarVC?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setClass(className: className)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)   
        scrollBeginingPoint = nil
    }
    
    // メモリリーク
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ローディング画面を表示
    func showLoadingView(_ loadingView: UIView, text: String = "", color: UIColor = .accentColor) {
        
        loadingView.backgroundColor = .white.withAlphaComponent(0.5)
        let indicator = UIActivityIndicatorView()
        indicator.center = loadingView.center
        indicator.style = .large
        indicator.color = color
        indicator.startAnimating()
        loadingView.addSubview(indicator)
        guard let windowFirst = Window.first else { return }
        
        if text != "" {
            backgroundView.backgroundColor = .white
            backgroundView.layer.cornerRadius = 10
            backgroundView.setShadow()
            loadingView.addSubview(backgroundView)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.widthAnchor.constraint(equalToConstant: 150).isActive = true
            backgroundView.heightAnchor.constraint(equalToConstant: 150).isActive = true
            backgroundView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
            backgroundView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
            
            let textLabel = UILabel()
            textLabel.text = text
            textLabel.font = .boldSystemFont(ofSize: 16)
            textLabel.textColor = color
            backgroundView.addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            textLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
            textLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 110).isActive = true
            
            do {
                let gif = try UIImage(gifName: "Bean.gif")
                let imageView = UIImageView(gifImage: gif)
                loadingView.addSubview(imageView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
                imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 5).isActive = true
            } catch {
                print("gifエラー\(error)")
            }
        }
        
        windowFirst.addSubview(loadingView)
    }
}
