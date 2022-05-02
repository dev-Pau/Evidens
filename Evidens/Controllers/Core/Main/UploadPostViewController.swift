//
//  UploadPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Firebase
import SDWebImage

class UploadPostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User
    
   
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = UIImage(systemName: "person.circle")
        return iv
    }()
    
    private lazy var postTextView: UITextView = {
        let tv = InputTextView()
        tv.placeholderText = "Start typing your post"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.delegate = self
        tv.placeHolderShouldCenter = false
        return tv
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0/100"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func didTapShare() {
        guard let postTextView = postTextView.text else { return }
        
        //Pass the user to UploadPostViewController instead of fetching current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //UserService.fetchUser(withUid: uid) { user in
            PostService.uploadPost(post: postTextView, user: user) { error in
                if let error = error {
                    print("DEBUG: Failed to upload post with error \(error.localizedDescription)")
                    return
                }
                
                //Upload FeedViewController when Post is published!!!
                self.navigationController?.popToRootViewController(animated: true)

            
        }
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "New Post"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(didTapShare))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(rgb: 0x79CBBF)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 10, paddingLeft: 12)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40/2
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        
        
        view.addSubview(postTextView)
        postTextView.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, right: view.rightAnchor, paddingLeft: 12, paddingRight: 12, height: 64)
        
        view.addSubview(characterCountLabel)
        characterCountLabel.anchor(bottom: postTextView.bottomAnchor, right: view.rightAnchor, paddingRight: 12)

        //profileImageView.sd_setImage(with: UserDefaults.standard.url(forKey: "imageUrl"))
        
    }
    
    func checkMaxLength(_ textView: UITextView) {
        if (textView.text.count > 100) {
            textView.deleteBackward()
        }
    }
}

//MARK: - UITextViewDelegate

extension UploadPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView)
        let count = textView.text.count
        characterCountLabel.text = "\(count)/100"
    }
}
