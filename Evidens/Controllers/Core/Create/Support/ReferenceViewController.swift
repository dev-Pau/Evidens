//
//  ReferencesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class ReferenceViewController: UIViewController {
    
    private let controller: AddPostViewController

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
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.quote)?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        return iv
    }()
    
    private let referenceTitle: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.addFont(size: 26, scaleStyle: .largeTitle, weight: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let referenceDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var referenceWebLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = K.Colors.separatorColor
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .bold, scales: false)
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
        button.configuration?.background.strokeColor = K.Colors.separatorColor
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .bold, scales: false)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.Reference.citationTitle, attributes: container)
        button.addTarget(self, action: #selector(handleAddCitation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        configureNavigationBar()
        configureUI()
    }
    
    init(controller: AddPostViewController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = K.Colors.primaryColor
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        let stack = UIStackView(arrangedSubviews: [referenceTitle, referenceDescription, referenceWebLinkButton, referenceAuthorCitationButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonSize: CGFloat = UIDevice.isPad ? 60.0 : 50.0

        referenceAuthorCitationButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        referenceWebLinkButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        scrollView.addSubviews(stack, referenceImageView)
        
        NSLayoutConstraint.activate([
            referenceImageView.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: -20),
            referenceImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            referenceImageView.heightAnchor.constraint(equalToConstant: buttonSize),
            referenceImageView.widthAnchor.constraint(equalToConstant: buttonSize),
            
            stack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: UIDevice.isPad ? -100 : -40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        referenceTitle.text = AppStrings.Reference.quote
        referenceDescription.text = AppStrings.Reference.quoteContent
    }

    @objc func handleAddWebLink() {
        let controller = AddWebLinkReferenceViewController(controller: controller)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleAddCitation() {
        let controller = AddAuthorReferenceViewController(controller: controller)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
