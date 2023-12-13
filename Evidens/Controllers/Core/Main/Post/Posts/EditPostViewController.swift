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

protocol EditPostViewControllerDelegate: AnyObject {
    func didEditPost(post: Post)
}

class EditPostViewController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: EditPostViewControllerDelegate?
    
    private var post: Post
    private var viewModel: EditPostViewModel

    private lazy var postImages: [UIImage] = []

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private var profileImage = ProfileImageView(frame: .zero)
    
    private let fullName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let postTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Post.share
        let font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .regular)
        tv.placeholderLabel.font = font
        tv.font = font
        tv.textColor = .label
        tv.tintColor = primaryColor
        tv.isScrollEnabled = false
        tv.placeHolderShouldCenter = false
        tv.textContainerInset = UIEdgeInsets.zero
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
   
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 17, scaleStyle: .title1, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.edit, attributes: container)
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
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
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
        scrollView.resizeContentSize()
        postTextView.becomeFirstResponder()
    }
    
    init(post: Post) {
        self.post = post
        self.viewModel = EditPostViewModel(post: post.postText, postId: post.postId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    
    private func configureUI() {
        guard let name = UserDefaults.standard.value(forKey: "name") as? String else { return }
        
        view.backgroundColor = .systemBackground
        postTextView.text = post.postText
        postTextView.handleTextDidChange()
        (_, _) = postTextView.processHashtagLink()
        postTextView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubviews(profileImage, separatorView, fullName, postTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            profileImage.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            profileImage.widthAnchor.constraint(equalToConstant: 50),
            
            fullName.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            fullName.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15),
            fullName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            separatorView.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            postTextView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            postTextView.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        profileImage.layer.cornerRadius = 50/2
        
        if let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageUrl != "" {
            profileImage.sd_setImage(with: URL(string: imageUrl))
        }
        
        fullName.text = name
    
        if let imageUrl = post.imageUrl?.first {
            postImageView.sd_setImage(with: URL(string: imageUrl)) { image, _, cacheType, _ in
                guard let image = image else { return }
                self.addSinglePostImageToView(image: image)
            }
            
            if imageUrl.count > 1 {
                self.addImageInfoButtonToView()
              
            }
        }
    }
    
    func addImageInfoButtonToView() {
        guard let imageUrl = post.imageUrl, imageUrl.count > 1 else { return }
        var container = AttributeContainer()
        
        container.font = UIFont.addFont(size: 17, scaleStyle: .title1, weight: .bold, scales: false)
        plusImagesButton.configuration?.attributedTitle = AttributedString("+ " + "\(imageUrl.count - 1)", attributes: container)
        view.addSubview(plusImagesButton)
        NSLayoutConstraint.activate([
            plusImagesButton.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            plusImagesButton.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor)
        ])
    }
    
    func addSinglePostImageToView(image: UIImage) {
        postImageView.image = image
        postImages.append(image)

        let ratio = image.size.width / image.size.height

        scrollView.addSubview(postImageView)
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: (view.frame.width - 20) / ratio)
        ])
    }
    
    //MARK: - Actions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            scrollView.resizeContentSize()
            
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
            
            scrollView.resizeContentSize()
        }
    }
    
    
    @objc func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func didTapEdit() {
        guard let postText = postTextView.text else { return }
        
        showProgressIndicator(in: view)
        
        PostService.editPost(viewModel: viewModel) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                strongSelf.post.postText = postText
                strongSelf.post.edited = true
                ContentManager.shared.editPostChange(post: strongSelf.post)
                strongSelf.dismiss(animated: true)
            }
        }
    }
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
        scrollView.resizeContentSize()
        
        if textView.text.count != 0 {
            
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        viewModel.edit(textView.text.trimmingCharacters(in: .whitespaces))
        let (hashtag, _) = textView.processHashtagLink()
        viewModel.set(hashtag)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}
