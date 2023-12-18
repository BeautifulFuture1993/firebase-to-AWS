//
//  UpdateNotice.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/07/05.
//

import UIKit

struct UpdateNotice {
    //最新バージョンがある時にアラートを出す
    static func fire(view: UIViewController) {
        guard let url = URL(string: "https://itunes.apple.com/jp/lookup?id=1623785510") else { return }
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let storeVersion = ((jsonData?["results"] as? [Any])?.first as? [String : Any])?["version"] as? String,
                      let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
                    return
                }
                switch storeVersion.compare(appVersion, options: .numeric) {
                case .orderedDescending:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "最新バージョンのお知らせ", message: "最新バージョンがあります。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "更新", style: .default) { _ in
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1623785510"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:])
                            }
                        })
                        view.present(alert, animated: true)
                    }
                    return
                case .orderedSame, .orderedAscending:
                    return
                }
            } catch {
            }
        })
        task.resume()
    }
}
