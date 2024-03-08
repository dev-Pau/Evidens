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

    private let cellHeight: CGFloat = (UIScreen.main.bounds.width - 40) * 0.55

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
    
    private let toolbar = PostToolbar()
    
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
        let standardAppearance = UINavigationBarAppearance.secondaryAppearance()
        let scrollAppearance = UINavigationBarAppearance.contentAppearance()
        navigationController?.navigationBar.standardAppearance = scrollAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
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
        collectionView.register(ShareCaseImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        collectionView.register(ContentLinkCell.self, forCellWithReuseIdentifier: contentLinkCellReuseIdentifier)
        collectionView.register(ContentReferenceCell.self, forCellWithReuseIdentifier: referenceCellReuseIdentifier)
        collectionView.isScrollEnabled = false
        scrollView.addSubviews(profileImageView, postTextView, collectionView)
        
        let imageSize: CGFloat = UIDevice.isPad ? 45 : 35
        
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
            
            postTextView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -(postTextView.font?.lineHeight ?? 0) / 2),
            postTextView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            collectionView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionViewHeightAnchor,
        ])

        profileImageView.layer.cornerRadius = imageSize / 2
        
        profileImageView.addImage(forUrl: UserDefaults.getImage(), size: imageSize)
       
        toolbar.toolbarDelegate = self
        updateForm()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let imageSize: CGFloat = UIDevice.isPad ? 45 : 35
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            if sectionNumber == 0 {
                
                let size: NSCollectionLayoutDimension = strongSelf.viewModel.hasReference ? .absolute(strongSelf.referenceHeight) : .estimated(strongSelf.referenceHeight)

                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: size, heightDimension: size))
               
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: size, heightDimension: size), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: imageSize + 20, bottom: 0, trailing: 10)
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
               
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: strongSelf.viewModel.kind == .link ? .fractionalWidth(1) : .fractionalWidth(0.5), heightDimension: .absolute(strongSelf.cellHeight)), subitems: [item])                                         
                let section = NSCollectionLayoutSection(group: group)

                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: imageSize + 20, bottom: 0, trailing: 10)
                return section
            }
            
        }
        return layout
    }
    
    func configureKeyboard() {
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        postTextView.inputAccessoryView = toolbar
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
                                                       bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom/* + 20*/,
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

extension AddPostViewController {
    func updateForm() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.postIsValid
    }
}

extension AddPostViewController: PostToolbarDelegate {
    func didTapQuoteButton() {
        if let reference = viewModel.reference {
            addReference(reference)
        } else {
            postTextView.resignFirstResponder()
            let controller = ReferenceViewController(controller: self)
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            
            present(navVC, animated: true)
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

extension AddPostViewController {
    
    func addReference(_ reference: Reference) {
        switch reference.option {
        case .link:
            let controller = AddWebLinkReferenceViewController(controller: self, reference: reference)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        case .citation:
            let controller = AddAuthorReferenceViewController(controller: self, reference: reference)
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
    }
}
