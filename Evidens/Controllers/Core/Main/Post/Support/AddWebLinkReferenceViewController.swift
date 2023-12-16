//
//  AddReferenceViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit
import WebKit

protocol AddWebLinkReferenceDelegate: AnyObject {
    func didTapDeleteReference()
}

class AddWebLinkReferenceViewController: UIViewController {
    
    weak var delegate: AddWebLinkReferenceDelegate?
    
    private var reference: Reference?
    private var referenceButton: UIButton!
    private var cancelButton: UIButton!
    
    private var link = ""
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .none
        return scrollView
    }()
    
    private let referenceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 25, scaleStyle: .largeTitle, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let referenceDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
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
        tf.autocapitalizationType = .none
        tf.placeholder = AppStrings.URL.pubmed
        tf.keyboardType = .URL
        tf.autocorrectionType = .no
        tf.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
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
        container.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Reference.verify, attributes: container)
        button.configuration?.baseForegroundColor = primaryColor
        button.addTarget(self, action: #selector(handleLinkVerification), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(reference: Reference? = nil) {
        self.reference = reference
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webLinkTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        webLinkTextField.becomeFirstResponder()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: primaryColor)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.frame = view.frame
        webLinkTextField.delegate = self
        let stack = UIStackView(arrangedSubviews: [referenceTitleLabel, referenceDescriptionLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack, webLinkTextField, separatorView, verifyLinkButton)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            webLinkTextField.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            webLinkTextField.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            webLinkTextField.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: webLinkTextField.bottomAnchor, constant: 3),
            separatorView.leadingAnchor.constraint(equalTo: webLinkTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: webLinkTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            verifyLinkButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 5),
            verifyLinkButton.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
        ])
        
        referenceTitleLabel.text = AppStrings.Reference.webLinks
        referenceDescriptionLabel.text = AppStrings.Reference.linkEvidence
        webLinkTextField.inputAccessoryView = addDiagnosisToolbar()
        cancelButton.isHidden = true
        
        if let reference = reference {
            webLinkTextField.text = reference.referenceText
            verifyLinkButton.isEnabled = false
            cancelButton.isEnabled = true
            cancelButton.isHidden = false
        }
    }
    
    @objc func handleLinkVerification() {
        if let url = URL(string: link) {
            if UIApplication.shared.canOpenURL(url) {
                presentSafariViewController(withURL: url)
            } else {
                presentWebViewController(withURL: url)
            }
        }
    }
    
    private func addDiagnosisToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        referenceButton = UIButton(type: .system)
        referenceButton.addTarget(self, action: #selector(addReference), for: .touchUpInside)
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(removeReference), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.baseBackgroundColor = primaryColor
        shareConfig.baseForegroundColor = .white
        var shareContainer = AttributeContainer()
        shareContainer.font = UIFont.addFont(size: 14, scaleStyle: .body, weight: .semibold, scales: false)
        
        shareConfig.attributedTitle = AttributedString(AppStrings.Global.add, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = UIFont.addFont(size: 14, scaleStyle: .body, weight: .regular, scales: false)
        cancelConfig.attributedTitle = AttributedString(AppStrings.Actions.remove, attributes: cancelContainer)
        cancelConfig.buttonSize = .mini
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        referenceButton.configuration = shareConfig
        
        cancelButton.configuration = cancelConfig
        let rightButton = UIBarButtonItem(customView: referenceButton)
        
        let leftButton = UIBarButtonItem(customView: cancelButton)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([leftButton, flexibleSpace, rightButton], animated: false)
        
        referenceButton.isEnabled = false
        
        return toolbar
    }
    
    
    @objc func textFieldDidChange() {
        
        guard let text = webLinkTextField.text else {
            webLinkTextField.tintColor = .label
            webLinkTextField.textColor = .label
            referenceButton.isEnabled = false
            verifyLinkButton.isEnabled = false
            return
        }
        
        link = text.processWebLink()
        
        if let url = URL(string: link), UIApplication.shared.canOpenURL(url), let host = url.host {

            let trimUrl = host.split(separator: ".")
            
            if let tld = trimUrl.last, String(tld).uppercased().isDomainExtension() {
                
                webLinkTextField.tintColor = primaryColor
                webLinkTextField.textColor = primaryColor
                referenceButton.isEnabled = true
                verifyLinkButton.isEnabled = true
            } else {
                
                webLinkTextField.tintColor = .label
                webLinkTextField.textColor = .label
                referenceButton.isEnabled = false
                verifyLinkButton.isEnabled = false
            }
        } else {
            
            webLinkTextField.tintColor = .label
            webLinkTextField.textColor = .label
            referenceButton.isEnabled = false
            verifyLinkButton.isEnabled = false
        }
    }
    
    @objc func addReference() {
        let reference = Reference(option: .link, referenceText: link)
        NotificationCenter.default.post(name: NSNotification.Name("PostReference"), object: nil, userInfo: ["reference": reference])
        dismiss(animated: true)
    }
    
    @objc func removeReference() {
        delegate?.didTapDeleteReference()
        dismiss(animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension AddWebLinkReferenceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        return true
    }
}
