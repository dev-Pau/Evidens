//
//  VerificationRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import MessageUI

class VerificationViewController: UIViewController {
    
    private var user: User
    private var comesFromMainScreen: Bool?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .label
        button.configuration?.cornerStyle = .capsule

        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Global.help, attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: "")
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.addFont(size: 15.0, scaleStyle: .title2, weight: .regular)
        label.font = font
        label.numberOfLines = 0
        label.textColor = K.Colors.primaryGray
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Opening.verifyNow, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .bold, scales: false)
        button.addTarget(self, action: #selector(handleVerifyNow), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = K.Colors.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Opening.or
        let font = UIFont.addFont(size: 12.0, scaleStyle: .title1, weight: .regular)
        label.font = font
        label.textColor = K.Colors.primaryGray
        label.backgroundColor = .systemBackground
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        label.font = font
        label.numberOfLines = 0
        label.text = AppStrings.Opening.registerIdentitySkip
        label.textColor = K.Colors.primaryGray
        return label
    }()
    
    private lazy var skipLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Global.skip
        label.textAlignment = .left
        let font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        label.font = font
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSkip)))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(user: User, comesFromMainScreen: Bool? = nil) {
        self.user = user
        self.comesFromMainScreen = comesFromMainScreen
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory) {
                guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate else {
                    return
                }

                sceneDelegate.updateViewController(ContainerViewController(withLoadingView: true))
            }
        }
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
        
        addNavigationBarLogo(withTintColor: K.Colors.primaryColor)
        
        if let _ = comesFromMainScreen {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
            navigationItem.leftBarButtonItem?.tintColor = .label
        } else {
            helpButton.menu = addMenuItems()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
        }
    }
    
    private func configureUI() {
        let buttonSize = UIDevice.isPad ? 60.0 : 50.0
        
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        var stackView: UIStackView!
        
        if let _ = comesFromMainScreen {
            stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel, continueButton])
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.alignment = .leading
            stackView.distribution = .equalSpacing
            stackView.axis = .vertical
            stackView.spacing = 20
            
            scrollView.addSubviews(stackView)
            
            NSLayoutConstraint.activate([
                
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                continueButton.heightAnchor.constraint(equalToConstant: buttonSize),
                continueButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                continueButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            ])
        } else {
            stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel, continueButton, separatorView, emailLabel, skipLabel])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.alignment = .leading
            stackView.distribution = .equalSpacing
            stackView.axis = .vertical
            stackView.spacing = 20
            
            scrollView.addSubviews(stackView, orLabel)
            
            NSLayoutConstraint.activate([

                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                continueButton.heightAnchor.constraint(equalToConstant: buttonSize),
                continueButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                continueButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                
                separatorView.heightAnchor.constraint(equalToConstant: 0.4),
                separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                
                orLabel.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),
                orLabel.centerXAnchor.constraint(equalTo: separatorView.centerXAnchor),
                orLabel.widthAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        let kind = user.kind
        titleLabel.text = AppStrings.Opening.registerIdentityTitle
        contentLabel.text = kind == .professional ? AppStrings.Opening.registerIdentityProfesionalContent : AppStrings.Opening.registerIdentityStudentContent
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: AppStrings.App.support, image: UIImage(systemName: AppStrings.Icons.fillTray, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                if MFMailComposeViewController.canSendMail() {
                    let controller = MFMailComposeViewController()
                    
                    #if DEBUG
                    controller.setToRecipients([AppStrings.App.personalMail])
                    #else
                    controller.setToRecipients([AppStrings.App.personalMail])
                    #endif
                    
                    controller.mailComposeDelegate = self
                    strongSelf.present(controller, animated: true)
                } else {
                    return
                }
            }),
            
            UIAction(title: AppStrings.Opening.logOut, image: UIImage(systemName: AppStrings.Icons.lineRightArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.logout()
                let controller = OpeningViewController()
                let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            })
        ])
        return menuItems
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleSkip() {
        guard let uid = user.uid else { return }
        
        if let _ = comesFromMainScreen {
            dismiss(animated: true)
        } else {
            showProgressIndicator(in: view)
            
            AuthService.skipDocumentationDetails(withUid: uid) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.user.phase = .pending
                    strongSelf.setUserDefaults(for: strongSelf.user)
                    
                    let controller = ContainerViewController()
                    controller.modalPresentationStyle = .fullScreen
                    strongSelf.present(controller, animated: false)
                }
            }
        }
    }
    
    @objc func handleVerifyNow() {
        let viewModel = VerificationViewModel(user: user)
        let controller = MediaCaptureViewController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension VerificationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}
