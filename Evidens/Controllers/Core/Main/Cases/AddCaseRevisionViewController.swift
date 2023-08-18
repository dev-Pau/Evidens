//
//  AddCaseUpdateViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/8/22.
//

import UIKit

protocol AddCaseUpdateViewControllerDelegate: AnyObject {
    func didAddRevision(revision: CaseRevision, for clinicalCase: Case)
}

class AddCaseRevisionViewController: UIViewController {

    private var clinicalCase: Case
    private var viewModel = CaseRevisionViewModel()
    weak var delegate: AddCaseUpdateViewControllerDelegate?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Content.Case.Revision.progressTitle
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = AppStrings.Content.Case.Revision.progressContent
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let titleTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Content.Case.Share.title, secureTextEntry: false, title: AppStrings.Content.Case.Share.title)
        return tf
    }()

    
    private lazy var contentTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Case.Share.description
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = primaryColor
        tv.tintColor = primaryColor
        tv.autocorrectionType = .no
        tv.isScrollEnabled = false
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        return tv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = AppStrings.Content.Case.Share.description
        label.alpha = 0
        return label
    }()
    
    private let bottomSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    
    init(clinicalCase: Case) {
        self.clinicalCase = clinicalCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
     private func configureNavigationBar() {
         navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .label
        
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.add, style: .done, target: self, action: #selector(handleAddRevision))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        
        scrollView.addSubviews(profileImageView, textLabel, contentLabel, titleTextField, descriptionLabel, contentTextView, separatorView, bottomSeparatorView)

        contentTextView.delegate = self
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        profileImageView.layer.cornerRadius = 40 / 2
        contentTextView.placeholderLabel.textColor = UIColor.tertiaryLabel
        
        if clinicalCase.privacy == .anonymous {
            profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        } else {
            if let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageUrl != "", clinicalCase.privacy == .regular {
                profileImageView.sd_setImage(with: URL(string: imageUrl))
            } else {
                profileImageView.image = UIImage(named: AppStrings.Assets.profile)
            }
        }
        
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            contentLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),

            separatorView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            profileImageView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            
            titleTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            titleTextField.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            contentTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            contentTextView.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),

            bottomSeparatorView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            bottomSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }

    func updateForm() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isValid
    }

    @objc func handleAddRevision() {
        guard let title = titleTextField.text, let content = contentTextView.text else { return }
        let revision = CaseRevision(title: title, content: content, kind: .update)

        CaseService.addCaseRevision(withCaseId: clinicalCase.caseId, revision: revision) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                print(error.localizedDescription)
            } else {
                strongSelf.delegate?.didAddRevision(revision: revision, for: strongSelf.clinicalCase)
                strongSelf.dismiss(animated: true)
            }
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel.title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        updateForm()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.resizeContentSize()
            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            if notification.name == UIResponder.keyboardWillHideNotification {
                scrollView.contentInset = .zero
            } else {
                scrollView.contentInset = UIEdgeInsets(top: 0,
                                                       left: 0,
                                                       bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 20,
                                                       right: 0)
            }
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollView.resizeContentSize()
        }
    }
}

extension AddCaseRevisionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let strongSelf = self else { return }
            if !textView.text.isEmpty {
                strongSelf.descriptionLabel.alpha = 1
            } else {
                strongSelf.descriptionLabel.alpha = 0
            }
            strongSelf.view.layoutIfNeeded()
        }
        
        let count = textView.text.count
        if count > 1000 {
            textView.deleteBackward()
        }
        
        scrollView.resizeContentSize()
        
        viewModel.content = textView.text
        updateForm()
    }
}
