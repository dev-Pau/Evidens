//
//  ProfileImageViewControllerl.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/21.
//

import UIKit

class ProfileImageViewController: UIViewController {
    
    //MARK: - Properties
    
    public var profileImage: UIImage?
    
    private var user: User
    
    init (user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        iv.addGestureRecognizer(pan)
        return iv
    }()
    
    private lazy var dismissButon: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(named: "xmark")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = .white.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        configureUI()
    }
    
    //MARK: - Actions

    /*
    @objc func didTapShare() {
        let activityVC = UIActivityViewController(activityItems: [self.profileImageView.image as Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
     */
    
    @objc func didTapEditProfile() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .black
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(didTapShare))
        
        view.addSubviews(profileImageView, dismissButon)
        
        NSLayoutConstraint.activate([
            dismissButon.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            dismissButon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dismissButon.heightAnchor.constraint(equalToConstant: 35),
            dismissButon.widthAnchor.constraint(equalToConstant: 35)
        
        ])
        
        profileImageView.centerY(inView: view)
        profileImageView.centerX(inView: view)
        
        let height = view.frame.width * 0.8

        profileImageView.setDimensions(height: height, width: height)
        profileImageView.layer.cornerRadius = height/2
        
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: profileImageView)

        
        let velocity = sender.velocity(in: profileImageView)
        
        let alpha = max(1 - (abs(translation.y) / 1000), 0.85)
        
        profileImageView.frame.origin = CGPoint(x: profileImageView.frame.origin.x , y: view.frame.height / 2 - profileImageView.frame.height / 2 + translation.y)
        view.backgroundColor = .black.withAlphaComponent(alpha)
        
        
        if sender.state == .ended {
            if abs(velocity.y) > 2000 {
                
                UIView.animate(withDuration: 0.2) {
                    if velocity.y < 0 {
                        self.profileImageView.frame.origin = CGPoint(x: self.profileImageView.frame.origin.x, y: -self.profileImageView.frame.height)
                        self.view.backgroundColor = .clear
                    } else {
                        self.profileImageView.frame.origin = CGPoint(x: self.profileImageView.frame.origin.x, y: self.view.frame.height + self.profileImageView.frame.height)
                        self.view.backgroundColor = .clear
                    }
                } completion: { _ in
                    self.dismiss(animated: false)
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.profileImageView.frame.origin = CGPoint(x: self.profileImageView.frame.origin.x, y: self.view.frame.height / 2 - self.profileImageView.frame.height / 2)
                    self.view.backgroundColor = .black
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

//MARK: - UIImagePickerControllerDelegate

extension ProfileImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        profileImage = selectedImage
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.image = selectedImage.withRenderingMode(.alwaysOriginal)
        
        //Upload image to Firestore
        StorageManager.uploadProfileImage(image: profileImage!, uid: user.uid!) { imageUrl in
            UserService.updateProfileUrl(profileImageUrl: imageUrl) { user in
                //self.user.profileImageUrl = imageUrl
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
