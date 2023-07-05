//
//  HomeImageTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/5/22.
//

import UIKit

class HomeImageTextCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    var user: User?
    weak var reviewDelegate: ReviewContentGroupDelegate?
    private lazy var reviewActionButtonsView = MEReviewActionButtons()
    private let cellContentView = UIView()
    weak var delegate: HomeCellDelegate?
    var userPostView = MEUserPostView()
    var postTextView = MEPostTextView()
    let showMoreView = MEShowMoreView()
    var actionButtonsView = MEPostActionButtons()
    
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .quaternarySystemFill
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        return iv
    }()
    
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
        backgroundColor = .systemBackground
        
        userPostView.delegate = self
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
        
        cellContentView.addSubviews(userPostView, postTextView, postImageView, actionButtonsView)
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            postTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            postTextView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),

            postImageView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 300),
    
            actionButtonsView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            actionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }

        userPostView.postTimeLabel.text = viewModel.time
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotsImageButton.menu = addMenuItems()

        actionButtonsView.likesLabel.text = viewModel.likesLabelText
        actionButtonsView.commentLabel.text = viewModel.commentsLabelText
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        
        //let postImageViewHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 300)
        //postImageViewHeightConstraint.priority = UILayoutPriority(999)
        //postImageViewHeightConstraint.isActive = true
        
        let showMoreSize = 100.0
        
        if postTextView.isTextTruncated {
            addSubview(showMoreView)
            NSLayoutConstraint.activate([
                showMoreView.heightAnchor.constraint(equalToConstant: postTextView.font?.lineHeight ?? 0.0),
                showMoreView.bottomAnchor.constraint(equalTo: postTextView.bottomAnchor),
                showMoreView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
                showMoreView.widthAnchor.constraint(equalToConstant: showMoreSize),
            ])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let strongSelf = self else { return }
                let firstLines = strongSelf.postTextView.getFirstLinesText(3)!
                let lastLine = strongSelf.postTextView.getLastLineText(3)!
                let lastLineFits = lastLine.getSubstringThatFitsWidth(width: UIScreen.main.bounds.width - 10 - showMoreSize, font: UIFont.systemFont(ofSize: 15, weight: .regular))

                strongSelf.postTextView.attributedText = NSMutableAttributedString(string: firstLines.appending(lastLineFits) , attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
                strongSelf.showMoreView.isHidden = false
            }
        } else {
            showMoreView.isHidden = true
            postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        }
        
        
        postImageView.sd_setImage(with: viewModel.postImageUrl.first!)
        
    }
    
    func set(user: User) {
        self.user = user
        if let profileImageUrl = user.profileImageUrl, profileImageUrl != "" {
            userPostView.profileImageView.sd_setImage(with: URL(string: profileImageUrl))
        }
        
        userPostView.usernameLabel.text = user.firstName! + " " + user.lastName!
        userPostView.userInfoCategoryLabel.attributedText = user.getUserAttributedInfo()
    }
    
    func hideSeparatorView() {
        actionButtonsView.separatorView.isHidden = true
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        
        var menuItems = [UIMenuElement]()
        
        if uid == viewModel.post.ownerUid {
            // Owner
            
            let ownerMenuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                UIAction(title: Post.PostMenuOptions.delete.rawValue, image: Post.PostMenuOptions.delete.menuOptionsImage, handler: { (_) in
                    self.delegate?.cell(self, didTapMenuOptionsFor: viewModel.post, option: .delete)
                }),
                UIAction(title: Post.PostMenuOptions.edit.rawValue, image: Post.PostMenuOptions.edit.menuOptionsImage, handler: { (_) in
                    self.delegate?.cell(self, didTapMenuOptionsFor: viewModel.post, option: .edit)
                })
            ])

            menuItems.append(ownerMenuItems)
        } else {
            //  Not owner
            let userMenuItems = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                UIAction(title: Post.PostMenuOptions.report.rawValue, image: Post.PostMenuOptions.report.menuOptionsImage, handler: { (_) in
                    self.delegate?.cell(self, didTapMenuOptionsFor: viewModel.post, option: .report)
                })
            ])

            menuItems.append(userMenuItems)
        }
        
        if viewModel.postReference != nil {
            let referenceItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
                UIAction(title: "Show Reference", image: Post.PostMenuOptions.report.menuOptionsImage, handler: { (_) in
                    self.delegate?.cell(self, didTapMenuOptionsFor: viewModel.post, option: .reference)
                })
            ])
            
            menuItems.append(referenceItem)
        }
        
        userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
        return UIMenu(children: menuItems)
    }
    func configureWithReviewOptions() {
        //private lazy var reviewActionButtonsView = MEReviewActionButtons()
        actionButtonsView.isHidden = true
        userPostView.dotsImageButton.isHidden = true
        addSubviews(reviewActionButtonsView)
        NSLayoutConstraint.activate([
            reviewActionButtonsView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            reviewActionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            reviewActionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            reviewActionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
       
    }
    
    @objc func handleImageTap() {
        delegate?.cell(self, didTapImage: [postImageView], index: 0)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 40))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    @objc func didTapPost() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, wantsToSeePost: viewModel.post, withAuthor: user)
    }
}


extension HomeImageTextCell: MEUserPostViewDelegate {
    func didTapThreeDots() { return }
    
    func didTapProfile() {
        guard let user = user else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
    }
}

extension HomeImageTextCell: MEPostInfoViewDelegate {
    func wantsToShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
}


extension HomeImageTextCell: MEPostActionButtonsDelegate {
    
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
    
    func handleShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
}


extension HomeImageTextCell: MEReviewActionButtonsDelegate {
    func didTapApprove() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapAcceptContent(contentId: viewModel.post.postId, type: .post)
    }
    
    func didTapDelete() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapCancelContent(contentId: viewModel.post.postId, type: .post)
    }
}

