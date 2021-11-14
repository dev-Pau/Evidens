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
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = UIImage(systemName: "person.circle")
        return iv
    }()
    
    public lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
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
    
    @objc func didTapEdit() {
        print("DEBUG: did tap edit")
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
        

        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "xmark.circle.fill"), style: .done, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(didTapEdit))
        
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
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.image = selectedImage.withRenderingMode(.alwaysOriginal)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
