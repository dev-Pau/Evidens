//
//  PrivacyPolicyViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/9/22.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        let url = URL(string: "https://developer.apple.com")!
        webView.load(URLRequest(url: url))
    }
    
    private func configureNavigationBar() {
        title = "Privacy Policy"
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.black), style: .done, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension PrivacyPolicyViewController: WKNavigationDelegate {
    
}
