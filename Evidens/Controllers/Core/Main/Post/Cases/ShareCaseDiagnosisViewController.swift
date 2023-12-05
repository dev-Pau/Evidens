//
//  ShareCaseDiagnosisViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/5/23.
//

import Foundation


import UIKit

class ShareCaseDiagnosisViewController: UIViewController {
    
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
    
    private lazy var solvedButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title3, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.addDiagnosis, attributes: container)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addDiagnosis), for: .touchUpInside)
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
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Case.Share.dismissDiagnosis, attributes: container)
        button.addTarget(self, action: #selector(shareCase), for: .touchUpInside)
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
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
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, solvedButton, unsolvedButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        descriptionLabel.text = AppStrings.Content.Case.Share.diagnosisContent
    }
    
    @objc func addDiagnosis() {
        let controller = CaseDiagnosisViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc func shareCase() {
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

extension ShareCaseDiagnosisViewController: CaseDiagnosisViewControllerDelegate {
    func handleSolveCase(diagnosis: CaseRevision?, clinicalCase: Case?) {
        guard let diagnosis = diagnosis else { return }
        viewModel.diagnosis = diagnosis
        shareCase()
    }
}
