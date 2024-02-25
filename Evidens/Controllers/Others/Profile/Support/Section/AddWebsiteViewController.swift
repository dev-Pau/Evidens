//
//  AddWebsiteViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/11/23.
//

import UIKit

protocol AddWebsiteViewControllerDelegate: AnyObject {
    func handleUpdateWebsite()
}

class AddWebsiteViewController: UIViewController {
    
    private var aboutButton: UIButton!
    private var skipButton: UIButton!

    weak var delegate: AddWebsiteViewControllerDelegate?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .none
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Sections.websiteContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var websiteTextField: UITextField = {
        let tf = UITextField()
        tf.tintColor = primaryColor
        tf.textColor = primaryColor
        tf.clearButtonMode = .whileEditing
        tf.autocapitalizationType = .none
        tf.placeholder = AppStrings.URL.url
        tf.autocorrectionType = .no
        tf.keyboardType = .URL
        tf.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
        getWebsite()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        websiteTextField.becomeFirstResponder()
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Sections.websiteSection
    }
    
    private func getWebsite() {
        guard let uid = UserDefaults.getUid() else { return }
        DatabaseManager.shared.fetchWebsite(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let about):
                strongSelf.websiteTextField.text = about
                strongSelf.websiteTextField.tintColor = primaryColor
                strongSelf.websiteTextField.textColor = primaryColor
            case .failure(let error):
                strongSelf.websiteTextField.text = ""
                guard error == .empty else {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    return
                }
            }
        }
    }
    
    private func configure() {
        
        view.backgroundColor = .systemBackground
        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(contentLabel, websiteTextField)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            websiteTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            websiteTextField.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            websiteTextField.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
        ])
        
        websiteTextField.inputAccessoryView = addToolbar()
    }
    
    private func addToolbar() -> UIToolbar {
        let toolbar = UIToolbar()

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let appearance = UIToolbarAppearance()

        appearance.configureWithOpaqueBackground()
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        
        aboutButton = UIButton(type: .system)
        aboutButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        
        skipButton = UIButton(type: .system)
        skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.baseBackgroundColor = primaryColor
        shareConfig.baseForegroundColor = .white
        var shareContainer = AttributeContainer()
        shareContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .semibold, scales: false)
        shareConfig.attributedTitle = AttributedString(AppStrings.Global.save, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular, scales: false)
        cancelConfig.attributedTitle = AttributedString(AppStrings.Miscellaneous.goBack, attributes: cancelContainer)
        cancelConfig.buttonSize = .mini
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        aboutButton.configuration = shareConfig
        
        skipButton.configuration = cancelConfig
        let rightButton = UIBarButtonItem(customView: aboutButton)

        let leftButton = UIBarButtonItem(customView: skipButton)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        toolbar.setItems([leftButton, flexibleSpace, rightButton], animated: false)
        toolbar.layoutIfNeeded()
        aboutButton.isEnabled = false
                
        return toolbar
    }
    
    private func addWebsite() {
        showProgressIndicator(in: view)
        websiteTextField.resignFirstResponder()
        
        guard let text = websiteTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            DatabaseManager.shared.addWebsite(withUrl: "") { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                
                if let _ = error {
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.websiteTextField.becomeFirstResponder()
                    }
                } else {
                    strongSelf.delegate?.handleUpdateWebsite()
                    strongSelf.navigationController?.popViewController(animated: true)
                    
                    let popupView = PopUpBanner(title: AppStrings.PopUp.websiteRemoved, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popupView.showTopPopup(inView: strongSelf.view)
                }
            }
            return
        }
        
        let link = text.processWebLink()
        
        if let url = URL(string: link), var host = url.host {
            if host.hasPrefix("www.") {
                host = String(host.dropFirst(4))
            }
            
            DatabaseManager.shared.addWebsite(withUrl: host) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                
                if let _ = error {
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.websiteTextField.becomeFirstResponder()
                    }
                } else {
                    strongSelf.delegate?.handleUpdateWebsite()
                    strongSelf.navigationController?.popViewController(animated: true)
                    
                    let popupView = PopUpBanner(title: AppStrings.PopUp.websiteAdded, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popupView.showTopPopup(inView: strongSelf.view)
                }
            }
            
        } else {
            dismissProgressIndicator()
        }
    }
    
    @objc func textFieldDidChange() {
        guard let text = websiteTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            aboutButton.isEnabled = true
            return
        }
        
        let link = text.processWebLink()
        
        if let url = URL(string: link), UIApplication.shared.canOpenURL(url), let host = url.host {

            let trimUrl = host.split(separator: ".")
            
            if let tld = trimUrl.last, String(tld).uppercased().isDomainExtension() {
                websiteTextField.tintColor = primaryColor
                websiteTextField.textColor = primaryColor
                aboutButton.isEnabled = true
            } else {
                websiteTextField.tintColor = .label
                websiteTextField.textColor = .label
                aboutButton.isEnabled = false
            }
        } else {
            websiteTextField.tintColor = .label
            websiteTextField.textColor = .label
            aboutButton.isEnabled = false
        }
    }
    
    @objc func handleContinue() {
        addWebsite()
    }
    
    @objc func handleSkip() {
        websiteTextField.resignFirstResponder()
        
        navigationController?.popViewController(animated: true)
    }
}

extension AddWebsiteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        return true
    }
}
