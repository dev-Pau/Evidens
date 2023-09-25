//
//  ShareCaseStageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/5/23.
//

import UIKit

class ShareCaseStageViewController: UIViewController {
    
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
    
    private lazy var solvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = primaryColor
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        container.foregroundColor = .white
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
        container.font = .systemFont(ofSize: 17, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.unsolved, attributes: container)
        button.addTarget(self, action: #selector(handleShareUnsolvedCase), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: ShareCaseViewModel) {
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
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.frame = view.bounds
        
        solvedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        unsolvedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, solvedButton, unsolvedButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func handleShareSolvedCase() {
        viewModel.phase = .solved
        let controller = ShareCaseDiagnosisViewController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @objc func handleShareUnsolvedCase() {
        viewModel.phase = .unsolved
        showProgressIndicator(in: view)
        CaseService.addCase(viewModel: viewModel) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                strongSelf.dismiss(animated: true)
            }
        }
    }
}

