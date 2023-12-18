//
//  UIBaseViewController.swift
//  Tatibanashi
//
//  Created by Apple on 2022/02/12.
//

import Nuke
import UIKit
import MapKit
import SwiftyGif
import FBSDKLoginKit
import SafariServices
import UserNotifications
import FirebaseFirestore

class UIBaseViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITabBarDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UIToolbarDelegate, UITableViewDelegate, UICollectionViewDelegate {
    
    let db = Firestore.firestore()
    let firebaseController = FirebaseController()
    let loadingView = UIView(frame: UIScreen.main.bounds)
    
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
    var pipeline = ImagePipeline.shared
    
    let selectedHobbyMin = 3
    
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
    
    // 余白をクリックで、キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // Returnキーで、キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    // 枠線の下線部を追加
    func underline(textField: UITextField, color: UIColor) {
        let widthOffset = 10
        let underBorder = CALayer()
        underBorder.frame = CGRect(x: 0, y: textField.frame.height, width: textField.frame.width - CGFloat(widthOffset), height: 1.0)
        underBorder.backgroundColor = color.cgColor
        textField.layer.addSublayer(underBorder)
    }
    // プロフィール画像の円加工
    func profileImageDesign(imageView: UIImageView) {
        imageView.contentMode = .scaleAspectFill
        imageView.rounded()
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor().setColor(colorType: "darkPinkColor", alpha: 1.0).cgColor
    }
    // メールアドレス バリデーション
    func validateEmail(emailText: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: emailText)
    }
    // 電話番号(携帯のみ許可) バリデーション
    func validateTel(telText: String) -> Bool {
        let telRegex = "^(070|080|090)\\d{4}\\d{4}$"
        return NSPredicate(format: "SELF MATCHES %@", telRegex).evaluate(with: telText)
    }
    // ニックネームのバリデーション
    func validateNickName(inputNickNameText: String) -> Bool {
        if inputNickNameText.count <= 10 {
            return true
        } else {
            return false
        }
    }
    // 生年月日のバリデーション
    func validateDate(inputDateText: String) -> Bool {
        let dateRegex = "[12]\\d{3}[年](0?[1-9]|1[0-2])[月](0?[1-9]|[12][0-9]|3[01])日?$"
        return NSPredicate(format: "SELF MATCHES %@", dateRegex).evaluate(with: inputDateText)
    }
    // プロフィールステータスのバリデーション
    func validateProfileStatus(inputProfileStatusText: String) -> Bool {
        if inputProfileStatusText.count <= 150 {
            return true
        } else {
            return false
        }
    }
    // プロフィール趣味カードのバリデーション
    func validateHobby(selectedHobbies: [String]) -> Bool {
        if selectedHobbies.count > 2 {
            return true
        } else {
            return false
        }
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
            let backgroundView = UIView()
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
    // 二地点間の距離を計算 (国土交通省でも使われているヒュペニ算)
    func distance(current: (la: Double, lo: Double), target: (la: Double, lo: Double)) -> Double {
        // 緯度経度をラジアンに変換
        let currentLa   = current.la * Double.pi / 180
        let currentLo   = current.lo * Double.pi / 180
        let targetLa    = target.la * Double.pi / 180
        let targetLo    = target.lo * Double.pi / 180
        // 緯度差
        let radLatDiff = currentLa - targetLa
        // 経度差算
        let radLonDiff = currentLo - targetLo
        // 平均緯度
        let radLatAve = (currentLa + targetLa) / 2.0
        // 測地系による値の違い
        // 赤道半径
        let a = 6377397.155 // japan
        // 極半径
        let b = 6356078.963 // japan
        // 第一離心率^2
        let e2 = (a * a - b * b) / (a * a)
        // 赤道上の子午線曲率半径
        let a1e2 = a * (1 - e2)
        let sinLat = sin(radLatAve)
        let w2 = 1.0 - e2 * (sinLat * sinLat)
        // 子午線曲率半径m
        let m = a1e2 / (sqrt(w2) * w2)
        // 卯酉線曲率半径 n
        let n = a / sqrt(w2)
        // 算出 (m単位)
        let t1 = m * radLatDiff
        let t2 = n * cos(radLatAve) * radLonDiff
        let distance = sqrt((t1 * t1) + (t2 * t2))
        return distance
    }
    // 新着表示
    func elapsedNewTime(registTime: Date) -> String {
        let now = Date()
        let span = now.timeIntervalSince(registTime)
        let hourSpan   = Int(floor(span/60/60))
        let daySpan    = Int(floor(span/60/60/24))
        
        if hourSpan < 12 {
            return "新着"
            
        } else if hourSpan < 24 {
            return "\(hourSpan)時間前"
            
        } else if daySpan > 0 {
            return "\(daySpan)日前"
            
        } else {
            return "新着"
            
        }
    }
    // ログアウト後からの経過時間
    func elapsedTime(isLogin: Bool, logoutTime: Date) -> [Int:Int] {
        // ログアウトしていない場合
        if isLogin { return [0:0] }
        
        let now = Date()
        let span = now.timeIntervalSince(logoutTime)
        
        let secondSpan = Int(floor(span))
        let minuteSpan = Int(floor(span/60))
        let hourSpan   = Int(floor(span/60/60))
        let daySpan    = Int(floor(span/60/60/24))
        
        if secondSpan > 0 && secondSpan < 60 {
            // ログアウトから秒数的な差がある場合
            return [1:secondSpan]
            
        } else if minuteSpan > 0 && minuteSpan < 60 {
            // ログアウトから分数的な差がある場合
            return [2:minuteSpan]
            
        } else if hourSpan > 0 && hourSpan < 24 {
            // ログアウトから時刻的な差がある場合
            return [3:hourSpan]
            
        } else if daySpan > 0 {
            // ログアウトから日数的な差がある場合
            return [4:daySpan]
            
        } else {
            // ログアウトしていない場合
            return [0:0]
            
        }
    }
}
