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

private let professionPostCellReuseIdentifier = "ProfessionCellReuseIdentifier"
private let shareCaseImageCellReuseIdentifier = "SharePostImageCellReuseIdentifier"
private let referenceHeaderReuseIdentifier = "ReferenceHeaderReuseIdentifier"
private let contentLinkCellReuseIdentifier = "ContentLinkCellReuseIdentifier"

class AddPostViewController: UIViewController {
    
    //MARK: - Properties
    private var viewModel: AddPostViewModel
    private var user: User

    private let cellHeight: CGFloat = (UIScreen.main.bounds.width - 40) * 0.55

    private var collectionView: UICollectionView!
    private var collectionViewHeightAnchor: NSLayoutConstraint!
    
    private var menu = PostPrivacyMenu()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let toolbar = PostToolbar()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: AppStrings.Assets.profile)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let fullName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var settingsPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = primaryColor
        button.configuration?.background.strokeWidth = 1
        
        let imageSize: CGFloat = UIDevice.isPad ? 20 : 15
        
        button.configuration?.image = viewModel.privacy.image.scalePreservingAspectRatio(targetSize: CGSize(width: imageSize, height: imageSize)).withTintColor(primaryColor)
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 10
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 12, scaleStyle: .title1, weight: .bold)
        button.configuration?.attributedTitle = AttributedString(viewModel.privacy.title, attributes: container)
        button.configuration?.baseForegroundColor = primaryColor
        button.addTarget(self, action: #selector(handleSettingsTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        tv.textContainerInset = UIEdgeInsets.zero
        tv.textContainer.lineFragmentPadding = .zero
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 17, scaleStyle: .title1, weight: .bold, scales: false)
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
        menu.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.resizeContentSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scrollView.resizeContentSize()
        postTextView.becomeFirstResponder()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("PostReference"), object: nil)
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
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        addNavigationBarLogo(withTintColor: primaryColor)
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
        collectionView.register(ShareCaseImageCell.self, forCellWithReuseIdentifier: shareCaseImageCellReuseIdentifier)
        collectionView.register(ReferenceHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: referenceHeaderReuseIdentifier)
        collectionView.register(ContentLinkCell.self, forCellWithReuseIdentifier: contentLinkCellReuseIdentifier)
        collectionView.isScrollEnabled = false
        scrollView.addSubviews(profileImageView, fullName, postTextView, settingsPostButton, collectionView)
        
        let imageSize: CGFloat = UIDevice.isPad ? 70 : 60
        
        collectionViewHeightAnchor = collectionView.heightAnchor.constraint(equalToConstant: 30)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15),
            profileImageView.heightAnchor.constraint(equalToConstant: imageSize),
            profileImageView.widthAnchor.constraint(equalToConstant: imageSize),
            
            fullName.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            fullName.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            fullName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            settingsPostButton.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 4),
            settingsPostButton.leadingAnchor.constraint(equalTo: fullName.leadingAnchor),
            settingsPostButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            postTextView.topAnchor.constraint(equalTo: settingsPostButton.bottomAnchor, constant: 15),
            postTextView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            collectionView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionViewHeightAnchor,
        ])

        profileImageView.layer.cornerRadius = imageSize / 2
        
        if let imageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }

        toolbar.toolbarDelegate = self
        fullName.text = user.name()
        updateForm()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
           
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: strongSelf.viewModel.kind == .link ? .fractionalWidth(1) : .fractionalWidth(0.5), heightDimension: .absolute(strongSelf.cellHeight)), subitems: [item])
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(strongSelf.referenceHeight)), elementKind: ElementKind.sectionHeader, alignment: .top)
                                                                     
            let section = NSCollectionLayoutSection(group: group)
            if strongSelf.viewModel.reference != nil { section.boundarySupplementaryItems = [header] }
            section.orthogonalScrollingBehavior = strongSelf.viewModel.kind == .link ? .none : .continuous
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            return section
        }
        return layout
    }
    
    func configureKeyboard() {
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        postTextView.inputAccessoryView = toolbar
    }
   
    @objc func handleSettingsTap() {
        postTextView.resignFirstResponder()
        menu.showPostSettings(in: view)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.kind {
        case .text:
            return 0
        case .image:
            return viewModel.images.count
        case .link:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.kind {
        case .text:
            fatalError()
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseImageCellReuseIdentifier, for: indexPath) as! ShareCaseImageCell
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: referenceHeaderReuseIdentifier, for: indexPath) as! ReferenceHeader
        header.reference = viewModel.reference
        header.delegate = self
        return header
    }
}

