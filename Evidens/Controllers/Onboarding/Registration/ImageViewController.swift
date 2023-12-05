//
//  ImageRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import PhotosUI
import MessageUI
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
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Profile.imageTitle)
        return label
    }()
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Profile.imageContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.tintAdjustmentMode = .normal
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.plus)?.scalePreservingAspectRatio(targetSize: CGSize(width: 45, height: 45)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = primaryColor
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule

        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .bold, scales: false)
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
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .bold, scales: false)
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
        container.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold, scales: false)
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
            let appearance = UINavigationBarAppearance.secondaryAppearance()
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            if let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageUrl != "" {
                profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
        } else {
            helpButton.menu = addMenuItems()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
        }
        
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configureUI() {
        profileImageView.layer.cornerRadius = 200 / 2

        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.addSubviews(titleLabel, profileImageView, contentLabel, imageButton, skipLabel, continueButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 200),
            profileImageView.heightAnchor.constraint(equalToConstant: 200),
            
            contentLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            contentLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            
            imageButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -10),
            imageButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 70),
            imageButton.widthAnchor.constraint(equalToConstant: 60),
            imageButton.heightAnchor.constraint(equalToConstant: 60),
            
            skipLabel.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            skipLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            skipLabel.widthAnchor.constraint(equalToConstant: 150),
            
            continueButton.bottomAnchor.constraint(equalTo: skipLabel.topAnchor, constant: -10),
            continueButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        imageButton.showsMenuAsPrimaryAction = true
        imageButton.menu = addImageButtonItems()
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
            
            showProgressIndicator(in: view)
            
            if imageSelected {
                guard let image = self.profileImageView.image else { return }
                
                StorageManager.addImage(image: image, uid: uid, kind: .profile) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let imageUrl):
                        credentials.set(imageUrl: imageUrl)
                        AuthService.setProfileDetails(withCredentials: credentials) { [weak self] error in
                            guard let strongSelf = self else { return }
                            
                            strongSelf.dismissProgressIndicator()
                            
                            if let error {
                                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            } else {
                                strongSelf.user.profileUrl = imageUrl
                                strongSelf.user.phase = .identity
                                strongSelf.setUserDefaults(for: strongSelf.user)
                                let controller = VerificationViewController(user: strongSelf.user)
                                let nav = UINavigationController(rootViewController: controller)
                                nav.modalPresentationStyle = .fullScreen
                                strongSelf.present(nav, animated: true)
                            }
                        }
                    case .failure(let error):
                        strongSelf.dismissProgressIndicator()
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    }
                }
            } else {
                AuthService.setProfileDetails(withCredentials: credentials) { [weak self] error in
                    guard let strongSelf = self else { return }
                    strongSelf.dismissProgressIndicator()
                    if let error {
                        strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    } else {
                        strongSelf.user.phase = .identity
                        strongSelf.setUserDefaults(for: strongSelf.user)
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
        let controller = CropViewController(croppingStyle: .circular, image: image)
        
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
        if results.count == 0 {
            picker.dismiss(animated: true)
            return
        }
        
        results.forEach { [weak self] result in
            guard let _ = self else { return }
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let _ = self else { return }
                guard let image = reading as? UIImage, error == nil else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    picker.dismiss(animated: true)

                    strongSelf.showCrop(image: image)
                }
            }
        }
    }
}

extension ImageViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        self.profileImageView.image = image
        self.imageButton.isHidden = true
        self.continueButton.isEnabled = true
        self.imageSelected = true
        if comesFromHomeOnboarding { viewModel.profileImage = image }
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
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
