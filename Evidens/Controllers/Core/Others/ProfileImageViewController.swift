//
//  ProfileImageViewControllerl.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/21.
//

import Foundation
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
        iv.image = UIImage(systemName: "person.circle")
        return iv
    }()
    
    public lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapEditProfile), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    
    @objc func didTapCancel() {
        print("DEBUG: did tap cancel")
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func didTapShare() {
        let activityVC = UIActivityViewController(activityItems: [self.profileImageView.image as Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func didTapEditProfile() {
        print("DEBUG: did tap edit profile")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    //MARK: - Helpers
    
    func configureUI() {
        
        let backgroundColor = profileImageView.image?.averageColor
        view.backgroundColor = backgroundColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark"), style: .done, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(systemName: "ellipsis"), style: .done, target: self, action: #selector(didTapShare))
        
        view.addSubview(profileImageView)
        profileImageView.centerY(inView: view)
        profileImageView.centerX(inView: view)
        
        let height = view.frame.width * 0.8

        profileImageView.setDimensions(height: height, width: height)
        profileImageView.layer.cornerRadius = height/2
        
        view.addSubview(editProfileButton)
        editProfileButton.anchor(left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 20, paddingBottom: 20)
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
        ImageUploader.uploadImage(image: profileImage!, uid: user.uid!) { imageUrl in
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
