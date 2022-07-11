//
//  UploadClinicalCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/6/22.
//

import UIKit
import PhotosUI

private let casesCellReuseIdentifier = "CasesCellReuseIdentifier"
private let specialityCellReuseIdentifier = "SpecialityCellReuseIdentifier"
private let caseTypeCellReuseIdentifier = "CaseTypeCellReuseIdentifier"

class ShareClinicalCaseViewController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User?
    
    private var specialitiesSelected: [String] = []
    private var caseTypesSelected: [String] = []
    
    private var cellSizes: [CGFloat] = []
    
    private var collectionImages = [UIImage]() {
        didSet {
            caseImagesCollectionView.reloadData()
        }
    }
    
    private var newCellWidth: [CGFloat] = []
    
    private var previousValue: Int = 0
    
    var diagnosisHeight: CGFloat = 0
    
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
    
    private let caseImagesCollectionView: UICollectionView = {
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
    
    private let specialitiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()
    
    private let caseTypeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
    
    private let imageTitleSeparatorLabel: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleDescriptionSeparatorLabel: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSeparatorLabel: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var descriptionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var titleShapeTracker = LinearShapeTextTracker(withSteps: CGFloat(50))
    
    private var descriptionShapeTracker = LinearShapeTextTracker(withSteps: CGFloat(1000))
    
    private lazy var titleTextField: UITextField = {
        let tf = METextField(placeholder: "Title", withSpacer: false)
        tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Description"
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
    
    private lazy var specialitiesView = CaseDetailsView(title: "Specialities")
    private lazy var clinicalTypeView = CaseDetailsView(title: "Type details")
    
    private lazy var caseStageView = CaseStageView()
    
    private lazy var diagnosisView = DiagnosisView()
    
    
       
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCaseCollectionView()
        configureSpecialityCollectionView()
        configureCaseTypeCollectionView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        specialitiesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToSpecialitiesController)))
        clinicalTypeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToClinicalTypeController)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.resizeScrollViewContentSize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleShapeTracker.addShapeIndicator(in: titleView)
        descriptionShapeTracker.addShapeIndicator(in: descriptionView)
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
        

        titleView.isHidden = true
        descriptionView.isHidden = true

        caseStageView.delegate = self
        
        scrollView.keyboardDismissMode = .onDrag
        
        
        scrollView.addSubviews(imageBackgroundView, photoImage, infoImageLabel, imageTitleSeparatorLabel, titleDescriptionSeparatorLabel, titleLabel, titleView, titleTextField, descriptionTextView, descriptionLabel, descriptionView, specialitiesView, clinicalTypeView, bottomSeparatorLabel, caseStageView)
        
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
            
            imageTitleSeparatorLabel.topAnchor.constraint(equalTo: infoImageLabel.bottomAnchor, constant: 20),
            imageTitleSeparatorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageTitleSeparatorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageTitleSeparatorLabel.heightAnchor.constraint(equalToConstant: 1),
            
            titleTextField.topAnchor.constraint(equalTo: imageTitleSeparatorLabel.bottomAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: imageTitleSeparatorLabel.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: imageTitleSeparatorLabel.trailingAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            titleView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 4),
            titleView.widthAnchor.constraint(equalToConstant: 70),
            titleView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 2),
            
            titleLabel.bottomAnchor.constraint(equalTo: titleTextField.topAnchor, constant: -2),
            titleLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
         
            titleDescriptionSeparatorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            titleDescriptionSeparatorLabel.leadingAnchor.constraint(equalTo: imageTitleSeparatorLabel.leadingAnchor),
            titleDescriptionSeparatorLabel.trailingAnchor.constraint(equalTo: imageTitleSeparatorLabel.trailingAnchor),
            titleDescriptionSeparatorLabel.heightAnchor.constraint(equalToConstant: 1),
          
            descriptionTextView.topAnchor.constraint(equalTo: titleDescriptionSeparatorLabel.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: imageTitleSeparatorLabel.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: imageTitleSeparatorLabel.trailingAnchor),
            
            descriptionView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            descriptionView.widthAnchor.constraint(equalToConstant: 70),
            descriptionView.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            descriptionView.heightAnchor.constraint(equalToConstant: 2),
            
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: -2),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            
            specialitiesView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            specialitiesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            specialitiesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            specialitiesView.heightAnchor.constraint(equalToConstant: 62),
            
            clinicalTypeView.topAnchor.constraint(equalTo: specialitiesView.bottomAnchor),
            clinicalTypeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clinicalTypeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            clinicalTypeView.heightAnchor.constraint(equalToConstant: 62),
            
            bottomSeparatorLabel.topAnchor.constraint(equalTo: clinicalTypeView.bottomAnchor),
            bottomSeparatorLabel.leadingAnchor.constraint(equalTo: imageTitleSeparatorLabel.leadingAnchor),
            bottomSeparatorLabel.trailingAnchor.constraint(equalTo: imageTitleSeparatorLabel.trailingAnchor),
            bottomSeparatorLabel.heightAnchor.constraint(equalToConstant: 1),
            
            caseStageView.topAnchor.constraint(equalTo: bottomSeparatorLabel.bottomAnchor),
            caseStageView.leadingAnchor.constraint(equalTo: bottomSeparatorLabel.leadingAnchor),
            caseStageView.trailingAnchor.constraint(equalTo: bottomSeparatorLabel.trailingAnchor),
            caseStageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        scrollView.resizeScrollViewContentSize()
    }
    
    func configureCaseCollectionView() {
        caseImagesCollectionView.register(CasesCell.self, forCellWithReuseIdentifier: casesCellReuseIdentifier)
        caseImagesCollectionView.delegate = self
        caseImagesCollectionView.dataSource = self
    }
    
    func configureSpecialityCollectionView() {
        specialitiesCollectionView.register(SpecialitiesCell.self, forCellWithReuseIdentifier: specialityCellReuseIdentifier)
        specialitiesCollectionView.delegate = self
        specialitiesCollectionView.dataSource = self

    }
    
    func configureCaseTypeCollectionView() {
        caseTypeCollectionView.register(SpecialitiesCell.self, forCellWithReuseIdentifier: caseTypeCellReuseIdentifier)
        caseTypeCollectionView.delegate = self
        caseTypeCollectionView.dataSource = self
    }
    
    func addCaseCollectionView() {
        imageBackgroundView.removeFromSuperview()
        photoImage.removeFromSuperview()
        
        scrollView.addSubview(caseImagesCollectionView)
        
        NSLayoutConstraint.activate([
            caseImagesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            caseImagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            caseImagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            caseImagesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            infoImageLabel.topAnchor.constraint(equalTo: caseImagesCollectionView.bottomAnchor, constant: 5),
        ])
    }
    
    func addSpecialityCollectionView() {
        specialitiesView.configure(collectionView: specialitiesCollectionView)
        specialitiesCollectionView.reloadData()
    }
    
    func addCaseTypeCollectionView() {
        clinicalTypeView.configure(collectionView: caseTypeCollectionView)
        caseTypeCollectionView.reloadData()
    }
    
    func addBackgroundImage() {
        caseImagesCollectionView.removeFromSuperview()
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
    
    func configureDiagnosisView(height: CGFloat) {
        diagnosisView.removeFromSuperview()
        scrollView.addSubview(diagnosisView)
        
        NSLayoutConstraint.activate([
            diagnosisView.topAnchor.constraint(equalTo: caseStageView.bottomAnchor, constant: 5),
            diagnosisView.leadingAnchor.constraint(equalTo: caseStageView.leadingAnchor),
            diagnosisView.trailingAnchor.constraint(equalTo: caseStageView.trailingAnchor),
            diagnosisView.heightAnchor.constraint(equalToConstant: height + 10)
        ])
        
        scrollView.resizeScrollViewContentSize()
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
        
        if count != 0 {
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
        
        if count > 50 {
            titleTextField.deleteBackward()
            return
        }
        
        if previousValue == 0 {
            titleShapeTracker.updateShapeIndicator(toValue: text.count, previousValue: 0)
        } else {
            titleShapeTracker.updateShapeIndicator(toValue: text.count, previousValue: previousValue)
        }
        
        previousValue = text.count
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
    
    @objc func goToSpecialitiesController() {
        let controller = SpecialitiesListViewController(specialitiesSelected: specialitiesSelected)
        controller.delegate = self
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = blackColor
        navigationItem.backBarButtonItem = backButton
                
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func goToClinicalTypeController() {
        let controller = ClinicalTypeViewController(selectedTypes: caseTypesSelected)
        controller.delegate = self
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = blackColor
        navigationItem.backBarButtonItem = backButton
        
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
        if collectionView == caseImagesCollectionView {
            return collectionImages.count
        } else if collectionView == specialitiesCollectionView {
            print(specialitiesSelected.count)
            return specialitiesSelected.count
        } else {
            print(caseTypesSelected.count)
            return caseTypesSelected.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == caseImagesCollectionView {
            let cell = caseImagesCollectionView.dequeueReusableCell(withReuseIdentifier: casesCellReuseIdentifier, for: indexPath) as! CasesCell
            cell.delegate = self
            cell.set(image: collectionImages[indexPath.row])
            return cell
            
        } else if collectionView == specialitiesCollectionView {
            let cell = specialitiesCollectionView.dequeueReusableCell(withReuseIdentifier: specialityCellReuseIdentifier, for: indexPath) as! SpecialitiesCell
            cell.specialityLabel.text = specialitiesSelected[indexPath.row]
            return cell
            
        } else {
            let cell = caseTypeCollectionView.dequeueReusableCell(withReuseIdentifier: caseTypeCellReuseIdentifier, for: indexPath) as! SpecialitiesCell
            cell.specialityLabel.text = caseTypesSelected[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == caseImagesCollectionView {
            if collectionImages.count == 1 {
                return CGSize(width: caseImagesCollectionView.frame.width - 10, height: caseImagesCollectionView.frame.height)
            } else { return CGSize(width: newCellWidth[indexPath.item], height: caseImagesCollectionView.frame.height) }
        } else if collectionView == specialitiesCollectionView {
            //let cell = specialitiesCollectionView.cellForItem(at: indexPath) as! SpecialitiesCell
            //let width = cell.size(forHeight: 50).width
            return CGSize(width: size(forHeight: 30, forText: specialitiesSelected[indexPath.item]).width + 30, height: 30)
        } else {
            return CGSize(width: size(forHeight: 30, forText: caseTypesSelected[indexPath.item]).width + 30, height: 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension ShareClinicalCaseViewController: CasesCellDelegate {
    func delete(_ cell: CasesCell) {
        if let indexPath = caseImagesCollectionView.indexPath(for: cell) {
            caseImagesCollectionView.performBatchUpdates {
                newCellWidth.remove(at: indexPath.item)
                collectionImages.remove(at: indexPath.item)
                caseImagesCollectionView.deleteItems(at: [indexPath])
                if collectionImages.isEmpty {
                    addBackgroundImage()
                }
            }
        }
    }
}

extension ShareClinicalCaseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleView.isHidden = true
    }
}

extension ShareClinicalCaseViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView)
        let count = textView.text.count
        
        if count != 0 {
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        if previousValue == 0 {
            descriptionShapeTracker.updateShapeIndicator(toValue: count, previousValue: 0)
        } else {
            descriptionShapeTracker.updateShapeIndicator(toValue: count, previousValue: previousValue)
        }
        
        previousValue = count
        //descriptionIndicator.characterCountLabel.text = "\(count)/2500"
        
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
        //descriptionIndicator.isHidden = false
        descriptionView.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //descriptionIndicator.isHidden = true
        descriptionView.isHidden = true
    }
}

extension ShareClinicalCaseViewController: SpecialitiesListViewControllerDelegate {
    func presentSpecialities(_ specialities: [String]) {
        specialitiesSelected = specialities
        addSpecialityCollectionView()
    }
    
    func size(forHeight height: CGFloat, forText text: String) -> CGSize {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.setHeight(height)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

extension ShareClinicalCaseViewController: ClinicalTypeViewControllerDelegate {
    func didSelectCaseType(_ types: [String]) {
        caseTypesSelected = types
        addCaseTypeCollectionView()
    }
}

extension ShareClinicalCaseViewController: CaseStageViewDelegate {
    func didTapResolved() {
        let controller = CaseDiagnosisViewController()
        controller.delegate = self
        let navController = UINavigationController(rootViewController: controller)
        
        if let presentationController = navController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        
        present(navController, animated: true)
    }
}

extension ShareClinicalCaseViewController: CaseDiagnosisViewControllerDelegate {
    func handleAddDiagnosis(_ text: String) {
        diagnosisHeight = size(forWidth: view.frame.width, forText: text).height + 40
        diagnosisView.diagnosisLabel.text = text
        configureDiagnosisView(height: diagnosisHeight)
    }
    
    func size(forWidth width: CGFloat, forText text: String) ->CGSize {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}



