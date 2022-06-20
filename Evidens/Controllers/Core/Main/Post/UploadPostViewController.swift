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
import AVFoundation
import AVKit

class UploadPostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User
    
    private var postImages: [UIImage] = []
    
    var gridImagesView = MEImagesGridView()
    
    //var postUrlImages: [String]?
    
    var videoUrl: URL?
    
    var newHeight: CGFloat = 0
    
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
    
    private lazy var videoImageView: UIImageView = {
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
        button.configuration = .gray()
        button.configuration?.image = UIImage(systemName: "xmark")
        button.configuration?.baseBackgroundColor = .black
        button.configuration?.baseForegroundColor = .white

        button.configuration?.cornerStyle = .capsule
        
        button.addTarget(self, action: #selector(didTapDeletePostImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var playVideoButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()
        button.configuration?.image = UIImage(systemName: "play.fill")
        button.configuration?.baseBackgroundColor = .black
        button.configuration?.baseForegroundColor = .white

        button.configuration?.cornerStyle = .capsule
        
        button.addTarget(self, action: #selector(didTapPlayPostVideo), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()

        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Share", attributes: container)
        
        button.isUserInteractionEnabled = true
        button.alpha = 1
        
        button.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
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
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "Create a Post"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    
    private func configureUI() {
        view.backgroundColor = .white

        view.addSubview(scrollView)

        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
      
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
        
        //postImages.append(image)
        
        postImageView.image = image
        
        scrollView.addSubview(postImageView)
        postImageView.anchor(top: postTextView.bottomAnchor, left: postTextView.leftAnchor, right: postTextView.rightAnchor, paddingTop: 10)
        
        
        let ratio = image.size.width / image.size.height
        newHeight = view.bounds.width / ratio
        postImageView.setHeight(newHeight)

        
        addCancelButtonImagePost(to: postImageView)
        
        toolbar.isUserInteractionEnabled = false
        cameraButton.alpha = 0.5
        
        scrollView.resizeScrollViewContentSize()
    }
    
    
    func addPostImagesToView(images: [UIImage]) {
        gridImagesView = MEImagesGridView(images: images, screenWidth: postTextView.bounds.size.width)
        
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
        
        addCancelButtonImagePost(to: gridImagesView)
    
        toolbar.isUserInteractionEnabled = false
        cameraButton.alpha = 0.5
        
        scrollView.resizeScrollViewContentSize()
    }
    
    func addVideoPostPlaceholderImage(image: UIImage) {
        
        //postImages.append(image)
        videoImageView.image = image

        scrollView.addSubview(videoImageView)
        videoImageView.anchor(top: postTextView.bottomAnchor, left: postTextView.leftAnchor, right: postTextView.rightAnchor, paddingTop: 10)
        
        videoImageView.setHeight(200)

        
        addCancelButtonImagePost(to: videoImageView)
        addPlayButtonImageToPost(to: videoImageView)
        
        toolbar.isUserInteractionEnabled = false
        cameraButton.alpha = 0.5
    }
    
    
    func addCancelButtonImagePost(to imageView: UIImageView) {
        scrollView.addSubview(deleteImageButton)
        deleteImageButton.anchor(top: imageView.topAnchor, right: imageView.rightAnchor, paddingTop: 10, paddingRight: 10)
    }
    
    
    func addCancelButtonImagePost(to imageView: MEImagesGridView) {
        scrollView.addSubview(deleteImageButton)
        deleteImageButton.anchor(top: imageView.topAnchor, right: imageView.rightAnchor, paddingTop: 10, paddingRight: 10)
    }
    
    func addPlayButtonImageToPost(to imageView: UIImageView) {
        scrollView.addSubview(playVideoButton)
        playVideoButton.centerY(inView: imageView)
        playVideoButton.centerX(inView: imageView)
    }
    
    
    @objc func didTapCameraButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        self.present(picker, animated: true)
    }
    
    
    @objc func didTapPlayButton() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        config.filter = PHPickerFilter.any(of: [.videos])
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
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
        gridImagesView.removeFromSuperview()
        videoImageView.removeFromSuperview()
        deleteImageButton.removeFromSuperview()
        playVideoButton.removeFromSuperview()
        
        postImages.removeAll()
        
        scrollView.resizeScrollViewContentSize()
        toolbar.isUserInteractionEnabled = true
        cameraButton.alpha = 1
    }
    
    @objc func didTapPlayPostVideo() {
        print("DEBUG: Play video here")
        //guard let videoUrl = media.url else { return }
        guard let videoUrl = videoUrl else {
            return
        }

        let vc = AVPlayerViewController()
        vc.player = AVPlayer(url: videoUrl)
        present(vc, animated: true)
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

            print(imagesToUpload.count)
            switch postImages.count {
            case 1:
                
                StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                    // Post images saved to firebase. Upload post with images
                    PostService.uploadPost(post: postTextView, postImageUrl: imageUrl, imageHeight: self.newHeight, type: .textWithImage, user: self.user) { error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        } else {
                            // Post is uploaded to Firebase
                            print("Post with text and image uploaded to Firebase with \(imageUrl.count)")
                        }
                    }
                }
            case 2:
                StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                    // Post images saved to firebase. Upload post with images
                    PostService.uploadPost(post: postTextView, postImageUrl: imageUrl, imageHeight: nil, type: .textWithTwoImage, user: self.user) { error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        } else {
                            // Post is uploaded to Firebase
                            print("Post with text and image uploaded to Firebase with \(imageUrl.count)")
                        }
                    }
                }
            case 3:
                StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                    // Post images saved to firebase. Upload post with images
                    PostService.uploadPost(post: postTextView, postImageUrl: imageUrl, imageHeight: nil, type: .textWithThreeImage, user: self.user) { error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        } else {
                            // Post is uploaded to Firebase
                            print("Post with text and image uploaded to Firebase with \(imageUrl.count)")
                        }
                    }
                }
            case 4:
                StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                    // Post images saved to firebase. Upload post with images
                    PostService.uploadPost(post: postTextView, postImageUrl: imageUrl, imageHeight: nil, type: .textWithFourImage, user: self.user) { error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        } else {
                            // Post is uploaded to Firebase
                            print("Post with text and image uploaded to Firebase with \(imageUrl.count)")
                        }
                    }
                }
            default:
                print("NO")
            }
            
            
            
            
        } else {
            // Post has text only
            PostService.uploadPost(post: postTextView, postImageUrl: nil, imageHeight: nil, type: .plainText, user: user) { error in
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
        postImages.removeAll()
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage,
           let _ = image.pngData() {
            print("Image got saved")
            addSinglePostImageToView(image: image)
        }
    }
}

