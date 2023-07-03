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
    
    var stageIsUpdating: Bool = false
    var diagnosisIsUpdating: Bool = false
    var caseId: String = ""
    var groupId: String?

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
        iv.image = UIImage(named: "user.profile")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Add your diagnosis and treatment details."
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
        label.text = "Add the diagnosis, observations, or any significant developments to keep others informed. Please note that for anonymously shared cases, the diagnosis will also remain anonymous."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    
    private lazy var contentTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Diagnosis"
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
        label.text = "Diagnosis"
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
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
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
        shareConfig.attributedTitle = AttributedString("Share", attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = .systemFont(ofSize: 14, weight: .regular)
        cancelConfig.attributedTitle = AttributedString(clinicalCase != nil ? "Skip Diagnosis" : "Go back", attributes: cancelContainer)
        cancelConfig.buttonSize = .mini
        
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

        //diagnosisTextView.placeholderLabel.text = diagnosisText.count > 0 ? "" : "Add your diagnosis here..."
        //diagnosisTextView.text = diagnosisText
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
            scrollView.resizeScrollViewContentSize()
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
            scrollView.resizeScrollViewContentSize()
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
            CaseService.updateCaseStage(to: .resolved, withCaseId: clinicalCase.caseId, withDiagnosis: revision) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    print(error.localizedDescription)
                } else {
                    strongSelf.delegate?.handleSolveCase(diagnosis: revision, clinicalCase: clinicalCase)
                    let popUpView = METopPopupView(title: "The case has been marked as solved and your diagnosis has been added.", image: AppStrings.Icons.checkmarkCircleFill, popUpType: .regular)
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
            dismissDiagnosisAlert { [weak self] in
                guard let strongSelf = self else { return }
                // User changes state to solved without diagnosis
                strongSelf.progressIndicator.show(in: strongSelf.view)
                CaseService.updateCaseStage(to: .resolved, withCaseId: clinicalCase.caseId) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        print(error.localizedDescription)
                    } else {
                        strongSelf.delegate?.handleSolveCase(diagnosis: nil, clinicalCase: clinicalCase)
                        let popUpView = METopPopupView(title: "The case has been marked as solved.", image: AppStrings.Icons.checkmarkCircleFill, popUpType: .regular)
                        popUpView.showTopPopup(inView: strongSelf.view)
                        strongSelf.dismiss(animated: true)
                    }
                }
            }
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
        
        scrollView.resizeScrollViewContentSize()
        
        if let shareButton { shareButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        navigationItem.rightBarButtonItem?.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let count = textView.text.count
        if count > 1000 {
            textView.deleteBackward()
        }
    }
}
