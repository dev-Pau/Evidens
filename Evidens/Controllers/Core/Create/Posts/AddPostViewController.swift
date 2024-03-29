//
//  AddPostViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Photos
import PhotosUI
import Firebase
import SDWebImage

private let postImageCellReuseIdentifier = "SharePostImageCellReuseIdentifier"
private let referenceHeaderReuseIdentifier = "ReferenceHeaderReuseIdentifier"
private let contentLinkCellReuseIdentifier = "ContentLinkCellReuseIdentifier"
private let referenceCellReuseIdentifier = "ReferenceCellReuseIdentifier"

class AddPostViewController: UIViewController {
    
    //MARK: - Properties
    private var viewModel: AddPostViewModel
    private var user: User

    private let cellHeight: CGFloat = (UIWindow.visibleScreenWidth - 40) * 0.55

    var textButton: UIButton!
    var mediaButton: UIButton!
    var referenceButton: UIButton!
    
    private var collectionView: UICollectionView!
    private var collectionViewHeightAnchor: NSLayoutConstraint!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let profileImageView = ProfileImageView(frame: .zero)
   
    private lazy var postTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Post.share
        let font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .regular)
        tv.placeholderLabel.font = font
        tv.font = font
        tv.textColor = .label
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.contentInset = UIEdgeInsets.zero
        tv.layoutManager.allowsNonContiguousLayout = false
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = K.Colors.primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .title1, weight: .semibold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Post.post, attributes: container)
        button.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        return button
    }()
    
    private var referenceHeight: CGFloat = 75
 
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
        scrollView.resizeContentSize()
    }
    
    init(user: User, viewModel: AddPostViewModel) {
        self.user = user
        self.viewModel = viewModel
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ShareCaseImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        collectionView.register(ContentLinkCell.self, forCellWithReuseIdentifier: contentLinkCellReuseIdentifier)
        collectionView.register(ContentReferenceCell.self, forCellWithReuseIdentifier: referenceCellReuseIdentifier)
        collectionView.isScrollEnabled = false
        scrollView.addSubviews(profileImageView, postTextView, collectionView)
        
        collectionViewHeightAnchor = collectionView.heightAnchor.constraint(equalToConstant: 30)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: K.Paddings.Content.verticalPadding),
            profileImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: K.Paddings.Content.horizontalPadding),
            profileImageView.heightAnchor.constraint(equalToConstant: K.Paddings.Content.userImageSize),
            profileImageView.widthAnchor.constraint(equalToConstant: K.Paddings.Content.userImageSize),
            
            postTextView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -(postTextView.font?.lineHeight ?? 0) / 2),
            postTextView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),
            
            collectionView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: K.Paddings.Content.verticalPadding),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionViewHeightAnchor,
        ])

        profileImageView.layer.cornerRadius = K.Paddings.Content.userImageSize / 2
        
        profileImageView.addImage(forUrl: UserDefaults.getImage(), size: K.Paddings.Content.userImageSize)

        updateForm()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            if sectionNumber == 0 {
                
                let size: NSCollectionLayoutDimension = strongSelf.viewModel.hasReference ? .absolute(strongSelf.referenceHeight) : .estimated(strongSelf.referenceHeight)

                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: size, heightDimension: size))
               
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: size, heightDimension: size), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: K.Paddings.Content.userImageSize + 20, bottom: 0, trailing: 10)
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
               
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: strongSelf.viewModel.kind == .link ? .absolute(strongSelf.view.frame.width - (K.Paddings.Content.userImageSize + 20 + K.Paddings.Content.horizontalPadding)) : .fractionalWidth(0.5), heightDimension: .absolute(strongSelf.cellHeight)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)

                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: K.Paddings.Content.userImageSize + 20, bottom: 0, trailing: 10)
                return section
            }
            
        }
        return layout
    }
    
    func configureKeyboard() {
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
        
        mediaButton = UIButton(type: .system)
        mediaButton.addTarget(self, action: #selector(handleAddMedia), for: .touchUpInside)
        mediaButton.translatesAutoresizingMaskIntoConstraints = false
        
        referenceButton = UIButton(type: .system)
        referenceButton.addTarget(self, action: #selector(handleAddReference), for: .touchUpInside)
        referenceButton.translatesAutoresizingMaskIntoConstraints = false
        
        var mediaConfig = UIButton.Configuration.filled()
        mediaConfig.baseBackgroundColor = K.Colors.primaryColor
        mediaConfig.baseForegroundColor = .white
        mediaConfig.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        mediaConfig.cornerStyle = .capsule
        mediaConfig.buttonSize = .mini
        mediaConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        var referenceConfig = UIButton.Configuration.plain()
        referenceConfig.baseForegroundColor = K.Colors.primaryColor
        referenceConfig.image = UIImage(systemName: AppStrings.Icons.quote, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor)
        referenceConfig.cornerStyle = .capsule
        referenceConfig.buttonSize = .mini
        referenceConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        var textConfig = UIButton.Configuration.plain()
        textConfig.baseForegroundColor = .label
        textConfig.buttonSize = .mini
        textConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)

        referenceButton.configuration = referenceConfig
        textButton.configuration = textConfig
        mediaButton.configuration = mediaConfig
        
        let leftButton = UIBarButtonItem(customView: referenceButton)
        let midButton = UIBarButtonItem(customView: textButton)
        let rightButton = UIBarButtonItem(customView: mediaButton)

        toolbar.setItems([leftButton, .flexibleSpace(), midButton, .flexibleSpace(), rightButton], animated: false)
        toolbar.layoutIfNeeded()
       
        updateTextCount(0)
        postTextView.inputAccessoryView = toolbar
    }
    
    //MARK: - Actions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let window = UIWindow.visibleScreen, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
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
        displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.postTextView.resignFirstResponder()
            strongSelf.dismiss(animated: true)
        }
    }
    
    @objc func didTapShare() {
        showProgressIndicator(in: view)
        postTextView.resignFirstResponder()
        
        PostService.addPost(viewModel: viewModel) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.postTextView.becomeFirstResponder()
                }
            } else {
                let popupView = PopUpBanner(title: AppStrings.PopUp.postAdded, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                popupView.showTopPopup(inView: strongSelf.view)
                strongSelf.dismiss(animated: true)
            }
        }
    }
}

