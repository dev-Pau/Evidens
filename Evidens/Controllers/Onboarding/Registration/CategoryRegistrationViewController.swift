//
//  NameRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit
import MessageUI

class CategoryRegistrationViewController: UIViewController {
    
    private var user: User
   
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let categoryLabel: UILabel = {
        let label = CustomLabel(placeholder: "Choose your main category")
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(named: "arrow.right")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .label
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Help", attributes: container)

        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let professionalCategory = MECategoryView(title: "Professional")
    private let studentCategory = MECategoryView(title: "Student")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        professionalCategory.delegate = self
        studentCategory.delegate = self
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Configure account"
        helpButton.menu = addMenuItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
        
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(categoryLabel, professionalCategory, studentCategory, nextButton)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            categoryLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            categoryLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            professionalCategory.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            professionalCategory.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            professionalCategory.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            professionalCategory.heightAnchor.constraint(equalToConstant: 120),
            
            studentCategory.topAnchor.constraint(equalTo: professionalCategory.bottomAnchor, constant: 10),
            studentCategory.leadingAnchor.constraint(equalTo: professionalCategory.leadingAnchor),
            studentCategory.trailingAnchor.constraint(equalTo: professionalCategory.trailingAnchor),
            studentCategory.heightAnchor.constraint(equalToConstant: 120),
            
            nextButton.topAnchor.constraint(equalTo: studentCategory.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: studentCategory.trailingAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Contact support", image: UIImage(systemName: "tray.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                if MFMailComposeViewController.canSendMail() {
                    let controller = MFMailComposeViewController()
                    controller.setToRecipients(["support@myevidens.com"])
                    controller.mailComposeDelegate = self
                    self.present(controller, animated: true)
                } else {
                    print("Device cannot send email")
                }
            }),
            
            UIAction(title: "Log out", image: UIImage(systemName: "arrow.right.to.line", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                AuthService.logout()
                AuthService.googleLogout()
                let controller = WelcomeViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
        ])
        return menuItems
    }
    
    @objc func handleNext() {
        let controller = ProfessionRegistrationViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}


extension CategoryRegistrationViewController: MECategoryViewDelegate {
    func didTapCategory(_ view: MECategoryView, completion: @escaping (Bool) -> Void) {
        professionalCategory.resetCategoryView()
        studentCategory.resetCategoryView()
        nextButton.isUserInteractionEnabled = true
        nextButton.configuration?.baseBackgroundColor = primaryColor
        
        switch view {
        case professionalCategory:
            user.category = .professional
        case studentCategory:
            user.category = .student
        default:
            user.category = .none
        }
        completion(true)
    }
}

extension CategoryRegistrationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

