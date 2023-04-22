//
//  AddReferenceViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class AddAuthorReferenceViewController: UIViewController {
    private var firstTimeTap: Bool = true
    
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
    
    private lazy var authorCitationTextView: UITextView = {
        let tf = UITextView()
        tf.tintColor = primaryColor
        tf.textColor = UIColor.lightGray
        tf.text = "Roy, P S, and B J Saikia. “Cancer and cure: A critical analysis.” Indian journal of cancer vol. 53,3 (2016): 441-442. doi:10.4103/0019-509X.200658"
        tf.textContainerInset = UIEdgeInsets.zero
        tf.contentInset = UIEdgeInsets.zero
        tf.textContainer.lineFragmentPadding = .zero
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.isScrollEnabled = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
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
        button.configuration?.attributedTitle = AttributedString("Add Author Citation", attributes: container)
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
        
        var textViewHeight = 120.0
        if let lineHeight = authorCitationTextView.font?.lineHeight {
            textViewHeight = lineHeight * 7
        }
        //referenceAuthorCitationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //referenceWebLinkButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.addSubviews(stack, authorCitationTextView, separatorView, submitReferenceButton)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            
            authorCitationTextView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            authorCitationTextView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            authorCitationTextView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            authorCitationTextView.heightAnchor.constraint(equalToConstant: textViewHeight),
            
            submitReferenceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            submitReferenceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitReferenceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitReferenceButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        referenceTitleLabel.text = "Citation with Authors"
        referenceDescriptionLabel.text = "Enhance your content with credible sources! Add proper citations with authors to give credit where it's due and strengthen the reliability of your post. Including reputable authors in your references showcases your commitment to accurate and trustworthy information, while upholding academic integrity and professionalism. Examples of sources with authors may include research papers, scholarly articles, official reports, expert opinions, and other reputable publications."
        authorCitationTextView.delegate = self
    }
    
    @objc func handleContinueReference() {
        guard let text = authorCitationTextView.text, !text.isEmpty else { return }
        let reference = Reference(option: .reference, referenceText: text)
        NotificationCenter.default.post(name: NSNotification.Name("PostReference"), object: nil, userInfo: ["reference": reference])
    }

    /*
    @objc func handleContinueReference() {
        guard let text = webLinkTextField.text else {
            return
        }
        
        if let url = URL(string: text) {
            if UIApplication.shared.canOpenURL(url) {
                
                NotificationCenter.default.post(name: NSNotification.Name("PostReferenceWebLink"), object: nil, userInfo: ["link": text])
                
            } else {
                let reportPopup = METopPopupView(title: "Apologies, but the URL you entered seems to be incorrect. Please double-check the URL and try again.", image: "exclamationmark.circle.fill", popUpType: .destructive)
                reportPopup.showTopPopup(inView: self.view)
            }
        } else {
            let reportPopup = METopPopupView(title: "Apologies, but the URL you entered seems to be incorrect", image: "exclamationmark.circle.fill", popUpType: .destructive)
            reportPopup.showTopPopup(inView: self.view)
        }
    }
     */
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension AddAuthorReferenceViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if firstTimeTap {
            textView.text = ""
            textView.tintColor = primaryColor
            textView.textColor = primaryColor
            firstTimeTap.toggle()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.isScrollEnabled = false
            textView.textColor = UIColor.lightGray
            textView.text = "Roy, P S, and B J Saikia. “Cancer and cure: A critical analysis.” Indian journal of cancer vol. 53,3 (2016): 441-442. doi:10.4103/0019-509X.200658"
            firstTimeTap.toggle()
        }
    }
}
