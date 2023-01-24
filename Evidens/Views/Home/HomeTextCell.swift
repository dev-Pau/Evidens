//
//  HomeTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

class HomeTextCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var reviewDelegate: ReviewContentGroupDelegate?
    
    private var user: User?
   
    private let cellContentView = UIView()
    
    weak var delegate: HomeCellDelegate?
    
    private var userPostView = MEUserPostView()
    
    var postTextLabel = MEPostLabel()
    
    var actionButtonsView = MEPostActionButtons()
    
    private lazy var reviewActionButtonsView = MEReviewActionButtons()
    
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
        
        userPostView.delegate = self
        actionButtonsView.delegate = self
        reviewActionButtonsView.delegate = self
        
        backgroundColor = .systemBackground

        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
         
    
        cellContentView.addSubviews(userPostView, postTextLabel, actionButtonsView)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            postTextLabel.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 15),
            postTextLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            actionButtonsView.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
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
        userPostView.postTimeLabel.text = viewModel.postIsEdited ? viewModel.timestampString! + " · Edited · " : viewModel.timestampString! + " · "
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        postTextLabel.text = viewModel.postText
        
        actionButtonsView.likesLabel.text = viewModel.likesLabelText
        actionButtonsView.commentLabel.text = viewModel.commentsLabelText
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        
    }
    
    func set(user: User) {
        self.user = user
        
        if let profileImageUrl = user.profileImageUrl {
            userPostView.profileImageView.sd_setImage(with: URL(string: profileImageUrl))
        }
        
        userPostView.usernameLabel.text = user.firstName! + " " + user.lastName!
        userPostView.userInfoCategoryLabel.attributedText = user.getUserAttributedInfo()
    }
    
    func configureWithReviewOptions() {
        //private lazy var reviewActionButtonsView = MEReviewActionButtons()
        actionButtonsView.isHidden = true
        addSubviews(reviewActionButtonsView)
        NSLayoutConstraint.activate([
            reviewActionButtonsView.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            reviewActionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            reviewActionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            reviewActionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
       
    }
    
    @objc func didTapPost() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, wantsToSeePost: viewModel.post, withAuthor: user)
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

extension HomeTextCell: MEUserPostViewDelegate {
    
    func didTapThreeDots() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, didPressThreeDotsFor: viewModel.post, forAuthor: user)
    }
    
    func didTapProfile() {
        guard let user = user else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
    }
}

extension HomeTextCell: MEPostActionButtonsDelegate {
    
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

extension HomeTextCell: MEReviewActionButtonsDelegate {
    func didTapApprove() {
        reviewDelegate?.didTapAcceptContent()
    }
    
    func didTapDelete() {
        print("second tap delete")
        reviewDelegate?.didTapCancelContent()
    }
}
