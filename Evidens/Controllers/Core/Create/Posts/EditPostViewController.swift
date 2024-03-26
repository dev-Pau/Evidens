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
    
    let maxCount = 700

    var viewModel: EditPostViewModel
    
    var textButton: UIButton!

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private var profileImage = ProfileImageView(frame: .zero)
    
    private let postTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Post.share
        let font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .regular)
        tv.placeholderLabel.font = font
        tv.font = font
        tv.textColor = .label
        tv.tintColor = K.Colors.primaryColor
        tv.layoutManager.allowsNonContiguousLayout = false
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
        button.configuration?.baseBackgroundColor = K.Colors.primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title1, weight: .semibold, scales: false)
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
        postTextView.becomeFirstResponder()
        scrollView.resizeContentSize()
        postTextView.handleTextDidChange()
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
        let standardAppearance = UINavigationBarAppearance.secondaryAppearance()
        let scrollAppearance = UINavigationBarAppearance.contentAppearance()
        navigationController?.navigationBar.standardAppearance = scrollAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        addNavigationBarLogo(withTintColor: K.Colors.primaryColor)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.leftBarButtonItem?.tintColor = .label
        
        postTextView.inputAccessoryView = addPostToolbar()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        postTextView.text = viewModel.postText
        postTextView.handleTextDidChange()
        
        (_, _) = postTextView.processHashtagLink()
        
        postTextView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubviews(profileImage, postTextView)
    
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: K.Paddings.Content.verticalPadding),
            profileImage.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: K.Paddings.Content.horizontalPadding),
            profileImage.heightAnchor.constraint(equalToConstant: K.Paddings.Content.userImageSize),
            profileImage.widthAnchor.constraint(equalToConstant: K.Paddings.Content.userImageSize),
            
            postTextView.topAnchor.constraint(equalTo: profileImage.centerYAnchor, constant: -(postTextView.font?.lineHeight ?? 0) / 2),
            postTextView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),
        ])
        
        profileImage.layer.cornerRadius = K.Paddings.Content.userImageSize / 2
        
        profileImage.addImage(forUrl: UserDefaults.getImage(), size: K.Paddings.Content.userImageSize)
        
        updateTextCount(postTextView.text.count)
    }
    
    private func addPostToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        toolbar.scrollEdgeAppearance = appearance
        toolbar.standardAppearance = appearance
        
        textButton = UIButton(type: .system)
        textButton.translatesAutoresizingMaskIntoConstraints = false
        
        var textConfig = UIButton.Configuration.plain()
        textConfig.baseForegroundColor = .label
        textConfig.buttonSize = .mini
        
        textButton.configuration = textConfig
        
        let midButton = UIBarButtonItem(customView: textButton)
        
        toolbar.setItems([.flexibleSpace(), midButton, .flexibleSpace()], animated: false)
        toolbar.layoutIfNeeded()

        return toolbar
    }
    
    //MARK: - Actions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let window = UIWindow.visibleScreen {
            
            let convertedFrame = view.convert(view.bounds, to: window)
            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
            
            scrollView.resizeContentSize()

            if notification.name == UIResponder.keyboardWillHideNotification {
                scrollView.contentInset = .zero
            } else {
                if UIDevice.isPad {
                    var bottomInset = keyboardViewEndFrame.height
                    let windowBottom = UIWindow.visibleScreenBounds.maxY
                    let viewControllerBottom = convertedFrame.maxY
                    let distance = windowBottom - viewControllerBottom
                    bottomInset -= distance
                    scrollView.contentInset.bottom = bottomInset
                } else {
                    scrollView.contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
                }
            }
 
            scrollView.scrollIndicatorInsets = scrollView.contentInset
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
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.postTextView.becomeFirstResponder()
                }
            } else {
                strongSelf.viewModel.post.postText = strongSelf.viewModel.postText
                strongSelf.viewModel.post.kind = strongSelf.viewModel.kind
                strongSelf.viewModel.post.edited = true
                
                if strongSelf.viewModel.kind == .link {
                    strongSelf.viewModel.post.linkUrl = strongSelf.viewModel.links.first
                }

                ContentManager.shared.editPostChange(post: strongSelf.viewModel.post)
                
                let popupView = PopUpBanner(title: AppStrings.PopUp.postModified, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                popupView.showTopPopup(inView: strongSelf.view)
                
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
        
        let count = textView.text.count

        if count > maxCount {
            textView.deleteBackward()
        } else {
            updateTextCount(count)
        }
        
        textView.sizeToFit()
        scrollView.resizeContentSize()
    }
        
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
    
    private func updateTextCount(_ count: Int) {
        
        var tContainer = AttributeContainer()
        tContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular, scales: false)
        tContainer.foregroundColor = K.Colors.primaryGray
        
        let remainingCount = maxCount - count
        textButton.configuration?.attributedTitle = AttributedString("\(remainingCount)", attributes: tContainer)
    }
}
