//
//  UploadClinicalCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/6/22.
//

import UIKit
import PhotosUI

private let casesCellReuseIdentifier = "CasesCellReuseIdentifier"

class ShareClinicalCaseViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User?
    
    private var collectionImages = [UIImage]() {
        didSet {
            casesCollectionView.reloadData()
        }
    }
    
    private var newCellWidth: [CGFloat] = []
    
    private lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()

        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Share", attributes: container)
        
        button.isUserInteractionEnabled = false
        button.alpha = 0.5
        
        button.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var imageBackgroundView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        //v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoTap)))
        v.backgroundColor = UIColor.init(rgb: 0xD5DBE7)
        v.layer.cornerRadius = 10
        return v
    }()
    
    private lazy var photoImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "image")
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoTap)))
        return iv
    }()
    
    private let casesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()
    
    private lazy var attributedImageInfo: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "Images can help others interpretation on what has happened to the patinent. Protecting patient privacy is our top priority. Visit our Patient Privacy Policy.")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12, weight: .bold), range: (aString.string as NSString).range(of: "Patient Privacy Policy"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Patient Privacy Policy"))
        return aString
    }()

    
    
    private lazy var infoImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.attributedText = attributedImageInfo
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title your case"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var titleTextField: UITextField = {
        let tf = METextField(placeholder: "Add a title")
        tf.delegate = self
        tf.font = .systemFont(ofSize: 17, weight: .semibold)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Help others with a description"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleIndicator = MECharacterIndicatorView(maxChar: 100)
    
    private lazy var descriptionTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add a description"
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tv.placeholderLabel.textColor = UIColor(white: 0.2, alpha: 0.7)
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = blackColor
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.backgroundColor = lightColor
        tv.layer.cornerRadius = 5
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var specialitiesLabel: UILabel = {
        let label = UILabel()
        label.text = "Specialities"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddSpecialities)))
        return label
    }()
    
    private lazy var descriptionIndicator = MECharacterIndicatorView(maxChar: 2500)
   
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCaseCollectionView()
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
        super.viewDidAppear(animated)
        scrollView.resizeScrollViewContentSize()
    }
    
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configureNavigationBar() {
        title = "Share a Case"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadButton)
        
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        titleIndicator.isHidden = true
        descriptionIndicator.isHidden = true
        
        scrollView.keyboardDismissMode = .onDrag
        
        scrollView.addSubviews(imageBackgroundView, photoImage, infoImageLabel, titleLabel, titleIndicator, titleTextField, descriptionLabel, descriptionTextView, descriptionIndicator, specialitiesLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageBackgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            imageBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageBackgroundView.heightAnchor.constraint(equalToConstant: 200),
            
            photoImage.centerXAnchor.constraint(equalTo: imageBackgroundView.centerXAnchor),
            photoImage.centerYAnchor.constraint(equalTo: imageBackgroundView.centerYAnchor),
            photoImage.widthAnchor.constraint(equalToConstant: 50),
            photoImage.heightAnchor.constraint(equalToConstant: 50),
            
            infoImageLabel.topAnchor.constraint(equalTo: imageBackgroundView.bottomAnchor, constant: 5),
            infoImageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            infoImageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: infoImageLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            titleTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            titleIndicator.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 2),
            titleIndicator.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            titleIndicator.heightAnchor.constraint(equalToConstant: 30),
            titleIndicator.widthAnchor.constraint(equalToConstant: 60),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleIndicator.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            descriptionIndicator.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 2),
            descriptionIndicator.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            descriptionIndicator.heightAnchor.constraint(equalToConstant: 30),
            descriptionIndicator.widthAnchor.constraint(equalToConstant: 60),
            
            specialitiesLabel.topAnchor.constraint(equalTo: descriptionIndicator.bottomAnchor),
            specialitiesLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            specialitiesLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            specialitiesLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        scrollView.resizeScrollViewContentSize()
    }
    
    func configureCaseCollectionView() {
        casesCollectionView.register(CasesCell.self, forCellWithReuseIdentifier: casesCellReuseIdentifier)
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
    }
    
    func addCaseCollectionView() {
        imageBackgroundView.removeFromSuperview()
        photoImage.removeFromSuperview()
        
        scrollView.addSubview(casesCollectionView)
        
        NSLayoutConstraint.activate([
            casesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            casesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            casesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            casesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            infoImageLabel.topAnchor.constraint(equalTo: casesCollectionView.bottomAnchor, constant: 5),
        ])
        
        
    }
    
    func addBackgroundImage() {
        casesCollectionView.removeFromSuperview()
        scrollView.addSubviews(imageBackgroundView, photoImage)
        
        NSLayoutConstraint.activate([
            imageBackgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            imageBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageBackgroundView.heightAnchor.constraint(equalToConstant: 200),
            
            photoImage.centerXAnchor.constraint(equalTo: imageBackgroundView.centerXAnchor),
            photoImage.centerYAnchor.constraint(equalTo: imageBackgroundView.centerYAnchor),
            photoImage.widthAnchor.constraint(equalToConstant: 50),
            photoImage.heightAnchor.constraint(equalToConstant: 50),
            
            infoImageLabel.topAnchor.constraint(equalTo: imageBackgroundView.bottomAnchor, constant: 5),
        ])
    }
    
    func checkMaxLength(_ textView: UITextView) {
        if textView.text.count > 2500 {
            textView.deleteBackward()
        }
    }
    
    //MARK: - Actions
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    
    @objc func didTapUpload() {
        print("DEBUG: Upload clinical case here")
    }
    
    @objc func handlePhotoTap() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 6
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.filter = PHPickerFilter.any(of: [.images])
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func textDidChange() {
        guard let text = titleTextField.text else { return }
        let count = text.count
        if count > 100 {
            titleTextField.deleteBackward()
            return
        }
        titleIndicator.characterCountLabel.text = "\(count)/100"
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.resizeScrollViewContentSize()

            let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)

            if notification.name == UIResponder.keyboardWillHideNotification {
                scrollView.contentInset = .zero
            } else {
                scrollView.contentInset = UIEdgeInsets(top: 0,
                                                       left: 0,
                                                       bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 45,
                                                       right: 0)
            }
            
            scrollView.scrollIndicatorInsets = scrollView.contentInset

            scrollView.resizeScrollViewContentSize()
        }
    }
    
    @objc func handleAddSpecialities() {
        let controller = SpecialitiesListViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = blackColor
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }

}

