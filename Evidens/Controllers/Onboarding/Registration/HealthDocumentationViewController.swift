//
//  HealthDocumentationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/8/22.
//

import UIKit
import MessageUI
import PhotosUI

class HealthDocumentationViewController: UIViewController {
    
    private let user: User
    private let registerBottomMenuLauncher = RegisterBottomMenuLauncher()
    private var selectedIdentityDocument: Int = 0
    private var frontSelected: Bool = false
    private var backSelected: Bool = false
    
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
        iv.backgroundColor = UIColor.init(rgb: 0xD5DBE7)
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
        
        scrollView.addSubviews(verificationTitle, verificationTextView, tuitionTextView, frontImageBackgroundView, topIdCardButton)
        
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
            frontImageBackgroundView.heightAnchor.constraint(equalToConstant: 180),
            
            topIdCardButton.centerXAnchor.constraint(equalTo: frontImageBackgroundView.centerXAnchor),
            topIdCardButton.centerYAnchor.constraint(equalTo: frontImageBackgroundView.centerYAnchor),
            topIdCardButton.heightAnchor.constraint(equalToConstant: 35),
            topIdCardButton.widthAnchor.constraint(equalToConstant: 35),
        ])
        
    }
    
    @objc func handlePhotoAction() {
        
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
    
    
}

extension HealthDocumentationViewController: HelperRegistrationViewControllerDelegate {
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
        /*
        frontImageBackgroundView.image = selectedImage
        frontIDLabel.isHidden = true
        frontSelected = true
        uploadSubmitButtonState()
         */
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension HealthDocumentationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        //guard let selectedImage = info[.editedImage] as? UIImage else { return }
        /*
        frontImageBackgroundView.image = selectedImage
        frontIDLabel.isHidden = true
        frontSelected = true
        uploadSubmitButtonState()
         */
    }
}


