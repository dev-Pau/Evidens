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
    private let helperBottomRegistrationMenuLauncher = HelperBottomMenuLauncher()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
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
        button.configuration = .gray()

        button.configuration?.baseBackgroundColor = lightGrayColor
        button.configuration?.baseForegroundColor = blackColor

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Help", attributes: container)
        
        button.isUserInteractionEnabled = true

        button.addTarget(self, action: #selector(handleHelp), for: .touchUpInside)
        return button
    }()
    
    private let professionalCategory = MECategoryView(title: "Professional")
    private let professorCategory = MECategoryView(title: "Professor")
    private let investigatorCategory = MECategoryView(title: "Research scientist")
    private let studentCategory = MECategoryView(title: "Student")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        
        helperBottomRegistrationMenuLauncher.delegate = self
        professionalCategory.delegate = self
        professorCategory.delegate = self
        investigatorCategory.delegate = self
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(categoryLabel, professionalCategory, investigatorCategory, professorCategory, studentCategory, nextButton)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            categoryLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            categoryLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            professionalCategory.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            professionalCategory.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            professionalCategory.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8 / 2 - 5),
            professionalCategory.heightAnchor.constraint(equalToConstant: 120),
            
            investigatorCategory.topAnchor.constraint(equalTo: professionalCategory.topAnchor),
            investigatorCategory.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            investigatorCategory.leadingAnchor.constraint(equalTo: professionalCategory.trailingAnchor, constant: 10),
            investigatorCategory.heightAnchor.constraint(equalToConstant: 120),
            
            professorCategory.topAnchor.constraint(equalTo: professionalCategory.bottomAnchor, constant: 10),
            professorCategory.leadingAnchor.constraint(equalTo: professionalCategory.leadingAnchor),
            professorCategory.trailingAnchor.constraint(equalTo: professionalCategory.trailingAnchor),
            professorCategory.heightAnchor.constraint(equalToConstant: 120),
            
            studentCategory.topAnchor.constraint(equalTo: investigatorCategory.bottomAnchor, constant: 10),
            studentCategory.leadingAnchor.constraint(equalTo: investigatorCategory.leadingAnchor),
            studentCategory.trailingAnchor.constraint(equalTo: investigatorCategory.trailingAnchor),
            studentCategory.heightAnchor.constraint(equalToConstant: 120),
            
            nextButton.topAnchor.constraint(equalTo: studentCategory.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: studentCategory.trailingAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    @objc func handleNext() {
        let controller = ProfessionRegistrationViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleHelp() {
        helperBottomRegistrationMenuLauncher.showImageSettings(in: view)
    }
}

extension CategoryRegistrationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "presentCommunityInformation" {
            let controller = CommunityRegistrationViewController()
            let navController = UINavigationController(rootViewController: controller)
            
            if let presentationController = navController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
            }
            present(navController, animated: true)
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}

extension CategoryRegistrationViewController: MECategoryViewDelegate {
    func didTapCategory(_ view: MECategoryView, completion: @escaping (Bool) -> Void) {
        professionalCategory.resetCategoryView()
        professorCategory.resetCategoryView()
        investigatorCategory.resetCategoryView()
        studentCategory.resetCategoryView()
        nextButton.isUserInteractionEnabled = true
        nextButton.configuration?.baseBackgroundColor = primaryColor
        
        switch view {
        case professionalCategory:
            user.category = .professional
        case professorCategory:
            user.category = .professor
        case investigatorCategory:
            user.category = .researcher
        case studentCategory:
            user.category = .student
        default:
            user.category = .none
        }
        completion(true)
    }
}

extension CategoryRegistrationViewController: HelperBottomMenuLauncherDelegate {
    func didTapContactSupport() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setToRecipients(["support@myevidens.com"])
            controller.mailComposeDelegate = self
            present(controller, animated: true)
        } else {
            print("Device cannot send email")
        }
    }
    
    func didTapLogout() {
        AuthService.logout()
        AuthService.googleLogout()
        let controller = WelcomeViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
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

