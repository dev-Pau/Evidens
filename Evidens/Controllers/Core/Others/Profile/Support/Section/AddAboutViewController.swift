//
//  AddSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit
import JGProgressHUD

protocol AddAboutViewControllerDelegate: AnyObject {
    func handleUpdateAbout()
}

class AddAboutViewController: UIViewController {
    
    var comesFromOnboarding: Bool = false
    private var isEditingAbout: Bool = false
    private let progressIndicator = JGProgressHUD()
    
    var viewModel: OnboardingViewModel?
    var user: User?

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
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor.withAlphaComponent(0.5)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var skipLabel: UILabel = {
        let label = UILabel()
        label.text = "Skip for now"
        label.sizeToFit()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .bold)
        let textRange = NSRange(location: 0, length: label.text!.count)
        let attributedText = NSMutableAttributedString(string: label.text!)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: textRange)
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSkip)))
        return label
    }()
    
    weak var delegate: AddAboutViewControllerDelegate?
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: "About yourself")
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Your about me section briefly summarize the most important information you want the community to know from you. It can be used to showcase your professional experience, skills, your professional brand or any other information you want to share."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var aboutTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add about here"
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        //tv.placeholderLabel.textColor = UIColor(white: 0.2, alpha: 0.7)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = .label
        tv.delegate = self
        tv.isScrollEnabled = true
        tv.tintColor = primaryColor
        tv.backgroundColor = .quaternarySystemFill
        tv.layer.cornerRadius = 5
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSection()
        configureNavigationBar()
        configureUI()
    }
    
    init(isEditingAbout: Bool? = nil) {
        if let isEditingAbout = isEditingAbout { self.isEditingAbout = isEditingAbout }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchSection() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        DatabaseManager.shared.fetchAboutSection(forUid: uid) { result in
            switch result {
            case .success(let aboutText):
                self.aboutTextView.text = aboutText
                self.aboutTextView.handleTextDidChange()
            case .failure(_):
                print("Error fetching")
            }
        }
    }
    
    private func configureNavigationBar() {
        if comesFromOnboarding {
            #warning("Put app icon on bar")
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: isEditingAbout ? "Edit" : "Save", style: .done, target: self, action: #selector(handleDone))
            navigationItem.rightBarButtonItem?.tintColor = primaryColor
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(infoLabel, titleLabel, aboutTextView)
        
        if !comesFromOnboarding {
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                
                infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

                aboutTextView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
                aboutTextView.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
                aboutTextView.trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor),
                aboutTextView.heightAnchor.constraint(equalToConstant: 200)
            ])
        } else {
            scrollView.addSubviews(continueButton, skipLabel)
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
                titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                titleLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
                
                infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                infoLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                
                aboutTextView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
                aboutTextView.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
                aboutTextView.trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor),
                aboutTextView.heightAnchor.constraint(equalToConstant: 200),

                skipLabel.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
                skipLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                skipLabel.widthAnchor.constraint(equalToConstant: 150),
                
                continueButton.bottomAnchor.constraint(equalTo: skipLabel.topAnchor, constant: -10),
                continueButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 10),
                continueButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -10),
            ])
        }
    }
    
    func uploadUserOnboardingChanges() {
        guard let viewModel = viewModel, let user = user else { return }
        progressIndicator.show(in: view)
        if let text = viewModel.aboutText { DatabaseManager.shared.uploadAboutSection(with: text) { _ in }}
        
        if viewModel.hasProfile && viewModel.hasBanner {
            StorageManager.uploadProfileImages(images: [viewModel.bannerImage!, viewModel.profileImage!], userUid: user.uid!) { urls in

                let bannerUrl = urls.first(where: { url in
                    url.contains("banners")
                })!
                
                let profileUrl = urls.first(where: { url in
                    url.contains("profile_images")
                })!
                
                UserService.updateUserProfileImages(bannerImageUrl: bannerUrl, profileImageUrl: profileUrl) { user in
                    self.progressIndicator.dismiss(animated: true)
                    self.goToCompleteOnboardingVC(user: user)
                }
            }
        } else if viewModel.hasProfile {
            StorageManager.uploadProfileImage(image: viewModel.profileImage!, uid: user.uid!) { url, error  in
                self.progressIndicator.dismiss(animated: true)
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    UserService.updateUserProfileImages(profileImageUrl: url) { user in
                        self.goToCompleteOnboardingVC(user: user)
                    }
                }
            }
        } else if viewModel.hasBanner {
            StorageManager.uploadBannerImage(image: viewModel.bannerImage!, uid: user.uid!) { url, error in
                self.progressIndicator.dismiss(animated: true)
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    UserService.updateUserProfileImages(bannerImageUrl: url) { user in
                        self.goToCompleteOnboardingVC(user: user)
                    }
                }
            }
        } else {
            progressIndicator.dismiss(animated: true)
            goToCompleteOnboardingVC(user: self.user!)
        }
    }
    
    func goToCompleteOnboardingVC(user: User) {
        let controller = ProfileCompletedViewController(user: user, viewModel: viewModel!)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleDone() {
        guard let text = aboutTextView.text else { return }
        progressIndicator.show(in: view)
        DatabaseManager.shared.uploadAboutSection(with: text) { completed in
            self.progressIndicator.dismiss(animated: true)
            if completed {
                self.delegate?.handleUpdateAbout()
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    @objc func handleContinue() {
        uploadUserOnboardingChanges()
    }
    
    @objc func handleSkip() {
        viewModel?.aboutText = nil
        uploadUserOnboardingChanges()
    }
}

extension AddAboutViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if comesFromOnboarding {
            viewModel?.aboutText = textView.text
            continueButton.backgroundColor = textView.text.isEmpty ? primaryColor.withAlphaComponent(0.5) : primaryColor
            continueButton.isUserInteractionEnabled = textView.text.isEmpty ? false : true
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = textView.text.isEmpty ? false : true
    }
}
