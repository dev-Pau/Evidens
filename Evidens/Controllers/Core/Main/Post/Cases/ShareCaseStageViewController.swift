//
//  ShareCaseStageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/5/23.
//

import UIKit
import JGProgressHUD

class ShareCaseStageViewController: UIViewController {
    
    private var viewModel: ShareCaseViewModel
    private var progressIndicator = JGProgressHUD()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let stageTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Has the case reached a resolution, or is it still an open case?"
        label.font = .systemFont(ofSize: 26, weight: .black)
        label.numberOfLines = 0
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
        container.font = .systemFont(ofSize: 15, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString("Share as Solved", attributes: container)
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
        container.font = .systemFont(ofSize: 15, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString("Share as Unsolved", attributes: container)
        button.addTarget(self, action: #selector(handleShareUnsolvedCase), for: .touchUpInside)
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
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
        title = "Share Case"
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        
        solvedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        unsolvedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [stageTitleLabel, solvedButton, unsolvedButton, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -50),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: view.frame.width - 40)
        ])
        
        descriptionLabel.text = "When categorizing a clinical case, you are required to select a stage that represents the current status of the case. By marking the case as solved, you indicates that you have successfully resolved a clinical case and obtained a confirmed diagnosis. By marking the case as unsolved, you can seek assistance from the community, engaging in discussions and receiving input from peers."
    }
    
    @objc func handleShareSolvedCase() {
        viewModel.stage = .resolved
        let controller = ShareCaseDiagnosisViewController(viewModel: viewModel)

        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @objc func handleShareUnsolvedCase() {
        guard let title = viewModel.title, let description = viewModel.description, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        viewModel.stage = .unresolved
        if let group = viewModel.group {
            if viewModel.images.isEmpty {
                GroupService.uploadGroupCase(groupId: group.groupId, permissions: group.permissions, caseTitle: title, caseDescription: description, specialities: viewModel.specialities, details: viewModel.details, stage: viewModel.stage!, type: .text, professions: viewModel.professions) { error in
                    
                    self.progressIndicator.dismiss(animated: true)
                    
                    if let error = error {
                        print("DEBUG: \(error.localizedDescription)")
                        
                        return
                    } else {
                        self.dismiss(animated: true)
                        return
                        
                    }
                }
            } else {
                StorageManager.uploadGroupCaseImage(images: viewModel.images, uid: uid, groupId: group.groupId) { imageUrl in
                    GroupService.uploadGroupCase(groupId: group.groupId, permissions: group.permissions, caseTitle: title, caseDescription: description, caseImageUrl: imageUrl, specialities: self.viewModel.specialities, details: self.viewModel.details, stage: self.viewModel.stage!, type: .textWithImage, professions: self.viewModel.professions) { error in
                        self.progressIndicator.dismiss(animated: true)
                        
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        } else {
                            self.dismiss(animated: true)
                            return
                        }
                    }
                }
            }
            
        } else {
            if viewModel.images.isEmpty {
                CaseService.uploadCase(privacy: viewModel.privacy, caseTitle: title, caseDescription: description, specialities: viewModel.specialities, details: viewModel.details, stage: viewModel.stage!, type: .text, professions: viewModel.professions) { error in
                    self.progressIndicator.dismiss(animated: true)
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.dismiss(animated: true)
                        return
                    }
                }
            } else {
                StorageManager.uploadCaseImage(images: viewModel.images, uid: uid) { imageUrl in
                    CaseService.uploadCase(privacy: self.viewModel.privacy, caseTitle: title, caseDescription: description, caseImageUrl: imageUrl, specialities: self.viewModel.specialities, details: self.viewModel.details, stage: self.viewModel.stage!, type: .textWithImage, professions: self.viewModel.professions) { error in
                        self.progressIndicator.dismiss(animated: true)
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        } else {
                            self.dismiss(animated: true)
                            return
                        }
                    }
                }
            }
        }
    }
}
