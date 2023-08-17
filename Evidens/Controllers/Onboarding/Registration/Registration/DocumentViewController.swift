//
//  DocumentViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/23.
//

import UIKit

class DocumentViewController: UIViewController {
    
    private var viewModel: VerificationViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = AppStrings.Opening.verifyQualityCheck
        return label
    }()
    
    private let docImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Global.go, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var goBackLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Opening.tryAgain
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    init(viewModel: VerificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        let kind = viewModel.userKind
        var multiplier = 0.0
        switch kind {
        case .professional:
            switch viewModel.kind {
            case .doc:
                titleLabel.text = AppStrings.Opening.verifyDocs
                multiplier = 0.7
            case .id:
                titleLabel.text = AppStrings.Opening.verifyId
                multiplier = 0.7
            }
        case .student:
            switch viewModel.kind {
            case .doc:
                titleLabel.text = AppStrings.Opening.verifyStudentDocs
                multiplier = 0.9
            case .id:
                titleLabel.text = AppStrings.Opening.verifyId
                multiplier = 0.7
            }
        }
        
        scrollView.addSubviews(titleLabel, contentLabel, docImage, continueButton, goBackLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            docImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            docImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            docImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            docImage.heightAnchor.constraint(equalTo: docImage.widthAnchor, multiplier: multiplier),
            
            contentLabel.topAnchor.constraint(equalTo: docImage.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            continueButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            goBackLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 20),
            goBackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            goBackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        docImage.layer.cornerRadius = 20
        
        switch viewModel.kind {
        case .doc:
            docImage.image = viewModel.docImage
        case .id:
            docImage.image = viewModel.idImage
        }
    }
    
    @objc func handleContinue() {
        switch viewModel.kind { 
        case .doc:
            viewModel.setKind()
            let controller = MediaCaptureViewController(viewModel: viewModel)
            navigationController?.pushViewController(controller, animated: true)
        case .id:
            guard let uid = viewModel.uid else { return }
            
            showProgressIndicator(in: view)
            
            StorageManager.addDocImages(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.dismissProgressIndicator()
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    AuthService.addDocumentationDetals(withUid: uid) { [weak self] error in
                        strongSelf.dismissProgressIndicator()
                        
                        guard let strongSelf = self else { return }
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            // aquí if vé de la principal, simplement fer dismiss i fer setUserDefaults(for: user)
                            let controller = ReviewViewController(user: strongSelf.viewModel.currentUser)
                            let nav = UINavigationController(rootViewController: controller)
                            nav.modalPresentationStyle = .fullScreen
                            strongSelf.present(nav, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
}
