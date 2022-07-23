//
//  CaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

private let caseStageCellReuseIdentifier = "CaseStageCellReuseIdentifier"
private let specialitiesCellReuseIdentifier = "SpecialitiesCellReuseIdentifier"
private let imageCellReuseIdentifier = "ImageCellReuseIdentifier"

class CaseTextImageCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    
    private var caseDetails: [String] = []
    private var specialitiesDetails: [String] = []
    private var urlImages: [URL] = []
    
    private var userPostView = MEUserPostView()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = .black
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleThreeDots), for: .touchUpInside)
        return button
    }()
    
    private let caseStageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.isUserInteractionEnabled = true
        collectionView.register(SpecialitiesCell.self, forCellWithReuseIdentifier: caseStageCellReuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let specialitiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.isUserInteractionEnabled = true
        collectionView.register(SpecialitiesCell.self, forCellWithReuseIdentifier: specialitiesCellReuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let caseImagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isUserInteractionEnabled = true
        collectionView.register(CaseImageCell.self, forCellWithReuseIdentifier: imageCellReuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var titleCaseLabel = METitleCaseLabel()
    private var descriptionCaseLabel = MEPostLabel()
    private var caseStatsView = MEPostStatsView()
    private var caseInfoView = MECaseInfoView(comments: 0, commentText: "", views: 0, viewText: "")
    private var caseActionButtons = MECaseActionButtons()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        caseStageCollectionView.delegate = self
        caseStageCollectionView.dataSource = self
        specialitiesCollectionView.delegate = self
        specialitiesCollectionView.dataSource = self
        caseImagesCollectionView.delegate = self
        caseImagesCollectionView.dataSource = self
        
        addSubviews(userPostView, dotsImageButton, caseStageCollectionView, titleCaseLabel, descriptionCaseLabel, caseImagesCollectionView, specialitiesCollectionView, caseStatsView, caseInfoView, caseActionButtons)
        
        backgroundColor = .white
        
        NSLayoutConstraint.activate([
            dotsImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            userPostView.centerYAnchor.constraint(equalTo: dotsImageButton.centerYAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: dotsImageButton.trailingAnchor, constant: -10),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            caseStageCollectionView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            caseStageCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseStageCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            caseStageCollectionView.heightAnchor.constraint(equalToConstant: 40),
            
            titleCaseLabel.topAnchor.constraint(equalTo: caseStageCollectionView.bottomAnchor, constant: 5),
            titleCaseLabel.leadingAnchor.constraint(equalTo: caseStageCollectionView.leadingAnchor, constant: 10),
            titleCaseLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionCaseLabel.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 5),
            descriptionCaseLabel.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            descriptionCaseLabel.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            caseImagesCollectionView.topAnchor.constraint(equalTo: descriptionCaseLabel.bottomAnchor, constant: 5),
            caseImagesCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseImagesCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            caseImagesCollectionView.heightAnchor.constraint(equalToConstant: 300),
            
            specialitiesCollectionView.topAnchor.constraint(equalTo: caseImagesCollectionView.bottomAnchor, constant: 5),
            specialitiesCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            specialitiesCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            specialitiesCollectionView.heightAnchor.constraint(equalToConstant: 40),
            
            caseStatsView.topAnchor.constraint(equalTo: specialitiesCollectionView.bottomAnchor, constant: 10),
            caseStatsView.leadingAnchor.constraint(equalTo: descriptionCaseLabel.leadingAnchor),
            caseStatsView.widthAnchor.constraint(equalToConstant: 150),
            caseStatsView.heightAnchor.constraint(equalToConstant: 20),
            
            caseInfoView.centerYAnchor.constraint(equalTo: caseStatsView.centerYAnchor),
            caseInfoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            caseInfoView.heightAnchor.constraint(equalToConstant: 25),
            caseInfoView.widthAnchor.constraint(equalToConstant: 150),
            
            caseActionButtons.topAnchor.constraint(equalTo: caseInfoView.bottomAnchor, constant: 5),
            caseActionButtons.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseActionButtons.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            caseActionButtons.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configure() {
        caseDetails = []
        
        guard let viewModel = viewModel else { return }
        userPostView.usernameLabel.text = viewModel.fullName
        userPostView.profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        userPostView.postTimeLabel.text = viewModel.timestampString
        userPostView.userInfoCategoryLabel.text = viewModel.ownerProfession
        
        titleCaseLabel.text = viewModel.caseTitle
        descriptionCaseLabel.text = viewModel.caseDescription
        
        caseInfoView.configure(comments: viewModel.caseComments, commentText: viewModel.commentsText, views: viewModel.caseViews, viewText: viewModel.viewsText)
        
        caseActionButtons.likeButton.configuration?.image = viewModel.likeButtonImage
        caseActionButtons.likeButton.configuration?.baseForegroundColor = viewModel.likeButtonTintColor
        
        caseStatsView.likesLabel.text = "\(viewModel.caseLikes)"
        
        specialitiesDetails = viewModel.caseSpecialities
        
        caseDetails.append(viewModel.caseStage)
        viewModel.caseTypeDetails.forEach {  caseDetails.append($0) }
        
        urlImages = viewModel.caseImageUrl!
        
        caseStageCollectionView.reloadData()
        specialitiesCollectionView.reloadData()
        caseImagesCollectionView.reloadData()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleThreeDots() {
        
    }
}

extension CaseTextImageCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == caseStageCollectionView {
            return caseDetails.count
        } else if collectionView == specialitiesCollectionView {
            return specialitiesDetails.count
        } else {
            return urlImages.count

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == caseStageCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseStageCellReuseIdentifier, for: indexPath) as! SpecialitiesCell
            cell.specialityLabel.text = caseDetails[indexPath.row]
            return cell
        } else if collectionView == specialitiesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: specialitiesCellReuseIdentifier, for: indexPath) as! SpecialitiesCell
            cell.specialityLabel.text = specialitiesDetails[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseIdentifier, for: indexPath) as! CaseImageCell
            cell.caseImageView.sd_setImage(with: urlImages[indexPath.row])
            cell.backgroundColor = .systemPink
            //cell.specialityLabel.text = specialitiesDetails[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == caseStageCollectionView {
            return CGSize(width: size(forHeight: 30, forText: caseDetails[indexPath.item]).width + 30, height: 30)
        } else if collectionView == specialitiesCollectionView {
            return CGSize(width: size(forHeight: 30, forText: specialitiesDetails[indexPath.item]).width + 30, height: 30)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: 300)
        }
    }
}

extension CaseTextImageCell {
    func size(forHeight height: CGFloat, forText text: String) -> CGSize {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.setHeight(height)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

