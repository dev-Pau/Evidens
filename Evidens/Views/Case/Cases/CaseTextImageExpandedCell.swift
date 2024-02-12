//
//  CaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

private let imageCellReuseIdentifier = "ImageCellReuseIdentifier"
private let caseTagCellReuseIdentifier = "CaseTagCellReuseIdentifier"

class CaseTextImageExpandedCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    private var buttonTopConstraint: NSLayoutConstraint!
    private var trailingTitleConstraint: NSLayoutConstraint!

    private var user: User?
    weak var delegate: CaseCellDelegate?

    private var userPostView = PrimaryUserView()
    var titleTextView = ExtendedTitleTextView()
    var contentTextView = ExtendedTextView()
    private var revisionView = ContentRevisionView()
    var actionButtonsView = PrimaryActionButton()
    private var contentTimestamp = ContentTimestampView()
    private var separator: UIView!
    
    private var caseCollectionView: UICollectionView!
    private var tagCollectionView: UICollectionView!
    
    private func createCaseLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self, let viewModel = strongSelf.viewModel else { return nil }

            let height = strongSelf.frame.width - 45
            let width = viewModel.images.count == 1 ? strongSelf.frame.width - 20 : strongSelf.frame.width - 45
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .absolute(height)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .absolute(height)), subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 5
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: viewModel.images.count == 1 ? 10 : 35)

            return section
        }
        
        return layout
    }
    
    private func createTagLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .estimated(250), heightDimension: .estimated(40))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        backgroundColor = .systemBackground
        
        actionButtonsView.delegate = self
        userPostView.delegate = self
        revisionView.delegate = self
        
        caseCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCaseLayout())
        caseCollectionView.register(CaseImageCell.self, forCellWithReuseIdentifier: imageCellReuseIdentifier)
        caseCollectionView.backgroundColor = .systemBackground
        caseCollectionView.dataSource = self
        caseCollectionView.delegate = self
        caseCollectionView.translatesAutoresizingMaskIntoConstraints = false
        caseCollectionView.alwaysBounceVertical = false
        
        tagCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createTagLayout())
        tagCollectionView.register(CaseTagExpandedCell.self, forCellWithReuseIdentifier: caseTagCellReuseIdentifier)
        tagCollectionView.backgroundColor = .systemBackground
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagCollectionView.bounces = true
        tagCollectionView.alwaysBounceHorizontal = true
        tagCollectionView.alwaysBounceVertical = false
        
        separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = separatorColor
        
        let insets = UIFont.addFont(size: 13.5, scaleStyle: .largeTitle, weight: .semibold).lineHeight

        let collectionViewHeightConstraint = tagCollectionView.heightAnchor.constraint(equalToConstant: insets * 2 + 5)
        collectionViewHeightConstraint.priority = .defaultLow

        addSubviews(userPostView, tagCollectionView, titleTextView, contentTextView, revisionView, caseCollectionView, contentTimestamp, actionButtonsView, separator)
        
        buttonTopConstraint = actionButtonsView.topAnchor.constraint(equalTo: revisionView.bottomAnchor)
        
        trailingTitleConstraint = titleTextView.trailingAnchor.constraint(equalTo: caseCollectionView.trailingAnchor, constant: -35)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 50),
            
            contentTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 15),
            contentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            caseCollectionView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            caseCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            caseCollectionView.heightAnchor.constraint(equalToConstant: frame.width - 45),
            
            titleTextView.topAnchor.constraint(equalTo: caseCollectionView.bottomAnchor, constant: -10),
            titleTextView.leadingAnchor.constraint(equalTo: caseCollectionView.leadingAnchor, constant: 10),
            trailingTitleConstraint,
            
            tagCollectionView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 10),
            tagCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionViewHeightConstraint,
            
            contentTimestamp.topAnchor.constraint(equalTo: tagCollectionView.bottomAnchor),
            contentTimestamp.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentTimestamp.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            revisionView.topAnchor.constraint(equalTo: contentTimestamp.bottomAnchor),
            revisionView.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            revisionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
           
            buttonTopConstraint,
            actionButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            actionButtonsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        titleTextView.layer.cornerRadius = 12
        titleTextView.layer.borderWidth = 0.4
        titleTextView.textContainerInset = UIEdgeInsets(top: 15, left: 5, bottom: 8, right: 5)
        titleTextView.layer.borderColor = separatorColor.cgColor
        titleTextView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        guard let viewModel = viewModel, let contentFont = contentTextView.font, let titleFont = titleTextView.font else { return }
        
        userPostView.dotButton.menu = addMenuItems()
        userPostView.timestampLabel.text = viewModel.timestamp
        
        contentTextView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        contentTextView.addGestureRecognizer(gestureRecognizer)

        revisionView.revision = viewModel.revision

        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsText
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage?.withTintColor(viewModel.likeColor)
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        
        contentTimestamp.set(timestamp: viewModel.detailedCase)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let title = NSMutableAttributedString(string: viewModel.title, attributes: [.font: titleFont, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        
        titleTextView.attributedText = title

        contentTextView.attributedText = NSMutableAttributedString(string: viewModel.content.appending(" "), attributes: [.font: contentFont, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        
        switch viewModel.revision {
        case .clear:
            buttonTopConstraint.constant = -20
            revisionView.isHidden = true
        case .update, .diagnosis:
            buttonTopConstraint.constant = 0
            revisionView.isHidden = false
        }
        
        trailingTitleConstraint.constant = viewModel.images.count == 1 ? -10 : -35
        _ = contentTextView.hashtags()

        tagCollectionView.reloadData()
        
        //layoutIfNeeded()
    }
    
    func set(user: User) {
        self.user = user
        userPostView.set(user: user)
    }
    
    func anonymize() {
        userPostView.anonymize()
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let delegate = delegate else { return nil }
        if let menu = UIMenu.createCaseMenu(for: viewModel, delegate: delegate) {
            userPostView.dotButton.showsMenuAsPrimaryAction = true
            return menu
        }
        return nil
    }
    
    @objc func didTapClinicalCase() {
        
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, wantsToSeeCase: viewModel.clinicalCase, withAuthor: user)
    }
    
    @objc func handleTextViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: contentTextView)
        let position = contentTextView.closestPosition(to: location)!

        if let range = contentTextView.tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: .layout(.left)) {
            let startIndex = contentTextView.offset(from: contentTextView.beginningOfDocument, to: range.start)
            let _ = contentTextView.offset(from: contentTextView.beginningOfDocument, to: range.end)

            let attributes = contentTextView.attributedText.attributes(at: startIndex, effectiveRange: nil)
            
            if attributes.keys.contains(.link), let hashtag = attributes[.link] as? String {
                delegate?.clinicalCase(wantsToSeeHashtag: hashtag)
            } else {
                didTapClinicalCase()
            }
        }
    }
}

