//
//  ContactUsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/6/23.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 16.0, scaleStyle: .title3, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.SideMenu.contact, attributes: container)
        button.addTarget(self, action: #selector(handleContact), for: .touchUpInside)
        return button
    }()
    
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "   " + AppStrings.Opening.or + "   "
        label.font = UIFont.addFont(size: 12.0, scaleStyle: .title1, weight: .semibold)
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let supportLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 16.0, scaleStyle: .title3, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    
    private lazy var supportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.adjustsImageSizeForAccessibilityContentSizeCategory = false
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = .secondaryLabel
        
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.docOnDoc, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        button.configuration?.imagePlacement = .trailing
        button.configuration?.imagePadding = 10
        button.addTarget(self, action: #selector(handleCopyMail), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }

    private func configureNavigationBar() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.addSubviews(contentLabel, contactButton, separatorView, orLabel, supportLabel,  supportButton)
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contactButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            contactButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contactButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contactButton.heightAnchor.constraint(equalToConstant: 50),
            
            separatorView.topAnchor.constraint(equalTo: contactButton.bottomAnchor, constant: 20),
            separatorView.leadingAnchor.constraint(equalTo: contactButton.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: contactButton.trailingAnchor, constant: -20),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            orLabel.centerXAnchor.constraint(equalTo: separatorView.centerXAnchor),
            orLabel.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),
            
            supportLabel.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 10),
            supportLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            supportLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            supportButton.topAnchor.constraint(equalTo: supportLabel.bottomAnchor, constant: 20),
            supportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            supportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            supportButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        contentLabel.text = AppStrings.App.assistance
        supportLabel.text = AppStrings.Settings.copy
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .bold, scales: false)
        container.foregroundColor = .label
        
        #if DEBUG
        supportButton.configuration?.attributedTitle = AttributedString(AppStrings.App.personalMail, attributes: container)
        #else
        supportButton.configuration?.attributedTitle = AttributedString(AppStrings.App.contactMail, attributes: container)
        #endif
    }
    
    private func configure() {
        title = AppStrings.SideMenu.contact
    }
    
    @objc func handleContact() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            
            #if DEBUG
            controller.setToRecipients([AppStrings.App.personalMail])
            #else
            controller.setToRecipients([AppStrings.App.contactMail])
            #endif
            
            controller.setSubject(AppStrings.Global.help)
            self.present(controller, animated: true)
        }
    }
    
    @objc func handleCopyMail() {
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: false)
        HapticsManager.shared.triggerWarningHaptic()
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .bold, scales: false)
        container.foregroundColor = .label
        supportButton.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.capsCopied, attributes: container)
        supportButton.configuration?.image = nil
        
        let pasteboard = UIPasteboard.general
        
        #if DEBUG
        pasteboard.string = AppStrings.App.personalMail
        UIPasteboard.general.string = AppStrings.App.personalMail
        #else
        pasteboard.string = AppStrings.App.contactMail
        UIPasteboard.general.string = AppStrings.App.contactMail
        #endif
    }
    
    @objc func fireTimer() {

        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .bold, scales: false)
        container.foregroundColor = .label
        
        #if DEBUG
        supportButton.configuration?.attributedTitle = AttributedString(AppStrings.App.personalMail, attributes: container)
        #else
        supportButton.configuration?.attributedTitle = AttributedString(AppStrings.App.contactMail, attributes: container)
        #endif
        
        supportButton.configuration?.image = UIImage(systemName: AppStrings.Icons.docOnDoc, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
    }
}

extension ContactUsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
