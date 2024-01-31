//
//  WebViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private var url: URL

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        webView.load(URLRequest(url: url))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Show the activity indicator when web content starts loading
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide the activity indicator when web content finishes loading
        activityIndicator.stopAnimating()
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
}
