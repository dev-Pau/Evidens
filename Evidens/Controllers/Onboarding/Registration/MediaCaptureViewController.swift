//
//  MediaCaptureViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/23.
//

import UIKit
import AVFoundation

class MediaCaptureViewController: UIViewController {
    
    private var viewModel: VerificationViewModel
    private var currentKind: IdentityKind
    private var frameView: UIView!
    
    private var session: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    private let output = AVCapturePhotoOutput()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private lazy var shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: AppStrings.Icons.filledInsetCircle)?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 70, height: 70))
        button.configuration = config
        button.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        checkCameraPermissions()
    }
    
    init(viewModel: VerificationViewModel) {
        self.viewModel = viewModel
        self.currentKind = viewModel.kind
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        view.backgroundColor = .black
        
        let appearance = UINavigationBarAppearance()
        
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        
        appearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.standardAppearance = appearance
        
        view.layer.addSublayer(previewLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let kind = viewModel.userKind
        var multiplier = 0.0
        switch currentKind {
        case .doc:
            switch kind {
            case .professional:
                titleLabel.text = AppStrings.Opening.verifyDocs
                multiplier = 0.7
            case .student:
                titleLabel.text = AppStrings.Opening.verifyStudentDocs
                multiplier = 0.9
            case .evidens:
                break
            }
        case .id:
            titleLabel.text = AppStrings.Opening.verifyId
            multiplier = 0.7
        }

        previewLayer.frame = view.bounds
        
        frameView = UIView()
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.layer.borderWidth = 7
        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.cornerRadius = 15
        frameView.backgroundColor = .clear
        frameView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubviews(frameView, blurView, shutterButton, titleLabel)
        
        NSLayoutConstraint.activate([
            frameView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            frameView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            frameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            frameView.heightAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: multiplier),
            
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -20),
            
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            shutterButton.heightAnchor.constraint(equalToConstant: 100),
            shutterButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let strongSelf = self else { return }
                guard granted else {
                    return
                    
                }
                DispatchQueue.main.async {
                    strongSelf.configureCamera()
                }
            }
        case .restricted, .denied:
            break
            
        case .authorized:
            configureCamera()
        @unknown default:
            break
        }
    }
    
    private func configureCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                DispatchQueue.global().async {
                    session.startRunning()
                }
                
                self.session = session
            } catch {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
            }
        }
    }
    
    //MARK: - Actions
    
    @objc func didTapTakePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension MediaCaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        
        if let image = UIImage(data: data) {
            if let cropImage = crop(image: image) {
                switch currentKind {
                case .doc:
                    viewModel.setDocImage(cropImage)
                case .id:
                    viewModel.setIdImage(cropImage)
                }
                
                let controller = DocumentViewController(viewModel: viewModel)
                navigationController?.pushViewController(controller, animated: true)
            }
            
        }
    }
    
    private func crop(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: frameView.frame)
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let cropRect = CGRect(x: (outputRect.origin.x * width), y: (outputRect.origin.y * height), width: (outputRect.size.width * width), height: (outputRect.size.height * height))
        
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: image.imageOrientation)
        }
        
        return nil
    }
}