extension AddPostViewController: ShareCaseImageCellDelegate, ReferenceHeaderDelegate {
    func referenceNotValid() {

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.displayAlert(withTitle: AppStrings.Error.unknown)

            strongSelf.viewModel.reference = nil
            strongSelf.collectionViewHeightAnchor.constant = max(strongSelf.collectionViewHeightAnchor.constant - strongSelf.referenceHeight, 0)
            strongSelf.scrollView.resizeContentSize()
            strongSelf.collectionView.reloadData()
            strongSelf.view.layoutIfNeeded()
        }
    }
    
    func didTapEditReference(_ reference: Reference) {
        switch reference.option {
        case .link:
            let controller = AddWebLinkReferenceViewController(reference: reference)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        case .citation:
            let controller = AddAuthorReferenceViewController(reference: reference)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("PostReference"), object: nil)
    }
    
    func delete(_ cell: ShareCaseImageCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            viewModel.images.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            toolbar.handleUpdateMediaButtonInteraction(forNumberOfImages: viewModel.images.count)
            
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
}

//MARK: - UITextViewDelegate

extension AddPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        let count = textView.text.count
        
        if count > viewModel.postSize {
            textView.deleteBackward()
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

                            NotificationCenter.default.post(name: NSNotification.Name("PostHeader"), object: nil)
                            strongSelf.collectionViewHeightAnchor.constant += strongSelf.viewModel.linkLoaded ? 0 : strongSelf.cellHeight
                            strongSelf.viewModel.linkLoaded = true
                            strongSelf.viewModel.linkMetadata = metadata
                            strongSelf.toolbar.enableImages(false)
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
                            NotificationCenter.default.post(name: NSNotification.Name("PostHeader"), object: nil)
                            
                            if let metadata {
                                guard strongSelf.viewModel.kind == .link, !links.isEmpty else { return }
                                strongSelf.viewModel.linkMetadata = metadata
                                
                                strongSelf.toolbar.enableImages(false)
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
                    
                    NotificationCenter.default.post(name: NSNotification.Name("PostHeader"), object: nil)
                    
                    strongSelf.view.layoutIfNeeded()
                    strongSelf.viewModel.images.append(contentsOf: images)
                    strongSelf.postTextView.becomeFirstResponder()
                    
                    strongSelf.collectionView.reloadData()
                    
                    strongSelf.toolbar.handleUpdateMediaButtonInteraction(forNumberOfImages: strongSelf.viewModel.images.count)
                    strongSelf.dismissProgressIndicator()
                    strongSelf.scrollView.resizeContentSize()
                }
            }
        }
    }
}

extension AddPostViewController: PostPrivacyMenuLauncherDelegate {
    func didTapPrivacyOption(_ option: PostPrivacy) {
        
        let imageSize: CGFloat = UIDevice.isPad ? 20 : 15
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 12, scaleStyle: .title1, weight: .bold)
        settingsPostButton.configuration?.attributedTitle = AttributedString(option.title, attributes: container)
        settingsPostButton.configuration?.image = option.image.scalePreservingAspectRatio(targetSize: CGSize(width: imageSize, height: imageSize)).withTintColor(primaryColor)
        viewModel.privacy = option
    }
    
    func didDissmisMenu() {
        postTextView.becomeFirstResponder()
    }
}

extension AddPostViewController {
    func updateForm() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.postIsValid
    }
}

extension AddPostViewController: PostToolbarDelegate {
    func didTapQuoteButton() {
        if let reference = viewModel.reference {
            didTapEditReference(reference)
        } else {
            postTextView.resignFirstResponder()
            let controller = ReferenceViewController()
            
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("PostReference"), object: nil)
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            
            present(navVC, animated: true)
        }
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        if let reference = notification.userInfo, let currentReference = reference["reference"] as? Reference {
            if !viewModel.hasReference {
                collectionViewHeightAnchor.constant += referenceHeight
            }
            
            viewModel.reference = currentReference
            collectionView.reloadData()
            scrollView.resizeContentSize()
        }
    }
    
    func didTapAddMediaButton() {
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
        NotificationCenter.default.post(name: NSNotification.Name("PostHeader"), object: nil)
        
        viewModel.linkMetadata = nil
        viewModel.linkLoaded = false
        collectionViewHeightAnchor.constant -= cellHeight
        collectionView.reloadData()
        toolbar.enableImages(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.scrollView.resizeContentSize()
        }
    }
}
