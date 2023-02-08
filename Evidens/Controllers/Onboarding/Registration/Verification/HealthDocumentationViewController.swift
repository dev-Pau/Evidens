//
//  HealthDocumentationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/8/22.
//

import UIKit
import MessageUI
import PhotosUI
import JGProgressHUD

class HealthDocumentationViewController: UIViewController {
    
    private let user: User
    private let image: [UIImage]
    private let type: String
    
    private let registerBottomMenuLauncher = RegisterBottomMenuLauncher()
  
    private var selectedIdentityDocument: Int = 0
    private var frontSelected: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let progressIndicator = JGProgressHUD()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()

        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .label

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)

        button.isUserInteractionEnabled = true
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let verificationTitle: UILabel = {
        let label = UILabel()
        label.text = "Upload one of the following"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verificationString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "To complete your profile and verify your eligibility, upload one of the following documents: Diploma mentioning speciality, Medical certificate or Employment contract.")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: (aString.string as NSString).range(of: "To complete your profile and verify your eligibility, upload one of the following documents: Diploma mentioning speciality, Medical certificate or Employment contract."))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: (aString.string as NSString).range(of: "To complete your profile and verify your eligibility, upload one of the following documents: Diploma mentioning speciality, Medical certificate or Employment contract."))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "Diploma mentioning speciality"))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "Medical certificate"))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "Employment contract"))
        
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Diploma mentioning speciality"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Medical certificate"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Employment contract"))
        return aString
    }()
    
    lazy var verificationTextView: UITextView = {
        let tv = UITextView()
        tv.attributedText = verificationString
        //tv.delegate = self
        tv.isSelectable = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let tuitionString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "If you are a student, upload your current college tuition.")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: (aString.string as NSString).range(of: "If you are a student, upload your current college tuition."))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: (aString.string as NSString).range(of: "If you are a student, upload your current college tuition."))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "college tuition"))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "student"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "college tuition"))
        return aString
    }()
    
    lazy var tuitionTextView: UITextView = {
        let tv = UITextView()
        tv.attributedText = tuitionString
        //tv.delegate = self
        tv.isSelectable = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var frontImageBackgroundView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightColor
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    private lazy var topIdCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "camera.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        button.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(handlePhotoAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor.withAlphaComponent(0.5)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(user: User, image: [UIImage], type: String) {
        self.user = user
        self.image = image
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureNavigationBar() {
        title = "Verification"
        helpButton.menu = addMenuItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    private func configureUI() {
        registerBottomMenuLauncher.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(verificationTitle, verificationTextView, tuitionTextView, frontImageBackgroundView, topIdCardButton, submitButton)
        
        NSLayoutConstraint.activate([
            verificationTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            verificationTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            verificationTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            verificationTextView.topAnchor.constraint(equalTo: verificationTitle.bottomAnchor, constant: 7),
            verificationTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            verificationTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            tuitionTextView.topAnchor.constraint(equalTo: verificationTextView.bottomAnchor),
            tuitionTextView.leadingAnchor.constraint(equalTo: verificationTextView.leadingAnchor),
            tuitionTextView.trailingAnchor.constraint(equalTo: verificationTextView.trailingAnchor),
            
            frontImageBackgroundView.topAnchor.constraint(equalTo: tuitionTextView.bottomAnchor, constant: 10),
            frontImageBackgroundView.leadingAnchor.constraint(equalTo: verificationTitle.leadingAnchor),
            frontImageBackgroundView.trailingAnchor.constraint(equalTo: verificationTitle.trailingAnchor),
            frontImageBackgroundView.heightAnchor.constraint(equalToConstant: 200),
            
            topIdCardButton.centerXAnchor.constraint(equalTo: frontImageBackgroundView.centerXAnchor),
            topIdCardButton.centerYAnchor.constraint(equalTo: frontImageBackgroundView.centerYAnchor),
            topIdCardButton.heightAnchor.constraint(equalToConstant: 35),
            topIdCardButton.widthAnchor.constraint(equalToConstant: 35),
            
            submitButton.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            submitButton.leadingAnchor.constraint(equalTo: verificationTitle.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: verificationTitle.trailingAnchor)
        ])
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Contact support", image: UIImage(systemName: "tray.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                if MFMailComposeViewController.canSendMail() {
                    let controller = MFMailComposeViewController()
                    controller.setToRecipients(["support@myevidens.com"])
                    controller.mailComposeDelegate = self
                    self.present(controller, animated: true)
                } else {
                    print("Device cannot send email")
                }
            }),
            
            UIAction(title: "Log out", image: UIImage(systemName: "arrow.right.to.line", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                AuthService.logout()
                AuthService.googleLogout()
                let controller = WelcomeViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
        ])
        return menuItems
    }
    
    private func uploadSubmitButtonState() {
        if frontSelected {
            submitButton.isUserInteractionEnabled = true
            submitButton.backgroundColor = primaryColor
        }
        else {
            submitButton.isUserInteractionEnabled = false
            submitButton.backgroundColor = primaryColor.withAlphaComponent(0.5)
        }
    }
    
    
    @objc func handlePhotoAction() {
        registerBottomMenuLauncher.showImageSettings(in: view)
    }
    
    @objc func handleSubmit() {
        guard let customImage = frontImageBackgroundView.image, let uid = user.uid else { return }
        progressIndicator.show(in: view)
        StorageManager.uploadDocumentationImage(images: image, type: type, uid: uid) { uploaded in
            if uploaded {
                StorageManager.uploadDocumentationImage(images: [customImage], type: "custom", uid: uid) { uploaded in
                    self.progressIndicator.dismiss(animated: true)
                    if uploaded {

                        AuthService.updateUserRegistrationDocumentationDetails(withUid: uid) { error in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            // All documentation uploaded present Waiting VC
                            DatabaseManager.shared.insertUser(with: ChatUser(firstName: self.user.firstName!, lastName: self.user.lastName!, emailAddress: self.user.email!, uid: self.user.uid!, profilePictureUrl: self.user.profileImageUrl!, profession: self.user.profession!, speciality: self.user.speciality!, category: self.user.category.userCategoryString))
                            print("Doc uploaded")
                        }
                    }
                }
            }
        }
    }
}

extension HealthDocumentationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

extension HealthDocumentationViewController: RegisterBottomMenuLauncherDelegate {
    func didTapImportFromGallery() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        config.filter = PHPickerFilter.any(of: [.images])
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func didTapImportFromCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
}

extension HealthDocumentationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        frontImageBackgroundView.image = selectedImage
        frontSelected = true
        uploadSubmitButtonState()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension HealthDocumentationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.count == 0 { return }
        showLoadingView()
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.dismissLoadingView()
                    self.frontImageBackgroundView.image = image
                    self.frontSelected = true
                    self.uploadSubmitButtonState()
                }
                
            }
        }
    }
}


