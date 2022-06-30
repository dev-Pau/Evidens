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
    
    private var collectionImages: [UIImage]? {
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
    
    
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCaseCollectionView()
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
        
        scrollView.addSubviews(imageBackgroundView, photoImage)
        
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
            photoImage.heightAnchor.constraint(equalToConstant: 50)
        ])
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
            casesCollectionView.heightAnchor.constraint(equalToConstant: 210)
        ])
        print(newCellWidth)
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
        guard let collectionImages = collectionImages else { return 0 }
        print(collectionImages.count)
        return collectionImages.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = casesCollectionView.dequeueReusableCell(withReuseIdentifier: casesCellReuseIdentifier, for: indexPath) as! CasesCell
        cell.delegate = self
        cell.set(image: collectionImages![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: newCellWidth[indexPath.row], height: casesCollectionView.frame.height)
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
            casesCollectionView.deleteItems(at: [indexPath])
            collectionImages?.remove(at: indexPath.item)
        }
    }
}


