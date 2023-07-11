//
//  ImageRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import PhotosUI
import MessageUI
import JGProgressHUD
import CropViewController

class ImageRegistrationViewController: UIViewController {
    
    private let user: User
    var comesFromHomeOnboarding: Bool = false
    private lazy var viewModel = OnboardingViewModel()
    private var imageSelected: Bool = false
                                                                          
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
    
    private let imageTextLabel: UILabel = {
        let label = CustomLabel(placeholder: "Pick a profile picture")
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "user.profile")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let instructionsImageLabel: UILabel = {
        let label = UILabel()
        label.text = "Posting a profile photo is optional, but it helps your connections and others to recognize you."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
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
        button.isUserInteractionEnabled = true
        //button.addTarget(self, action: #selector(handleUploadPicture), for: .touchUpInside)
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
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSkip)))
        return label
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .label
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Help", attributes: container)
        button.isUserInteractionEnabled = true
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        if imageSelected == true && comesFromHomeOnboarding {
            viewModel.profileImage = profileImageView.image
        }
    }
    
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
        if comesFromHomeOnboarding {
            //newUser = user
            if let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" {
                profileImageView.sd_setImage(with: URL(string: imageUrl))
                //continueButton.backgroundColor = primaryColor
                //continueButton.isUserInteractionEnabled = true
            }
        } else {
            title = "Account details"
            helpButton.menu = addMenuItems()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
        }
    }
    
    private func configureUI() {
        profileImageView.layer.cornerRadius = 200 / 2

        view.backgroundColor = .systemBackground
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
        
        uploadPictureButton.showsMenuAsPrimaryAction = true
        uploadPictureButton.menu = addImageButtonItems()
    }
    
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
    
    private func addImageButtonItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Import from Camera", image: UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                self.didTapImportFromCamera()
            }),
            
            UIAction(title: "Choose from Gallery", image: UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                self.didTapImportFromGallery()
            })
        ])
        return menuItems
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Contact Support", image: UIImage(systemName: "tray.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                if MFMailComposeViewController.canSendMail() {
                    let controller = MFMailComposeViewController()
                    controller.setToRecipients(["support@myevidens.com"])
                    controller.mailComposeDelegate = self
                    self.present(controller, animated: true)
                } else {
                    print("Device cannot send email")
                }
            }),
            
            UIAction(title: "Log Out", image: UIImage(systemName: "arrow.right.to.line", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                AuthService.logout()
                AuthService.googleLogout()
                let controller = OpeningViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
        ])
        return menuItems
    }

    @objc func handleContinue() {
        if comesFromHomeOnboarding {
            let controller = BannerRegistrationViewController(user: user, viewModel: viewModel)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
        
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        } else {
            guard let uid = user.uid,
                  let firstName = user.firstName,
                  let lastName = user.lastName else { return }
            
            if imageSelected {
                
            } else {
                
            }
            /*
            let credentials = AuthCredentials(firstName: firstName, lastName: lastName, email: "", password: "", profileImageUrl: "", phase: .verificationPhase, category: .none, profession: "", speciality: "", interests: user.interests ?? [])
            
            progressIndicator.show(in: view)
            
            AuthService.updateUserRegistrationNameDetails(withUid: uid, withCredentials: credentials) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if self.imageSelected {
                        guard let image = self.profileImageView.image else { return }
                        StorageManager.uploadProfileImage(image: image, uid: uid) { url, error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                guard let url = url else { return }
                                UserService.updateProfileImageUrl(profileImageUrl: url) { error in
                                    //self.newUser.profileImageUrl = url
                                    //DatabaseManager.shared.insertUser(with: ChatUser(firstName: credentials.firstName, lastName: credentials.lastName, //emailAddress: credentials.email, uid: uid))
                                    self.progressIndicator.dismiss(animated: true)
                                    
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
                        }
                    } else {
                        self.progressIndicator.dismiss(animated: true)
                        //self.user.profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/evidens-ec6bd.appspot.com/o/profile_images%2FprofileImage.png?alt=media&token=30c5ae77-8f49-4f1b-9edf-49eda8a7e58f"
                        let controller = VerificationRegistrationViewController(user: self.user)
                        
                        let nav = UINavigationController(rootViewController: controller)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true)
                    }
                }
            }
             */
        }
    }
    
    @objc func handleSkip() {
        if comesFromHomeOnboarding {
            viewModel.profileImage = nil
            
            let controller = BannerRegistrationViewController(user: user, viewModel: viewModel)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
        
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        } else {
            handleContinue()
        }
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func showCrop(image: UIImage) {
        let controller = TOCropViewController(croppingStyle: .circular, image: image)
        
        controller.doneButtonTitle = "Done"
        controller.cancelButtonTitle = "Cancel"

        controller.delegate = self
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        
        self.present(navVC, animated: true)
    }
}

extension ImageRegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        showCrop(image: selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ImageRegistrationViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if results.count == 0 { return }
        progressIndicator.show(in: view)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                
                DispatchQueue.main.async {
                    picker.dismiss(animated: true)
                    self.progressIndicator.dismiss(animated: true)
                    self.showCrop(image: image)
                    
                }
            }
        }
    }
}

extension ImageRegistrationViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        self.profileImageView.image = image
        self.uploadPictureButton.isHidden = true
        self.continueButton.isUserInteractionEnabled = true
        self.continueButton.backgroundColor = primaryColor
        self.imageSelected = true
        if comesFromHomeOnboarding { viewModel.profileImage = image }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
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