extension ShareClinicalCaseViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if results.count == 0 { return }
        
        let group = DispatchGroup()
        var asyncDict = [String:UIImage]()
        var asyncDictWidth = [String:CGFloat]()
        var order = [String]()
        var images = [UIImage]()
        var widths = [CGFloat]()
        
        results.forEach { result in
            group.enter()
            order.append(result.assetIdentifier ?? "")
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else { return }
                asyncDict[result.assetIdentifier ?? ""] = image
                
                let ratio = image.size.width / image.size.height
                let newWidth = ratio * 200
                asyncDictWidth[result.assetIdentifier ?? ""] = newWidth
            }
        }
        
        group.notify(queue: .main) {
            for id in order {
                images.append(asyncDict[id]!)
                widths.append(asyncDictWidth[id]!)
            }
            self.collectionImages = images
            self.newCellWidth = widths
            self.addCaseCollectionView()
        }
    }
}

extension ShareClinicalCaseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionImages.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = casesCollectionView.dequeueReusableCell(withReuseIdentifier: casesCellReuseIdentifier, for: indexPath) as! CasesCell
        cell.delegate = self
        cell.set(image: collectionImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionImages.count == 1 {
            return CGSize(width: casesCollectionView.frame.width - 10, height: casesCollectionView.frame.height)
        } else { return CGSize(width: newCellWidth[indexPath.item], height: casesCollectionView.frame.height) }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Open photo
    }
    
}

extension ShareClinicalCaseViewController: CasesCellDelegate {
    func delete(_ cell: CasesCell) {
        if let indexPath = casesCollectionView.indexPath(for: cell) {
            casesCollectionView.performBatchUpdates {
                newCellWidth.remove(at: indexPath.item)
                collectionImages.remove(at: indexPath.item)
                casesCollectionView.deleteItems(at: [indexPath])
                if collectionImages.isEmpty {
                    addBackgroundImage()
                }
            }
        }
    }
}

extension ShareClinicalCaseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleIndicator.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleIndicator.isHidden = true
    }
}

extension ShareClinicalCaseViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView)
        let count = textView.text.count
        descriptionIndicator.characterCountLabel.text = "\(count)/2500"
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        descriptionTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        scrollView.resizeScrollViewContentSize()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionIndicator.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        descriptionIndicator.isHidden = true
    }
}


