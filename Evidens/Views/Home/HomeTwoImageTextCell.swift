//
//  HomeTwoImageTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/6/22.
//

import UIKit

class HomeTwoImageTextCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private var user: User?
    weak var reviewDelegate: ReviewContentGroupDelegate?
    weak var delegate: HomeCellDelegate?
    private let cellContentView = UIView()
    private var userPostView = MEUserPostView()
    var postTextView = MEPostTextView()
    private let postReferenceView = MEReferenceView()
    private var referenceHeightAnchor: NSLayoutConstraint!
    let showMoreView = MEShowMoreView()
    var actionButtonsView = MEPostActionButtons()
    private lazy var reviewActionButtonsView = MEReviewActionButtons()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .quaternarySystemFill
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap(gesture:))))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var postTwoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .quaternarySystemFill
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap(gesture:))))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
        backgroundColor = .systemBackground
        
        userPostView.delegate = self
        postReferenceView.delegate = self
        actionButtonsView.delegate = self
        reviewActionButtonsView.delegate = self
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(userPostView, postTextView, postReferenceView, postImageView, postTwoImageView, actionButtonsView)
        
        let postImageViewHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 350)
        postImageViewHeightConstraint.priority = UILayoutPriority(999)
        
        referenceHeightAnchor = postReferenceView.heightAnchor.constraint(equalToConstant: 0)
        referenceHeightAnchor.isActive = true
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            postTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 10),
            postTextView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            postReferenceView.topAnchor.constraint(equalTo: postTextView.bottomAnchor),
            postReferenceView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            postReferenceView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            postImageView.topAnchor.constraint(equalTo: postReferenceView.bottomAnchor),
            postImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            //postImageView.heightAnchor.constraint(equalToConstant: 350),
            postImageViewHeightConstraint,
            postImageView.widthAnchor.constraint(equalToConstant: frame.width / 2 - 4),
            
            postTwoImageView.topAnchor.constraint(equalTo: postReferenceView.bottomAnchor),
            postTwoImageView.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 2),
            postTwoImageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            postTwoImageView.bottomAnchor.constraint(equalTo: postImageView.bottomAnchor),
            
            actionButtonsView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            actionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 40))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func hideSeparatorView() {
        actionButtonsView.separatorView.isHidden = true
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }

        userPostView.postTimeLabel.text = viewModel.postIsEdited ? viewModel.timestampString! + " ·• Edited • " : viewModel.timestampString! + " • "
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotsImageButton.menu = addMenuItems()
        postTextView.text = viewModel.postText
        
        actionButtonsView.likesLabel.text = viewModel.likesLabelText
        actionButtonsView.commentLabel.text = viewModel.commentsLabelText
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage

        if postTextView.isTextTruncated {
            addSubview(showMoreView)
            NSLayoutConstraint.activate([
                showMoreView.heightAnchor.constraint(equalToConstant: postTextView.font?.lineHeight ?? 0.0),
                showMoreView.bottomAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: -1),
                showMoreView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
                showMoreView.widthAnchor.constraint(equalToConstant: 130),
            ])
            
        } else {
            showMoreView.isHidden = true
        }
        
        postImageView.sd_setImage(with: viewModel.postImageUrl[0])
        postTwoImageView.sd_setImage(with: viewModel.postImageUrl[1])
        
        if let reference = viewModel.postReference {
            postReferenceView.isHidden = false
            referenceHeightAnchor.isActive = false
            referenceHeightAnchor.constant = 26
            referenceHeightAnchor.isActive = true
            postReferenceView.configureWithReference(reference, referenceText: viewModel.postReferenceText)
        } else {
            postReferenceView.isHidden = true
        }
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        if uid == viewModel.post.ownerUid {
            // Owner
            
            let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                UIAction(title: Post.PostMenuOptions.delete.rawValue, image: Post.PostMenuOptions.delete.menuOptionsImage, handler: { (_) in
                    self.delegate?.cell(self, didTapMenuOptionsFor: viewModel.post, option: .delete)
                }),
                UIAction(title: Post.PostMenuOptions.edit.rawValue, image: Post.PostMenuOptions.edit.menuOptionsImage, handler: { (_) in
                    self.delegate?.cell(self, didTapMenuOptionsFor: viewModel.post, option: .edit)
                })
            ])
            userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
            return menuItems
        } else {
            //  Not owner
            let menuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                UIAction(title: Post.PostMenuOptions.report.rawValue, image: Post.PostMenuOptions.report.menuOptionsImage, handler: { (_) in
                    self.delegate?.cell(self, didTapMenuOptionsFor: viewModel.post, option: .report)
                })
            ])
            userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
            return menuItems
        }
    }
    
    func set(user: User) {
        self.user = user
        if let profileImageUrl = user.profileImageUrl, profileImageUrl != "" {
            userPostView.profileImageView.sd_setImage(with: URL(string: profileImageUrl))
        }
        
        userPostView.usernameLabel.text = user.firstName! + " " + user.lastName!
        userPostView.userInfoCategoryLabel.attributedText = user.getUserAttributedInfo()
    }
    
    
    func configureWithReviewOptions() {
        //
        actionButtonsView.isHidden = true
        userPostView.dotsImageButton.isHidden = true
        addSubviews(reviewActionButtonsView)
        NSLayoutConstraint.activate([
            reviewActionButtonsView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            reviewActionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            reviewActionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            reviewActionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
       
    }
    
    
    @objc func handleImageTap(gesture: UITapGestureRecognizer) {
        guard let image = gesture.view as? UIImageView else { return }
        if image == postImageView {
            delegate?.cell(self, didTapImage: [postImageView, postTwoImageView], index: 0)
        } else {
            delegate?.cell(self, didTapImage: [postImageView, postTwoImageView], index: 1)
        }
    }
    
    @objc func didTapPost() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, wantsToSeePost: viewModel.post, withAuthor: user)
    }
}


extension HomeTwoImageTextCell: MEUserPostViewDelegate {
    func didTapThreeDots() { return }
    
    func didTapProfile() {
        guard let user = user else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
    }
}

extension HomeTwoImageTextCell: MEReferenceViewDelegate {
    func didTapShowReference() {
        guard let viewModel = viewModel, let reference = viewModel.postReference else { return }
        delegate?.cell(self, wantsToSeeReference: reference)
    }
}

extension HomeTwoImageTextCell: MEPostInfoViewDelegate {
    func wantsToShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
}


extension HomeTwoImageTextCell: MEPostActionButtonsDelegate {
    func handleShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
    
    
    func handleComments() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, wantsToShowCommentsFor: viewModel.post, forAuthor: user)
    }
    
    
    func handleBookmark() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didBookmark: viewModel.post)
    }
    
    
    
    func handleLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didLike: viewModel.post)
    }
}


extension HomeTwoImageTextCell: MEReviewActionButtonsDelegate {
    func didTapApprove() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapAcceptContent(contentId: viewModel.post.postId, type: .post)
    }
    
    func didTapDelete() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapCancelContent(contentId: viewModel.post.postId, type: .post)
    }
}




