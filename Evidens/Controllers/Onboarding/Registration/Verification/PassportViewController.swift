//
//  PassportViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit
import MessageUI
import PhotosUI
import JGProgressHUD

class PassportViewController: UIViewController {
    
    private var user: User
    
    private let registerBottomMenuLauncher = RegisterBottomMenuLauncher()
    private let helperBottomRegistrationMenuLauncher = HelperBottomMenuLauncher()
    
    private var hasCode: Bool = false
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
        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = .quaternarySystemFill
        button.configuration?.baseForegroundColor = .label

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Help", attributes: container)
     
        button.isUserInteractionEnabled = true

        button.addTarget(self, action: #selector(handleHelp), for: .touchUpInside)
        return button
    }()
    
    private let idCardVerificationTitle: UILabel = {
        let label = UILabel()
        label.text = "Upload Passport Photo"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    

    private let idCardVerificationSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Please make sure that the materials you provide are real, clear and correct. If not, the verification will fail and therefore slow down your verification process."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var frontImageBackgroundView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    private let frontIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Passport"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private let membershipCodeConditionsString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "I acknowledge that I am able to provide my membership code. If not, press Next to continue.")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: (aString.string as NSString).range(of: "I acknowledge that I am able to provide my membership code. If not, press Next to continue."))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: (aString.string as NSString).range(of: "I acknowledge that I am able to provide my membership code. If not, press Next to continue."))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "membership code"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "membership code"))
        return aString
    }()
    
    private lazy var squareButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "square")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
        button.configuration?.baseForegroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleMembershipConditions), for: .touchUpInside)
        return button
    }()
    
    lazy var membershipCodeTextView: UITextView = {
        let tv = UITextView()
        tv.attributedText = membershipCodeConditionsString
        //tv.delegate = self
        tv.isSelectable = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var membershipCodeTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Membership code")
        tf.tintColor = primaryColor
        tf.keyboardType = .numberPad
        tf.isHidden = true
        tf.clearButtonMode = .whileEditing
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        helperBottomRegistrationMenuLauncher.delegate = self
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureNavigationBar() {
        title = "Verification"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    private func configureUI() {
        registerBottomMenuLauncher.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(idCardVerificationTitle, idCardVerificationSubtitle, frontImageBackgroundView, topIdCardButton, submitButton, frontIDLabel, squareButton, membershipCodeTextView, membershipCodeTextField)
        
        NSLayoutConstraint.activate([
            idCardVerificationTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            idCardVerificationTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            idCardVerificationTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            idCardVerificationSubtitle.topAnchor.constraint(equalTo: idCardVerificationTitle.bottomAnchor, constant: 10),
            idCardVerificationSubtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            idCardVerificationSubtitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            frontImageBackgroundView.topAnchor.constraint(equalTo: idCardVerificationSubtitle.bottomAnchor, constant: 20),
            frontImageBackgroundView.leadingAnchor.constraint(equalTo: idCardVerificationTitle.leadingAnchor),
            frontImageBackgroundView.trailingAnchor.constraint(equalTo: idCardVerificationTitle.trailingAnchor),
            frontImageBackgroundView.heightAnchor.constraint(equalToConstant: 200),
            
            squareButton.topAnchor.constraint(equalTo: frontImageBackgroundView.bottomAnchor, constant: 20),
            squareButton.leadingAnchor.constraint(equalTo: frontImageBackgroundView.leadingAnchor),
            squareButton.heightAnchor.constraint(equalToConstant: 24),
            squareButton.widthAnchor.constraint(equalToConstant: 24),
            
            topIdCardButton.centerXAnchor.constraint(equalTo: frontImageBackgroundView.centerXAnchor),
            topIdCardButton.centerYAnchor.constraint(equalTo: frontImageBackgroundView.centerYAnchor),
            topIdCardButton.heightAnchor.constraint(equalToConstant: 35),
            topIdCardButton.widthAnchor.constraint(equalToConstant: 35),
            
            frontIDLabel.topAnchor.constraint(equalTo: topIdCardButton.bottomAnchor, constant: 5),
            frontIDLabel.centerXAnchor.constraint(equalTo: frontImageBackgroundView.centerXAnchor),
            frontIDLabel.leadingAnchor.constraint(equalTo: frontImageBackgroundView.leadingAnchor),
            frontIDLabel.trailingAnchor.constraint(equalTo: frontImageBackgroundView.trailingAnchor),
            
            membershipCodeTextField.topAnchor.constraint(equalTo: squareButton.bottomAnchor, constant: 13),
            membershipCodeTextField.leadingAnchor.constraint(equalTo: squareButton.leadingAnchor),
            membershipCodeTextField.trailingAnchor.constraint(equalTo: idCardVerificationTitle.trailingAnchor),
            
            submitButton.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            submitButton.leadingAnchor.constraint(equalTo: idCardVerificationTitle.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: idCardVerificationTitle.trailingAnchor),
            
            membershipCodeTextView.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            membershipCodeTextView.leadingAnchor.constraint(equalTo: squareButton.trailingAnchor, constant: 4),
            membershipCodeTextView.trailingAnchor.constraint(equalTo: idCardVerificationTitle.trailingAnchor),
        ])
    }
    
    private func uploadSubmitButtonState() {
        if frontSelected {
            if !hasCode {
                submitButton.isUserInteractionEnabled = true
                submitButton.backgroundColor = primaryColor
                submitButton.setTitle("Next", for: .normal)
            } else {
                guard let text = membershipCodeTextField.text else { return }
                submitButton.isUserInteractionEnabled = text.isEmpty ? false : true
                submitButton.backgroundColor = text.isEmpty ? primaryColor.withAlphaComponent(0.5) : primaryColor
                submitButton.setTitle("Submit", for: .normal)
            }
        }
    }
    
    @objc func handleHelp() {
        helperBottomRegistrationMenuLauncher.showImageSettings(in: view)
    }
    
    @objc func handlePhotoAction() {
        registerBottomMenuLauncher.showImageSettings(in: view)
    }
    
    @objc func handleSubmit() {
        guard let frontImage = frontImageBackgroundView.image else { return }
        if hasCode {
            guard let uid = user.uid, let membershipCode = membershipCodeTextField.text else { return }
            progressIndicator.show(in: view)
            StorageManager.uploadDocumentationImage(images: [frontImage], type: "passport", uid: uid) { uploaded in
                
                if uploaded {
                    
                    AuthService.updateUserRegistrationDocumentationDetails(withUid: uid, withMembershipCode: membershipCode) { error in
                        self.progressIndicator.dismiss(animated: true)
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        DatabaseManager.shared.insertUser(with: ChatUser(firstName: self.user.firstName!, lastName: self.user.lastName!, emailAddress: self.user.email!, uid: self.user.uid!, profilePictureUrl: self.user.profileImageUrl!, profession: self.user.profession!, speciality: self.user.speciality!, category: self.user.category.userCategoryString))
                        
                        let controller = WaitingVerificationViewController(user: self.user)
                        let navigationController = UINavigationController(rootViewController: controller)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true)
                    }
                }
            }
        } else {
            let controller = HealthDocumentationViewController(user: user, image: [frontImage], type: "passport")
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func textDidChange() {
        uploadSubmitButtonState()
    }
    
    @objc func handleMembershipConditions() {
        hasCode.toggle()
        squareButton.configuration?.image = hasCode ? UIImage(systemName: "checkmark.square.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor) : UIImage(systemName: "square")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
        membershipCodeTextField.isHidden = hasCode ? false : true
        uploadSubmitButtonState()
    }
    
}


extension PassportViewController: RegisterBottomMenuLauncherDelegate {
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


extension PassportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

extension PassportViewController: HelperBottomMenuLauncherDelegate {
    func didTapContactSupport() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setToRecipients(["support@myevidens.com"])
            controller.mailComposeDelegate = self
            present(controller, animated: true)
        } else {
            print("Device cannot send email")
        }
    }
    
    func didTapLogout() {
        AuthService.logout()
        AuthService.googleLogout()
        let controller = WelcomeViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

extension PassportViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        frontImageBackgroundView.image = selectedImage
        frontIDLabel.isHidden = true
        frontSelected = true
        uploadSubmitButtonState()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension PassportViewController: PHPickerViewControllerDelegate {
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
                    self.frontIDLabel.isHidden = true
                    self.frontSelected = true
                    self.uploadSubmitButtonState()
                }
                
            }
        }
    }
}



