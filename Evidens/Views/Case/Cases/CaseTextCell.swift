//
//  CaseTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

private let caseStageCellReuseIdentifier = "CaseStageCellReuseIdentifier"

class CaseTextCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet { configure() }
    }
    
    private var user: User?
    
    weak var delegate: CaseCellDelegate?
    
    private let cellContentView = UIView()

    private var heightCaseUpdatesConstraint: NSLayoutConstraint!
   
    private let caseInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var userPostView = PrimaryUserView()
    var titleCaseLabel = TitleCaseLabel()
    var descriptionTextView = SecondaryTextView()
    private var revisionView = CaseRevisionView()
    var actionButtonsView = PrimaryActionButton()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        backgroundColor = .systemBackground
        
        actionButtonsView.delegate = self
        userPostView.delegate = self
        revisionView.delegate = self
    
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
       
        cellContentView.addSubviews(userPostView, caseInfoLabel,  titleCaseLabel, descriptionTextView, revisionView, actionButtonsView)
       
        heightCaseUpdatesConstraint = revisionView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            caseInfoLabel.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            caseInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            caseInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            titleCaseLabel.topAnchor.constraint(equalTo: caseInfoLabel.bottomAnchor, constant: 10),
            titleCaseLabel.leadingAnchor.constraint(equalTo: userPostView.leadingAnchor, constant: 10),
            titleCaseLabel.trailingAnchor.constraint(equalTo: userPostView.trailingAnchor, constant: -10),
          
            descriptionTextView.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            heightCaseUpdatesConstraint,
            revisionView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 10),
            revisionView.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            revisionView.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            actionButtonsView.topAnchor.constraint(equalTo: revisionView.bottomAnchor),
            actionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        userPostView.postTimeLabel.text = viewModel.timestamp + AppStrings.Characters.dot
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotsImageButton.menu = addMenuItems()
        caseInfoLabel.text = viewModel.summary.joined(separator: AppStrings.Characters.dot)
        descriptionTextView.attributedText = NSMutableAttributedString(string: viewModel.content.appending(" "), attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        _ = descriptionTextView.hashtags()
        descriptionTextView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        descriptionTextView.addGestureRecognizer(gestureRecognizer)

        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsText
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage?.withTintColor(viewModel.likeColor)
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage?.withTintColor(.secondaryLabel)
        
        titleCaseLabel.text = viewModel.title
        
        revisionView.revision = viewModel.revision

        switch viewModel.revision {
        case .clear:
            heightCaseUpdatesConstraint.constant = 0
            revisionView.isHidden = true
        case .update, .diagnosis:
            revisionView.isHidden = false
            heightCaseUpdatesConstraint.constant = 20
        }
        
        if viewModel.anonymous {
            revisionView.profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        }
        
        layoutIfNeeded()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        if uid == viewModel.clinicalCase.uid {
            // Owner
            if viewModel.clinicalCase.phase == .solved {
                let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                    UIAction(title: CaseMenu.delete.title, image: CaseMenu.delete.image, handler: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.delegate?.clinicalCase(strongSelf, didTapMenuOptionsFor: viewModel.clinicalCase, option: .delete)
                    }),
                ])
                userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
                return menuItems
            } else {
                let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                    UIAction(title: CaseMenu.delete.title, image: CaseMenu.delete.image, handler: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.delegate?.clinicalCase(strongSelf, didTapMenuOptionsFor: viewModel.clinicalCase, option: .delete)
                    }),
                    UIAction(title: CaseMenu.revision.title, image: CaseMenu.revision.image, handler: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.delegate?.clinicalCase(strongSelf, didTapMenuOptionsFor: viewModel.clinicalCase, option: .revision)
                    }),
                    UIAction(title: CaseMenu.solve.title, image: CaseMenu.solve.image, handler: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.delegate?.clinicalCase(strongSelf, didTapMenuOptionsFor: viewModel.clinicalCase, option: .solve)
                    })
                ])
                userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
                return menuItems
            }
        } else {
            //  Not owner
            let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                UIAction(title: CaseMenu.report.title, image: CaseMenu.report.image, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.clinicalCase(strongSelf, didTapMenuOptionsFor: viewModel.clinicalCase, option: .report)
                })
            ])
            userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
            return menuItems
        }
    }
    
    
    func set(user: User) {
        self.user = user
        userPostView.set(user: user)
        if let imageUrl = user.profileUrl, imageUrl != "" {
            revisionView.profileImageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            revisionView.profileImageView.image = UIImage(named: AppStrings.Assets.profile)
        }
    }
        
    func anonymize() {
        userPostView.anonymize()
    }
    
    @objc func didTapClinicalCase() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, wantsToSeeCase: viewModel.clinicalCase, withAuthor: user)
    }
    
    @objc func handleTextViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: descriptionTextView)
        let position = descriptionTextView.closestPosition(to: location)!

        if let range = descriptionTextView.tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: .layout(.left)) {
            let startIndex = descriptionTextView.offset(from: descriptionTextView.beginningOfDocument, to: range.start)
            let endIndex = descriptionTextView.offset(from: descriptionTextView.beginningOfDocument, to: range.end)

            let attributes = descriptionTextView.attributedText.attributes(at: startIndex, effectiveRange: nil)
            
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

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 40))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

extension CaseTextCell: PrimaryUserViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, !viewModel.anonymous else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
    
    func didTapThreeDots() { return }
}

extension CaseTextCell: PrimaryActionButtonDelegate {
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


extension CaseTextCell: CaseRevisionViewDelegate {
    func didTapRevisions() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, wantsToSeeUpdatesForCase: viewModel.clinicalCase)
    }
}

extension CaseTextCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension CaseTextCell: CaseCellProtocol { }




