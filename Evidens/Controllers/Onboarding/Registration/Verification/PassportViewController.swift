//
//  PassportViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit
import MessageUI
import PhotosUI

class PassportViewController: UIViewController {
    
    private var user: User
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
    
    private let idCardVerificationTitle: UILabel = {
        let label = UILabel()
        label.text = "Upload Passport Photo"
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
        button.addTarget(self, action: #selector(handlePhotoAction), for: .touchUpInside)
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
        label.text = "Upload Driver's License (Front)"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
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
        
        scrollView.addSubviews(idCardVerificationTitle, idCardVerificationSubtitle, frontImageBackgroundView, topIdCardButton, submitButton, frontIDLabel)
        
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
            frontImageBackgroundView.heightAnchor.constraint(equalToConstant: 180),
            
            topIdCardButton.centerXAnchor.constraint(equalTo: frontImageBackgroundView.centerXAnchor),
            topIdCardButton.centerYAnchor.constraint(equalTo: frontImageBackgroundView.centerYAnchor),
            topIdCardButton.heightAnchor.constraint(equalToConstant: 35),
            topIdCardButton.widthAnchor.constraint(equalToConstant: 35),
            
            frontIDLabel.topAnchor.constraint(equalTo: topIdCardButton.bottomAnchor, constant: 5),
            frontIDLabel.centerXAnchor.constraint(equalTo: frontImageBackgroundView.centerXAnchor),
            frontIDLabel.leadingAnchor.constraint(equalTo: frontImageBackgroundView.leadingAnchor),
            frontIDLabel.trailingAnchor.constraint(equalTo: frontImageBackgroundView.trailingAnchor),
            
            submitButton.topAnchor.constraint(equalTo: frontImageBackgroundView.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: frontImageBackgroundView.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: frontImageBackgroundView.trailingAnchor)
        ])
    }
    
    private func uploadSubmitButtonState() {
            submitButton.isUserInteractionEnabled = true
            submitButton.backgroundColor = primaryColor
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
    
    @objc func handlePhotoAction() {
        registerBottomMenuLauncher.showImageSettings(in: view)
    }
    
    @objc func handleSubmit() {
        print("Submit user doc here")
    }
}


extension PassportViewController: HelperRegistrationViewControllerDelegate {
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

extension PassportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
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



