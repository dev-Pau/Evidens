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
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Profile.updated)
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Profile.see, for: .normal)
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
            UserDefaults.standard.set(user.profileUrl!, forKey: "profileUrl")
        }
        if let _ = viewModel.bannerImage {
            UserDefaults.standard.set(user.bannerUrl!, forKey: "bannerUrl")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("UserUpdateIdentifier"), object: nil, userInfo: ["user": user])
    }
    
    private func configureNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
    
        scrollView.addSubviews(titleLabel, continueButton)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -topbarHeight),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            continueButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    @objc func handleContinue() {
        dismiss(animated: true)
    }
}