extension UploadPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        if results.count == 0 { return }
        
        shareButton.isUserInteractionEnabled = true
        shareButton.alpha = 1
        
        postImages.removeAll()
        
        let group = DispatchGroup()
        
        results.forEach { result in
            group.enter()
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                //UIImage
                print("Image")
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                    guard let self = self else { return }
                    defer {
                        group.leave()
                    }
                    guard let image = reading as? UIImage, error == nil else { return }
                    self.postImages.append(image)
                }
                group.notify(queue: .main) {
                    if self.postImages.count == 1 {
                        print("only 1 image to upload")
                        self.addSinglePostImageToView(image: self.postImages[0])
                        
                    } else {
                        print("more than 1 image to upload")
                        self.addPostImagesToView(images: self.postImages)
                    }
                }
            } else {
                //Video
                print("Video")
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let _ = error {
                        return
                    }
                    
                    guard let url = url else { return }
                    
                    let fileName = "\(Int(Date().timeIntervalSince1970)).\(url.pathExtension)"
                    self.videoUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                    
                    try? FileManager.default.copyItem(at: url, to: self.videoUrl!)
                    DispatchQueue.main.async {
                        //self.playVideo(newUrl)
                        self.getThumbnailImageFromVideoUrl(url: self.videoUrl!) { thumbNailImage in
                            guard let thumbNailImage = thumbNailImage else {
                                return
                            }

                            self.addVideoPostPlaceholderImage(image: thumbNailImage)
                        }
                    }
                }
            }
        }
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 0, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbNailImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
}


