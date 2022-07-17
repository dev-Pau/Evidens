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
    
    public let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions

    @objc func didTapShare() {
        let activityVC = UIActivityViewController(activityItems: [self.profileImageView.image as Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func didTapEditProfile() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(didTapShare))
        
        view.addSubview(profileImageView)
        profileImageView.centerY(inView: view)
        profileImageView.centerX(inView: view)
        
        let height = view.frame.width * 0.8

        profileImageView.setDimensions(height: height, width: height)
        profileImageView.layer.cornerRadius = height/2
        
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
