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
    
    private let kindSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
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
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let additionalTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let additionalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var deactivateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        
        label.text = AppStrings.Alerts.Title.deactivateLower
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
        title = AppStrings.Alerts.Title.deactivate
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        
        let size: CGFloat = UIDevice.isPad ? 45 : 35
        
        scrollView.addSubviews(kindLabel, kindSeparator, image, name, titleLabel, contentLabel, additionalLabel, additionalTitleLabel, deactivateLabel)
        NSLayoutConstraint.activate([
            kindLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            kindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            kindLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            kindSeparator.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 10),
            kindSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            kindSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            kindSeparator.heightAnchor.constraint(equalToConstant: 0.4),
            
            image.topAnchor.constraint(equalTo: kindSeparator.bottomAnchor, constant: 20),
            image.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: size),
            image.heightAnchor.constraint(equalToConstant: size),
            
            name.centerYAnchor.constraint(equalTo: image.centerYAnchor),
            name.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 10),
            name.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            contentLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            additionalTitleLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 40),
            additionalTitleLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            additionalTitleLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            additionalLabel.topAnchor.constraint(equalTo: additionalTitleLabel.bottomAnchor, constant: 15),
            additionalLabel.leadingAnchor.constraint(equalTo: additionalTitleLabel.leadingAnchor),
            additionalLabel.trailingAnchor.constraint(equalTo: additionalTitleLabel.trailingAnchor),
            
            deactivateLabel.topAnchor.constraint(equalTo: additionalLabel.bottomAnchor, constant: 30),
            deactivateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deactivateLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        kindLabel.text = AppStrings.Settings.accountDeactivateContent
        contentLabel.text = AppStrings.User.Changes.deactivateProcess
        titleLabel.text = AppStrings.User.Changes.deactivateResults
        additionalTitleLabel.text = AppStrings.User.Changes.deactivateDetails
        additionalLabel.text = AppStrings.User.Changes.restore
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        if let url = currentUser.profileUrl, !url.isEmpty {
            image.sd_setImage(with: URL(string: url))
        } else {
            image.image = UIImage(named: AppStrings.Assets.profile)
        }
        
        name.text = currentUser.name()
        scrollView.resizeContentSize()
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
            
            strongSelf.displayAlert(withTitle: AppStrings.Alerts.Title.deactivate, withMessage: AppStrings.Alerts.Subtitle.deactivate, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.deactivate, style: .default) { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.displayAlertWithText(withTitle: AppStrings.Alerts.Title.deactivateWarning, withMessage: AppStrings.Alerts.Title.deactivateWarning, withCancelButtonText: AppStrings.Global.cancel, withDoneButtonText: AppStrings.Alerts.Actions.deactivate, withPlaceholder: AppStrings.Alerts.Title.deactivateCaps) {
                    
                    AuthService.deactivate { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let _ = error {
                            strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
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
                strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                strongSelf.dismiss(animated: true)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let placeholder = textField.placeholder {
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
        
        submitAction = UIAlertAction(title: AppStrings.Alerts.Actions.confirm, style: .default) { _ in
            completion()
        }
        
        submitAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: AppStrings.Global.cancel, style: .cancel)
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
