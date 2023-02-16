//
//  ProfileCompletedViewControllerl.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/2/23.
//

import UIKit

class ProfileCompletedViewController: UIViewController {
    
    private var user: User
    private var viewModel: OnboardingViewModel
    
    private let imageTextLabel: UILabel = {
        let label = CustomLabel(placeholder: "Your profile is updated")
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See profile", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserDefaults()
        configureNavigationBar()
        configureUI()
    }
    
    init(user: User, viewModel: OnboardingViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUserDefaults() {
        if let _ = viewModel.profileImage {
            UserDefaults.standard.set(user.profileImageUrl!, forKey: "userProfileImageUrl")
        }
        if let _ = viewModel.bannerImage {
            UserDefaults.standard.set(user.bannerImageUrl!, forKey: "userProfileBannerUrl")
        }
    }
    
    private func configureNavigationBar() {
       
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
    
        scrollView.addSubviews(imageTextLabel, continueButton)
        
        NSLayoutConstraint.activate([
            imageTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: view.frame.height / 4),
            imageTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageTextLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            
            continueButton.topAnchor.constraint(equalTo: imageTextLabel.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: imageTextLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: imageTextLabel.trailingAnchor)
        ])
    }
    
    @objc func handleContinue() {
        dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("UserUpdateIdentifier"), object: nil, userInfo: ["user": user])
    }
}