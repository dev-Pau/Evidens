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

private let pollCellReuseIdentifier = "PollCellReuseIdentifier"

class UploadPostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User
    private var group: Group?
    
    private var viewModel = UploadPostViewModel()
    
    private var postPrivacyMenuLauncher = PostPrivacyMenuLauncher()
    
    private var postImages: [UIImage] = []
    
    private var privacyType: Post.PrivacyOptions = .all
    
    var gridImagesView = MEImagesGridView(images: [UIImage()], screenWidth: .zero)
    
    var newHeight: CGFloat = 0.0
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barTintColor = .systemBackground
        toolbar.clipsToBounds = true
        toolbar.sizeToFit()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let fullName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var settingsPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = primaryColor
        button.configuration?.background.strokeWidth = 1
        button.configuration?.image = privacyType.privacyImage.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(primaryColor)
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 5
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        button.configuration?.attributedTitle = AttributedString(" \(privacyType.privacyTitle)", attributes: container)
        button.configuration?.baseForegroundColor = primaryColor
        button.addTarget(self, action: #selector(handleSettingsTap), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
    
        return button
    }()
    
    private lazy var attachementsButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "photo.on.rectangle.angled")
        button.configuration?.baseForegroundColor = primaryColor
        button.addTarget(self, action: #selector(handleAttachementsTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var postTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "What would you like to share?"
        tv.placeholderLabel.font = .systemFont(ofSize: 18, weight: .regular)
        tv.font = .systemFont(ofSize: 18, weight: .regular)
        tv.textColor = .label
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
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
   
    private lazy var deleteImageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .systemRed.withAlphaComponent(0.7)
        button.configuration?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18)).withTintColor(.white)
        button.addTarget(self, action: #selector(didTapDeletePostImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
   
    private lazy var shareButton: UIButton = {
        let button = UIButton()

        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Upload", attributes: container)
        
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

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scrollView.resizeScrollViewContentSize()
        postTextView.becomeFirstResponder()
    }
    
    init(user: User, group: Group? = nil) {
        self.user = user
        
        if let group = group {
            privacyType = .group
            self.group = group
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "Upload a post"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.leftBarButtonItem?.tintColor = .label
    
    }
    
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        if let group = group {
            postPrivacyMenuLauncher.isUploadingPostFromGroup(group: group)
            didSelectGroup(group)
        }
        
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
            //settingsPostButton.heightAnchor.constraint(equalToConstant: 24),
            settingsPostButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            settingsPostButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            postTextView.topAnchor.constraint(equalTo: settingsPostButton.bottomAnchor, constant: 10),
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
        
        textViewDidChange(postTextView)
        
        viewModel.hasImage = true
        updateForm()
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
       
        //scrollView.resizeScrollViewContentSize()
        textViewDidChange(postTextView)
    }
    
    
    
    func addCancelButtonImagePost(to imageView: UIImageView) {
        scrollView.addSubview(deleteImageButton)
        deleteImageButton.anchor(top: imageView.topAnchor, right: imageView.rightAnchor, paddingTop: 10, paddingRight: 10)
    }
    
    
    func addCancelButtonImagePost(to imageView: MEImagesGridView) {
        scrollView.addSubview(deleteImageButton)
        deleteImageButton.anchor(top: imageView.topAnchor, right: imageView.rightAnchor, paddingTop: 10, paddingRight: 10)
    }

    @objc func didTapDeletePostImage() {
        postImageView.removeFromSuperview()
        gridImagesView.removeFromSuperview()
        deleteImageButton.removeFromSuperview()
        
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
        updateForm()
        
        attachementsButton.isUserInteractionEnabled = true
        attachementsButton.alpha = 1
    }
    
    @objc func handleSettingsTap() {
        postTextView.resignFirstResponder()
        postPrivacyMenuLauncher.showPostSettings(in: view)
    }
    
    @objc func handleAttachementsTap() {
        postTextView.resignFirstResponder()
        
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 4
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.filter = PHPickerFilter.any(of: [.images])
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
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
        dismiss(animated: true)
    }
    
    
    @objc func didTapShare() {
        guard let postTextView = postTextView.text else { return }
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        showLoadingView()
      

        if let group = group {
            // Group post
            if postImages.count > 0 {
                let imagesToUpload = postImages.compactMap { $0 }
                var postType = Post.PostType(rawValue: imagesToUpload.count) ?? .plainText
                if postImages.count == 1 {
                    
                    #warning("pujar el post amb type")
                } else {
                    StorageManager.uploadGroupPostImage(images: imagesToUpload, uid: uid, groupId: group.groupId) { imageUrl in
                        GroupService.uploadGroupPost(groupId: group.groupId, post: postTextView, type: postType, privacy: .group, groupPermission: group.permissions, postImageUrl: imageUrl) { error in
                            self.dismiss(animated: true)
                            if let error = error {
                                print("DEBUG: \(error.localizedDescription)")
                                
                                return
                            } else {

                                return
                                
                            }
                        }
                    }
                }
            } else {
                
                GroupService.uploadGroupPost(groupId: group.groupId, post: postTextView, type: .plainText, privacy: .group, groupPermission: group.permissions, postImageUrl: nil) { error in
                    self.dismiss(animated: true)
                    if let error = error {
                        print("DEBUG: \(error.localizedDescription)")
                        
                        return
                    } else {

                        return
                        
                    }
                }
            }
            }
        else {
            
            
            
            
            
            
            
            
            
            
            // No group post
            
            if postImages.count > 0 {
                print("Has images")
                let imagesToUpload = postImages.compactMap { $0 }
              
                switch imagesToUpload.count {
                case 1:
                    StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                        // Post images saved to firebase. Upload post with images
                        // post: postTextView, type: .plainText, privacy: privacyType, user: user
                        PostService.uploadSingleImagePost(post: postTextView, type: .textWithImage, privacy: self.privacyType, postImageUrl: imageUrl, imageHeight: self.newHeight, user: self.user) { error in
                            self.dismissLoadingView()
                            if let error = error {
                                print("DEBUG: \(error.localizedDescription)")
                                
                                return
                            } else {
                                self.dismiss(animated: true)
                                
                            }
                        }
                    }
                    
                case 2:
                    StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                        // Post images saved to firebase. Upload post with images
                        PostService.uploadPost(post: postTextView, type: .textWithTwoImage, privacy: self.privacyType, postImageUrl: imageUrl, user: self.user) { error in
                            self.dismissLoadingView()
                            if let error = error {
                                print("DEBUG: \(error.localizedDescription)")
                                return
                            } else {
                                self.dismiss(animated: true)
                            }
                        }
                    }
                case 3:
                    StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                        // Post images saved to firebase. Upload post with images
                        PostService.uploadPost(post: postTextView, type: .textWithThreeImage, privacy: self.privacyType, postImageUrl: imageUrl, user: self.user) { error in
                            self.dismissLoadingView()
                            if let error = error {
                                print("DEBUG: \(error.localizedDescription)")
                                return
                            } else {
                                self.dismiss(animated: true)
                            }
                        }
                    }
                case 4:
                    StorageManager.uploadPostImage(images: imagesToUpload, uid: uid) { imageUrl in
                        // Post images saved to firebase. Upload post with images
                        PostService.uploadPost(post: postTextView, type: .textWithFourImage, privacy: self.privacyType, postImageUrl: imageUrl, user: self.user) { error in
                            self.dismissLoadingView()
                            if let error = error {
                                print("DEBUG: \(error.localizedDescription)")
                                return
                            } else {
                                self.dismiss(animated: true)
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
                        self.dismissLoadingView()
                        print("DEBUG: \(error.localizedDescription)")
                        return
                    } else {
                        self.dismiss(animated: true)
                    }
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
        postTextView.becomeFirstResponder()
        if results.count == 0 { return }
        
        
        let group = DispatchGroup()
        var order = [String]()
        var asyncDict = [String:UIImage]()
        var images = [UIImage]()
        
        showLoadingView()
        
        results.forEach { result in
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                order.append(result.assetIdentifier ?? "")
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    defer {
                        group.leave()
                    }
                    guard let image = reading as? UIImage, error == nil else { return }
                    asyncDict[result.assetIdentifier ?? ""] = image
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
            }
            self.dismissLoadingView()
        }
    }

}


extension UploadPostViewController: PostPrivacyMenuLauncherDelegate {
    func didTapPrivacyOption(_ option: Post.PrivacyOptions) {
        if option == .group {
            let controller = PostGroupSelectionViewController(groupSelected: group)
            controller.delegate = self
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            
            present(navVC, animated: true)
            return
        }
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        settingsPostButton.configuration?.attributedTitle = AttributedString(" \(option.privacyTitle)", attributes: container)
        settingsPostButton.configuration?.image = option.privacyImage.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(primaryColor)
        privacyType = option
        self.group = Group(groupId: "", dictionary: [:])
    }
 
    func didDissmisMenu() {
        postTextView.becomeFirstResponder()
    }
}

extension UploadPostViewController: UploadContentViewModel {
    func updateForm() {
        //shareButton.configuration?.baseBackgroundColor = viewModel.buttonBackgroundColor
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.postIsValid
    }
}

extension UploadPostViewController: PostGroupSelectionViewControllerDelegate {
    func didSelectGroup(_ group: Group) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        settingsPostButton.configuration?.attributedTitle = AttributedString(" \(group.name)", attributes: container)
        settingsPostButton.configuration?.image = Post.PrivacyOptions.group.privacyImage.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(primaryColor)
        privacyType = .group
        self.group = group
        postPrivacyMenuLauncher.updatePrivacyWithGroupOptions(group: group)
    }
}
