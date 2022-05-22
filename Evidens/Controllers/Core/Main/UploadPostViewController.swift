//
//  UploadPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Firebase
import SDWebImage
import NextGrowingTextView


class UploadPostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    
    private lazy var postTextView: UITextView = {
        let tv = InputTextView()
        tv.placeholderText = "Start typing your post"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.placeHolderShouldCenter = false
        return tv
    }()
     
     
    /*
    private lazy var postTextView: NextGrowingTextView = {
        let tv = NextGrowingTextView()
        tv.configuration.minLines = 1
        tv.configuration.maxLines = 20
        tv.configuration.isAutomaticScrollToBottomEnabled = true
        tv.configuration.isFlashScrollIndicatorsEnabled = true
        tv.placeholderLabel.text = "What would you like to share"
        tv.placeholderLabel.font = .systemFont(ofSize: 18, weight: .light)
        tv.placeholderLabel.textColor = grayColor
        tv.textView.font = .systemFont(ofSize: 18, weight: .regular)
        tv.textView.textColor = blackColor
        return tv
    }()
     */
     

    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        button.tintColor = UIColor(rgb: 0x2B2D42)
        return button
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        button.tintColor = UIColor(rgb: 0x2B2D42)
        return button
    }()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureKeyboard()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        postTextView.becomeFirstResponder()
        scrollView.resizeScrollViewContentSize()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            scrollView.resizeScrollViewContentSize()

            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            
            if notification.name == UIResponder.keyboardWillHideNotification {
                scrollView.contentInset = .zero
            } else {
                scrollView.contentInset = UIEdgeInsets(top: 0,
                                                       left: 0,
                                                       bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 20,
                                                       right: 0)
            }
            
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            
            scrollView.resizeScrollViewContentSize()
            //postTextView.anchor(bottom: scrollView.bottomAnchor)
            //let selectedRange = postTextView.selectedRange
            //postTextView.scrollRangeToVisible(selectedRange)
            
            
            //self.view.frame.origin.y = 0 - keyboardSize.height * 0.3
            //scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - keyboardSize.height)
        }
    }
    
    @objc func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func didTapShare() {
        guard let postTextView = postTextView.text else { return } //postTextView.textView.text
        
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
        
        view.addSubview(scrollView)
        view.backgroundColor = .white
        scrollView.backgroundColor = .red
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        //scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        //scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
     
        scrollView.addSubview(profileImageView)
        profileImageView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, paddingTop: 10, paddingLeft: 15)
        profileImageView.setDimensions(height: 60, width: 60)
        profileImageView.layer.cornerRadius = 60/2
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        
        scrollView.addSubview(postTextView)
        postTextView.anchor(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, paddingTop: 10, paddingRight: 15)
        postTextView.setDimensions(height: 100, width: UIScreen.main.bounds.width - 30)
        
        textViewDidChange(postTextView)
    }
    
    func configureKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedSpace.width = 10
        
        let cameraButtonKeyboard = UIBarButtonItem(customView: cameraButton)
        let playButtonKeyboard = UIBarButtonItem(customView: playButton)
        toolbar.setItems([cameraButtonKeyboard, fixedSpace, playButtonKeyboard, flexibleSpace], animated: true)
        
        postTextView.inputAccessoryView = toolbar //postTextView.textView
        
        postTextView.becomeFirstResponder()
    }
    
    func addPostImageToView(image: UIImage) {
        postImageView.image = image
        scrollView.addSubview(postImageView)
        postImageView.anchor(top: postTextView.bottomAnchor, left: scrollView.leftAnchor)
        postImageView.setDimensions(height: 400, width: UIScreen.main.bounds.width)
    }
    
    @objc func didTapCameraButton() {
        print("Did press camera")
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        self.present(picker, animated: true)
    }
    
    @objc func didTapPlayButton() {
        print("Did press video")
    }
}

//MARK: - UITextViewDelegate

extension UploadPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        scrollView.isScrollEnabled = true
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        postTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        scrollView.resizeScrollViewContentSize()
        
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension UploadPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage,
           let imageData = image.pngData() {
            print("Image got saved")
            addPostImageToView(image: image)
        }
        scrollView.resizeScrollViewContentSize()
    }
}

