//
//  AddLanguageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit
import JGProgressHUD

protocol AddLanguageViewControllerDelegate: AnyObject {
    func didAddLanguage(_ language: Language)
    func didDeleteLanguage(_ language: Language)
}

class AddLanguageViewController: UIViewController {
    
    weak var delegate: AddLanguageViewControllerDelegate?
    
    private var viewModel = LanguageViewModel()
    private var userIsEditing = false

    private let progressIndicator = JGProgressHUD()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Sections.languageContent
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var kindTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.languageTitle, secureTextEntry: false, title: AppStrings.Sections.languageTitle)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var proficiencyTextField: InputTextField = {
        let tf = InputTextField(placeholder: AppStrings.Sections.Language.proficiency, secureTextEntry: false, title: AppStrings.Sections.Language.proficiency)
        tf.keyboardType = .default
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
       
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Alerts.Title.deleteLanguage,  attributes: container)

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
    
    init(language: Language? = nil) {
        viewModel.set(language: language)
        if let _ = language {
            userIsEditing = true
        } else {
            userIsEditing = false
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Sections.languageTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: userIsEditing ? AppStrings.Global.save : AppStrings.Global.add, style: .done, target: self, action: #selector(handleDone))
        deleteButton.isHidden = userIsEditing ? false : true
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(contentLabel, kindTextField, proficiencyTextField)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            kindTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            kindTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            kindTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            proficiencyTextField.topAnchor.constraint(equalTo: kindTextField.bottomAnchor, constant: 20),
            proficiencyTextField.leadingAnchor.constraint(equalTo: kindTextField.leadingAnchor),
            proficiencyTextField.trailingAnchor.constraint(equalTo: kindTextField.trailingAnchor),
        ])
        
        kindTextField.delegate = self
        proficiencyTextField.delegate = self
        
        kindTextField.text = viewModel.kind?.name
        proficiencyTextField.text = viewModel.proficiency?.name
        
        let kindGesture = UITapGestureRecognizer(target: self, action: #selector(kindTap))
        let proficiencyGesture = UITapGestureRecognizer(target: self, action: #selector(proficiencyTap))
        
        if userIsEditing {
            scrollView.addSubview(deleteButton)
            NSLayoutConstraint.activate([
                deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                deleteButton.topAnchor.constraint(equalTo: proficiencyTextField.bottomAnchor, constant: 20)
            ])
            
            kindTextField.isUserInteractionEnabled = false
            kindTextField.textColor = .secondaryLabel

            proficiencyTextField.addGestureRecognizer(proficiencyGesture)
        } else {
            kindTextField.addGestureRecognizer(kindGesture)
            proficiencyTextField.addGestureRecognizer(proficiencyGesture)
        }
    }
    
    private func isValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isValid
    }
    
    @objc func handleDone() {
        guard viewModel.isValid else { return }
        progressIndicator.show(in: view)
        if userIsEditing {
            DatabaseManager.shared.updateLanguage(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let language = strongSelf.viewModel.language else { return }
                    strongSelf.delegate?.didAddLanguage(language)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            DatabaseManager.shared.addLanguage(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)
                if let error {
                    switch error {
                    case .network, .unknown, .empty:
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    case .exists:
                        let popUp = PopUpBanner(title: AppStrings.Error.languageExists, image: AppStrings.Icons.xmarkCircleFill, popUpKind: .destructive)
                        popUp.showTopPopup(inView: strongSelf.view)
                    }
                } else {
                    guard let language = strongSelf.viewModel.language else { return }
                    strongSelf.delegate?.didAddLanguage(language)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func handleDelete() {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteLanguage, withMessage: AppStrings.Alerts.Subtitle.deleteLanguage, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.progressIndicator.show(in: strongSelf.view)
            DatabaseManager.shared.deleteLanguage(viewModel: strongSelf.viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    guard let language = strongSelf.viewModel.language else { return }
                    strongSelf.delegate?.didDeleteLanguage(language)
                    strongSelf.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func proficiencyTap() {
        let controller = LanguageListViewController(source: .proficiency, proficiency: viewModel.proficiency)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func kindTap() {
        let controller = LanguageListViewController(source: .kind, kind: viewModel.kind)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension AddLanguageViewController: SupportSectionViewControllerDelegate {
    func didAddKind(_ kind: LanguageKind) {
        kindTextField.text = kind.name
        viewModel.set(kind: kind)
        isValid()
    }
    
    func didAddProficiency(_ proficiency: LanguageProficiency) {
        proficiencyTextField.text = proficiency.name
        viewModel.set(proficiency: proficiency)
        isValid()
    }
}

extension AddLanguageViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

