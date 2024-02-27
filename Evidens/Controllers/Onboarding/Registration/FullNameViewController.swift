//
//  FullNameViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import MessageUI

class FullNameViewController: UIViewController {
    
    private var user: User
    
    private var viewModel = FullNameViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let nameTextLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Opening.registerNameTitle)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Opening.registerNameContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let firstNameTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.registerFirstName, secureTextEntry: false, title: AppStrings.Opening.registerFirstName)
        return tf
    }()
    
    private let lastNameTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.registerLastName, secureTextEntry: false, title: AppStrings.Opening.registerLastName)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureNotificationObservers()
    }
    
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
        firstNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        textDidChange()
        
        firstNameTextField.textFieldDidChange()
        lastNameTextField.textFieldDidChange()
        
        scrollView.addSubviews(nameTextLabel, contentLabel, firstNameTextField, lastNameTextField, nextButton)
        
        NSLayoutConstraint.activate([
            nameTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            nameTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: nameTextLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: nameTextLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: nameTextLabel.trailingAnchor),
            
            firstNameTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 40),
            firstNameTextField.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            firstNameTextField.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10),
            lastNameTextField.leadingAnchor.constraint(equalTo: firstNameTextField.leadingAnchor),
            lastNameTextField.trailingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor),
            
            nextButton.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: lastNameTextField.trailingAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
        ])
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

        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        
        viewModel.set(firstName: firstName)
        viewModel.set(lastName: lastName)
        nextButton.isEnabled = viewModel.formIsValid
    }
    
    @objc func handleNext() {
        guard let firstName = viewModel.firstName, let lastName = viewModel.lastName else { return }
        user.firstName = firstName
        user.lastName = lastName
        
        let controller = ImageViewController(user: user)
        
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FullNameViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        
        controller.dismiss(animated: true)
    }
}

