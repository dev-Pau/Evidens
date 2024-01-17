//
//  WaitingVerificationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/8/22.
//

import UIKit
import PhotosUI

class ReviewViewController: UIViewController {
    private var user: User

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private var titleLabel: UILabel!
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Miscellaneous.gotIt, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont.addFont(size: 18, scaleStyle: .body, weight: .bold, scales: false)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance

        appearance.shadowImage = nil
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
   
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configure() {

        #if DEBUG
        user.phase = .verified
        titleLabel = PrimaryLabel(placeholder: AppStrings.Debug.finishRegister)
        contentLabel.text = AppStrings.Debug.finishRegisterContent
        #else
        user.phase = .review
        titleLabel = PrimaryLabel(placeholder: AppStrings.Miscellaneous.allGood)
        contentLabel.text = AppStrings.Opening.finishRegister
        #endif

        setUserDefaults(for: user)
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel, continueButton])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 20
        
        scrollView.addSubviews(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }
    
    @objc func handleContinue() {
        let controller = ContainerViewController()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false)
    }
}
