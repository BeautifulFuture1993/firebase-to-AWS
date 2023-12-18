//
//  TermsWebViewController.swift
//  Touch
//
//  Created by sasaki.ken on 2023/11/18.
//

import UIKit
import WebKit
import FirebaseFirestore

final class TermsWebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var bottomView: UIView!
    
    private enum WebViewStatus {
        case loading
        case contents
        case error
    }
    
    private var status: WebViewStatus = .loading {
        didSet {
            webView?.isHidden = true
            errorView?.isHidden = true
            indicatorView?.isHidden = true
            bottomView.isHidden = true
            
            switch status {
            case .loading:
                indicatorView?.isHidden = false
                errorView?.isHidden = true
                webView?.isHidden = true
                bottomView.isHidden = true
            case .contents:
                webView?.isHidden = false
                bottomView.isHidden = false
                errorView?.isHidden = true
                indicatorView?.isHidden = true
            case .error:
                errorView?.isHidden = false
                bottomView.isHidden = true
                webView?.isHidden = true
                indicatorView?.isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        loadWebView()
    }
    
    private func loadWebView() {
        status = .loading
        
        if let link = GlobalVar.shared.links["termsOfService"], let url = URL(string: link), let webView = webView {
            let request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: 10
            )
            
            webView.navigationDelegate = self
            webView.load(request)
        }
    }
    
    @IBAction func onRetryButtonTapped(_ sender: UIButton) {
        loadWebView()
    }
    
    @IBAction func onAgreeButtonTapped(_ sender: UIButton) {
        if let uid = GlobalVar.shared.loginUser?.uid {
            let db = Firestore.firestore()
            let document = db.collection("users").document(uid).collection("new_terms_agree").document(uid)
            let registTime = Timestamp()
            let data: [String: Any] =  [
                "is_agree": true,
                "created_at": registTime,
                "updated_at":registTime
            ]
            
            document.setData(data) { error in
                if error != nil {
                    print("新利用規約の同意に失敗:", error as Any)
                }
                
                self.dismiss(animated: true)
            }
        }
    }
}

extension TermsWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        status = .contents
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        status = .error
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        status = .error
    }
}
