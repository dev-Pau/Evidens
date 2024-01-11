//
//  ShareCaseReviewViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/1/24.
//

import UIKit

class ShareCaseReviewViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let reviewLabel: UILabel  = {
        let label = PrimaryLabel(placeholder: AppStrings.Opening.sentCase)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 16.0, scaleStyle: .title1, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var greatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Miscellaneous.exclamationGreat, for: .normal)
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
    
    private func configureNavigationBar() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(reviewLabel, greatButton, contentLabel)
        
        NSLayoutConstraint.activate([
            reviewLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            reviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: reviewLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: reviewLabel.trailingAnchor),
            
            greatButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 30),
            greatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            greatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            greatButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        contentLabel.text = AppStrings.Content.Case.Share.sentCaseContent
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
