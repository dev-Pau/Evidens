//
//  HomeFourImageTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/6/22.
//

import UIKit

class HomeFourImageTextCell: UICollectionViewCell {
    
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
    
    var postTextLabel = MEPostLabel()
    
    var actionButtonsView = MEPostActionButtons()
    
    private lazy var reviewActionButtonsView = MEReviewActionButtons()
    
    private var appended: [Int] = []
    
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
    
    private lazy var postThreeImageView: UIImageView = {
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
    
    private lazy var postFourImageView: UIImageView = {
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
        
        backgroundColor = .systemBackground
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        userPostView.delegate = self
        actionButtonsView.delegate = self
        reviewActionButtonsView.delegate = self
        cellContentView.addSubviews(userPostView, postTextLabel, postImageView, postTwoImageView, postThreeImageView, postFourImageView, actionButtonsView)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            postTextLabel.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 15),
            postTextLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            postImageView.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 200),
            postImageView.widthAnchor.constraint(equalToConstant: frame.width),
            
            postTwoImageView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 2),
            postTwoImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            postTwoImageView.widthAnchor.constraint(equalToConstant: frame.width / 3 - 4),
            postTwoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            postFourImageView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 2),
            postFourImageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            postFourImageView.heightAnchor.constraint(equalToConstant: 150),
            postFourImageView.widthAnchor.constraint(equalToConstant: frame.width / 3 - 4),
            
            postThreeImageView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 2),
            postThreeImageView.leadingAnchor.constraint(equalTo: postTwoImageView.trailingAnchor, constant: 2),
            postThreeImageView.trailingAnchor.constraint(equalTo: postFourImageView.leadingAnchor, constant: -2),
            postThreeImageView.heightAnchor.constraint(equalToConstant: 150),
            
            actionButtonsView.topAnchor.constraint(equalTo: postThreeImageView.bottomAnchor, constant: 10),
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
        
        userPostView.postTimeLabel.text = viewModel.postIsEdited ? viewModel.timestampString! + " • Edited • " : viewModel.timestampString! + " • "
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotsImageButton.menu = addMenuItems()
        postTextLabel.text = viewModel.postText
        
        actionButtonsView.likesLabel.text = viewModel.likesLabelText
        actionButtonsView.commentLabel.text = viewModel.commentsLabelText
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
       
        postImageView.sd_setImage(with: viewModel.postImageUrl[0])
        postTwoImageView.sd_setImage(with: viewModel.postImageUrl[1])
        postThreeImageView.sd_setImage(with: viewModel.postImageUrl[2])
        postFourImageView.sd_setImage(with: viewModel.postImageUrl[3])
        
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
    func configureWithReviewOptions() {
        //
        actionButtonsView.isHidden = true
        userPostView.dotsImageButton.isHidden = true
        addSubviews(reviewActionButtonsView)
        NSLayoutConstraint.activate([
            reviewActionButtonsView.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            reviewActionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            reviewActionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            reviewActionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
       
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
    
    
    @objc func handleImageTap(gesture: UITapGestureRecognizer) {
        guard let image = gesture.view as? UIImageView else { return }
        let images = [postImageView, postTwoImageView, postThreeImageView,postFourImageView]
        if image == postImageView {
            delegate?.cell(self, didTapImage: images, index: 0)
        } else if image == postTwoImageView {
            delegate?.cell(self, didTapImage: images, index: 1)
        } else if image == postThreeImageView {
            delegate?.cell(self, didTapImage: images, index: 2)
        } else {
            delegate?.cell(self, didTapImage: images, index: 3)
        }
    }
}

extension HomeFourImageTextCell: MEUserPostViewDelegate {
    func didTapThreeDots() { return }
    
    func didTapProfile() {
        guard let user = user else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
    }
}


extension HomeFourImageTextCell: MEPostInfoViewDelegate {
    func wantsToShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
}


extension HomeFourImageTextCell: MEPostActionButtonsDelegate {
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


extension HomeFourImageTextCell: MEReviewActionButtonsDelegate {
    func didTapApprove() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapAcceptContent(contentId: viewModel.post.postId, type: .post)
    }
    
    func didTapDelete() {
        guard let viewModel = viewModel else { return }
        reviewDelegate?.didTapCancelContent(contentId: viewModel.post.postId, type: .post)
    }
}


