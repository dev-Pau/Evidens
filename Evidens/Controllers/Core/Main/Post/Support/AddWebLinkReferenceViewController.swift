//
//  AddReferenceViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit
import WebKit

class AddWebLinkReferenceViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let referenceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let referenceDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private lazy var webLinkTextField: UITextField = {
        let tf = UITextField()
        tf.tintColor = primaryColor
        tf.textColor = primaryColor
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "https://pubmed.ncbi.nlm.nih.gov/28244479/"
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var verifyLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.contentInsets = .zero
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13, weight: .regular)
        button.configuration?.attributedTitle = AttributedString("Tap to verify the link", attributes: container)
        button.configuration?.baseForegroundColor = primaryColor
        button.addTarget(self, action: #selector(handleLinkVerification), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var submitReferenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Add Web Link", attributes: container)
        button.addTarget(self, action: #selector(handleContinueReference), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        
        let stack = UIStackView(arrangedSubviews: [referenceTitleLabel, referenceDescriptionLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        //referenceAuthorCitationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //referenceWebLinkButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.addSubviews(stack, webLinkTextField, separatorView, verifyLinkButton, submitReferenceButton)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            
            webLinkTextField.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            webLinkTextField.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            webLinkTextField.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: webLinkTextField.bottomAnchor, constant: 3),
            separatorView.leadingAnchor.constraint(equalTo: webLinkTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: webLinkTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            verifyLinkButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 5),
            verifyLinkButton.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            
            submitReferenceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            submitReferenceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitReferenceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitReferenceButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        referenceTitleLabel.text = "Web Links"
        referenceDescriptionLabel.text = "By utilizing web links as references, you can ensure proper attribution and demonstrate your commitment to referencing and citing sources accurately, in accordance with evidence-based practice principles. This highlights your dedication to upholding accuracy and professionalism in your content. Some examples may be research articles, scholarly publications, official guidelines, educational videos or any other relevant resources."
    }
    
    @objc func handleLinkVerification() {
        guard let text = webLinkTextField.text else {
            return
        }
        
        if let url = URL(string: text) {
            if UIApplication.shared.canOpenURL(url) {
                let webViewController = WebViewController(url: url)
                //let navigationController = UINavigationController(rootViewController: webViewController)
                present(webViewController, animated: true, completion: nil)
                
            } else {
                let reportPopup = METopPopupView(title: "Apologies, but the URL you entered seems to be incorrect. Please double-check the URL and try again.", image: "exclamationmark.circle.fill", popUpType: .destructive)
                reportPopup.showTopPopup(inView: self.view)
            }
        } else {
            let reportPopup = METopPopupView(title: "Apologies, but the URL you entered seems to be incorrect. Please double-check the URL and try again.", image: "exclamationmark.circle.fill", popUpType: .destructive)
            reportPopup.showTopPopup(inView: self.view)
        }
    }
    
    @objc func textFieldDidChange() {
        guard let text = webLinkTextField.text else {
            verifyLinkButton.isEnabled = false
            submitReferenceButton.isEnabled = false
            return
        }
        
        guard !text.isEmpty else {
            submitReferenceButton.isEnabled = false
            verifyLinkButton.isEnabled = false
            return
        }
        
        submitReferenceButton.isEnabled = true
        verifyLinkButton.isEnabled = true
    }
    
    @objc func handleContinueReference() {
        guard let text = webLinkTextField.text else {
            return
        }
        
        if let url = URL(string: text) {
            if UIApplication.shared.canOpenURL(url) {
                let reference = Reference(option: .link, referenceText: text)
                NotificationCenter.default.post(name: NSNotification.Name("PostReference"), object: nil, userInfo: ["reference": reference])
                
            } else {
                let reportPopup = METopPopupView(title: "Apologies, but the URL you entered seems to be incorrect", image: "exclamationmark.circle.fill", popUpType: .destructive)
                reportPopup.showTopPopup(inView: self.view)
            }
        } else {
            let reportPopup = METopPopupView(title: "Apologies, but the URL you entered seems to be incorrect", image: "exclamationmark.circle.fill", popUpType: .destructive)
            reportPopup.showTopPopup(inView: self.view)
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
