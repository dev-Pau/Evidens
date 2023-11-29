//
//  CaseTextImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/11/23.
//

import UIKit

private let caseImageCellReuseIdentifier = "ImageCellReuseIdentifier"

class CaseTextImageCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    private let caseTagsLabel: UILabel = {
        let label = UILabel()
        let customFontSize: CGFloat = 15.0
        let fontMetrics = UIFontMetrics(forTextStyle: .subheadline)
        let scaledFontSize = fontMetrics.scaledValue(for: customFontSize)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
       
        label.font = UIFont(descriptor: fontDescriptor, size: scaledFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var user: User?
    weak var delegate: CaseCellDelegate?

    private var userPostView = PrimaryUserView()
    var titleTextView = TitleTextView()
    var contentTextView = SecondaryTextView()
    var actionButtonsView = PrimaryActionButton()
    private var separator: UIView!
    private var collectionView: UICollectionView!
    
    private func createCaseLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self, let _ = strongSelf.viewModel else { return nil }

            let width = strongSelf.frame.width - 55 - 20
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .absolute(width)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .absolute(width)), subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 55, bottom: 0, trailing: 20)
            
            return section
        }
        
        return layout
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        backgroundColor = .systemBackground
        
        actionButtonsView.delegate = self
        userPostView.delegate = self

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCaseLayout())
        collectionView.register(CaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = false
        
        separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = separatorColor
        
        addSubviews(userPostView, caseTagsLabel, contentTextView, collectionView, titleTextView, actionButtonsView, separator)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 50),
            
            titleTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            titleTextView.leadingAnchor.constraint(equalTo: userPostView.leadingAnchor, constant: 55),
            titleTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            caseTagsLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 5),
            caseTagsLabel.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            caseTagsLabel.trailingAnchor.constraint(equalTo: titleTextView.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: caseTagsLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: frame.width - 75),

            contentTextView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -10),
            contentTextView.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: titleTextView.trailingAnchor, constant: -10),
            
            actionButtonsView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor),
            actionButtonsView.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 40),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        contentTextView.delegate = self
        contentTextView.layer.cornerRadius = 12
        contentTextView.layer.borderWidth = 0.4
        contentTextView.textContainerInset = UIEdgeInsets(top: 15, left: 5, bottom: 8, right: 5)
        contentTextView.layer.borderColor = separatorColor.cgColor
        contentTextView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        userPostView.postTimeLabel.text = viewModel.timestamp + AppStrings.Characters.dot
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotButton.menu = addMenuItems()
        caseTagsLabel.text = viewModel.summary.joined(separator: AppStrings.Characters.dot)
        
        contentTextView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        contentTextView.addGestureRecognizer(gestureRecognizer)
        
        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsText
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage?.withTintColor(viewModel.likeColor)
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        titleTextView.isUserInteractionEnabled = false
        contentTextView.isUserInteractionEnabled = false
        let font: UIFont = .preferredFont(forTextStyle: .subheadline)
        
        contentTextView.attributedText = NSMutableAttributedString(string: viewModel.content.appending(" "), attributes: [.font: font, .foregroundColor: UIColor.label])
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold.rawValue
            ]
        ])
        
        let boldFont = UIFont(descriptor: heavyFontDescriptor, size: 0)
        
        titleTextView.attributedText = NSMutableAttributedString(string: viewModel.title.appending(" "), attributes: [.font: boldFont, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        
        _ = contentTextView.hashtags()

        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
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
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

extension CaseTextImageCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { fatalError() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! CaseImageCell
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
    }
}

extension CaseTextImageCell: PrimaryUserViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, !viewModel.anonymous else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }

    func didTapThreeDots() { return }
}

extension CaseTextImageCell: PrimaryActionButtonDelegate {
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

extension CaseTextImageCell: CaseImageCellDelegate {
    func didTapImage(_ imageView: UIImageView) {
        delegate?.clinicalCase(self, didTapImage: [imageView] , index: 0)
    }
}

extension CaseTextImageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension CaseTextImageCell: CaseCellProtocol { }
