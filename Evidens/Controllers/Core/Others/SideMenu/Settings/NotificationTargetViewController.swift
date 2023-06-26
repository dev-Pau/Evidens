//
//  NotificationTargetViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

class NotificationTargetViewController: UIViewController {

    private let topic: NotificationTopic
    private let isOn: Bool
    private let target: NotificationTarget
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let uiSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let targetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private var followingView: NotificationTargetView!
    private var anyoneView: NotificationTargetView!

    init(topic: NotificationTopic, isOn: Bool, target: NotificationTarget) {
        self.topic = topic
        self.isOn = isOn
        self.target = target
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        title = topic.title
    }
    
    private func configure() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
       
        uiSwitch.isOn = isOn
        followingView = NotificationTargetView(title: "My Network", isOn: target == .follow ? true : false)
        anyoneView = NotificationTargetView(title: "From Anyone", isOn: target == .anyone ? true : false)
        
        followingView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followingView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        anyoneView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        anyoneView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.4).isActive = true
        separator.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [separator, followingView, anyoneView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.alignment = .leading
        
        scrollView.addSubviews(contentLabel, titleLabel, uiSwitch, stackView, targetLabel)

        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            uiSwitch.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            uiSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            titleLabel.centerYAnchor.constraint(equalTo: uiSwitch.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: uiSwitch.leadingAnchor, constant: -10),
            
            stackView.topAnchor.constraint(equalTo: uiSwitch.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            targetLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            targetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            targetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
        
        contentLabel.text = topic.content
        titleLabel.text = topic.title
        uiSwitch.isOn = isOn
        targetLabel.text = topic.target
        
        if !isOn {
            stackView.isHidden = true
            targetLabel.isHidden = true
        }
    }
}
