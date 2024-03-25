//
//  NotificationTargetViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

protocol NotificationTargetViewControllerDelegate: AnyObject {
    func didToggle(topic: NotificationTopic, _ value: Bool)
    func didChange(topic: NotificationTopic, for target: NotificationTarget)
}

class NotificationTargetViewController: UIViewController {
    
    weak var delegate: NotificationTargetViewControllerDelegate?

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
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 13.0, scaleStyle: .title1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
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
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    private let targetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 13.0, scaleStyle: .title1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private var followingView: NotificationTargetView!
    private var anyoneView: NotificationTargetView!
    private var stackView: UIStackView!

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
        uiSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        followingView = NotificationTargetView(title: AppStrings.Notifications.Settings.myNetwork, isOn: target == .follow ? true : false)
        anyoneView = NotificationTargetView(title: AppStrings.Notifications.Settings.anyone, isOn: target == .anyone ? true : false)
        
        followingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        anyoneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        
        stackView = UIStackView(arrangedSubviews: [separator, followingView, anyoneView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = K.Paddings.Settings.verticalPadding
        stackView.alignment = .leading
        
        scrollView.addSubviews(contentLabel, titleLabel, uiSwitch, stackView, targetLabel)

        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: K.Paddings.Settings.verticalPadding),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: K.Paddings.Settings.horizontalPadding),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            
            uiSwitch.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: K.Paddings.Settings.verticalPadding),
            uiSwitch.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: uiSwitch.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: uiSwitch.leadingAnchor, constant: -10),
            
            stackView.topAnchor.constraint(equalTo: uiSwitch.bottomAnchor, constant: K.Paddings.Settings.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            targetLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            targetLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            targetLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            separator.heightAnchor.constraint(equalToConstant: 0.4),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            followingView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            followingView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            
            anyoneView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            anyoneView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor)
        ])
        
        contentLabel.text = topic.content
        titleLabel.text = topic.title
        uiSwitch.isOn = isOn
        targetLabel.text = topic.target
        
        if !isOn {
            targetLabel.alpha = 0
            stackView.alpha = 0
            stackView.isUserInteractionEnabled = false
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        
        switch topic {
        case .replies:
            NotificationService.set("reply", "value", sender.isOn) { [weak self] error in
                guard let strongSelf = self else { return }
                if let _ = error {
                    strongSelf.uiSwitch.isOn.toggle()
                }
            }
            
        case .likes:
            NotificationService.set("like", "value", sender.isOn) { [weak self] error in
                guard let strongSelf = self else { return }
                if let _ = error {
                    strongSelf.uiSwitch.isOn.toggle()
                }
            }
            
        case .connections, .cases: break
            
        }
        
        delegate?.didToggle(topic: topic, sender.isOn)
        
        if sender.isOn {
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.stackView.alpha = 1
                strongSelf.targetLabel.alpha = 1
                strongSelf.stackView.isUserInteractionEnabled = true
            }
        } else {
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.stackView.alpha = 0
                strongSelf.targetLabel.alpha = 0
                strongSelf.stackView.isUserInteractionEnabled = false
            }
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        let tappedView = gestureRecognizer.view
        
        if tappedView == followingView {
            if followingView.isOn == true { return }
        } else {
            if anyoneView.isOn == true { return }
        }

        followingView.set(isOn: tappedView == followingView ? true : false)
        anyoneView.set(isOn: tappedView == anyoneView ? true : false)
        
        switch topic {
        case .replies:
            NotificationService.set("reply", "target", tappedView == followingView ? NotificationTarget.follow.rawValue : NotificationTarget.anyone.rawValue) { [weak self] error in
                guard let strongSelf = self else { return }
                if let _ = error {
                    strongSelf.followingView.set(isOn: tappedView == strongSelf.followingView ? false : true)
                    strongSelf.anyoneView.set(isOn: tappedView == strongSelf.anyoneView ? false : true)
                    return
                } else {
                    strongSelf.delegate?.didChange(topic: strongSelf.topic, for: tappedView == strongSelf.followingView ? NotificationTarget.follow : NotificationTarget.anyone)
                }
            }

        case .likes:
            NotificationService.set("like", "target", tappedView == followingView ? NotificationTarget.follow.rawValue : NotificationTarget.anyone.rawValue) { [weak self] error in
                guard let strongSelf = self else { return }
                if let _ = error {
                    strongSelf.followingView.set(isOn: tappedView == strongSelf.followingView ? false : true)
                    strongSelf.anyoneView.set(isOn: tappedView == strongSelf.anyoneView ? false : true)
                    return
                } else {
                    strongSelf.delegate?.didChange(topic: strongSelf.topic, for: tappedView == strongSelf.followingView ? NotificationTarget.follow : NotificationTarget.anyone)
                }
            }
        case .connections, .cases: break
        }
        
    }
}
