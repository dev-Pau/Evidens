//
//  AboutSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/8/22.
//

import UIKit

class AboutSectionViewController: UIViewController {
    
    private let user: User
    private let section: String
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: "")
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    init(user: User, section: String) {
        self.user = user
        self.section = section
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        titleLabel.text = AppStrings.Sections.aboutSection + " " + user.firstName!
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(titleLabel, contentLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
        
        contentLabel.text = section
    }
}

