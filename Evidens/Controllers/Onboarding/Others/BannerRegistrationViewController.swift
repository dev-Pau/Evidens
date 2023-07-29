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
    
    private let bannerLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Profile.bannerTitle)
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
        iv.image = UIImage(named: AppStrings.Assets.profile)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 4
        iv.layer.borderColor = UIColor.systemBackground.cgColor
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    private let instructionsImageLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Profile.bannerContent
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
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private lazy var uploadPictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.buttonSize = .mini
      
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.white)
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
        button.setTitle(AppStrings.Global.go, for: .normal)
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
        if let bannerUrl = UserDefaults.standard.value(forKey: "userProfileBannerUrl") as? String, bannerUrl != "" {
            bannerImageView.sd_setImage(with: URL(string: bannerUrl))
        }
        
        if let image = viewModel.profileImage {
            profileImageView.image = image
        } else if let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.addSubviews(bannerLabel, bannerImageView, profileImageView, instructionsImageLabel, skipLabel, continueButton, uploadPictureButton, fullNameLabel, professionLabel)
        
        NSLayoutConstraint.activate([
            bannerLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            bannerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bannerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            instructionsImageLabel.topAnchor.constraint(equalTo: bannerLabel.bottomAnchor, constant: 10),
            instructionsImageLabel.leadingAnchor.constraint(equalTo: bannerLabel.leadingAnchor),
            instructionsImageLabel.trailingAnchor.constraint(equalTo: bannerLabel.trailingAnchor),
            
            bannerImageView.topAnchor.constraint(equalTo: instructionsImageLabel.bottomAnchor, constant: 40),
            bannerImageView.leadingAnchor.constraint(equalTo: instructionsImageLabel.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: instructionsImageLabel.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: (view.frame.width - 20) / 3),
           
            profileImageView.centerYAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: bannerLabel.trailingAnchor),
            
            professionLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
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
        fullNameLabel.text = user.firstName! + " " + user.lastName!
        professionLabel.text = user.discipline!.name + AppStrings.Characters.dot + user.speciality!.name
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
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSkip() {
        viewModel.bannerImage = nil
        
        let controller = AddAboutViewController()
        controller.comesFromOnboarding = true
        controller.viewModel = viewModel
        controller.user = user
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BannerRegistrationViewController: PHPickerViewControllerDelegate, CropViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.count == 0 { return }
        progressIndicator.show(in: view)
        results.forEach { [weak self] result in
            guard let _ = self else { return }
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let strongSelf = self else { return }
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    picker.dismiss(animated: true)
                    strongSelf.progressIndicator.dismiss(animated: true)
                    strongSelf.showCrop(image: image)
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
        vc.doneButtonTitle = AppStrings.Global.done
        vc.cancelButtonTitle = AppStrings.Global.cancel
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
