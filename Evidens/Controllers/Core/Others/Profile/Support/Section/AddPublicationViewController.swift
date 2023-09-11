//
//  AddPublicationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

private let contributorsCellReuseIdentifier = "ContributorsCellReuseIdentifier"

protocol AddPublicationViewControllerDelegate: AnyObject {
    func didAddPublication(_ publication: Publication)
    func didDeletePublication(_ publication: Publication)
}

class AddPublicationViewController: UIViewController {
    
    weak var delegate: AddPublicationViewControllerDelegate?

    private let user: User
    private var viewModel = PublicationViewModel()
  
    private var userIsEditing = false

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
        label.text = AppStrings.Sections.publicationContent
        label.font = .systemFont(ofSize: 15, weight: .regular)
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

    private let urlTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.URL.url, secureTextEntry: false, title: AppStrings.URL.url)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let dateTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Miscellaneous.date, secureTextEntry: false, title: AppStrings.Miscellaneous.date)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
       
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Alerts.Title.deletePublication,  attributes: container)

        button.configuration?.baseForegroundColor = .systemRed
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        configureDatePicker()
    }
    
    init(user: User, publication: Publication? = nil) {
        self.user = user
        viewModel.set(publication: publication)
        if let _ = publication {
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
    
    private func configureDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleAddDate))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
    }
    
    private func configureUI() {
        title = AppStrings.Sections.publicationTitle

        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(contentLabel, titleTextField, urlTextField, dateTextField)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           
            urlTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            urlTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            urlTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            dateTextField.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 20),
            dateTextField.leadingAnchor.constraint(equalTo: urlTextField.leadingAnchor),
            dateTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
        ])
        
        if userIsEditing {
            scrollView.addSubview(deleteButton)
            
            NSLayoutConstraint.activate([
                deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                deleteButton.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 20)
            ])
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none

            dateTextField.text = formatter.string(from: Date(timeIntervalSince1970: viewModel.timestamp ?? .zero))
            titleTextField.text = viewModel.title
            urlTextField.text = viewModel.url
            
            dateTextField.textFieldDidChange()
            titleTextField.textFieldDidChange()
            urlTextField.textFieldDidChange()
            
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
        urlTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func showInvalidUrl() {
        let reportPopup = PopUpBanner(title: AppStrings.PopUp.evidenceUrlError, image: AppStrings.Icons.fillExclamation, popUpKind: .destructive)
        reportPopup.showTopPopup(inView: view)
        HapticsManager.shared.triggerErrorHaptic()
    }
    
    private func isValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isValid
    }
    
    @objc func handleDone() {
        guard viewModel.isValid, let url = viewModel.url else { return }

        if let url = URL(string: url) {
            if UIApplication.shared.canOpenURL(url) {
                showProgressIndicator(in: view)
                
                if userIsEditing {
                    DatabaseManager.shared.editPublication(viewModel: viewModel) { [weak self] error in
                        guard let strongSelf = self else { return }
                        strongSelf.dismissProgressIndicator()
                        if let error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            guard let publication = strongSelf.viewModel.publication else { return }
                            strongSelf.delegate?.didAddPublication(publication)
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                } else {
                    DatabaseManager.shared.addPublication(viewModel: viewModel) { [weak self] result in
                        guard let strongSelf = self else { return }
                        strongSelf.dismissProgressIndicator()
                        switch result {
                            
                        case .success(let publication):
                            strongSelf.delegate?.didAddPublication(publication)
                            strongSelf.navigationController?.popViewController(animated: true)
                        case .failure(let error):
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        }
                    }
                }
            } else {
                showInvalidUrl()
            }
        } else {
            showInvalidUrl()
        }
    }
    
    @objc func handleAddDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        dateTextField.text = formatter.string(from: datePicker.date)
        dateTextField.textFieldChanged()

        let timeInterval = datePicker.date.timeIntervalSince1970
        viewModel.set(timestamp: timeInterval)
        
        isValid()
        
        view.endEditing(true)
    }
    
    @objc func handleDelete() {
        displayAlert(withTitle: AppStrings.Alerts.Title.deletePublication, withMessage: AppStrings.Alerts.Subtitle.deletePublication, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showProgressIndicator(in: strongSelf.view)
            DatabaseManager.shared.deletePublication(viewModel: strongSelf.viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let publication = strongSelf.viewModel.publication else { return }
                    strongSelf.delegate?.didDeletePublication(publication)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: InputTextField) {

        if textField == titleTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(title: text)
            } else {
                viewModel.set(title: nil)
            }

        } else if textField == urlTextField {
            if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
                viewModel.set(url: textField.text)
            } else {
                viewModel.set(url: nil)
            }
        }
        
        isValid()
    }
}
