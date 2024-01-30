//
//  CaseResolvedViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/22.
//

import UIKit

class CaseDiagnosisViewController: UIViewController {
    
    private var user: User?
    private var viewModel: ShareCaseViewModel?

    private var clinicalCase: Case?
    
    private var nextButtonConstraint: NSLayoutConstraint!

    private var shareButton: UIButton!
    private var cancelButton: UIButton!
    
    private let charCount = 1000
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.next, attributes: container)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = AppStrings.Content.Case.Share.diagnosisContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        return label
    }()
    
    private lazy var contentTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Case.Share.diagnosis
        let font = UIFont.addFont(size: 17, scaleStyle: .title2, weight: .regular)
        tv.placeholderLabel.font = font
        tv.font = font
        tv.textColor = .label
        tv.tintColor = .label
        tv.autocorrectionType = .no
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainerInset = UIEdgeInsets.zero
        tv.layer.cornerRadius = 0
        tv.textContainer.lineFragmentPadding = .zero
        return tv
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = AppStrings.Content.Case.Share.diagnosis
        label.alpha = 0
        return label
    }()
    
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(clinicalCase: Case) {
        self.clinicalCase = clinicalCase
        self.user = nil
        self.viewModel = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(user: User, viewModel: ShareCaseViewModel) {
        self.clinicalCase = nil
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentTextView.resignFirstResponder()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: primaryColor)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .label
        
        if clinicalCase != nil {
            contentTextView.inputAccessoryView = addDiagnosisToolbar()
            contentTextView.isScrollEnabled = false
        } else {
            scrollView.keyboardDismissMode = .onDrag
            contentTextView.isScrollEnabled = true
        }
    }
    
    private func addDiagnosisToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        shareButton = UIButton(type: .system)
        shareButton.addTarget(self, action: #selector(shareCase), for: .touchUpInside)
        
        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.baseBackgroundColor = primaryColor
        shareConfig.baseForegroundColor = .white
        var shareContainer = AttributeContainer()
        shareContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .semibold, scales: false)
        shareConfig.attributedTitle = AttributedString(AppStrings.Actions.share, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular, scales: false)
        cancelConfig.attributedTitle = AttributedString(clinicalCase != nil ? AppStrings.Content.Case.Share.skip : AppStrings.Miscellaneous.goBack, attributes: cancelContainer)
        cancelConfig.buttonSize = .mini
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        shareButton.configuration = shareConfig
        cancelButton.configuration = cancelConfig
        
        let rightButton = UIBarButtonItem(customView: shareButton)

        let leftButton = UIBarButtonItem(customView: cancelButton)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        toolbar.setItems([leftButton, flexibleSpace, rightButton], animated: false)
        
        shareButton.isEnabled = false
                
        return toolbar
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .none

        nextButtonConstraint = nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        view.addSubview(scrollView)
        
        scrollView.addSubviews(contentLabel, descriptionLabel, contentTextView, nextButton)

        contentTextView.delegate = self
        
        contentTextView.placeholderLabel.textColor = UIColor.tertiaryLabel

        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            descriptionLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            contentTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            contentTextView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),

            nextButtonConstraint,
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        if clinicalCase == nil {
            contentTextView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20).isActive = true
        } else {
            nextButton.removeFromSuperview()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if clinicalCase != nil {
            
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
        } else {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {

                if notification.name == UIResponder.keyboardWillHideNotification {
                    
                    UIView.animate(withDuration: duration) { [weak self] in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.nextButtonConstraint.constant = 0
                        strongSelf.view.layoutIfNeeded()
                    }
                } else {
                    UIView.animate(withDuration: duration) { [weak self] in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.nextButtonConstraint.constant = -keyboardSize.height + 10
                        strongSelf.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        if let _ = clinicalCase {
            dismiss(animated: true)
        } else {
            displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
            }
        }
    }
    
    @objc func handleNext() {
        let diagnosis = contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !diagnosis.isEmpty, var viewModel = viewModel, let user = user else { return }
        
        viewModel.diagnosis = CaseRevision(content: diagnosis, kind: .diagnosis)

        let controller = ShareCasePrivacyViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func shareCase() {
        guard let content = contentTextView.text, let clinicalCase = clinicalCase else { return }
        
        let revision = CaseRevision(content: content, kind: .diagnosis)

        showProgressIndicator(in: view)
        contentTextView.resignFirstResponder()
        
        CaseService.editCasePhase(to: .solved, withCaseId: clinicalCase.caseId, withDiagnosis: revision) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {

                ContentManager.shared.solveCaseChange(caseId: clinicalCase.caseId, diagnosis: .diagnosis)

                let popUpView = PopUpBanner(title: AppStrings.PopUp.addCase, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                popUpView.showTopPopup(inView: strongSelf.view)
                strongSelf.dismiss(animated: true)
            }
        }
    }
    
    @objc func goBack() {
        guard let clinicalCase = clinicalCase else { return }
        
        displayAlert(withTitle: AppStrings.Content.Case.Share.skip, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.skip, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showProgressIndicator(in: strongSelf.view)
            strongSelf.contentTextView.resignFirstResponder()
            
            CaseService.editCasePhase(to: .solved, withCaseId: clinicalCase.caseId) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    
                    ContentManager.shared.solveCaseChange(caseId: clinicalCase.caseId, diagnosis: nil)
                    
                    let popUpView = PopUpBanner(title: AppStrings.PopUp.solvedCase, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popUpView.showTopPopup(inView: strongSelf.view)
                    strongSelf.dismiss(animated: true)
                }
            }
        }
    }
}

extension CaseDiagnosisViewController: UITextViewDelegate {
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
        
        nextButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if clinicalCase != nil {
            scrollView.resizeContentSize()
        }

        if let shareButton { shareButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        let count = textView.text.count
        if count > charCount {
            textView.deleteBackward()
        }
    }
}
