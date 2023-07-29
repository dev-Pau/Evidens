//
//  CaseResolvedViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/22.
//

import UIKit
import JGProgressHUD

protocol CaseDiagnosisViewControllerDelegate: AnyObject {
    func handleSolveCase(diagnosis: CaseRevision?, clinicalCase: Case?)
}

class CaseDiagnosisViewController: UIViewController {
    
    weak var delegate: CaseDiagnosisViewControllerDelegate?

    private var clinicalCase: Case?
    
    private var shareButton: UIButton!
    private var cancelButton: UIButton!
    
    private let charCount = 1000
    
    private let progressIndicator = JGProgressHUD()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Content.Case.Share.addDiagnosisTitle
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
        label.text = AppStrings.Content.Case.Share.addDiagnosisContent
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    
    private lazy var contentTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Case.Share.diagnosis
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = primaryColor
        tv.tintColor = primaryColor
        tv.layer.cornerRadius = 5
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
    
    init(clinicalCase: Case? = nil) {
        self.clinicalCase = clinicalCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureNavigationBar() {
        contentTextView.inputAccessoryView = addDiagnosisToolbar()
        if clinicalCase != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
            navigationItem.leftBarButtonItem?.tintColor = .label
            
        }
    }
    
    private func addDiagnosisToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        
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
        shareContainer.font = .systemFont(ofSize: 14, weight: .semibold)
        shareConfig.attributedTitle = AttributedString(AppStrings.Actions.share, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = .systemFont(ofSize: 14, weight: .regular)
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
        view.addSubview(scrollView)
        
        scrollView.addSubviews(profileImageView, textLabel, contentLabel, descriptionLabel, contentTextView, separatorView)

        contentTextView.delegate = self
        
        profileImageView.layer.cornerRadius = 40 / 2
        contentTextView.placeholderLabel.textColor = UIColor.tertiaryLabel

        if let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
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

            descriptionLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
            
            contentTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            contentTextView.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.contentTextView.becomeFirstResponder()
        }
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
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func shareCase() {
        guard let content = contentTextView.text else { return }
        let revision = CaseRevision(content: content, kind: .diagnosis)
        if let clinicalCase = clinicalCase {
            // We have a clinical case update acorrdingly
            CaseService.editCasePhase(to: .solved, withCaseId: clinicalCase.caseId, withDiagnosis: revision) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    print(error.localizedDescription)
                } else {
                    strongSelf.delegate?.handleSolveCase(diagnosis: revision, clinicalCase: clinicalCase)
                    let popUpView = PopUpBanner(title: AppStrings.PopUp.addCase, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popUpView.showTopPopup(inView: strongSelf.view)
                    strongSelf.dismiss(animated: true)
                }
            }
        } else {
            delegate?.handleSolveCase(diagnosis: revision, clinicalCase: nil)
        }
    }
    
    @objc func goBack() {
        if let clinicalCase {
            // Update Case stage without diagnosis
            #warning("posar dismiss diagnosis alert")
            /*
            dismissDiagnosisAlert { [weak self] in
                guard let strongSelf = self else { return }
                // User changes state to solved without diagnosis
                strongSelf.progressIndicator.show(in: strongSelf.view)
                CaseService.editCasePhase(to: .solved, withCaseId: clinicalCase.caseId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        print(error.localizedDescription)
                    } else {
                        strongSelf.delegate?.handleSolveCase(diagnosis: nil, clinicalCase: clinicalCase)
                        let popUpView = PopUpBanner(title: AppStrings.PopUp.solvedCase, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                        popUpView.showTopPopup(inView: strongSelf.view)
                        strongSelf.dismiss(animated: true)
                    }
                }
            }
             */
        } else {
            navigationController?.popViewController(animated: true)
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
        
        scrollView.resizeContentSize()
        
        if let shareButton { shareButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        navigationItem.rightBarButtonItem?.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let count = textView.text.count
        if count > charCount {
            textView.deleteBackward()
        }
    }
}
