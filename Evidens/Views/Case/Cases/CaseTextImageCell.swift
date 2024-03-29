//
//  CaseTextImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/11/23.
//

import UIKit

private let caseImageCellReuseIdentifier = "ImageCellReuseIdentifier"
private let caseTagCellReuseIdentifier = "CaseTagCellReuseIdentifier"

class CaseTextImageCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    private var user: User?
    weak var delegate: CaseCellDelegate?

    private var userPostView = PrimaryUserView()
    var titleTextView = TitleTextView()
    var contentTextView = SecondaryTextView()
    var actionButtonsView = PrimaryActionButton()
    private var separator: UIView!
    private var caseCollectionView: UICollectionView!
    private var tagCollectionView: UICollectionView!
    
    private func createCaseLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self, let _ = strongSelf.viewModel else { return nil }

            let padding: CGFloat = K.Paddings.Content.horizontalPadding + K.Paddings.Content.userImageSize + 10
            
            let width = strongSelf.frame.width - padding - 40
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .absolute(width)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .absolute(width)), subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: 40)
            
            return section
        }
        
        return layout
    }
    
    private func createTagLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .estimated(250), heightDimension: .estimated(40))
        
        let padding: CGFloat = K.Paddings.Content.horizontalPadding + K.Paddings.Content.userImageSize + 10
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: K.Paddings.Content.horizontalPadding)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        backgroundColor = .systemBackground
        
        actionButtonsView.delegate = self
        userPostView.delegate = self

        caseCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCaseLayout())
        caseCollectionView.register(CaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        caseCollectionView.backgroundColor = .systemBackground
        caseCollectionView.dataSource = self
        caseCollectionView.delegate = self
        caseCollectionView.translatesAutoresizingMaskIntoConstraints = false
        caseCollectionView.alwaysBounceVertical = false
        caseCollectionView.isUserInteractionEnabled = true
        
        tagCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createTagLayout())
        tagCollectionView.register(CaseTagCell.self, forCellWithReuseIdentifier: caseTagCellReuseIdentifier)
        tagCollectionView.backgroundColor = .systemBackground
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagCollectionView.bounces = true
        tagCollectionView.alwaysBounceHorizontal = true
        tagCollectionView.alwaysBounceVertical = false
        
        separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = K.Colors.separatorColor
        
        let insets = UIFont.addFont(size: 11.5, scaleStyle: .largeTitle, weight: .semibold).lineHeight

        let textPadding: CGFloat = K.Paddings.Content.horizontalPadding + K.Paddings.Content.userImageSize + 10
        
        let collectionViewHeightConstraint = tagCollectionView.heightAnchor.constraint(equalToConstant: insets * 2 + 5)
        collectionViewHeightConstraint.priority = .defaultLow
        
        addSubviews(userPostView, contentTextView, caseCollectionView, titleTextView, tagCollectionView, actionButtonsView, separator)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            titleTextView.leadingAnchor.constraint(equalTo: userPostView.leadingAnchor, constant: textPadding),
            titleTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),

            caseCollectionView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 10),
            caseCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            caseCollectionView.heightAnchor.constraint(equalToConstant: frame.width - textPadding - 40),

            contentTextView.topAnchor.constraint(equalTo: caseCollectionView.bottomAnchor, constant: -1),
            contentTextView.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: caseCollectionView.trailingAnchor, constant: -40),
            
            tagCollectionView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            tagCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionViewHeightConstraint,
            
            actionButtonsView.topAnchor.constraint(equalTo: tagCollectionView.bottomAnchor),
            actionButtonsView.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        contentTextView.delegate = self
        contentTextView.layer.cornerRadius = 12
        contentTextView.layer.borderWidth = 0.4
        contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 8)
        contentTextView.layer.borderColor = K.Colors.separatorColor.cgColor
        contentTextView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
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
        
        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsText
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage?.withTintColor(viewModel.likeColor)
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        
        contentTextView.attributedText = NSMutableAttributedString(string: viewModel.content.appending(" "), attributes: [.font: contentFont, .foregroundColor: UIColor.label])
        
        titleTextView.attributedText = NSMutableAttributedString(string: viewModel.title.appending(" "), attributes: [.font: titleFont, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        
        _ = contentTextView.hashtags()

        caseCollectionView.reloadData()
        caseCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        
        tagCollectionView.reloadData()
        tagCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
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

extension CaseTextImageCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTagCellReuseIdentifier, for: indexPath) as! CaseTagCell
            cell.set(tag: viewModel.summary[indexPath.row])
            return cell
        }
    }
}

extension CaseTextImageCell: PrimaryUserViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, !viewModel.anonymous, user.phase == .verified else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
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
        guard let _ = imageView.image else { return }
        delegate?.clinicalCase(self, didTapImage: imageView)
    }
}

extension CaseTextImageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension CaseTextImageCell: CaseCellProtocol { }
