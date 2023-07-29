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
import JGProgressHUD

private let professionPostCellReuseIdentifier = "ProfessionCellReuseIdentifier"
private let shareCaseImageCellReuseIdentifier = "SharePostImageCellReuseIdentifier"
private let referenceHeaderReuseIdentifier = "ReferenceHeaderReuseIdentifier"

class AddPostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User
    private var collectionView: UICollectionView!
    private var viewModel = AddPostViewModel()
    private var menu = PostPrivacyMenu()
    private let progressIndicator = JGProgressHUD()

    private let topSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let toolbar: PostToolbar!
    
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
        button.configuration?.image = viewModel.privacy.image.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(primaryColor)
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 5
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        button.configuration?.attributedTitle = AttributedString(" \(viewModel.privacy.title)", attributes: container)
        button.configuration?.baseForegroundColor = primaryColor
        button.addTarget(self, action: #selector(handleSettingsTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var postTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = AppStrings.Content.Post.share
        tv.placeholderLabel.font = .systemFont(ofSize: 18, weight: .regular)
        tv.font = .systemFont(ofSize: 18, weight: .regular)
        tv.textColor = .label
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.placeHolderShouldCenter = false
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
        container.font = .systemFont(ofSize: 17, weight: .bold)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Content.Post.post, attributes: container)
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
    
    init(user: User) {
        self.user = user
        toolbar = PostToolbar(disciplines: [user.discipline!])
        viewModel.disciplines = [user.discipline!]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        
        scrollView.addSubviews(profileImageView, fullName, topSeparatorView, postTextView, settingsPostButton)
        
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
            settingsPostButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            settingsPostButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            topSeparatorView.topAnchor.constraint(equalTo: settingsPostButton.bottomAnchor, constant: 10),
            topSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            postTextView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 10),
            postTextView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ShareCaseImageCell.self, forCellWithReuseIdentifier: shareCaseImageCellReuseIdentifier)
        collectionView.register(ReferenceHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: referenceHeaderReuseIdentifier)
        profileImageView.layer.cornerRadius = 50/2
        
        if let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }

        toolbar.toolbarDelegate = self
        fullName.text = user.firstName! + " " + user.lastName!
        updateForm()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
           
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(200)), subitems: [item])
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)), elementKind: ElementKind.sectionHeader, alignment: .top)
                                                                     
            let section = NSCollectionLayoutSection(group: group)
            if strongSelf.viewModel.reference != nil { section.boundarySupplementaryItems = [header] }
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
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
   
    func addContentCollectionView() {
        scrollView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        collectionView.reloadData()
        scrollView.resizeContentSize()
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
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollView.resizeContentSize()
        }
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc func didTapShare() {
        progressIndicator.show(in: view)
        PostService.addPost(viewModel: viewModel) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.progressIndicator.dismiss(animated: true)
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                strongSelf.dismiss(animated: true)
            }
        }
    }
}

extension AddPostViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareCaseImageCellReuseIdentifier, for: indexPath) as! ShareCaseImageCell
        cell.caseImage = viewModel.images[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: referenceHeaderReuseIdentifier, for: indexPath) as! ReferenceHeader
        header.reference = viewModel.reference
        header.delegate = self
        return header
    }
}

extension AddPostViewController: ShareCaseImageCellDelegate, ReferenceHeaderDelegate {
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
            if viewModel.images.isEmpty {
                toolbar.handleUpdateMediaButtonInteraction()
            }
        }
    }
}

extension AddPostViewController: AddWebLinkReferenceDelegate {
    func didTapDeleteReference() {
        viewModel.reference = nil
        collectionView.reloadData()
    }
}

//MARK: - UITextViewDelegate

extension AddPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.text = textView.text
        viewModel.hashtags = textView.hashtags()
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        postTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }

        scrollView.resizeContentSize()
        updateForm()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

//MARK: - PHPickerViewControllerDelegate

extension AddPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        postTextView.becomeFirstResponder()
        if results.count == 0 { return }
        
        let group = DispatchGroup()
        var order = [String]()
        var asyncDict = [String:UIImage]()
        var images = [UIImage]()
        
        progressIndicator.show(in: view)
        
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
                    strongSelf.viewModel.images = images
                    strongSelf.addContentCollectionView()
                    strongSelf.toolbar.handleUpdateMediaButtonInteraction()
                    strongSelf.progressIndicator.dismiss(animated: true)
                }
            }
        }
    }
}

extension AddPostViewController: PostPrivacyMenuLauncherDelegate {
    func didTapPrivacyOption(_ option: PostPrivacy) {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .bold)
        settingsPostButton.configuration?.attributedTitle = AttributedString(" \(option.title)", attributes: container)
        settingsPostButton.configuration?.image = option.image.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(primaryColor)
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

extension AddPostViewController: ProfessionListViewControllerDelegate {
    func didTapAddProfessions(profession: [Discipline]) {
        viewModel.disciplines = profession
        toolbar.set(disciplines: viewModel.disciplines)
    }
}

extension AddPostViewController: PostToolbarDelegate {
    func didTapQuoteButton() {
        if let reference = viewModel.reference {
            didTapEditReference(reference)
        } else {
            postTextView.resignFirstResponder()
            let controller = ReferencesViewController()
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("PostReference"), object: nil)
            
            present(navVC, animated: true)
        }
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        if let reference = notification.userInfo, let currentReference = reference["reference"] as? Reference {
            viewModel.reference = currentReference
            if viewModel.images.isEmpty {
                addContentCollectionView()
            } else {
                collectionView.reloadData()
            }
        }
    }
    
    func didTapAddMediaButton() {
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
    
    func didTapConfigureDisciplines() {
        let controller = ProfessionListViewController(professionsSelected: viewModel.disciplines)
        controller.delegate = self
       
        navigationController?.pushViewController(controller, animated: true)
    }
}
