//
//  ReferencesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class ReferencesViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let referenceImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "note")?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        return iv
    }()
    
    private let referenceTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let referenceDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var referenceWebLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = separatorColor
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString("Web Links", attributes: container)
        button.addTarget(self, action: #selector(handleAddWebLink), for: .touchUpInside)
        return button
    }()
    
    private lazy var referenceAuthorCitationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = separatorColor
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString("Citation with Authors", attributes: container)
        button.addTarget(self, action: #selector(handleAddCitation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        
        let stack = UIStackView(arrangedSubviews: [referenceTitle, referenceDescription, referenceWebLinkButton, referenceAuthorCitationButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        referenceAuthorCitationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        referenceWebLinkButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.addSubviews(stack, referenceImageView)
        
        NSLayoutConstraint.activate([
            referenceImageView.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: -20),
            referenceImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            referenceImageView.heightAnchor.constraint(equalToConstant: 50),
            referenceImageView.widthAnchor.constraint(equalToConstant: 50),
            
            stack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -40),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: view.frame.width - 40)
        ])
        
        referenceTitle.text = "Quote"
        referenceDescription.text = "Our content sharing system places a strong emphasis on the use of scientific evidence to support your content. You can easily and accurately add quotes to your content using two referencing options: web links or author references.\n\nBy using these referencing options, you can ensure proper attribution and support your content with credible sources, helping to maintain accuracy, credibility, and professionalism. This demonstrates your commitment to referencing and citing sources accurately in accordance with evidence-based practice principles, promoting best practices in the healthcare sector."
    }

    @objc func handleAddWebLink() {
        let controller = AddWebLinkReferenceViewController()
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleAddCitation() {
        let controller = AddAuthorReferenceViewController()
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
