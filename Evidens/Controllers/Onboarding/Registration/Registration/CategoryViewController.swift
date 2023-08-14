//
//  NameRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit
import MessageUI

class CategoryViewController: UIViewController {
    
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
        let label = PrimaryLabel(placeholder: AppStrings.Opening.categoryTitle)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.rightArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.white)
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
        button.configuration?.attributedTitle = AttributedString(AppStrings.Global.help, attributes: container)

        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let professionalKind = CategoryView(kind: .professional)
    private let studentKind = CategoryView(kind: .student)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
        professionalKind.delegate = self
        studentKind.delegate = self
    }
    
    init(user: User) {
        self.user = user
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
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        scrollView.addSubviews(categoryLabel, professionalKind, studentKind, nextButton)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            professionalKind.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            professionalKind.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            professionalKind.trailingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            professionalKind.heightAnchor.constraint(equalToConstant: 120),
            
            studentKind.topAnchor.constraint(equalTo: professionalKind.bottomAnchor, constant: 10),
            studentKind.leadingAnchor.constraint(equalTo: professionalKind.leadingAnchor),
            studentKind.trailingAnchor.constraint(equalTo: professionalKind.trailingAnchor),
            studentKind.heightAnchor.constraint(equalToConstant: 120),
            
            nextButton.topAnchor.constraint(equalTo: studentKind.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: studentKind.trailingAnchor),
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
    
    @objc func handleNext() {
        let controller = DisciplineViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}


extension CategoryViewController: CategoryViewDelegate {
    func didTapCategory(_ view: CategoryView) {
        nextButton.isUserInteractionEnabled = true
        nextButton.configuration?.baseBackgroundColor = primaryColor
        
        switch view {
        case professionalKind:
            user.kind = .professional
            studentKind.resetCategoryView()
        case studentKind:
            user.kind = .student
            professionalKind.resetCategoryView()
        default:
            break
        }
    }
}

extension CategoryViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

