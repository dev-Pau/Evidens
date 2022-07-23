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
import AVKit

private let pollCellReuseIdentifier = "PollCellReuseIdentifier"

class UploadPostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User
    
    private var viewModel = UploadPostViewModel()
    
    private var postPrivacyMenuLauncher = PostPrivacyMenuLauncher()
    
    private var postAttachementsMenuLauncher = PostAttachementsMenuLauncher()
    
    private var postImages: [UIImage] = []
    
    private var privacyType: Post.PrivacyOptions = .all
    
    private var postDocumentUrl: URL?
    private var postDocumentPages: Int?
    private var postDocumentTitle: String?
    private var stop: Bool = false
    
    var gridImagesView = MEImagesGridView(images: [UIImage()], screenWidth: .zero)
    
    var videoUrl: URL?
    
    var newHeight: CGFloat = 0.0
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.white
        toolbar.clipsToBounds = true
        toolbar.sizeToFit()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let fullName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = blackColor
        return label
    }()
    
    private lazy var settingsPostButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = grayColor
        button.configuration?.background.strokeWidth = 1
        button.configuration?.image = UIImage(systemName: "globe.europe.africa.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        
        button.configuration?.imagePlacement = .leading
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        button.configuration?.attributedTitle = AttributedString(" Public", attributes: container)
        button.configuration?.baseForegroundColor = grayColor
        button.addTarget(self, action: #selector(handleSettingsTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var attachementsButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "paperclip")
        button.configuration?.baseForegroundColor = grayColor
        button.addTarget(self, action: #selector(handleAttachementsTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var postTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "What would you like to share?"
        tv.placeholderLabel.font = .systemFont(ofSize: 18, weight: .regular)
        tv.font = .systemFont(ofSize: 18, weight: .regular)
        tv.textColor = blackColor
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
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
    
    private lazy var documentImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.layer.borderWidth = 1
        iv.layer.borderColor = blackColor.cgColor
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var deleteImageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 13, weight: .heavy)
        container.foregroundColor = UIColor.red
        
        button.configuration?.attributedTitle = AttributedString(" Delete", attributes: container)
        
        //button.configuration?.baseForegroundColor = .red
        button.configuration?.baseBackgroundColor = .black.withAlphaComponent(0.7)
        
        button.addTarget(self, action: #selector(didTapDeletePostImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var playVideoButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule

        button.configuration?.image = UIImage(systemName: "play.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(.white)
        button.configuration?.imagePlacement = .leading
        
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = .black.withAlphaComponent(0.7)
        
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
        container.font = .systemFont(ofSize: 17, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Share", attributes: container)
        
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
        postPrivacyMenuLauncher.delegate = self
        postAttachementsMenuLauncher.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scrollView.resizeScrollViewContentSize()
        
        if viewModel.hasVideo || viewModel.hasDocument {
            postTextView.becomeFirstResponder()
            return
        }
        
        postAttachementsMenuLauncher.showPostSettings(in: view)

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
        scrollView.addSubviews(profileImageView, fullName, postTextView, settingsPostButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            
            fullName.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            fullName.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            fullName.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -15),
            fullName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            settingsPostButton.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 4),
            settingsPostButton.leadingAnchor.constraint(equalTo: fullName.leadingAnchor),
            settingsPostButton.heightAnchor.constraint(equalToConstant: 23),
            
            postTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            postTextView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)

        ])

        profileImageView.layer.cornerRadius = 50/2
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
    
        fullName.text = user.firstName! + " " + user.lastName!
        updateForm()
    }
    
    func configureKeyboard() {
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: self, action: nil)
        fixedSpace.width = 10

        let attachementButton = UIBarButtonItem(customView: attachementsButton)
      
        toolbar.setItems([flexibleSpace, attachementButton], animated: true)
        
        postTextView.inputAccessoryView = toolbar //postTextView.textView
    }
    
    func addSinglePostImageToView(image: UIImage) {
        postImageView.image = image
        postImages.append(image)
        
        scrollView.addSubview(postImageView)
        postImageView.anchor(top: postTextView.bottomAnchor, left: postTextView.leftAnchor, right: postTextView.rightAnchor, paddingTop: 10)
        
        
        let ratio = image.size.width / image.size.height
        newHeight = view.bounds.width / ratio
        postImageView.setHeight(newHeight)

        addCancelButtonImagePost(to: postImageView)
        
        attachementsButton.isUserInteractionEnabled = false
        attachementsButton.alpha = 0.5
        
        viewModel.hasImage = true
        updateForm()
     
        scrollView.resizeScrollViewContentSize()
    }
    
    func addDocumentPostImageToView(image: UIImage) {
        postImageView.image = image
        postImages.append(image)
        
        scrollView.addSubview(postImageView)
        postImageView.anchor(top: postTextView.bottomAnchor, left: postTextView.leftAnchor, right: postTextView.rightAnchor, paddingTop: 10)
        
        
        let ratio = image.size.width / image.size.height
        newHeight = view.bounds.width / ratio
        postImageView.setHeight(newHeight)

        addCancelButtonImagePost(to: postImageView)
        
        attachementsButton.isUserInteractionEnabled = false
        attachementsButton.alpha = 0.5
        
        viewModel.hasDocument = true
        updateForm()
     
        scrollView.resizeScrollViewContentSize()
    }
    
    
    func addPostImagesToView(images: [UIImage]) {
        gridImagesView.images = images

        gridImagesView.screenWidth = postTextView.bounds.size.width
        
        gridImagesView.configure()
        
        gridImagesView.translatesAutoresizingMaskIntoConstraints = false
        gridImagesView.layer.cornerRadius = 10
        gridImagesView.layer.borderWidth = 1
        gridImagesView.layer.borderColor = UIColor.black.cgColor
        
        scrollView.addSubview(gridImagesView)
        
        NSLayoutConstraint.activate([
            gridImagesView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            gridImagesView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            gridImagesView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
            gridImagesView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        addCancelButtonImagePost(to: gridImagesView)
    
        attachementsButton.isUserInteractionEnabled = false
        attachementsButton.alpha = 0.5
        
        viewModel.hasImage = true
        updateForm()
       
        scrollView.resizeScrollViewContentSize()
        
    }
    
    func addVideoPostPlaceholderImage(image: UIImage) {
        
        videoImageView.image = image

        scrollView.addSubview(videoImageView)
        videoImageView.anchor(top: postTextView.bottomAnchor, left: postTextView.leftAnchor, right: postTextView.rightAnchor, paddingTop: 10)
        
        videoImageView.setHeight(200)

        addCancelButtonImagePost(to: videoImageView)
        addPlayButtonImageToPost(to: videoImageView)
        
        attachementsButton.isUserInteractionEnabled = false
        attachementsButton.alpha = 0.5
        
        viewModel.hasVideo = true
        updateForm()
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
    
    @objc func didTapDeletePostImage() {
        postImageView.removeFromSuperview()
        gridImagesView.removeFromSuperview()
        videoImageView.removeFromSuperview()
        deleteImageButton.removeFromSuperview()
        playVideoButton.removeFromSuperview()
        
        let group = DispatchGroup()
        
        postImageView.constraints.forEach { constraint in
            group.enter()
            defer {
                group.leave()
            }
            constraint.isActive = false
        }
        
        postImages.removeAll()
        newHeight = 0.0
        
        group.notify(queue: .main) {
            self.scrollView.resizeScrollViewContentSize()
        }
        
        scrollView.resizeScrollViewContentSize()
        
        viewModel.hasImage = false
        viewModel.hasVideo = false
        viewModel.hasDocument = false
        updateForm()
        
        attachementsButton.isUserInteractionEnabled = true
        attachementsButton.alpha = 1
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
        vc.player?.play()
    }
    
    @objc func handleSettingsTap() {
        postTextView.resignFirstResponder()
        postPrivacyMenuLauncher.showPostSettings(in: view)
    }
    
    @objc func handleAttachementsTap() {
        postTextView.resignFirstResponder()
        postAttachementsMenuLauncher.showPostSettings(in: view)
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
        
        if viewModel.hasDocument {
            print("has document")
            guard let docUrl = postDocumentUrl else {
                return
            }
            
            let fileName = uid + docUrl.lastPathComponent
            StorageManager.uploadPostFile(fileName: fileName, url: docUrl) { result in
                switch result {
                case .success(let url):
                    //print(url)
                    PostService.uploadDocumentPost(post: postTextView, documentURL: url, documentTitle: self.postDocumentTitle!, documentPages: self.postDocumentPages!, user: self.user, type: .document) { error in
                        if let error = error {
                            print(error.localizedDescription)
                            
                        } else {
                            print("Document uploaded to firebase")

                        }
                    }
                case .failure(let error):
                    print("Could not create the url")
                    print(error)
                }
            }
            return
        }
        
        
        
        if postImages.count > 0 {
            print("Has images")
            let imagesToUpload = postImages.compactMap { $0 }

            switch imagesToUpload.count {
            case 1:
                StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                    // Post images saved to firebase. Upload post with images
                    // post: postTextView, type: .plainText, privacy: privacyType, user: user
                    PostService.uploadSingleImagePost(post: postTextView, type: .textWithImage, privacy: self.privacyType, postImageUrl: imageUrl, imageHeight: self.newHeight, user: self.user) { error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        } else {
                            // Post is uploaded to Firebase
                            // Dismiss VC Here

                        }
                    }
                }
                
            case 2:
                StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                    // Post images saved to firebase. Upload post with images
                    PostService.uploadPost(post: postTextView, postImageUrl: imageUrl, type: .textWithTwoImage, user: self.user) { error in
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
                    PostService.uploadPost(post: postTextView, postImageUrl: imageUrl, type: .textWithThreeImage, user: self.user) { error in
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
                    PostService.uploadPost(post: postTextView, postImageUrl: imageUrl, type: .textWithFourImage, user: self.user) { error in
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
                break
            }
        } else {
            // Post has text only
            PostService.uploadTextPost(post: postTextView, type: .plainText, privacy: privacyType, user: user) { error in
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
        viewModel.text = textView.text
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        postTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        scrollView.resizeScrollViewContentSize()
        updateForm()
    }
}

//MARK: - PHPickerViewControllerDelegate

extension UploadPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        if results.count == 0 { return }
        
        
        let group = DispatchGroup()
        var order = [String]()
        var asyncDict = [String:UIImage]()
        var images = [UIImage]()
        
        
        results.forEach { result in
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                order.append(result.assetIdentifier ?? "")
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                    guard let self = self else { return }
                    defer {
                        group.leave()
                    }
                    guard let image = reading as? UIImage, error == nil else { return }
                    asyncDict[result.assetIdentifier ?? ""] = image
                    
                }

            }
            
            
            
            else {
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
                        self.getThumbnailImageFromVideoUrl(url: self.videoUrl!) { thumbNailImage in
                            guard let thumbNailImage = thumbNailImage else {
                                return
                            }
                            DispatchQueue.main.async {
                                self.addVideoPostPlaceholderImage(image: thumbNailImage)
                            }

                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            if order.count == 1 {
                self.addSinglePostImageToView(image: asyncDict[order[0]]!)
                
            } else {
                for id in order {
                    images.append(asyncDict[id]!)
                }
                self.postImages = images
                self.addPostImagesToView(images: self.postImages)
            
            
            
            //else if self.postImages.count == results.count {
                //self.addPostImagesToView(images: self.postImages)
            }
        }
        postAttachementsMenuLauncher.handleDismissMenu()
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


extension UploadPostViewController: PostPrivacyMenuLauncherDelegate {
    func didTapPrivacyOption(_ option: Post.PrivacyOptions, _ image: UIImage, _ privacyText: String) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        settingsPostButton.configuration?.attributedTitle = AttributedString(" \(privacyText)", attributes: container)
        settingsPostButton.configuration?.image = image.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        privacyType = option
        
    }
    
    func didDissmisMenu() {
        postTextView.becomeFirstResponder()
    }
}

extension UploadPostViewController: UploadContentViewModel {
    func updateForm() {
        shareButton.configuration?.baseBackgroundColor = viewModel.buttonBackgroundColor
        shareButton.isUserInteractionEnabled = viewModel.postIsValid
    }
}


extension UploadPostViewController: PostAttachementsMenuLauncherDelegate {
    func didTap(_ option: Attachement) {
        
        switch option {
        case .photo:
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = 4
            config.preferredAssetRepresentationMode = .current
            config.selection = .ordered
            config.filter = PHPickerFilter.any(of: [.images])
            
            let vc = PHPickerViewController(configuration: config)
            vc.delegate = self
            present(vc, animated: true)
            
        case .video:
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = 1
            config.preferredAssetRepresentationMode = .current
            config.filter = PHPickerFilter.any(of: [.videos])
            
            let vc = PHPickerViewController(configuration: config)
            vc.delegate = self
            present(vc, animated: true)
            
        case .document:
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
            picker.delegate = self
            navigationController?.present(picker, animated: true)
            
        case .poll:
            /*
            let controller = PollConfigurationViewController()
            
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
             */
            
            postAttachementsMenuLauncher.handleDismissMenu()
        }
    }
    
    
    func menuDidDismiss() {
        postTextView.becomeFirstResponder()
    }
}


extension UploadPostViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        _ = url.startAccessingSecurityScopedResource()
        
        self.postAttachementsMenuLauncher.handleDismissMenu()
        
        let controller = FileConfiguratorViewController(url: url)
        controller.delegate = self
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

extension UploadPostViewController: FileConfiguratorViewControllerDelegate {
    func addDocumentToPost(title: String, numberOfPages: Int, documentImage: UIImage, documentURL: URL) {
        postDocumentTitle = title
        postDocumentPages = numberOfPages
        postDocumentUrl = documentURL
        addDocumentPostImageToView(image: documentImage)
    }
}

extension UploadPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pollCellReuseIdentifier, for: indexPath) as! PostPollCell
        cell.titlePollOption.placeholder = "Choice \(indexPath.row + 1)"
        cell.titlePollOption.delegate = self
        cell.selectionStyle = .none
        cell.contentView.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension UploadPostViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField)
    }
    
    
}
