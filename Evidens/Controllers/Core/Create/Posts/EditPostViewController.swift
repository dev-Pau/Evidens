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
    
    //private var post: Post
    var viewModel: EditPostViewModel

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
        tv.textContainerInset = UIEdgeInsets.zero
        tv.contentInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
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
    }
    
    init(post: Post) {
        self.viewModel = EditPostViewModel(post: post)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: primaryColor)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    
    private func configureUI() {
        guard let name = UserDefaults.standard.value(forKey: "name") as? String else { return }
        
        view.backgroundColor = .systemBackground
        postTextView.text = viewModel.postText
        postTextView.handleTextDidChange()
        
        (_, _) = postTextView.processHashtagLink()
        
        postTextView.delegate = self
        
        let imageSize: CGFloat = UIDevice.isPad ? 60 : 50
        
        view.addSubview(scrollView)
        scrollView.addSubviews(profileImage, fullName, postTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            profileImage.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            profileImage.heightAnchor.constraint(equalToConstant: imageSize),
            profileImage.widthAnchor.constraint(equalToConstant: imageSize),
            
            fullName.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            fullName.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15),
            fullName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        
            postTextView.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10),
            postTextView.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        profileImage.layer.cornerRadius = imageSize/2
        
        if let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageUrl != "" {
            profileImage.sd_setImage(with: URL(string: imageUrl))
        }
        
        fullName.text = name

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
            
            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            
            scrollView.resizeContentSize()
        }
    }
    
    
    @objc func didTapCancel() {
        guard navigationItem.rightBarButtonItem?.isEnabled == true else { 
            dismiss(animated: true)
            return
        }
        
        displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.postTextView.resignFirstResponder()
            strongSelf.dismiss(animated: true)
        }
    }
    
    @objc func didTapEdit() {
        guard let _ = postTextView.text else { return }
        
        showProgressIndicator(in: view)
        postTextView.resignFirstResponder()
        
        PostService.editPost(viewModel: viewModel) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                strongSelf.viewModel.post.postText = strongSelf.viewModel.postText
                strongSelf.viewModel.post.kind = strongSelf.viewModel.kind
                strongSelf.viewModel.post.edited = true
                
                if strongSelf.viewModel.kind == .link {
                    strongSelf.viewModel.post.linkUrl = strongSelf.viewModel.links.first
                }

                ContentManager.shared.editPostChange(post: strongSelf.viewModel.post)
                strongSelf.dismiss(animated: true)
            }
        }
    }
}

//MARK: - UITextViewDelegate

extension EditPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {

        viewModel.edit(textView.text.trimmingCharacters(in: .whitespacesAndNewlines))
        
        var links = [String]()
        var hashtag = [String]()
        
        (hashtag, links) = textView.processHashtagLink()
        
        viewModel.set(hashtag)

        navigationItem.rightBarButtonItem?.isEnabled = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? false : true

        switch viewModel.kind {
            
        case .text:
            if !links.isEmpty {
                viewModel.addLink(links) { [weak self] metadata in
                    guard let _ = self else { return }
                }
            } else {
                viewModel.setLinks([String]())
            }
        case .image:
            break
        case .link:
            if links.isEmpty && viewModel.linkLoaded {
                viewModel.set(nil)
                viewModel.set(false)
            } else {
                
                if links.first != viewModel.links.first {
                    viewModel.set(false)

                    viewModel.addLink(links) { [weak self] metadata in
                        guard let _ = self else { return }
                    }
                }
            }
        }
        
        let currentOffset = scrollView.contentOffset
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        postTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }

        scrollView.contentOffset = currentOffset

           UIView.animate(withDuration: 0.2) { [weak self] in
               guard let strongSelf = self else { return }
               strongSelf.view.layoutIfNeeded()
           }
        
        scrollView.resizeContentSize()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}
