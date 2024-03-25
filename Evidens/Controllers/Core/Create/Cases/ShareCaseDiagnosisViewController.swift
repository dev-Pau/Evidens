//
//  ShareCaseDiagnosisViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/5/23.
//

import Foundation


import UIKit

class ShareCaseDiagnosisViewController: UIViewController {
    
    private let user: User
    private var viewModel: ShareCaseViewModel
   
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Content.Case.Share.diagnosisTitle)
        return label
    }()
    
    private lazy var diagnosisButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = K.Colors.primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title3, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.addDiagnosis, attributes: container)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addDiagnosis), for: .touchUpInside)
        return button
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = K.Colors.separatorColor
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title3, weight: .bold, scales: false)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.dismissDiagnosis, attributes: container)
        button.addTarget(self, action: #selector(shareCase), for: .touchUpInside)
        return button
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    init(user: User, viewModel: ShareCaseViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        addNavigationBarLogo(withTintColor: K.Colors.primaryColor)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.frame = view.bounds
        
        diagnosisButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.addSubviews(titleLabel, contentLabel, diagnosisButton, dismissButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: K.Paddings.Content.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dismissButton.topAnchor.constraint(equalTo: diagnosisButton.bottomAnchor, constant: K.Paddings.Content.verticalPadding),
            dismissButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            diagnosisButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            diagnosisButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            diagnosisButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
        
        contentLabel.text = AppStrings.Content.Case.Share.diagnosisContent
    }
    
    @objc func addDiagnosis() {
        let controller = CaseDiagnosisViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc func shareCase() {
        let controller = ShareCasePrivacyViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleDismiss() {
        displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
        }
    }
}
