//
//  EditPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/8/22.
//

import UIKit
import Photos
import PhotosUI
import Firebase
import SDWebImage

class EditPostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var post: Post
    
    private lazy var postImages: [UIImage] = []
    
    private lazy var hasImage: Bool = false
    
    lazy var gridImagesView = MEImagesGridView(images: [UIImage()], screenWidth: .zero)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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
        label.textColor = .black
        return label
    }()
    
    private lazy var postTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "What do you want to talk about?"
        tv.placeholderLabel.font = .systemFont(ofSize: 18, weight: .regular)
        tv.font = .systemFont(ofSize: 18, weight: .regular)
        tv.textColor = .black
        tv.delegate = self
        tv.tintColor = primaryColor
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
        iv.layer.borderColor = UIColor.black.cgColor
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
   
    private lazy var editButton: UIButton = {
        let button = UIButton()
        
        button.configuration = .gray()
        
        button.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
        button.configuration?.baseForegroundColor = .white
        
        button.isUserInteractionEnabled = false
        
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Save", attributes: container)
        
        button.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        return button
    }()
    
    private lazy var plusImagesButton: UIButton = {
        let button = UIButton()
        
        button.configuration = .filled()
        
        button.configuration?.baseBackgroundColor = .black.withAlphaComponent(0.7)
        button.configuration?.baseForegroundColor = .white
        
        button.configuration?.buttonSize = .mini
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isUserInteractionEnabled = false
        
        button.configuration?.cornerStyle = .capsule

        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        
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
        scrollView.resizeScrollViewContentSize()
        postTextView.becomeFirstResponder()
    }
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "Edit your post"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    
    private func configureUI() {
        view.backgroundColor = .white
        postTextView.text = post.postText
        postTextView.handleTextDidChange()
        
        
        view.addSubview(scrollView)
        scrollView.addSubviews(profileImageView, fullName, postTextView)
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            
            fullName.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            fullName.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            fullName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            postTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            postTextView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        profileImageView.layer.cornerRadius = 50/2
        
        profileImageView.sd_setImage(with: URL(string: post.ownerImageUrl))
        fullName.text = post.ownerFirstName + " " + post.ownerLastName
        
        if post.postImageUrl.count != 0 {
            postImageView.sd_setImage(with: URL(string: post.postImageUrl.first!)) { image, _, cacheType, _ in
                guard let image = image else { return }
                self.addSinglePostImageToView(image: image)
            }
            if post.postImageUrl.count > 1 {
                self.addImageInfoButtonToView()
              
            }
        }
    }
    
    func addImageInfoButtonToView() {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        plusImagesButton.configuration?.attributedTitle = AttributedString("+ " + "\(post.postImageUrl.count - 1)", attributes: container)
        view.addSubview(plusImagesButton)
        NSLayoutConstraint.activate([
            plusImagesButton.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            plusImagesButton.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor)
        ])
    }
    
    func addSinglePostImageToView(image: UIImage) {
        postImageView.image = image
        postImages.append(image)
        
        let imageHeight = post.imageHeight.isZero ? 270 : post.imageHeight
        
        scrollView.addSubview(postImageView)
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: imageHeight)
        ])
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
    
    @objc func didTapEdit() {
        guard let postText = postTextView.text else { return }
    
        showLoadingView()
        
        PostService.editPost(withPostUid: post.postId, withNewText: postText) { uploaded in
            self.dismissLoadingView()
            if uploaded {
                self.dismiss(animated: true)
            } else {
                //Post not uploaded
            }
        }

        
        
    }
    
    //MARK: - Helpers
    
    
}

//MARK: - UITextViewDelegate

extension EditPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        postTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        scrollView.resizeScrollViewContentSize()
        
        if hasImage || textView.text.count != 0 {
            editButton.configuration?.baseBackgroundColor = primaryColor
            editButton.isUserInteractionEnabled = true
        } else {
            editButton.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
            editButton.isUserInteractionEnabled = false
        }
    }
}
