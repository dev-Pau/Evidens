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
    
    private var comesFromOnboarding: Bool
    private var isEditingAbout: Bool = false
    
    var viewModel: OnboardingViewModel?
    var user: User?
    
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
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
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
        tv.font = .systemFont(ofSize: 16, weight: .regular)
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
    
    init(comesFromOnboarding: Bool) {
        self.comesFromOnboarding = comesFromOnboarding
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        aboutTextView.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        if comesFromOnboarding {
            addNavigationBarLogo(withTintColor: primaryColor)
        } else {
            title = AppStrings.Sections.aboutSection
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
       
        if comesFromOnboarding {
            scrollView.addSubviews(contentLabel, titleLabel, aboutTextView)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                aboutTextView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
                aboutTextView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
                aboutTextView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            ])
            
        } else {
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
            
        }
        
        aboutTextView.inputAccessoryView = addToolbar()
    }
    
    private func addToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
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
        shareContainer.font = .systemFont(ofSize: 14, weight: .semibold)
        shareConfig.attributedTitle = AttributedString(comesFromOnboarding ? AppStrings.Global.go : AppStrings.Global.save, attributes: shareContainer)
        shareConfig.cornerStyle = .capsule
        shareConfig.buttonSize = .mini
        shareConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.baseForegroundColor = .label
        
        var cancelContainer = AttributeContainer()
        cancelContainer.font = .systemFont(ofSize: 14, weight: .regular)
        cancelConfig.attributedTitle = AttributedString(comesFromOnboarding ? AppStrings.Global.skip : AppStrings.Miscellaneous.goBack, attributes: cancelContainer)
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
    
    func addUserChanges() {
        guard let viewModel = viewModel else { return }

        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
            return
        }
        
        if let text = viewModel.aboutText {
            DatabaseManager.shared.addAboutUs(withText: text) { [weak self] error in
                guard let _ = self else { return }
            }
        }
        
        showProgressIndicator(in: view)
        
        if viewModel.hasProfile && viewModel.hasBanner {
            guard let profile = viewModel.profileImage, let banner = viewModel.bannerImage else { return }
            let images = [banner, profile]
            StorageManager.addUserImages(images: images) { [weak self] result in
                guard let strongSelf = self else { return }
                
                switch result {
                case .success(let urls):
                    let bannerUrl = urls.first(where: { url in
                        url.contains("banner")
                    })!
                    
                    let profileUrl = urls.first(where: { url in
                        url.contains("profile")
                    })!
                    
                    UserService.updateUserImages(withBannerUrl: bannerUrl, withProfileUrl: profileUrl) { [weak self] user in
                        guard let strongSelf = self else { return }
                        strongSelf.dismissProgressIndicator()
                        if let user {
                            strongSelf.goToCompleteOnboardingVC(user: user)
                        } else {
                            strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                        }
                    }
                    
                case .failure(_):
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                    strongSelf.dismissProgressIndicator()
                }
            }
        } else if viewModel.hasProfile {
            guard let profile = viewModel.profileImage, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            StorageManager.addImage(image: profile, uid: uid, kind: .profile) { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                    
                case .success(let profileUrl):
                    
                    UserService.updateUserImages(withProfileUrl: profileUrl) { [weak self] user in
                        guard let strongSelf = self else { return }
                        strongSelf.dismissProgressIndicator()
                        if let user {
                            strongSelf.goToCompleteOnboardingVC(user: user)
                        } else {
                            strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                        }
                    }
                    
                case .failure(_):
                    strongSelf.dismissProgressIndicator()
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                }
            }
        } else if viewModel.hasBanner {
            guard let banner = viewModel.bannerImage, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            StorageManager.addImage(image: banner, uid: uid, kind: .banner) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let bannerUrl):

                    UserService.updateUserImages(withBannerUrl: bannerUrl) { [weak self] user in
                        guard let strongSelf = self else { return }
                        strongSelf.dismissProgressIndicator()
                        if let user {
                            strongSelf.goToCompleteOnboardingVC(user: user)
                        } else {
                            strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                        }
                    }
                    
                case .failure(_):
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                    strongSelf.dismissProgressIndicator()
                }
            }
        } else {
            dismissProgressIndicator()
            if let user {
                goToCompleteOnboardingVC(user: user)
            }
        }
    }
    
    func goToCompleteOnboardingVC(user: User) {
        let controller = ProfileCompletedViewController(user: user, viewModel: viewModel!)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func addAbout() {
        guard let text = aboutTextView.text else { return }
        showProgressIndicator(in: view)
        DatabaseManager.shared.addAboutUs(withText: text) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let _ = error {
                strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
            } else {
                strongSelf.delegate?.handleUpdateAbout()
                strongSelf.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func handleContinue() {
        if comesFromOnboarding {
            addUserChanges()
        } else {
            addAbout()
        }
    }
    
    @objc func handleSkip() {
        if comesFromOnboarding {
            viewModel?.aboutText = nil
            addUserChanges()
        } else {
            navigationController?.popViewController(animated: true)
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
}

extension AddAboutViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        if comesFromOnboarding {
            viewModel?.aboutText = textView.text
        }
        
        aboutButton.isEnabled = textView.text.isEmpty ? false : true
        
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


