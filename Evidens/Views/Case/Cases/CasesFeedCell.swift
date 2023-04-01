//
//  CasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/9/22.
//

import UIKit
import Combine
import SwiftUI

private let caseStageCellReuseIdentifier = "CaseStageCellReuseIdentifier"
private let specialitiesCellReuseIdentifier = "SpecialitiesCellReuseIdentifier"
private let imageCellReuseIdentifier = "ImageCellReuseIdentifier"
private let pagingSectionFooterViewReuseIdentifier = "PagingSectionFooterViewReuseIdentifier"

class CasesFeedCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    private var user: User?
    
    weak var delegate: CaseCellDelegate?
    
    private let cellContentView = UIView()
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    private lazy var caseStateButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 10, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Solved", attributes: container)
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var caseTags: [String] = []
    private var caseUrlImages = [String]()
    
    var titleCaseLabel = METitleCaseLabel()

    private var actionButtonsView = MECaseActionButtons()
    
    lazy var profileImageView = MEProfileImageView(frame: .zero)
    
    private var compositionalCollectionView: UICollectionView!
    
    private var tagsCollectionView: UICollectionView!
    
    private func createCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(170)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            
            if let caseImages = self.viewModel?.caseImagesCount {
                if caseImages > 1 {
                    let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(15)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)

                    section.boundarySupplementaryItems = [footer]
                    
                    section.visibleItemsInvalidationHandler = { [weak self] (item, offset, env) -> Void in
                        guard let self = self else { return }
                        let page = round(offset.x / self.bounds.width)
                        // Send the page of the visible image to the PagingInfoSubject
                        self.pagingInfoSubject.send(PagingInfo(currentPage: Int(page)))
                    }
                    return section
                }
            }
            return section
        }
        return layout
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.quaternarySystemFill.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTap)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        backgroundColor = .systemBackground
        
        actionButtonsView.delegate = self
        
        compositionalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCellLayout())
        compositionalCollectionView.register(CaseImageCell.self, forCellWithReuseIdentifier: imageCellReuseIdentifier)
        compositionalCollectionView.register(PagingSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: pagingSectionFooterViewReuseIdentifier)
        
        compositionalCollectionView.dataSource = self
        compositionalCollectionView.delegate = self
        compositionalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        compositionalCollectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        compositionalCollectionView.layer.cornerRadius = 10
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
       
        cellContentView.addSubviews(compositionalCollectionView, titleCaseLabel, profileImageView, actionButtonsView, caseStateButton)
       
        NSLayoutConstraint.activate([
         
            compositionalCollectionView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            compositionalCollectionView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            compositionalCollectionView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            compositionalCollectionView.heightAnchor.constraint(equalToConstant: 190),
            
            titleCaseLabel.topAnchor.constraint(equalTo: compositionalCollectionView.bottomAnchor),
            titleCaseLabel.leadingAnchor.constraint(equalTo: compositionalCollectionView.leadingAnchor, constant: 10),
            titleCaseLabel.trailingAnchor.constraint(equalTo: compositionalCollectionView.trailingAnchor, constant: -10),
            
            actionButtonsView.heightAnchor.constraint(equalToConstant: 40),
            actionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            
            profileImageView.bottomAnchor.constraint(equalTo: actionButtonsView.topAnchor, constant: -10),
            profileImageView.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            
            caseStateButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            caseStateButton.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 30 / 2
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        caseStateButton.configuration?.attributedTitle = viewModel.caseStage
        caseStateButton.configuration?.baseBackgroundColor = viewModel.caseStageBackgroundColor
        caseStateButton.configuration?.baseForegroundColor = viewModel.caseStageTextColor
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage?.withTintColor(viewModel.likeButtonTintColor)
        //actionButtonsView.likeButton.configuration?.baseForegroundColor = viewModel.likeButtonTintColor
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage?.withTintColor(.label)
        
        titleCaseLabel.text = viewModel.caseTitle
        titleCaseLabel.numberOfLines = 4
        titleCaseLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        caseUrlImages = viewModel.caseImages
        compositionalCollectionView.reloadData()
        
        if viewModel.caseIsAnonymous {
            print(viewModel.clinicalCase.caseTitle + "is  " + String(viewModel.caseIsAnonymous))
            profileImageView.image = UIImage(named: "user.profile.privacy")
        } else {
            print(viewModel.clinicalCase.caseTitle + "is  " + String(viewModel.caseIsAnonymous))
            profileImageView.image = UIImage(named: "user.profile")
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 layer.borderColor = UIColor.quaternarySystemFill.cgColor
             }
         }
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        
        if let imageUrl = user.profileImageUrl, imageUrl != "", !viewModel.caseIsAnonymous {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
        
        /*
         if viewModel.caseIsAnonymous {
         print(viewModel.clinicalCase.caseTitle + "is" + String(viewModel.caseIsAnonymous))
         profileImageView.image = UIImage(named: "user.profile.privacy")
         } else {
         */
        //}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapClinicalCase() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.clinicalCase(self, wantsToSeeCase: viewModel.clinicalCase, withAuthor: user)
    }
    
    @objc func handleProfileTap() {
        guard let user = user, let viewModel = viewModel, !viewModel.caseIsAnonymous else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
}

extension CasesFeedCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return caseUrlImages.isEmpty ? 1 : caseUrlImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseIdentifier, for: indexPath) as! CaseImageCell
        cell.delegate = self
        if !caseUrlImages.isEmpty { cell.caseImageView.sd_setImage(with: URL(string: caseUrlImages[indexPath.row])) } else {
            cell.caseImageView.image = UIImage(named: "case.image.empty")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: pagingSectionFooterViewReuseIdentifier, for: indexPath) as! PagingSectionFooterView
        let itemCount = caseUrlImages.count
        footer.configure(with: itemCount)
        footer.subscribeTo(subject: pagingInfoSubject)
        return footer
    }
}


extension CasesFeedCell: MEPostActionButtonsDelegate {
    func handleLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, didLike: viewModel.clinicalCase)
    }
    
    func handleComments() {
        return
    }
    
    func handleBookmark() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, didBookmark: viewModel.clinicalCase)
    }
    
    func handleShowLikes() {
        return
    }
}

extension CasesFeedCell: CaseImageCellDelegate {
    func didTapImage(_ imageView: UIImageView) {
        guard let viewModel = viewModel, viewModel.caseType == 1 else { return }
        delegate?.clinicalCase(self, didTapImage: [imageView] , index: 0)
    }
}

