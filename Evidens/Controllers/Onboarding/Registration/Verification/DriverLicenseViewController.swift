//
//  DriverLicenseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit
import MessageUI
import PhotosUI

class DriverLicenseViewController: UIViewController {
    
    private var user: User
    private let registerBottomMenuLauncher = RegisterBottomMenuLauncher()
    private var selectedIdentityDocument: Int = 0
    private var frontSelected: Bool = false
    private var backSelected: Bool = false
    private var hasCode: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()

        button.configuration?.baseBackgroundColor = lightGrayColor
        button.configuration?.baseForegroundColor = .black

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
        label.text = "Upload Driver's License Photo"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
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
        button.addTarget(self, action: #selector(handlePhotoAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomIdCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "camera.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        button.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(handlePhotoAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private let idCardVerificationSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Please make sure that the materials you provide are real, clear and correct. If not, the verification will fail and therefore slow down your verification process."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
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
        iv.backgroundColor = UIColor.init(rgb: 0xD5DBE7)
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    private let frontIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Driver's License (Front)"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Driver's License (Back)"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backImageBackgroundView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.init(rgb: 0xD5DBE7)
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    private let membershipCodeConditionsString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "I acknowledge that I am able to provide my membership code. If not, press Next to continue.")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: (aString.string as NSString).range(of: "I acknowledge that I am able to provide my membership code. If not, press Next to continue."))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: grayColor, range: (aString.string as NSString).range(of: "I acknowledge that I am able to provide my membership code. If not, press Next to continue."))
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
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
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
    
    private lazy var membershipCodeTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Membership code")
        tf.tintColor = primaryColor
        tf.keyboardType = .numberPad
        tf.isHidden = true
        tf.clearButtonMode = .whileEditing
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
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
        
        scrollView.addSubviews(idCardVerificationTitle, idCardVerificationSubtitle, frontImageBackgroundView, backImageBackgroundView, topIdCardButton, bottomIdCardButton, frontIDLabel, backIDLabel, squareButton, membershipCodeTextView, membershipCodeTextField, submitButton)
        
        NSLayoutConstraint.activate([
            idCardVerificationTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            idCardVerificationTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            idCardVerificationTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            idCardVerificationSubtitle.topAnchor.constraint(equalTo: idCardVerificationTitle.bottomAnchor, constant: 10),
            idCardVerificationSubtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            idCardVerificationSubtitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            frontImageBackgroundView.topAnchor.constraint(equalTo: idCardVerificationSubtitle.bottomAnchor, constant: 20),
            frontImageBackgroundView.leadingAnchor.constraint(equalTo: idCardVerificationTitle.leadingAnchor),
            frontImageBackgroundView.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 15),
            frontImageBackgroundView.heightAnchor.constraint(equalToConstant: 130),
            
            topIdCardButton.centerXAnchor.constraint(equalTo: frontImageBackgroundView.centerXAnchor),
            topIdCardButton.centerYAnchor.constraint(equalTo: frontImageBackgroundView.centerYAnchor),
            topIdCardButton.heightAnchor.constraint(equalToConstant: 35),
            topIdCardButton.widthAnchor.constraint(equalToConstant: 35),
            
            frontIDLabel.topAnchor.constraint(equalTo: topIdCardButton.bottomAnchor, constant: 5),
            frontIDLabel.centerXAnchor.constraint(equalTo: frontImageBackgroundView.centerXAnchor),
            frontIDLabel.leadingAnchor.constraint(equalTo: frontImageBackgroundView.leadingAnchor),
            frontIDLabel.trailingAnchor.constraint(equalTo: frontImageBackgroundView.trailingAnchor),
            
            backImageBackgroundView.topAnchor.constraint(equalTo: idCardVerificationSubtitle.bottomAnchor, constant: 20),
            backImageBackgroundView.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 15),
            backImageBackgroundView.trailingAnchor.constraint(equalTo: idCardVerificationTitle.trailingAnchor),
            backImageBackgroundView.heightAnchor.constraint(equalToConstant: 130),
            
            bottomIdCardButton.centerXAnchor.constraint(equalTo: backImageBackgroundView.centerXAnchor),
            bottomIdCardButton.centerYAnchor.constraint(equalTo: backImageBackgroundView.centerYAnchor),
            bottomIdCardButton.heightAnchor.constraint(equalToConstant: 35),
            bottomIdCardButton.widthAnchor.constraint(equalToConstant: 35),
            
            backIDLabel.topAnchor.constraint(equalTo: bottomIdCardButton.bottomAnchor, constant: 5),
            backIDLabel.centerXAnchor.constraint(equalTo: backImageBackgroundView.centerXAnchor),
            backIDLabel.leadingAnchor.constraint(equalTo: backImageBackgroundView.leadingAnchor),
            backIDLabel.trailingAnchor.constraint(equalTo: backImageBackgroundView.trailingAnchor),
            
            squareButton.topAnchor.constraint(equalTo: frontImageBackgroundView.bottomAnchor, constant: 20),
            squareButton.leadingAnchor.constraint(equalTo: frontImageBackgroundView.leadingAnchor),
            squareButton.heightAnchor.constraint(equalToConstant: 24),
            squareButton.widthAnchor.constraint(equalToConstant: 24),
            
            membershipCodeTextView.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            membershipCodeTextView.leadingAnchor.constraint(equalTo: squareButton.trailingAnchor, constant: 4),
            membershipCodeTextView.trailingAnchor.constraint(equalTo: idCardVerificationTitle.trailingAnchor),
            
            membershipCodeTextField.topAnchor.constraint(equalTo: squareButton.bottomAnchor, constant: 13),
            membershipCodeTextField.leadingAnchor.constraint(equalTo: squareButton.leadingAnchor),
            membershipCodeTextField.trailingAnchor.constraint(equalTo: idCardVerificationTitle.trailingAnchor),
            
            submitButton.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            submitButton.leadingAnchor.constraint(equalTo: idCardVerificationTitle.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: idCardVerificationTitle.trailingAnchor)
        ])
    }
    
    private func uploadSubmitButtonState() {
        if backSelected && frontSelected {
            
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
    
    @objc func textDidChange() {
        uploadSubmitButtonState()
    }
    
    @objc func handleHelp() {
        DispatchQueue.main.async {
            let controller = HelperRegistrationViewController()
            controller.delegate = self
            if let sheet = controller.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            self.present(controller, animated: true)
        }
    }
    
    @objc func handlePhotoAction(_ sender: UIButton) {
        if sender == topIdCardButton {
            selectedIdentityDocument = 0
        } else {
            selectedIdentityDocument = 1
        }
        registerBottomMenuLauncher.showImageSettings(in: view)
    }
    
    @objc func handleMembershipConditions() {
        hasCode.toggle()
        squareButton.configuration?.image = hasCode ? UIImage(systemName: "checkmark.square.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor) : UIImage(systemName: "square")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
        membershipCodeTextField.isHidden = hasCode ? false : true
        uploadSubmitButtonState()
    }
    
    @objc func handleSubmit() {
        if hasCode {
            guard let frontImage = frontImageBackgroundView.image, let backImage = backImageBackgroundView.image, let uid = user.uid else { return }
            showLoadingView()
            StorageManager.uploadDocumentationImage(images: [frontImage, backImage], type: "driver", uid: uid) { uploaded in
                if uploaded {
                    AuthService.updateUserRegistrationDocumentationDetails(withUid: uid) { error in
                        self.dismissLoadingView()
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } else {
            let controller = HealthDocumentationViewController(user: user)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
       

extension DriverLicenseViewController: HelperRegistrationViewControllerDelegate {
    func didTapLogout() {
        AuthService.logout()
        AuthService.googleLogout()
        let controller = WelcomeViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    
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
}

extension DriverLicenseViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

extension DriverLicenseViewController: RegisterBottomMenuLauncherDelegate {
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

extension DriverLicenseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        if selectedIdentityDocument == 0 {
            frontImageBackgroundView.image = selectedImage
            frontIDLabel.isHidden = true
            frontSelected = true
            uploadSubmitButtonState()
        } else {
            backImageBackgroundView.image = selectedImage
            backIDLabel.isHidden = true
            backSelected = true
            uploadSubmitButtonState()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension DriverLicenseViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.count == 0 { return }
        showLoadingView()
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.dismissLoadingView()
                    if self.selectedIdentityDocument == 0 {
                        self.frontImageBackgroundView.image = image
                        self.frontIDLabel.isHidden = true
                        self.frontSelected = true
                        self.uploadSubmitButtonState()
                        
                    } else {
                        self.backImageBackgroundView.image = image
                        self.backIDLabel.isHidden = true
                        self.backSelected = true
                        self.uploadSubmitButtonState()
                    }
                    
                }
            }
        }
    }
}

