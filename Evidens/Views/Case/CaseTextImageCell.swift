//
//  CaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit
import Combine
import SwiftUI

private let caseStageCellReuseIdentifier = "CaseStageCellReuseIdentifier"
private let specialitiesCellReuseIdentifier = "SpecialitiesCellReuseIdentifier"
private let imageCellReuseIdentifier = "ImageCellReuseIdentifier"
private let pagingSectionFooterViewReuseIdentifier = "PagingSectionFooterViewReuseIdentifier"

struct PagingInfo: Equatable, Hashable {
    let currentPage: Int
}

class CaseTextImageCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    private var user: User?
    
    
    weak var reviewDelegate: ReviewContentGroupDelegate?
    
    weak var delegate: CaseCellDelegate?
    
    private let cellContentView = UIView()
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    private lazy var caseStateButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.configuration?.imagePadding = 5
        button.tintAdjustmentMode = .normal
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    private let viewsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var caseTags: [String] = []
    private var stringUrlImages: [String] = []
    
    private var userPostView = MEUserPostView()
    var titleCaseLabel = METitleCaseLabel()
    var descriptionCaseLabel = MEPostLabel()
    private var updateView = MECaseUpdateView()
    private var actionButtonsView = MEPostActionButtons()
    private lazy var reviewActionButtonsView = MEReviewActionButtons()
    
    private var compositionalCollectionView: UICollectionView!
    
    private func createCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(400)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(20)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)

                section.boundarySupplementaryItems = [footer]
                
                section.visibleItemsInvalidationHandler = { [weak self] (item, offset, env) -> Void in
                    guard let self = self else { return }
                    let page = round(offset.x / UIScreen.main.bounds.width)
                    // Send the page of the visible image to the PagingInfoSubject
                    self.pagingInfoSubject.send(PagingInfo(currentPage: Int(page)))
                }
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
                return section
                
            }
        }
        return layout
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        
        backgroundColor = .systemBackground
        
        actionButtonsView.delegate = self
        userPostView.delegate = self
        reviewActionButtonsView.delegate = self
        updateView.delegate = self
    
        compositionalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCellLayout())
        compositionalCollectionView.register(CaseImageCell.self, forCellWithReuseIdentifier: imageCellReuseIdentifier)
        compositionalCollectionView.register(PagingSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: pagingSectionFooterViewReuseIdentifier)
        compositionalCollectionView.register(CaseTagCell.self, forCellWithReuseIdentifier: caseStageCellReuseIdentifier)
        compositionalCollectionView.dataSource = self
        compositionalCollectionView.delegate = self
        compositionalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
       
        cellContentView.addSubviews(caseStateButton, viewsLabel, separatorView, userPostView, compositionalCollectionView, titleCaseLabel, descriptionCaseLabel, updateView, actionButtonsView)
       
        NSLayoutConstraint.activate([
            caseStateButton.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            caseStateButton.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            
            viewsLabel.centerYAnchor.constraint(equalTo: caseStateButton.centerYAnchor),
            viewsLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            separatorView.leadingAnchor.constraint(equalTo: caseStateButton.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            separatorView.topAnchor.constraint(equalTo: caseStateButton.bottomAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            userPostView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 5),
            userPostView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            compositionalCollectionView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 10),
            compositionalCollectionView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            compositionalCollectionView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            compositionalCollectionView.heightAnchor.constraint(equalToConstant: 460),
            
            titleCaseLabel.topAnchor.constraint(equalTo: compositionalCollectionView.bottomAnchor, constant: 10),
            titleCaseLabel.leadingAnchor.constraint(equalTo: userPostView.leadingAnchor, constant: 10),
            titleCaseLabel.trailingAnchor.constraint(equalTo: userPostView.trailingAnchor, constant: -10),
            
            descriptionCaseLabel.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 10),
            descriptionCaseLabel.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            descriptionCaseLabel.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            updateView.topAnchor.constraint(equalTo: descriptionCaseLabel.bottomAnchor, constant: 10),
            updateView.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            updateView.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            updateView.heightAnchor.constraint(equalToConstant: 20),
            
            actionButtonsView.topAnchor.constraint(equalTo: updateView.bottomAnchor, constant: 10),
            actionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        caseStateButton.configuration?.image = viewModel.caseImageStage.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysOriginal).withTintColor(viewModel.caseStageTextColor)
        caseStateButton.configuration?.attributedTitle = viewModel.caseStage
        caseStateButton.configuration?.baseBackgroundColor = viewModel.caseStageBackgroundColor
        caseStateButton.configuration?.baseForegroundColor = viewModel.caseStageTextColor
        
        userPostView.postTimeLabel.text = viewModel.timestampString! + " · "
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
       
        descriptionCaseLabel.text = viewModel.caseDescription
        
        if viewModel.caseResolvedWithDiagnosis {
            updateView.isHidden = false
            updateView.diagnosisLabel.text = "The author has added a diagnosis"
            updateView.setHeightConstraint(toConstant: 20)
        } else if viewModel.caseHasUpdates {
            updateView.isHidden = false
            updateView.diagnosisLabel.text = "An update has been made by the author"
            updateView.setHeightConstraint(toConstant: 20)
        } else {
            updateView.setHeightConstraint(toConstant: 0)
            updateView.isHidden = true
        }
        
        /*
        if viewModel.caseIsAnonymous {
            updateView.profileImageView.image = UIImage(systemName: "hand.raised.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        } else {
            updateView.profileImageView.sd_setImage(with: URL(string: viewModel.userProfileImageUrl!))
        }
         */
        
        viewsLabel.text = viewModel.viewsText
        
        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsText
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage?.withTintColor(viewModel.likeButtonTintColor)
        //actionButtonsView.likeButton.configuration?.baseForegroundColor = viewModel.likeButtonTintColor
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage?.withTintColor(.label)
        
        titleCaseLabel.text = viewModel.caseTitle
        caseTags = viewModel.caseTags
        
        stringUrlImages = viewModel.caseImages!
        compositionalCollectionView.reloadData()
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        
        //userPostView.usernameLabel.text = user.firstName! + " " + user.lastName!
        
        /*
        if viewModel.caseIsAnonymous {
            #warning("Choose anonymous image")
            userPostView.profileImageView.image = UIImage(systemName: "")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        } else {
            userPostView.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        }
         */
        
        if viewModel.caseIsAnonymous {
            #warning("Add anonymous images")
            updateView.profileImageView.image = UIImage(named: "")
            userPostView.profileImageView.image = UIImage(named: "")
            userPostView.usernameLabel.text = "Shared anonymously"
        } else {
            updateView.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
            userPostView.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
            userPostView.usernameLabel.text = user.firstName! + " " + user.lastName!
        }
        
        userPostView.userInfoCategoryLabel.attributedText = user.getUserAttributedInfo()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithReviewOptions() {
        //private lazy var reviewActionButtonsView = MEReviewActionButtons()
        actionButtonsView.isHidden = true
        userPostView.dotsImageButton.isHidden = true
        addSubviews(reviewActionButtonsView)
        NSLayoutConstraint.activate([
            reviewActionButtonsView.topAnchor.constraint(equalTo: updateView.bottomAnchor, constant: 10),
            reviewActionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            reviewActionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            reviewActionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
       
    }
    
    @objc func didTapClinicalCase() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.clinicalCase(self, wantsToSeeCase: viewModel.clinicalCase, withAuthor: user)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 40))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

