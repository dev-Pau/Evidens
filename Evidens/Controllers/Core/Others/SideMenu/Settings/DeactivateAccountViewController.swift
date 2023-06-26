//
//  DeactivateAccountViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/6/23.
//

import UIKit

class DeactivateAccountViewController: UIViewController {
    private var submitAction: UIAlertAction!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let image: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let additionalTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let additionalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    
    private lazy var deactivateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.text = "Deactivate"
        label.textColor = .systemRed
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDeactivate)))
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        title = "Deactivate Account"
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        scrollView.addSubviews(kindLabel, image, name, titleLabel, contentLabel, additionalLabel, additionalTitleLabel, deactivateLabel)
        NSLayoutConstraint.activate([
            kindLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            kindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            kindLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            image.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 20),
            image.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: 35),
            image.heightAnchor.constraint(equalToConstant: 35),
            
            name.centerYAnchor.constraint(equalTo: image.centerYAnchor),
            name.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 10),
            name.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            additionalTitleLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            additionalTitleLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            additionalTitleLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            additionalLabel.topAnchor.constraint(equalTo: additionalTitleLabel.bottomAnchor, constant: 5),
            additionalLabel.leadingAnchor.constraint(equalTo: additionalTitleLabel.leadingAnchor),
            additionalLabel.trailingAnchor.constraint(equalTo: additionalTitleLabel.trailingAnchor),
            
            deactivateLabel.topAnchor.constraint(equalTo: additionalLabel.bottomAnchor, constant: 30),
            deactivateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        
        ])
        
        kindLabel.text = AppStrings.Settings.accountDeactivateContent
        contentLabel.text = "You're about to start the process of deactivating your account. As a result, your display name, and public profile will no longer be accessible or visible."
        titleLabel.text = "This action will result in the deactivation of your account"
        additionalTitleLabel.text = "Some important details you should know"
        additionalLabel.text = "You can restore your account if it was accidentally or wrongfully deactivated for up to 30 days after deactivation."
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        if let url = currentUser.profileImageUrl, !url.isEmpty {
            image.sd_setImage(with: URL(string: url))
        } else {
            image.image = UIImage(named: AppStrings.Assets.profile)
        }
        
        name.text = currentUser.firstName! + " " + currentUser.lastName!
    }
    
    func pushDeactivatePasswordController() {
        let controller = DeactivatePasswordViewController()
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    func showDeleteAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.displayMEDestructiveAlert(withTitle: "Deactivate your account?", withMessage: "Your account will be deactivated.", withCancelButtonText: "Cancel", withDoneButtonText: "Yes, deactivate") {
                strongSelf.displayAlertWithText(withTitle: "This action will deactivate your account. Are you sure?", withMessage: "Your account will be deactivated. Please, type DEACTIVATE to confirm.", withCancelButtonText: "Cancel", withDoneButtonText: "Yes, deactivate", withPlaceholder: "DEACTIVATE") {
                    
                    AuthService.deactivate { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let _ = error {
                            strongSelf.displayAlert(withTitle: "Error", withMessage: "Oops, something went wrong. Please try again later.")
                        } else {

                            let controller = UserChangesViewController(change: .deactivate)
                            let navVC = UINavigationController(rootViewController: controller)
                            navVC.modalPresentationStyle = .fullScreen
                            strongSelf.present(navVC, animated: true) {
                                strongSelf.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleDeactivate() {
        AuthService.providerKind { [weak self] provider in
            guard let strongSelf = self else { return }
            switch provider {
            case .password:
                strongSelf.pushDeactivatePasswordController()
            case .google:
                strongSelf.showDeleteAlert()
            case .apple:
                strongSelf.showDeleteAlert()
            case .undefined:
                strongSelf.displayAlert(withTitle: "Error", withMessage: "Oops, something went wrong. Please try again later.")
                strongSelf.dismiss(animated: true)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let placeholder = textField.placeholder {
            print("did change")
            submitAction.isEnabled = text == placeholder
        }
    }
    
    func displayAlertWithText(withTitle title: String, withMessage message: String, withCancelButtonText cancelButtonText: String, withDoneButtonText doneButtonText: String, withPlaceholder placeholder: String, completion: @escaping() -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            guard let strongSelf = self else { return }
            textField.placeholder = placeholder
            textField.addTarget(self, action: #selector(strongSelf.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        submitAction = UIAlertAction(title: "Yes, confirm", style: .default) { _ in
            completion()
        }
        submitAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
