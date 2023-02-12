//
//  BannerRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/2/23.
//

import UIKit
import PhotosUI
import CropViewController
import JGProgressHUD

class BannerRegistrationViewController: UIViewController {
    
    private let user: User
    private var viewModel: OnboardingViewModel
    
    private var bannerSelected: Bool = false
    
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
        let label = CustomLabel(placeholder: "Pick a banner")
        return label
    }()
    
    private lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = primaryColor.withAlphaComponent(0.5)
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.layer.cornerRadius = 10
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadPicture)))
        return iv
    }()
    
    private lazy var borderView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .clear
        iv.layer.borderColor = primaryColor.withAlphaComponent(0.5).cgColor
        iv.layer.borderWidth = 1
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        iv.layer.cornerRadius = 10
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadPicture)))
        return iv
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "user")?.withTintColor(.secondaryLabel)
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .tertiarySystemGroupedBackground
        iv.clipsToBounds = true
        iv.layer.borderWidth = 4
        iv.layer.borderColor = UIColor.systemBackground.cgColor
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    private let instructionsImageLabel: UILabel = {
        let label = UILabel()
        label.text = "Posting a banner picture is optional, but as Napoleon Bonaparte said, \"a picture is worth a thousand words.\""
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private lazy var uploadPictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.buttonSize = .mini
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        button.configuration?.attributedTitle = AttributedString("Upload", attributes: container)
        
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.white)
        button.configuration?.imagePadding = 5
        button.configuration?.imagePlacement = .top
        button.configuration?.baseForegroundColor = .white
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
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSkip)))
        return label
    }()
    
    init(user: User, viewModel: OnboardingViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        /*
        if isFirstHomeOnboardingStep {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
            navigationItem.leftBarButtonItem?.tintColor = .label
        }
         */
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        scrollView.addSubviews(imageTextLabel, bannerImageView, profileImageView, instructionsImageLabel, skipLabel, continueButton, uploadPictureButton, fullNameLabel, professionLabel)
        
        NSLayoutConstraint.activate([
            imageTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            imageTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageTextLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            
            instructionsImageLabel.topAnchor.constraint(equalTo: imageTextLabel.bottomAnchor, constant: 10),
            instructionsImageLabel.leadingAnchor.constraint(equalTo: imageTextLabel.leadingAnchor),
            instructionsImageLabel.trailingAnchor.constraint(equalTo: imageTextLabel.trailingAnchor),
            
            bannerImageView.topAnchor.constraint(equalTo: instructionsImageLabel.bottomAnchor, constant: 40),
            bannerImageView.leadingAnchor.constraint(equalTo: instructionsImageLabel.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: instructionsImageLabel.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: (view.frame.width - 20) / 3),
            //uploadPictureButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -10),
            //uploadPictureButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 70),
            //uploadPictureButton.widthAnchor.constraint(equalToConstant: 60),
            //uploadPictureButton.heightAnchor.constraint(equalToConstant: 60),
            
            profileImageView.centerYAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            profileImageView.centerXAnchor.constraint(equalTo: bannerImageView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            fullNameLabel.leadingAnchor.constraint(equalTo: imageTextLabel.leadingAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: imageTextLabel.trailingAnchor),
            
            professionLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            professionLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor),
            
            skipLabel.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            skipLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            skipLabel.widthAnchor.constraint(equalToConstant: 150),
            
            continueButton.bottomAnchor.constraint(equalTo: skipLabel.topAnchor, constant: -10),
            continueButton.leadingAnchor.constraint(equalTo: instructionsImageLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: instructionsImageLabel.trailingAnchor),
            
            uploadPictureButton.centerXAnchor.constraint(equalTo: bannerImageView.centerXAnchor),
            uploadPictureButton.centerYAnchor.constraint(equalTo: bannerImageView.centerYAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 60 / 2
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        fullNameLabel.text = user.firstName! + " " + user.lastName!
        professionLabel.text = user.profession! + " · " + user.speciality!
    }
    
    
    
    @objc func handleUploadPicture() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        config.filter = PHPickerFilter.any(of: [.images])
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func handleContinue() {
        let controller = AddAboutViewController()
        controller.comesFromOnboarding = true
        controller.viewModel = viewModel
        controller.user = user
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSkip() {
        viewModel.bannerImage = nil
        
        let controller = AddAboutViewController()
        controller.comesFromOnboarding = true
        controller.viewModel = viewModel
        controller.user = user
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BannerRegistrationViewController: PHPickerViewControllerDelegate, CropViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
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
    
    func showCrop(image: UIImage) {
        let vc = CropViewController(image: image)
        vc.delegate = self
        vc.aspectRatioLockEnabled = true
        vc.aspectRatioPickerButtonHidden = true
        vc.rotateButtonsHidden = true
        vc.resetButtonHidden = true
        vc.aspectRatioPreset = .presetCustom
        vc.customAspectRatio = CGSize(width: 3, height: 1)
        vc.toolbarPosition = .bottom
        vc.doneButtonTitle = "Done"
        vc.cancelButtonTitle = "Cancel"
        self.present(vc, animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        bannerImageView.image = image
        bannerSelected = true
        borderView.layer.borderColor = UIColor.quaternarySystemFill.cgColor
        uploadPictureButton.isHidden = true
        continueButton.isUserInteractionEnabled = true
        viewModel.bannerImage = image
        continueButton.backgroundColor = primaryColor
    }
}
