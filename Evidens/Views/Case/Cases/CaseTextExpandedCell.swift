//
//  CaseTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

private let caseTagCellReuseIdentifier = "CaseTagCellReuseIdentifier"

class CaseTextExpandedCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    private var user: User?
    
    weak var delegate: CaseCellDelegate?
    
    private var heightCaseUpdatesConstraint: NSLayoutConstraint!
   
    private var collectionView: UICollectionView!
    private var userPostView = PrimaryUserView()
    var titleTextView = ExtendedTitleTextView()
    var contentTextView = ExtendedTextView()
    private var revisionView = ContentRevisionView()
    var actionButtonsView = PrimaryActionButton()
    private var contentTimestamp = ContentTimestampView()
    private var separator: UIView!
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        backgroundColor = .systemBackground
        
        actionButtonsView.delegate = self
        userPostView.delegate = self
        revisionView.delegate = self
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        
        collectionView.register(CaseTagExpandedCell.self, forCellWithReuseIdentifier: caseTagCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = separatorColor
        
        addSubviews(userPostView,  titleTextView, contentTextView, revisionView, collectionView, actionButtonsView, contentTimestamp, separator)
       
        heightCaseUpdatesConstraint = revisionView.heightAnchor.constraint(equalToConstant: 0)
        
        let insets = UIFont.addFont(size: 13.5, scaleStyle: .largeTitle, weight: .semibold).lineHeight / 2

        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 7),
            titleTextView.leadingAnchor.constraint(equalTo: userPostView.leadingAnchor, constant: 10),
            titleTextView.trailingAnchor.constraint(equalTo: userPostView.trailingAnchor, constant: -10),
          
            contentTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 5),
            contentTextView.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: titleTextView.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: UIFont.addFont(size: 13.5, scaleStyle: .largeTitle, weight: .semibold).lineHeight + insets * 2 + 5),
            
            contentTimestamp.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            contentTimestamp.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentTimestamp.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentTimestamp.heightAnchor.constraint(equalToConstant: 40),

            heightCaseUpdatesConstraint,
            revisionView.topAnchor.constraint(equalTo: contentTimestamp.bottomAnchor),
            revisionView.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            revisionView.trailingAnchor.constraint(equalTo: titleTextView.trailingAnchor),
            revisionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -41),
            
            actionButtonsView.topAnchor.constraint(equalTo: revisionView.bottomAnchor),
            actionButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            actionButtonsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 40),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .estimated(250), heightDimension: .estimated(40))
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configure() {
        guard let viewModel = viewModel, let contentFont = contentTextView.font, let titleFont = titleTextView.font else { return }
        
        userPostView.dotButton.menu = addMenuItems()

        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsText
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage?.withTintColor(viewModel.likeColor)
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        contentTimestamp.set(timestamp: viewModel.detailedCase)
        
        titleTextView.attributedText = NSMutableAttributedString(string: viewModel.title.appending(" "), attributes: [.font: titleFont, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        
        revisionView.revision = viewModel.revision
        
        switch viewModel.revision {
        case .clear:
            heightCaseUpdatesConstraint.constant = 0
            revisionView.isHidden = true
        case .update, .diagnosis:
            revisionView.isHidden = false
            heightCaseUpdatesConstraint.constant = 40
        }

        contentTextView.attributedText = NSMutableAttributedString(string: viewModel.content.appending(" "), attributes: [.font: contentFont, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])

        _ = contentTextView.hashtags()
        contentTextView.delegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        contentTextView.addGestureRecognizer(gestureRecognizer)
        
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let delegate = delegate else { return nil }
        if let menu = UIMenu.createCaseMenu(self, for: viewModel, delegate: delegate) {
            userPostView.dotButton.showsMenuAsPrimaryAction = true
            return menu
        }
        return nil
    }
    
    func set(user: User) {
        self.user = user
        userPostView.set(user: user)
    }
        
    func anonymize() {
        userPostView.anonymize()
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
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

extension CaseTextExpandedCell: PrimaryUserViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, !viewModel.anonymous else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
    
    func didTapThreeDots() { return }
}

extension CaseTextExpandedCell: PrimaryActionButtonDelegate {
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


extension CaseTextExpandedCell: ContentRevisionViewDelegate {
    func didTapRevisions() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, wantsToSeeUpdatesForCase: viewModel.clinicalCase)
    }
}

extension CaseTextExpandedCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension CaseTextExpandedCell: CaseCellProtocol { }

extension CaseTextExpandedCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { fatalError() }
        return viewModel.summary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { fatalError() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTagCellReuseIdentifier, for: indexPath) as! CaseTagExpandedCell
        cell.set(tag: viewModel.summary[indexPath.row])
        return cell
    }
}





