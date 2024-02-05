//
//  BannerRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/2/23.
//

import UIKit
import PhotosUI
import CropViewController

class BannerRegistrationViewController: UIViewController {
    
    private let user: User
    private var viewModel: OnboardingViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Profile.bannerTitle)
        return label
    }()
    
    private lazy var bannerImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 12
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
    
    private lazy var profileImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: AppStrings.Assets.profile)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Profile.bannerContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        
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
        addNavigationBarLogo(withTintColor: primaryColor)

        if let banner = viewModel.bannerImage {
            bannerImage.image = banner
        } else if let bannerUrl = UserDefaults.standard.value(forKey: "bannerUrl") as? String, bannerUrl != "" {
            bannerImage.sd_setImage(with: URL(string: bannerUrl))
        }
        
        if let image = viewModel.profileImage {
            profileImage.image = image
        } else if let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageUrl != "" {
            profileImage.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.addSubviews(titleLabel, bannerImage, profileImage, contentLabel, skipLabel, continueButton)
        
        let imageSize: CGFloat = UIDevice.isPad ? 200 : 80
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            bannerImage.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 40),
            bannerImage.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            bannerImage.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            bannerImage.heightAnchor.constraint(equalToConstant: (view.frame.width - 20.0) / bannerAR),
           
            profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: 10),
            profileImage.leadingAnchor.constraint(equalTo: bannerImage.leadingAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: imageSize),
            profileImage.heightAnchor.constraint(equalToConstant: imageSize),
            
            skipLabel.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
            skipLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            skipLabel.widthAnchor.constraint(equalToConstant: 150),
            
            continueButton.bottomAnchor.constraint(equalTo: skipLabel.topAnchor, constant: -10),
            continueButton.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        profileImage.layer.cornerRadius = imageSize / 2
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
        let controller = AddAboutViewController(comesFromOnboarding: true)
        controller.viewModel = viewModel
        controller.user = user
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSkip() {
        viewModel.bannerImage = nil
        
        let controller = AddAboutViewController(comesFromOnboarding: true)
        controller.viewModel = viewModel
        controller.user = user
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BannerRegistrationViewController: PHPickerViewControllerDelegate, CropViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.count == 0 { return }

        results.forEach { [weak self] result in
            guard let _ = self else { return }
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let strongSelf = self else { return }
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    picker.dismiss(animated: true)

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
        vc.customAspectRatio = CGSize(width: bannerAR, height: 1)
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
        bannerImage.image = image

        borderView.layer.borderColor = separatorColor.cgColor
        continueButton.isEnabled = true
        viewModel.bannerImage = image
    }
}
