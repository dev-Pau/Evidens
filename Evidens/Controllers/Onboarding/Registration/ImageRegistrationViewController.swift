//
//  ImageRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import PhotosUI
import MessageUI

class ImageRegistrationViewController: UIViewController {
    
    private let user: User
    
    private var imageSelected: Bool = false
    
    private let registerBottomMenuLauncher = RegisterBottomMenuLauncher()
                                                                                                                                
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let imageTextLabel: UILabel = {
        let label = CustomLabel(placeholder: "Pick a profile picture")
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "user")?.withTintColor(grayColor)
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightColor
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadPicture)))
        return iv
    }()
    
    private let instructionsImageLabel: UILabel = {
        let label = UILabel()
        label.text = "Posting a profile photo is optional, but it helps your connections and others to recognize you."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var uploadPictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "plus")?.scalePreservingAspectRatio(targetSize: CGSize(width: 45, height: 45)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(handleUploadPicture), for: .touchUpInside)
        return button
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
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleContinue)))
        return label
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()

        button.configuration?.baseBackgroundColor = lightGrayColor
        button.configuration?.baseForegroundColor = blackColor

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Help", attributes: container)
        
        button.isUserInteractionEnabled = true

        button.addTarget(self, action: #selector(handleHelp), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        registerBottomMenuLauncher.delegate = self
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Account details"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBack))
        navigationController?.navigationBar.tintColor = blackColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    private func configureUI() {
        
        profileImageView.layer.cornerRadius = 200 / 2

        view.backgroundColor = .white
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        scrollView.addSubviews(imageTextLabel, profileImageView, instructionsImageLabel, uploadPictureButton, skipLabel, continueButton)
        
        NSLayoutConstraint.activate([
            imageTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            imageTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageTextLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            
            profileImageView.topAnchor.constraint(equalTo: imageTextLabel.bottomAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 200),
            profileImageView.heightAnchor.constraint(equalToConstant: 200),
            
            instructionsImageLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            instructionsImageLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            instructionsImageLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            
            uploadPictureButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -10),
            uploadPictureButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 70),
            uploadPictureButton.widthAnchor.constraint(equalToConstant: 60),
            uploadPictureButton.heightAnchor.constraint(equalToConstant: 60),
            
            skipLabel.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            skipLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            skipLabel.widthAnchor.constraint(equalToConstant: 150),
            
            continueButton.bottomAnchor.constraint(equalTo: skipLabel.topAnchor, constant: -10),
            continueButton.leadingAnchor.constraint(equalTo: instructionsImageLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: instructionsImageLabel.trailingAnchor)
        ])
    }
    
    @objc func handleUploadPicture() {
        imageSelected ? registerBottomMenuLauncher.showImageSettings(in: view) : registerBottomMenuLauncher.showImageSettings(in: view)
    }
    
    @objc func handleContinue() {
        guard let uid = user.uid,
              let firstName = user.firstName,
              let lastName = user.lastName else { return }
        
        let credentials = AuthCredentials(firstName: firstName, lastName: lastName, email: "", password: "", profileImageUrl: "", phase: .verificationPhase, category: .none, profession: "", speciality: "")
        
        showLoadingView()
        
        AuthService.updateUserRegistrationNameDetails(withUid: uid, withCredentials: credentials) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if self.imageSelected {
                    guard let image = self.profileImageView.image else { return }
                    StorageManager.uploadProfileImage(image: image, uid: uid) { url in
                        UserService.updateProfileImageUrl(profileImageUrl: url) { error in
                            self.dismissLoadingView()
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                let controller = VerificationRegistrationViewController(user: self.user)
                                let nav = UINavigationController(rootViewController: controller)
                                nav.modalPresentationStyle = .fullScreen
                                self.present(nav, animated: true)
                            }
                        }
                    }
                } else {
                    self.dismissLoadingView()
                    let controller = VerificationRegistrationViewController(user: self.user)
                    let nav = UINavigationController(rootViewController: controller)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
                }
            }
        }
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
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

extension ImageRegistrationViewController: RegisterBottomMenuLauncherDelegate {
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

extension ImageRegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        profileImageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ImageRegistrationViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.count == 0 { return }
        showLoadingView()
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.dismissLoadingView()
                    self.profileImageView.image = image
                    self.uploadPictureButton.isHidden = true
                    self.continueButton.isUserInteractionEnabled = true
                    self.continueButton.backgroundColor = primaryColor
                    self.imageSelected = true
                }
            }
        }
    }
}

extension ImageRegistrationViewController: HelperRegistrationViewControllerDelegate {
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

extension ImageRegistrationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