extension AddPostViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.hasReference ? 1 : 0
        } else {
            switch viewModel.kind {
            case .text:
                return 0
            case .image:
                return viewModel.images.count
            case .link:
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: referenceCellReuseIdentifier, for: indexPath) as! ContentReferenceCell
            cell.reference = viewModel.reference
            return cell
        } else {
            switch viewModel.kind {
            case .text:
                fatalError()
            case .image:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! ShareCaseImageCell
                cell.set(image: viewModel.images[indexPath.row])
                cell.delegate = self
                return cell
            case .link:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentLinkCellReuseIdentifier, for: indexPath) as! ContentLinkCell
                cell.delegate = self
                cell.configure(linkMetadata: viewModel.linkMetadata ?? nil)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let reference = viewModel.reference else { return }
            addReference(reference)
        }
    }
}

extension AddPostViewController: ShareCaseImageCellDelegate {

    func delete(_ cell: ShareCaseImageCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            viewModel.images.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            mediaButton.isEnabled = viewModel.images.count < 4
          
            if !viewModel.hasImages {
                collectionViewHeightAnchor.constant -= cellHeight
                scrollView.resizeContentSize()
                view.layoutIfNeeded()
            }
        }
    }
}

extension AddPostViewController: AddWebLinkReferenceDelegate {
    
    func didTapDeleteReference() {
        viewModel.reference = nil
        collectionViewHeightAnchor.constant -= referenceHeight
        scrollView.resizeContentSize()
        collectionView.reloadData()
        view.layoutIfNeeded()
    }
    
    func didAddReference(_ reference: Reference) {
        if !viewModel.hasReference {
            collectionViewHeightAnchor.constant += referenceHeight
        }
        
        viewModel.reference = reference
        collectionView.reloadData()
        scrollView.resizeContentSize()
        view.layoutIfNeeded()
    }
}

//MARK: - UITextViewDelegate

extension AddPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {

        let count = textView.text.count
        
        if count > viewModel.postSize {
            textView.deleteBackward()
        } else {
            updateTextCount(count)
        }
        
        viewModel.text = textView.text
        
        var links = [String]()
        
        (viewModel.hashtags, links) = textView.processHashtagLink()