extension CaseTextImageExpandedCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == caseCollectionView {
            return viewModel?.images.count ?? 0
        } else {
            return viewModel?.summary.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { fatalError() }
        if collectionView == caseCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseIdentifier, for: indexPath) as! CaseImageCell
            cell.delegate = self
            cell.caseImageView.sd_setImage(with: URL(string: viewModel.images[indexPath.row]))
            
            if viewModel.images.count == 1 {
                cell.set(maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
            } else {
                if indexPath.row == 0 {
                    cell.set(maskedCorners: [.layerMinXMinYCorner])
                } else if indexPath.row == viewModel.images.count - 1 {
                    cell.set(maskedCorners: [.layerMaxXMinYCorner])
                } else {
                    cell.set(maskedCorners: [])
                }
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTagCellReuseIdentifier, for: indexPath) as! CaseTagExpandedCell
            cell.set(tag: viewModel.summary[indexPath.row])
            return cell
        }
        
    }
}

extension CaseTextImageExpandedCell: PrimaryUserViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, !viewModel.anonymous, user.phase == .verified else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
}

extension CaseTextImageExpandedCell: PrimaryActionButtonDelegate {
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

extension CaseTextImageExpandedCell: ContentRevisionViewDelegate {
    func didTapRevisions() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, wantsToSeeUpdatesForCase: viewModel.clinicalCase)
    }
}

extension CaseTextImageExpandedCell: CaseImageCellDelegate {
    func didTapImage(_ imageView: UIImageView) {
        guard let _ = imageView.image else { return }
        delegate?.clinicalCase(self, didTapImage: [imageView] , index: 0)
    }
}

extension CaseTextImageExpandedCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension CaseTextImageExpandedCell: CaseCellProtocol { }
