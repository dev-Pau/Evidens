//
//  UserChangesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/6/23.
//

import UIKit

class UserChangesViewController: UIViewController {
    private let change: UserChange

    private lazy var titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: change.title)
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = change.content
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
        button.setTitle(change.hint, for: .normal)
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
        configureNavigationBar()
        configureUI()
    }
    
    init(change: UserChange) {
        self.change = change
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
    }
    
    private func configureUI() {
        if change == .deactivate {
            AuthService.logout()
            AuthService.googleLogout()
        }

        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 10
        
        let bottomStack = UIStackView(arrangedSubviews: [stack, continueButton])
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.alignment = .leading
        bottomStack.distribution = .fill
        bottomStack.axis = .vertical
        bottomStack.spacing = 20
    
        scrollView.addSubview(bottomStack)
        NSLayoutConstraint.activate([
            bottomStack.bottomAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -30),
            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            continueButton.widthAnchor.constraint(equalToConstant: view.frame.width - 40)
        ])
    }
    
    @objc func handleContinue() {
        switch change {
        case .email, .password:
            dismiss(animated: true)
        case .deactivate:
            let controller = OpeningViewController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
}