        switch viewModel.kind {
        case .text:
            if !links.isEmpty {
                viewModel.addLink(links) { [weak self] metadata in
                    guard let _ = self else { return }
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        
                        if let metadata {
                            strongSelf.collectionViewHeightAnchor.constant += strongSelf.viewModel.linkLoaded ? 0 : strongSelf.cellHeight
                            strongSelf.viewModel.linkLoaded = true
                            strongSelf.viewModel.linkMetadata = metadata
                            strongSelf.mediaButton.isEnabled = false
                            strongSelf.collectionView.reloadData()
                        }
                    }
                }
            } else {
                viewModel.links.removeAll()
            }
        case .image:
            break
        case .link:
            if links.isEmpty && viewModel.linkLoaded {
                didDeleteLink()
            } else {
                
                if links.first != viewModel.links.first {
                    viewModel.linkLoaded = false
                    collectionView.reloadData()
                    
                    viewModel.addLink(links) { [weak self] metadata in
                        guard let _ = self else { return }
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                           
                            if let metadata {
                                guard strongSelf.viewModel.kind == .link, !links.isEmpty else { return }
                                strongSelf.viewModel.linkMetadata = metadata
                                
                                strongSelf.mediaButton.isEnabled = false
                                strongSelf.viewModel.linkLoaded = true
                                strongSelf.collectionView.reloadData()
                            } else {
                                strongSelf.didDeleteLink()
                            }
                        }
                    }
                }
            }
        }
        
        textView.sizeToFit()

        scrollView.resizeContentSize()
        
        updateForm()
    }
    

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
 
        if text.contains(UIPasteboard.general.string ?? "") {
            
        }
        
        return true
    }
}

//MARK: - PHPickerViewControllerDelegate

extension AddPostViewController: PHPickerViewControllerDelegate {
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if results.count == 0 { 
            postTextView.becomeFirstResponder()
            return
        }
        
        let group = DispatchGroup()
        var order = [String]()
        var asyncDict = [String:UIImage]()
        var images = [UIImage]()
        
        showProgressIndicator(in: view)
        
        results.forEach { result in
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                order.append(result.assetIdentifier ?? "")
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                    guard let _ = self else { return }
                    defer {
                        group.leave()
                    }
                    guard let image = reading as? UIImage, error == nil else { return }
                    asyncDict[result.assetIdentifier ?? ""] = image
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            for id in order {
                images.append(asyncDict[id]!)
                if images.count == order.count {
                    
                    guard !strongSelf.viewModel.linkLoaded else { return }
                    if !strongSelf.viewModel.hasImages {
                        strongSelf.collectionViewHeightAnchor.constant += strongSelf.cellHeight
                    }
                    
                    strongSelf.view.layoutIfNeeded()
                    strongSelf.viewModel.images.append(contentsOf: images)
                    strongSelf.postTextView.becomeFirstResponder()
                    
                    strongSelf.collectionView.reloadData()
                    
                    strongSelf.mediaButton.isEnabled = strongSelf.viewModel.images.count < 4
                    strongSelf.dismissProgressIndicator()
                    strongSelf.scrollView.resizeContentSize()
                }
            }
        }
    }
}

extension AddPostViewController {
    func updateForm() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.postIsValid
    }
}

extension AddPostViewController {
    @objc func handleAddReference() {
        if let reference = viewModel.reference {
            addReference(reference)
        } else {
            postTextView.resignFirstResponder()
            let controller = ReferenceViewController(controller: self)
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = UIModalPresentationStyle.getBasePresentationStyle()
            
            present(navVC, animated: true)
        }
    }
    
    @objc func handleAddMedia() {
        postTextView.resignFirstResponder()
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 4 - viewModel.images.count
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.filter = PHPickerFilter.any(of: [.images])
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
}

extension AddPostViewController: ContentLinkCellDelegate {
    func didAddLink() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.scrollView.resizeContentSize()
        }
    }
    
    func didDeleteLink() {
      
        viewModel.linkMetadata = nil
        viewModel.linkLoaded = false
        collectionViewHeightAnchor.constant -= cellHeight
        collectionView.reloadData()
        mediaButton.isEnabled = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.scrollView.resizeContentSize()
        }
    }
}

extension AddPostViewController {
  
    func addReference(_ reference: Reference) {
        switch reference.option {
        case .link:
            let controller = AddWebLinkReferenceViewController(controller: self, reference: reference)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = UIModalPresentationStyle.getBasePresentationStyle()
            present(navVC, animated: true)
        case .citation:
            let controller = AddAuthorReferenceViewController(controller: self, reference: reference)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = UIModalPresentationStyle.getBasePresentationStyle()
            present(navVC, animated: true)
        }
    }

    private func updateTextCount(_ count: Int) {
        
        var tContainer = AttributeContainer()
        tContainer.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular, scales: false)
        tContainer.foregroundColor = K.Colors.primaryGray
        
        let remainingCount = viewModel.postSize - count
        textButton.configuration?.attributedTitle = AttributedString("\(remainingCount)", attributes: tContainer)
    }
}