extension CaseTextImageCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return stringUrlImages.count
        } else {
            return caseTags.count
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseIdentifier, for: indexPath) as! CaseImageCell
            cell.delegate = self
            cell.caseImageView.sd_setImage(with: URL(string: stringUrlImages[indexPath.row]))
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseStageCellReuseIdentifier, for: indexPath) as! CaseTagCell
            cell.tagsLabel.text = caseTags[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: pagingSectionFooterViewReuseIdentifier, for: indexPath) as! PagingSectionFooterView
        let itemCount = stringUrlImages.count
        footer.configure(with: itemCount)
        footer.subscribeTo(subject: pagingInfoSubject)
        return footer
    }
}

extension CaseTextImageCell: MEUserPostViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, !viewModel.caseIsAnonymous else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
    
    func didTapThreeDots() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, didPressThreeDotsFor: viewModel.clinicalCase)
    }
    
    
}

extension CaseTextImageCell: MEPostActionButtonsDelegate {
    func handleLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, didLike: viewModel.clinicalCase)
    }
    
    func handleComments() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.clinicalCase(wantsToShowCommentsFor: viewModel.clinicalCase, forAuthor: user)
    }
    
    func handleBookmark() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, didBookmark: viewModel.clinicalCase)
    }
    
    func handleShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(wantsToSeeLikesFor: viewModel.clinicalCase)
    }
}

extension CaseTextImageCell: MECaseUpdateViewDelegate {
    func didTapCaseUpdates() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, wantsToSeeUpdatesForCase: viewModel.clinicalCase)
    }
}

extension CaseTextImageCell: CaseImageCellDelegate {
    func didTapImage(_ imageView: UIImageView) {
        delegate?.clinicalCase(self, didTapImage: [imageView] , index: 0)
    }
}


extension CaseTextImageCell: MEReviewActionButtonsDelegate {
    func didTapApprove() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapAcceptContent(contentId: viewModel.clinicalCase.caseId, type: .clinicalCase)
    }
    
    func didTapDelete() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapCancelContent(contentId: viewModel.clinicalCase.caseId, type: .clinicalCase)
    }
}





