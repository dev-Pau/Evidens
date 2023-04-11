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
    
    weak var reviewDelegate: ReviewContentGroupDelegate?
    
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
    
    private var userPostView = MEUserPostView()
    var titleCaseLabel = METitleCaseLabel()
    var descriptionCaseLabel = MEPostLabel()
    private var updateView = MECaseUpdateView()
    var actionButtonsView = MEPostActionButtons()
    private lazy var reviewActionButtonsView = MEReviewActionButtons()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClinicalCase)))
        reviewActionButtonsView.delegate = self
        backgroundColor = .systemBackground
        
        actionButtonsView.delegate = self
        userPostView.delegate = self
        updateView.delegate = self
    
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
       
        cellContentView.addSubviews(userPostView, caseInfoLabel,  titleCaseLabel, descriptionCaseLabel, updateView, actionButtonsView)
       
        heightCaseUpdatesConstraint = updateView.heightAnchor.constraint(equalToConstant: 0)
        heightCaseUpdatesConstraint.isActive = true
        
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
          
            descriptionCaseLabel.topAnchor.constraint(equalTo: titleCaseLabel.bottomAnchor, constant: 10),
            descriptionCaseLabel.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            descriptionCaseLabel.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            updateView.topAnchor.constraint(equalTo: descriptionCaseLabel.bottomAnchor, constant: 10),
            updateView.leadingAnchor.constraint(equalTo: titleCaseLabel.leadingAnchor),
            updateView.trailingAnchor.constraint(equalTo: titleCaseLabel.trailingAnchor),
            
            actionButtonsView.topAnchor.constraint(equalTo: updateView.bottomAnchor, constant: 10),
            actionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        userPostView.postTimeLabel.text = viewModel.timestampString! + " • "
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotsImageButton.menu = addMenuItems()
        caseInfoLabel.text = viewModel.caseSummaryInfoString.joined(separator: " • ")
        descriptionCaseLabel.text = viewModel.caseDescription
        
        if viewModel.caseResolvedWithDiagnosis {
            updateView.layoutIfNeeded()
            updateView.isHidden = false
            updateView.diagnosisLabel.text = "The author has added a diagnosis"
            heightCaseUpdatesConstraint.constant = 20
            heightCaseUpdatesConstraint.isActive = true
            //updateView.setHeightConstraint(toConstant: 20)
        } else if viewModel.caseHasUpdates {
            updateView.layoutIfNeeded()
            updateView.isHidden = false
            updateView.diagnosisLabel.text = "An update has been made by the author"
            heightCaseUpdatesConstraint.constant = 20
            heightCaseUpdatesConstraint.isActive = true
        } else {
            updateView.layoutIfNeeded()
            heightCaseUpdatesConstraint.constant = 0
            heightCaseUpdatesConstraint.isActive = true
            updateView.isHidden = true
        }
        
        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsText
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage?.withTintColor(viewModel.likeButtonTintColor)
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage?.withTintColor(.label)
        
        titleCaseLabel.text = viewModel.caseTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        if uid == viewModel.clinicalCase.ownerUid {
            // Owner
            if viewModel.clinicalCase.stage == .resolved {
                let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                    UIAction(title: Case.CaseMenuOptions.delete.rawValue, image: Case.CaseMenuOptions.delete.menuOptionsImage, handler: { (_) in
                        self.delegate?.clinicalCase(self, didTapMenuOptionsFor: viewModel.clinicalCase, option: .delete)
                    }),
                    UIAction(title: Case.CaseMenuOptions.edit.rawValue, image: Case.CaseMenuOptions.edit.menuOptionsImage, handler: { (_) in
                        self.delegate?.clinicalCase(self, didTapMenuOptionsFor: viewModel.clinicalCase, option: .edit)
                    })
                   
                ])
                userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
                return menuItems
            } else {
                let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                    UIAction(title: Case.CaseMenuOptions.delete.rawValue, image: Case.CaseMenuOptions.delete.menuOptionsImage, handler: { (_) in
                        self.delegate?.clinicalCase(self, didTapMenuOptionsFor: viewModel.clinicalCase, option: .delete)
                    }),
                    UIAction(title: Case.CaseMenuOptions.update.rawValue, image: Case.CaseMenuOptions.update.menuOptionsImage, handler: { (_) in
                        self.delegate?.clinicalCase(self, didTapMenuOptionsFor: viewModel.clinicalCase, option: .update)
                    }),
                    UIAction(title: Case.CaseMenuOptions.solved.rawValue, image: Case.CaseMenuOptions.solved.menuOptionsImage, handler: { (_) in
                        self.delegate?.clinicalCase(self, didTapMenuOptionsFor: viewModel.clinicalCase, option: .solved)
                    })
                ])
                userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
                return menuItems
            }
        } else {
            //  Not owner
            let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                UIAction(title: Case.CaseMenuOptions.report.rawValue, image: Case.CaseMenuOptions.report.menuOptionsImage, handler: { (_) in
                    self.delegate?.clinicalCase(self, didTapMenuOptionsFor: viewModel.clinicalCase, option: .report)
                })
            ])
            userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
            return menuItems
        }
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user

        if viewModel.caseIsAnonymous {
            updateView.profileImageView.image = UIImage(named: "user.profile.privacy")
            userPostView.profileImageView.image = UIImage(named: "user.profile.privacy")
            userPostView.usernameLabel.text = "Shared anonymously"
        } else {
            if let imageUrl = user.profileImageUrl, imageUrl != "" {
                updateView.profileImageView.sd_setImage(with: URL(string: imageUrl))
                userPostView.profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
            
            userPostView.usernameLabel.text = user.firstName! + " " + user.lastName!
        }
       
        userPostView.userInfoCategoryLabel.attributedText = user.getUserAttributedInfo()
    }
    
    func configureWithReviewOptions() {
        //private lazy var reviewActionButtonsView = MEReviewActionButtons()
        actionButtonsView.isHidden = true
        userPostView.dotsImageButton.isHidden = true
        addSubviews(reviewActionButtonsView)
        NSLayoutConstraint.activate([
            reviewActionButtonsView.topAnchor.constraint(equalTo: descriptionCaseLabel.bottomAnchor, constant: 10),
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

extension CaseTextCell: MEUserPostViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, !viewModel.caseIsAnonymous else { return }
        delegate?.clinicalCase(self, wantsToShowProfileFor: user)
    }
    
    func didTapThreeDots() { return }
}

extension CaseTextCell: MEPostActionButtonsDelegate {
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


extension CaseTextCell: MECaseUpdateViewDelegate {
    func didTapCaseUpdates() {
        guard let viewModel = viewModel else { return }
        delegate?.clinicalCase(self, wantsToSeeUpdatesForCase: viewModel.clinicalCase)
    }
}


extension CaseTextCell: MEReviewActionButtonsDelegate {
    func didTapApprove() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapAcceptContent(contentId: viewModel.clinicalCase.caseId, type: .clinicalCase)
    }
    
    func didTapDelete() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapCancelContent(contentId: viewModel.clinicalCase.caseId, type: .clinicalCase)
    }
}



