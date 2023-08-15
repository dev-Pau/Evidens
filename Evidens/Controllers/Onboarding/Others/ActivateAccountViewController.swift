//
//  AccountActivationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/6/23.
//

import UIKit

class ActivateAccountViewController: UIViewController {
    
    private let user: User
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let passwordLabel: UILabel  = {
        let label = PrimaryLabel(placeholder: AppStrings.Opening.reactivateAccount)
            return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    private lazy var activateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Opening.reactivateAccountAction, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleReactivate), for: .touchUpInside)
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
        addNavigationBarLogo()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(passwordLabel, activateButton, contentLabel)
        
        NSLayoutConstraint.activate([
            passwordLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            
            activateButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 30),
            activateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            activateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            activateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        guard let dDate = user.dDate else { return }
        let dateValue = dDate.dateValue()
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        let deactivationDate = dateFormatter.string(from: dateValue)
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = 1

        if let nextMonthDate = calendar.date(byAdding: dateComponents, to: dateValue) {
            let deadlineDate = dateFormatter.string(from: nextMonthDate)
            contentLabel.text = AppStrings.Opening.deactivateAccountMessage(withDeactivationDate: deactivationDate, withDeadlineDate: deadlineDate)
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
        AuthService.logout()
        AuthService.googleLogout()
        let controller = OpeningViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @objc func handleReactivate() {
        guard let dDate = user.dDate else { return }
        AuthService.activate(dDate: dDate) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                let controller = ContainerViewController()
                controller.modalPresentationStyle = .fullScreen
                strongSelf.present(controller, animated: false)
            }
        }
    }
}

