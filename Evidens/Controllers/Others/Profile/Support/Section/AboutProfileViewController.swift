//
//  AboutProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/2/24.
//

import UIKit

class AboutProfileViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    
    private let viewModel: UserProfileViewModel

    private let aboutLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemFill
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    init(viewModel: UserProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false

        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(separator, aboutLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            separator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separator.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 40),
            
            aboutLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 20),
            aboutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            aboutLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
        
        scrollView.contentSize.width = view.frame.width
        separator.layer.cornerRadius = 3
        
        aboutLabel.text = viewModel.about
        scrollView.resizeContentSize()
    }
}
