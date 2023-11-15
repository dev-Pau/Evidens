//
//  ReferencesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class ReferenceViewController: UIViewController {

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
        //iv.image = UIImage(systemName: AppStrings.Icons.fillHeart, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        iv.image = UIImage(named: AppStrings.Assets.quote)?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
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
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
        button.configuration?.attributedTitle = AttributedString(AppStrings.Reference.linkTitle, attributes: container)
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
        button.configuration?.attributedTitle = AttributedString(AppStrings.Reference.citationTitle, attributes: container)
        button.addTarget(self, action: #selector(handleAddCitation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        configureNavigationBar()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        let stack = UIStackView(arrangedSubviews: [referenceTitle, referenceDescription, referenceWebLinkButton, referenceAuthorCitationButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        referenceAuthorCitationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        referenceWebLinkButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.addSubviews(stack, referenceImageView)
        
        NSLayoutConstraint.activate([
            referenceImageView.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: -20),
            referenceImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            referenceImageView.heightAnchor.constraint(equalToConstant: 50),
            referenceImageView.widthAnchor.constraint(equalToConstant: 50),
            
            stack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        referenceTitle.text = AppStrings.Reference.quote
        referenceDescription.text = AppStrings.Reference.quoteContent
    }

    @objc func handleAddWebLink() {
        let controller = AddWebLinkReferenceViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleAddCitation() {
        let controller = AddAuthorReferenceViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
