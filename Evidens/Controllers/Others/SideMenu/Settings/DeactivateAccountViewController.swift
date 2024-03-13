//
//  DeactivateAccountViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/6/23.
//

import UIKit
import Firebase

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
    
    private let image = ProfileImageView(frame: .zero)
   
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
        
        scrollView.addSubviews(kindLabel, kindSeparator, image, titleLabel, contentLabel, additionalLabel, additionalTitleLabel, deactivateLabel)
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
        
        image.layer.cornerRadius = size / 2
        kindLabel.text = AppStrings.Settings.accountDeactivateContent
        contentLabel.text = AppStrings.User.Changes.deactivateProcess
        titleLabel.text = AppStrings.User.Changes.deactivateResults
        additionalTitleLabel.text = AppStrings.User.Changes.deactivateDetails
        additionalLabel.text = AppStrings.User.Changes.restore

        guard let tab = tabBarController as? MainTabController else { return }
        guard let _ = tab.user else { return }
        image.addImage(forUrl: UserDefaults.getImage(), size: size)
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
                    
                    strongSelf.showProgressIndicator(in: strongSelf.view)
                    
                    AuthService.deactivate { [weak self] error in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.dismissProgressIndicator()
                        
                        if let _ = error {
                            strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                        } else {
                            UserDefaults.deactivate()
                            
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
        
        showProgressIndicator(in: view)
        
        AuthService.getLastDeactivationDate { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.dismissProgressIndicator()
            
            switch result {
                
            case .success(let timestamp):
                guard strongSelf.atLeastOneDayHasPassed(since: timestamp) else {
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.deactivate)
                    return
                }
                
            case .failure(let error):
                guard error == .notFound else {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    return
                }
            }
            
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
    }
    
    private func atLeastOneDayHasPassed(since timestamp: Timestamp) -> Bool {
        let currentDate = Date()

        let timestampDate = timestamp.dateValue()

        let calendar = Calendar.current

        if let difference = calendar.dateComponents([.day], from: timestampDate, to: currentDate).day {
            return difference >= 1
        } else {
            return false
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
