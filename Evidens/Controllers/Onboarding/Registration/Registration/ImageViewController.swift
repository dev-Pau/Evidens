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

class ImageViewController: UIViewController {
    
    private var user: User
    var comesFromHomeOnboarding: Bool = false
    private lazy var viewModel = OnboardingViewModel()
    private var imageSelected: Bool = false
                                                                          
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let progressIndicator = JGProgressHUD()
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Profile.imageTitle)
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: AppStrings.Assets.profile)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let instructionsImageLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Profile.imageContent
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var uploadPictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.plus)?.scalePreservingAspectRatio(targetSize: CGSize(width: 45, height: 45)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = primaryColor
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        config.attributedTitle = AttributedString(AppStrings.Global.go, attributes: container)
        
        button.configuration = config
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var skipLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Global.skip
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
        button.configuration?.attributedTitle = AttributedString(AppStrings.Global.help, attributes: container)
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
            if let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" {
                profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
        } else {
            helpButton.menu = addMenuItems()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
        }
    }
    
    private func configureUI() {
        profileImageView.layer.cornerRadius = 200 / 2

        view.backgroundColor = .systemBackground
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        scrollView.addSubviews(titleLabel, profileImageView, instructionsImageLabel, uploadPictureButton, skipLabel, continueButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
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
            continueButton.trailingAnchor.constraint(equalTo: instructionsImageLabel.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
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
            UIAction(title: AppStrings.Menu.importCamera, image: UIImage(systemName: AppStrings.Icons.fillCamera, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.didTapImportFromCamera()
            }),
            
            UIAction(title: AppStrings.Menu.chooseGallery, image: UIImage(systemName: AppStrings.Icons.photo, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.didTapImportFromGallery()
            })
        ])
        return menuItems
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: AppStrings.App.support, image: UIImage(systemName: AppStrings.Icons.fillTray, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                if MFMailComposeViewController.canSendMail() {
                    let controller = MFMailComposeViewController()
                    controller.setToRecipients([AppStrings.App.contactMail])
                    controller.mailComposeDelegate = self
                    strongSelf.present(controller, animated: true)
                } else {
                    return
                }
            }),
            
            UIAction(title: AppStrings.Opening.logOut, image: UIImage(systemName: AppStrings.Icons.lineRightArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                AuthService.logout()
                AuthService.googleLogout()
                let controller = OpeningViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            })
        ])
        return menuItems
    }

    @objc func handleContinue() {
        if comesFromHomeOnboarding {
            let controller = BannerRegistrationViewController(user: user, viewModel: viewModel)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            guard let uid = user.uid,
                  let firstName = user.firstName,
                  let lastName = user.lastName else { return }
            
            var credentials = AuthCredentials(uid: uid, firstName: firstName, lastName: lastName, phase: .identity)
            
            if let hobbies = user.hobbies {
                credentials.set(hobbies: hobbies)
            }
            
            if imageSelected {
                guard let image = self.profileImageView.image else { return }
                progressIndicator.show(in: view)
                StorageManager.addImage(image: image, uid: uid, kind: .profile) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let imageUrl):
                        credentials.set(imageUrl: imageUrl)
                        AuthService.setProfileDetails(withCredentials: credentials) { [weak self] error in
                            guard let strongSelf = self else { return }
                            strongSelf.progressIndicator.dismiss(animated: true)
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.user.profileUrl = imageUrl
                                let controller = VerificationViewController(user: strongSelf.user)
                                let nav = UINavigationController(rootViewController: controller)
                                nav.modalPresentationStyle = .fullScreen
                                strongSelf.present(nav, animated: true)
                            }
                        }
                    case .failure(let error):
                        strongSelf.progressIndicator.dismiss(animated: true)
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    }
                }
            } else {
                AuthService.setProfileDetails(withCredentials: credentials) { [weak self] error in
                    guard let strongSelf = self else { return }
                    strongSelf.progressIndicator.dismiss(animated: true)
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        let controller = VerificationViewController(user: strongSelf.user)
                        let nav = UINavigationController(rootViewController: controller)
                        nav.modalPresentationStyle = .fullScreen
                        strongSelf.present(nav, animated: true)
                    }
                }
            }

        }
    }
    
    @objc func handleSkip() {
        if comesFromHomeOnboarding {
            viewModel.profileImage = nil
            let controller = BannerRegistrationViewController(user: user, viewModel: viewModel)
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
        
        controller.doneButtonTitle = AppStrings.Global.done
        controller.cancelButtonTitle = AppStrings.Global.cancel

        controller.delegate = self
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
    }
}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        showCrop(image: selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ImageViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if results.count == 0 { return }
        progressIndicator.show(in: view)
        results.forEach { [weak self] result in
            guard let _ = self else { return }
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let _ = self else { return }
                guard let image = reading as? UIImage, error == nil else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    picker.dismiss(animated: true)
                    strongSelf.progressIndicator.dismiss(animated: true)
                    strongSelf.showCrop(image: image)
                }
            }
        }
    }
}

extension ImageViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        self.profileImageView.image = image
        self.uploadPictureButton.isHidden = true
        self.continueButton.isEnabled = true
        self.imageSelected = true
        if comesFromHomeOnboarding { viewModel.profileImage = image }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
}

extension ImageViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

/*
let credentials = AuthCredentials(firstName: firstName, lastName: lastName, email: "", password: "", profileImageUrl: "", phase: .verificationPhase, category: .none, profession: "", speciality: "", interests: user.interests ?? [])



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
