//
//  UsernameViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/2/24.
//

import UIKit
import MessageUI

class UsernameViewController: UIViewController {
    
    private var user: User
    private var viewModel = UsernameViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    
    private let usernameLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Opening.usernameTitle)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Opening.usernameContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.usernamePlaceholder, secureTextEntry: false, title: AppStrings.Opening.usernamePlaceholder)
        return tf
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.rightArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = primaryColor
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()

        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .label

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .semibold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Global.help, attributes: container)
     
        button.isUserInteractionEnabled = true
        button.showsMenuAsPrimaryAction = true

        return button
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
        configureNotificationObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameTextField.becomeFirstResponder()
        
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
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configureNotificationObservers() {
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.delegate = self
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        scrollView.addSubviews(usernameLabel, contentLabel, usernameTextField, nextButton)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            
            usernameTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 40),
            usernameTextField.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            nextButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        usernameTextField.autocapitalizationType = .none
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
    
    @objc func textDidChange() {
        guard let username = usernameTextField.text else {
            viewModel.set(username: String())
            return
        }
        
        guard username.count <= viewModel.maxCount else {
            usernameTextField.deleteBackward()
            return
        }
        
        viewModel.set(username: username)
        nextButton.isEnabled = viewModel.formIsValid()
    }
    
    @objc func handleNext() {
        
        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
            return
        }
        
        usernameTextField.resignFirstResponder()
        
        var phase: UserPhase?
        
        #if DEBUG
        phase = .verified
        #else
        phase = .identity
        #endif
        
        guard let phase else { return }
        
        showProgressIndicator(in: view)
        
        viewModel.addUsername(toPhase: phase) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            
            if let error {
                strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.usernameTextField.becomeFirstResponder()
                }
            } else {
                let username = strongSelf.viewModel.username.trimmingCharacters(in: .whitespaces)

                #if DEBUG
                strongSelf.user.phase = .verified
                strongSelf.user.set(username: username)
                strongSelf.setUserDefaults(for: strongSelf.user)
                
                let controller = ReviewViewController(user: strongSelf.user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)

                #else
                strongSelf.user.phase = .identity
                strongSelf.user.set(username: username)
                strongSelf.setUserDefaults(for: strongSelf.user)
                let controller = VerificationViewController(user: strongSelf.user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
                #endif
            }
        }
    }
}

extension UsernameViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string.contains(" ") && viewModel.username.count <= viewModel.maxCount {
            textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: "_")
            return false
        }
        
        return true
    }
}

extension UsernameViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        
        controller.dismiss(animated: true)
    }
}

