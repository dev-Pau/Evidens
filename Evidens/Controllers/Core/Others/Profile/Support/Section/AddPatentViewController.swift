//
//  AddPatentViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

private let contributorsCellReuseIdentifier = "ContributorsCellReuseIdentifier"

protocol AddPatentViewControllerDelegate: AnyObject {
    func didAddPatent(_ patent: Patent)
    func didDeletePatent(_ patent: Patent)
}

class AddPatentViewController: UIViewController {
    
    private let user: User
    private var viewModel = PatentViewModel()
  
    private var userIsEditing = false

    weak var delegate: AddPatentViewControllerDelegate?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Sections.patentContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Content.Case.Share.title, secureTextEntry: false, title: AppStrings.Content.Case.Share.title)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let codeTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.code, secureTextEntry: false, title: AppStrings.Sections.code)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
       
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Alerts.Title.deletePatent,  attributes: container)

        button.configuration?.baseForegroundColor = .systemRed
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(user: User, patent: Patent? = nil) {
        self.user = user
        viewModel.set(patent: patent)
        if let _ = patent {
            userIsEditing = true
        } else {
            userIsEditing = false
            viewModel.set(users: [user])
        }

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: userIsEditing ? AppStrings.Global.save : AppStrings.Global.add, style: .done, target: self, action: #selector(handleDone))
        deleteButton.isHidden = userIsEditing ? false : true
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        title = AppStrings.Sections.patentTitle
      
        deleteButton.isHidden = userIsEditing ? false : true
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(contentLabel, titleTextField, codeTextField)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 40),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            codeTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            codeTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            codeTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
        ])
        
        if userIsEditing {
            scrollView.addSubview(deleteButton)
            
            NSLayoutConstraint.activate([
                deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                deleteButton.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: 20)
            ])
            
            titleTextField.text = viewModel.title
            codeTextField.text = viewModel.code
            
            titleTextField.textFieldDidChange()
            codeTextField.textFieldDidChange()
            
            if let uids = viewModel.uids, let uid = UserDefaults.standard.value(forKey: "uid") as? String {
                let newUids = uids.filter { $0 != uid }
                if !newUids.isEmpty {
                    UserService.fetchUsers(withUids: newUids) { [weak self] newUsers in
                        guard let strongSelf = self else { return }
                        
                        var users = newUsers
                        users.insert(strongSelf.user, at: 0)
                        
                        strongSelf.viewModel.set(users: users)
                    }
                } else {
                    viewModel.set(users: [user])
                }
            }
        }

        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        codeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func isValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isValid
    }
    
    @objc func textFieldDidChange(_ textField: InputTextField) {
        if textField == titleTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(title: text)
            } else {
                viewModel.set(title: nil)
            }
        } else if textField == codeTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(code: text)
            } else {
                viewModel.set(code: nil)
            }
        }
        
        isValid()
    }
    
    @objc func handleDone() {
        guard viewModel.isValid else { return }

        showProgressIndicator(in: view)
        
        if userIsEditing {
            DatabaseManager.shared.editPatent(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let patent = strongSelf.viewModel.patent else { return }
                    strongSelf.delegate?.didAddPatent(patent)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            DatabaseManager.shared.addPatent(viewModel: viewModel) { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                switch result {
                    
                case .success(let patent):
                    strongSelf.delegate?.didAddPatent(patent)
                    strongSelf.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
  
    @objc func handleDelete() {
        displayAlert(withTitle: AppStrings.Alerts.Title.deletePatent, withMessage: AppStrings.Alerts.Subtitle.deletePatent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showProgressIndicator(in: strongSelf.view)
            DatabaseManager.shared.deletePatent(viewModel: strongSelf.viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let patent = strongSelf.viewModel.patent else { return }
                    strongSelf.delegate?.didDeletePatent(patent)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
