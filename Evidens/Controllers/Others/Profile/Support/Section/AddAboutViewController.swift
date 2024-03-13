//
//  AddSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

protocol AddAboutViewControllerDelegate: AnyObject {
    func handleUpdateAbout()
}

class AddAboutViewController: UIViewController {
    
    private var aboutButton: UIButton!
    private var skipButton: UIButton!

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .none
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    weak var delegate: AddAboutViewControllerDelegate?
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Sections.aboutTitle)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Sections.aboutContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var aboutTextView: UITextView = {
        let tv = UITextView()
        tv.tintColor = primaryColor
        tv.textColor = .label
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        fetchAboutUs()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        aboutTextView.becomeFirstResponder()
    }
    
    private func fetchAboutUs() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        DatabaseManager.shared.fetchAboutUs(forUid: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let about):
                strongSelf.aboutTextView.text = about
            case .failure(let error):
                strongSelf.aboutTextView.text = ""
                
                guard error == .empty else {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    return
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Sections.aboutSection
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(contentLabel, aboutTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            aboutTextView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            aboutTextView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            aboutTextView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
        ])
        
        aboutTextView.inputAccessoryView = addToolbar()
    }
    
    private func addToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        aboutButton = UIButton(type: .system)
        aboutButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        
        skipButton = UIButton(type: .system)
        skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.baseBackgroundColor = primaryColor
        shareConfig.baseForegroundColor = .white
        var shareContainer = AttributeContainer()
        shareContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .semibold, scales: false)
        shareConfig.attributedTitle = AttributedString(AppStrings.Global.save, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular, scales: false)
        cancelConfig.attributedTitle = AttributedString(AppStrings.Miscellaneous.goBack, attributes: cancelContainer)
        cancelConfig.buttonSize = .mini
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        aboutButton.configuration = shareConfig
        
        skipButton.configuration = cancelConfig
        let rightButton = UIBarButtonItem(customView: aboutButton)

        let leftButton = UIBarButtonItem(customView: skipButton)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        toolbar.setItems([leftButton, flexibleSpace, rightButton], animated: false)
        
        aboutButton.isEnabled = false
                
        return toolbar
    }

    private func addAbout() {
        aboutTextView.resignFirstResponder()
        showProgressIndicator(in: view)
        
        guard let text = aboutTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DatabaseManager.shared.addAboutUs(withText: "") { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let _ = error {
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                } else {
                    strongSelf.delegate?.handleUpdateAbout()
                    strongSelf.navigationController?.popViewController(animated: true)
                    
                    let popupView = PopUpBanner(title: AppStrings.PopUp.aboutRemoved, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                    popupView.showTopPopup(inView: strongSelf.view)
                }
            }
            return
        }

        DatabaseManager.shared.addAboutUs(withText: text) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let _ = error {
                strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
            } else {
                strongSelf.delegate?.handleUpdateAbout()
                strongSelf.navigationController?.popViewController(animated: true)
                
                let popupView = PopUpBanner(title: AppStrings.PopUp.aboutAdded, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                popupView.showTopPopup(inView: strongSelf.view)
            }
        }
    }
    
    @objc func handleContinue() {
        addAbout()
    }
    
    @objc func handleSkip() {
        navigationController?.popViewController(animated: true)
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

extension AddAboutViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        aboutButton.isEnabled = true
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        scrollView.resizeContentSize()
        
        navigationItem.rightBarButtonItem?.isEnabled = textView.text.isEmpty ? false : true
    }
}


