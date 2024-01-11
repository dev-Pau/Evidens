//
//  ShareCaseStageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/5/23.
//

import UIKit

class ShareCaseStageViewController: UIViewController {
    
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
        let label = PrimaryLabel(placeholder: AppStrings.Content.Case.Share.phaseTitle)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Content.Case.Share.phaseContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var solvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = separatorColor
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title3, weight: .bold, scales: false)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.solved, attributes: container)
        button.addTarget(self, action: #selector(handleShareSolvedCase), for: .touchUpInside)
        return button
    }()
    
    private lazy var unsolvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = separatorColor
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title3, weight: .bold, scales: false)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.unsolved, attributes: container)
        button.addTarget(self, action: #selector(handleShareUnsolvedCase), for: .touchUpInside)
        return button
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
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: primaryColor)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.frame = view.bounds
        
        solvedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        unsolvedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.addSubviews(titleLabel, contentLabel, solvedButton, unsolvedButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            unsolvedButton.topAnchor.constraint(equalTo: solvedButton.bottomAnchor, constant: 10),
            unsolvedButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            unsolvedButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            solvedButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            solvedButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            solvedButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    @objc func handleShareSolvedCase() {
        viewModel.phase = .solved
        let controller = ShareCaseDiagnosisViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleShareUnsolvedCase() {
        viewModel.phase = .unsolved
        
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

