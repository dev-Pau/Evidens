//
//  BanAccountViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/8/23.
//

import UIKit
import MessageUI

class BanAccountViewController: UIViewController {
    
    private let viewModel: BanAccountViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let passwordLabel: UILabel  = {
        let label = PrimaryLabel(placeholder: AppStrings.Opening.banAccount)
            return label
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.isEditable = false
        tv.font = UIFont.addFont(size: 16.0, scaleStyle: .title1, weight: .regular)
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var activateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Miscellaneous.gotIt, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont.addFont(size: 18, scaleStyle: .body, weight: .bold, scales: false)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    init(user: User) {
        self.viewModel = BanAccountViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(passwordLabel, activateButton, contentTextView)
        
        NSLayoutConstraint.activate([
            passwordLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentTextView.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            contentTextView.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            
            activateButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 30),
            activateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            activateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            activateButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        contentTextView.delegate = self
        contentTextView.attributedText = viewModel.banText
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
        logout()
        let controller = OpeningViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory) {
                guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate else {
                    return
                }

                sceneDelegate.updateViewController(ContainerViewController(withLoadingView: true))
            }
        }
    }
}

extension BanAccountViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let urlString = url.absoluteString
        if urlString == AppStrings.Opening.banContent {
            if MFMailComposeViewController.canSendMail() {
                let controller = MFMailComposeViewController()
                controller.setToRecipients([AppStrings.App.contactMail])
                controller.mailComposeDelegate = self
                present(controller, animated: true)
            } else {
                return false
            }
            
            return true
        }
        
        return false
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}

extension BanAccountViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}
    




