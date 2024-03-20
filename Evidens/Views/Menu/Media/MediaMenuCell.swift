//
//  MediaMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/3/24.
//

import UIKit
import AVFoundation

class MediaMenuCell: UICollectionViewCell {
    
    private var session: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let output = AVCapturePhotoOutput()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cameraImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.fillCamera)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = containerView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        checkCameraPermissions()
        
        containerView.backgroundColor = darkColor
        previewLayer.backgroundColor = darkColor.cgColor
        
        addSubviews(containerView, cameraImage)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            containerView.widthAnchor.constraint(equalToConstant: 80),
            containerView.heightAnchor.constraint(equalToConstant: 80),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            cameraImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cameraImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            cameraImage.widthAnchor.constraint(equalToConstant: 30),
            cameraImage.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        containerView.layer.masksToBounds = true
        containerView.layer.addSublayer(previewLayer)
        containerView.layer.cornerRadius = 80 * 0.2
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = separatorColor.cgColor
        
        previewLayer.cornerRadius = 80 * 0.2
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
        
        var selectedCamera: AVCaptureDevice?

        if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            selectedCamera = frontCamera
        }

        if selectedCamera == nil {
            selectedCamera = AVCaptureDevice.default(for: .video)
        }
        
        guard let camera = selectedCamera else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
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
            // Handle error
        }
    }
}