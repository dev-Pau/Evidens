//
//  UploadPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Photos
import PhotosUI
import Firebase
import SDWebImage

class UploadPostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User
    
    private var postImages = [UIImage]()
    
    var postUrlImages: [String]?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.isTranslucent = false
        toolbar.layer.borderWidth = 0
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let fullName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = blackColor
        return label
    }()
    
    private lazy var cancelImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "x")
        iv.setDimensions(height: 35, width: 35)
        iv.tintColor = blackColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCancel))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var postTextView: UITextView = {
        let tv = InputTextView()
        tv.placeholderText = "What would you like to share"
        tv.placeholderLabel.font = .systemFont(ofSize: 18, weight: .light)
        tv.font = .systemFont(ofSize: 18, weight: .regular)
        tv.textColor = blackColor
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.placeHolderShouldCenter = false
        return tv
    }()
     
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
    
    private lazy var galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.addTarget(self, action: #selector(didTapGalleryButton), for: .touchUpInside)
        button.tintColor = UIColor(rgb: 0x2B2D42)
        return button
    }()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.layer.borderWidth = 1
        iv.layer.borderColor = blackColor.cgColor
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumLineSpacing = 1
        collectionViewFlowLayout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.isPagingEnabled = true
        collectionView.indicatorStyle = .white
        return collectionView
    }()
    
    private lazy var deleteImageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = blackColor
        button.configuration?.image = UIImage(named: "x")?.scalePreservingAspectRatio(targetSize: CGSize(width:15, height: 15))
        button.configuration?.cornerStyle = .capsule
        button.setDimensions(height: 30, width: 30)
        button.addTarget(self, action: #selector(didTapDeletePostImage), for: .touchUpInside)
        return button
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
        
        guard let postTextView = postTextView.text else { return }
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        if postImages.count > 0 {
            // Unwrap the images array
            let imagesToUpload = postImages.compactMap { $0 }
            
            if postImages.isEmpty == false {
                StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                    // Post images saved to firebase. Upload post with images
                    PostService.uploadPost(post: postTextView, postImageUrl: imageUrl, type: .textWithImage, user: self.user) { error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        } else {
                            // Post is uploaded to Firebase
                            print("Post with text and image uploaded to FB")
                        }
                    }
                }
            } else {
                print("Post has no image")
            }
        } else {
            // Post has text
            PostService.uploadPost(post: postTextView, postImageUrl: nil, type: .plainText, user: user) { error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                } else {
                    // Post is uploaded to Firebase
                    print("Post with only text uploaded to FB")
                }
            }
        }
        
        
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Create a Post"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: cancelImageView.image, style: .plain, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(didTapShare))
        navigationItem.leftBarButtonItem?.tintColor = blackColor
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        
        view.addSubview(scrollView)
        view.backgroundColor = .white
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        //scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        //scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
     
        scrollView.addSubview(profileImageView)
        profileImageView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, paddingTop: 10, paddingLeft: 15)
        profileImageView.setDimensions(height: 60, width: 60)
        profileImageView.layer.cornerRadius = 60/2
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        
        scrollView.addSubview(fullName)
        fullName.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, paddingLeft: 4)
        fullName.text = user.firstName! + " " + user.lastName!
        
        scrollView.addSubview(postTextView)
        postTextView.anchor(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, paddingTop: 10, paddingRight: 15)
        postTextView.setDimensions(height: 100, width: UIScreen.main.bounds.width - 30)
        
        textViewDidChange(postTextView)
    }
    
    func configureKeyboard() {
        
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedSpace.width = 10
        
        let cameraButtonKeyboard = UIBarButtonItem(customView: cameraButton)
        let playButtonKeyboard = UIBarButtonItem(customView: playButton)
        let galleryButtonKeyboard = UIBarButtonItem(customView: galleryButton)
        
        toolbar.setItems([cameraButtonKeyboard, fixedSpace, playButtonKeyboard, fixedSpace, galleryButtonKeyboard, flexibleSpace], animated: true)
        
        postTextView.inputAccessoryView = toolbar //postTextView.textView
        
        postTextView.becomeFirstResponder()
    }
    
    func addSinglePostImageToView(image: UIImage) {
        postImageView.image = image
        scrollView.addSubview(postImageView)
        postImageView.anchor(top: postTextView.bottomAnchor, left: postTextView.leftAnchor, right: postTextView.rightAnchor, paddingTop: 10)
        
        
        let ratio = image.size.width / image.size.height
        let newHeight = view.bounds.width / ratio
        postImageView.setHeight(newHeight)
        //postImageView.setDimensions(height: newHeight, width: view.bounds.width)
        //view.layoutIfNeeded()
        
        
        scrollView.addSubview(deleteImageButton)
        deleteImageButton.anchor(top: postImageView.topAnchor, right: postImageView.rightAnchor, paddingTop: 10, paddingRight: 10)
    
        postImages.append(image)
        
        toolbar.isUserInteractionEnabled = false
        cameraButton.alpha = 0.5
    }
    
    
    func addPostImagesToView(images: [UIImage]) {
        let gridImagesView = MEImagesGridView(images: images, screenWidth: postTextView.bounds.size.width)
        
        gridImagesView.translatesAutoresizingMaskIntoConstraints = false
        gridImagesView.layer.cornerRadius = 10
        gridImagesView.layer.borderWidth = 1
        gridImagesView.layer.borderColor = blackColor.cgColor
        
        scrollView.addSubview(gridImagesView)
        
        NSLayoutConstraint.activate([
            gridImagesView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            gridImagesView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            gridImagesView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
            gridImagesView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        scrollView.addSubview(deleteImageButton)
        deleteImageButton.anchor(top: gridImagesView.topAnchor, right: gridImagesView.rightAnchor, paddingTop: 10, paddingRight: 10)
    
        toolbar.isUserInteractionEnabled = false
        cameraButton.alpha = 0.5
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
    
    @objc func didTapGalleryButton() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 4
        config.preferredAssetRepresentationMode = .current
        config.filter = PHPickerFilter.any(of: [.images])
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func didTapDeletePostImage() {
        postImageView.removeFromSuperview()
        
        postImages.removeAll()
        deleteImageButton.removeFromSuperview()
        scrollView.resizeScrollViewContentSize()
        toolbar.isUserInteractionEnabled = true
        cameraButton.alpha = 1
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
           let _ = image.pngData() {
            print("Image got saved")
            addSinglePostImageToView(image: image)

        }
        scrollView.resizeScrollViewContentSize()
    }
}

extension UploadPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        postImages.removeAll()
        
        picker.dismiss(animated: true, completion: nil)
        
        let group = DispatchGroup()
        
        
        results.forEach { result in
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let self = self else { return }
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else { return }
                self.postImages.append(image)
            }
        }
        group.notify(queue: .main) {
            if self.postImages.count == 1 {
                self.addSinglePostImageToView(image: self.postImages[0])
                
            } else {
                print("More thlan  1image")
                self.addPostImagesToView(images: self.postImages)
            }
        }
    }
}

