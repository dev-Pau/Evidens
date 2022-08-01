//
//  AddSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

class AddSectionViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.text = "Your about me section briefly summarize the most important information you want the community to know from you. It can be used to showcase your professional experience, skills, your professional brand or any other information you want to share."
        return label
    }()
    
    
    private lazy var aboutTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add about here"
        tv.placeholderLabel.font = .systemFont(ofSize: 15, weight: .regular)
        tv.placeholderLabel.textColor = UIColor(white: 0.2, alpha: 0.7)
        tv.font = .systemFont(ofSize: 15, weight: .regular)
        tv.textColor = .black
        //tv.delegate = self
        tv.isScrollEnabled = true
        tv.backgroundColor = lightColor
        tv.layer.cornerRadius = 5
        //tv.layer.borderWidth = 1
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureUI() {
        //NotificationCenter.addObserver(<#T##self: NotificationCenter##NotificationCenter#>)
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        scrollView.addSubviews(infoLabel, aboutTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            aboutTextView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
            aboutTextView.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
            aboutTextView.trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor),
            aboutTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func handleDone() {
        print("Update About")
    }
}
