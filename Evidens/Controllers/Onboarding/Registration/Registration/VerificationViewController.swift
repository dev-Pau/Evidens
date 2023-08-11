//
//  VerificationRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import MessageUI
import JGProgressHUD

class VerificationViewController: UIViewController {
    
    private var user: User
    private let progressIndicator = JGProgressHUD()
   
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
        container.font = .systemFont(ofSize: 15, weight: .semibold)
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
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Opening.verifyNow, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleVerifyNow), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Opening.or
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemBackground
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.text = AppStrings.Opening.registerIdentitySkip
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var skipLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Global.skip
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = primaryColor
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
    
    init(user: User) {
        self.user = user
        print(user)
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
        
        helpButton.menu = addMenuItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    private func configureUI() {
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel, continueButton, separatorView, emailLabel, skipLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 20
    
        scrollView.addSubviews(stackView, orLabel)

        NSLayoutConstraint.activate([
            
            stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: continueButton.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: continueButton.trailingAnchor, constant: -10),
            
            orLabel.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),
            orLabel.centerXAnchor.constraint(equalTo: separatorView.centerXAnchor),
            orLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
        
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
                    controller.setToRecipients([AppStrings.App.contactMail])
                    controller.mailComposeDelegate = self
                    strongSelf.present(controller, animated: true)
                } else {
                    return
                }
            }),
            
            UIAction(title: AppStrings.Opening.logOut, image: UIImage(systemName: AppStrings.Icons.lineRightArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                AuthService.logout()
                AuthService.googleLogout()
                let controller = OpeningViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            })
        ])
        return menuItems
    }
    
    @objc func handleSkip() {
        guard let uid = user.uid else { return }
        
        setUserDefaults(for: user)
        
        progressIndicator.show(in: view)
        
        AuthService.skipDocumentationDetails(withUid: uid) { [weak self] error in
            guard let strongSelf = self else { return }

            if let error {
                strongSelf.progressIndicator.dismiss(animated: true)
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                DatabaseManager.shared.insert(user: strongSelf.user) { [weak self] error in
                    guard let strongSelf = self else { return }
                    strongSelf.progressIndicator.dismiss(animated: true)
                    
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