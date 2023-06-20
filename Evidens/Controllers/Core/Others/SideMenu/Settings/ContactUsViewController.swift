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
    
    private let contactTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let contactDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
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
        container.font = .systemFont(ofSize: 18, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Contact Us", attributes: container)
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
        label.text = " OR "
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let supportLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    
    private lazy var supportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = .secondaryLabel
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.App.contactMail, attributes: container)
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
        scrollView.addSubviews(contactTitleLabel, contactDescriptionLabel, contactButton, separatorView, orLabel, supportLabel,  supportButton)
        
        NSLayoutConstraint.activate([
            contactTitleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contactTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contactTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contactDescriptionLabel.topAnchor.constraint(equalTo: contactTitleLabel.bottomAnchor, constant: 10),
            contactDescriptionLabel.leadingAnchor.constraint(equalTo: contactTitleLabel.leadingAnchor),
            contactDescriptionLabel.trailingAnchor.constraint(equalTo: contactTitleLabel.trailingAnchor),
            
            contactButton.topAnchor.constraint(equalTo: contactDescriptionLabel.bottomAnchor, constant: 20),
            contactButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contactButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contactButton.heightAnchor.constraint(equalToConstant: 50),
            
            separatorView.topAnchor.constraint(equalTo: contactButton.bottomAnchor, constant: 20),
            separatorView.leadingAnchor.constraint(equalTo: contactButton.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contactButton.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            orLabel.centerXAnchor.constraint(equalTo: separatorView.centerXAnchor),
            orLabel.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),
            
            supportLabel.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 10),
            supportLabel.leadingAnchor.constraint(equalTo: contactTitleLabel.leadingAnchor),
            supportLabel.trailingAnchor.constraint(equalTo: contactTitleLabel.trailingAnchor),
            
            supportButton.topAnchor.constraint(equalTo: supportLabel.bottomAnchor, constant: 10),
            supportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            supportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            supportButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        contactTitleLabel.text = "We can help."
        contactDescriptionLabel.text = "We're here to provide support and assistance for any questions or concerns you may have. Please let us know how we can assist you further."
        supportLabel.text = "Easily copy our email by tapping it."
    }
    
    private func configure() {
        title = "Contact Us"
    }
    
    @objc func handleContact() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setToRecipients([AppStrings.App.contactMail])
            controller.setSubject("Help")
            self.present(controller, animated: true)
        } else {
            print("Device cannot send email")
        }
    }
    
    @objc func handleCopyMail() {
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: false)
        HapticsManager.shared.vibrate(for: .success)
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        container.foregroundColor = .label
        supportButton.configuration?.attributedTitle = AttributedString("COPIED", attributes: container)
        supportButton.configuration?.image = nil
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = AppStrings.App.contactMail
        UIPasteboard.general.string = AppStrings.App.contactMail
    }
    
    @objc func fireTimer() {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        container.foregroundColor = .label
        supportButton.configuration?.attributedTitle = AttributedString(AppStrings.App.contactMail, attributes: container)
        supportButton.configuration?.image = UIImage(systemName: AppStrings.Icons.docOnDoc, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
    }
}

extension ContactUsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}