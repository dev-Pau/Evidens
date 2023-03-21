//
//  PollConfiguratorViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/7/22.
//

import UIKit

class PollConfigurationViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "What do you want to ask?"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var descriptionTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Ask a question..."
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tv.placeholderLabel.textColor = UIColor(white: 0.2, alpha: 0.7)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = blackColor
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.backgroundColor = lightColor
        tv.tintColor = primaryColor
        
        tv.layer.cornerRadius = 5
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        title = "Create Poll"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(handleAddPoll))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        //navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        scrollView.addSubviews(descriptionLabel, descriptionTextView, topSeparatorView)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            topSeparatorView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            topSeparatorView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionTextView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor)
            
            
        ])
    }
    
    @objc func handleAddPoll() {
        
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension PollConfigurationViewController: UITextViewDelegate {
    
}
