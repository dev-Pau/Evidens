//
//  HomeImageTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/5/22.
//

import UIKit

private let reuseIdentifier = "reuseIdentifier"

class HomeImageTextCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: HomeCellDelegate?
    
    
    private var headerPostView = MEHeaderPostView(category: "  Nutrition  ", subCategory: "  Vegetables  ")
    
    private var userPostView = MEUserPostView()
    
    private var postTextLabel = MEPostLabel()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = lightGrayColor
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private var postStatsView = MEPostStatsView()
    
    private var postInfoView = MEPostInfoView(comments: 0, commentText: "", shares: 0, shareText: "")
    
    private var actionButtonsView = MEPostActionButtons()
    
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        //headerPostView.delegate = self

        addSubviews(headerPostView, userPostView, postTextLabel, postImageView, postStatsView, postInfoView, actionButtonsView)
        
        NSLayoutConstraint.activate([
            headerPostView.topAnchor.constraint(equalTo: topAnchor),
            headerPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerPostView.heightAnchor.constraint(equalToConstant: 50),
            
            userPostView.topAnchor.constraint(equalTo: headerPostView.bottomAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            postTextLabel.topAnchor.constraint(equalTo: userPostView.bottomAnchor),
            postTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            postImageView.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            
            postStatsView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            postStatsView.leadingAnchor.constraint(equalTo: postImageView.leadingAnchor, constant: 10),
            postStatsView.widthAnchor.constraint(equalToConstant: 150),
            postStatsView.heightAnchor.constraint(equalToConstant: 20),
            
            postInfoView.centerYAnchor.constraint(equalTo: postStatsView.centerYAnchor),
            postInfoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            postInfoView.heightAnchor.constraint(equalToConstant: 25),
            postInfoView.widthAnchor.constraint(equalToConstant: 150),
            
            actionButtonsView.topAnchor.constraint(equalTo: postInfoView.bottomAnchor, constant: 5),
            actionButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    
    
    @objc func didTapThreeDots() {
        //dotsImageButton.menu = addMenuItems()
        //dotsImageButton.showsMenuAsPrimaryAction = true
    }
    
    @objc func didTapUsername() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowProfileFor: viewModel.post.ownerUid)
    }
    
    @objc func didTapComments() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowCommentsFor: viewModel.post)
    }
    
    @objc func didTapLike() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didLike: viewModel.post)
    }
    
    @objc func didTapBookmark() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didBookmark: viewModel.post)
 
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }

        userPostView.usernameLabel.text = viewModel.fullName
        userPostView.profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        userPostView.postTimeLabel.text = viewModel.timestampString
        userPostView.userCategoryLabel.text = "Physiotherapist"
        
        postTextLabel.text = viewModel.postText
        
        postStatsView.likesLabel.text = viewModel.likesLabelText
        postStatsView.likesIndicatorImage.isHidden = viewModel.isLikesHidden
        
        postInfoView.configure(comments: viewModel.comments, commentText: viewModel.commentsLabelText, shares: viewModel.shares, shareText: viewModel.shareLabelText)
        
        
        
        
        
        //likesLabel.text = viewModel.likesLabelText
        //likesIndicatorImage.isHidden = viewModel.isLikesHidden
        //postTimeLabel.text = viewModel.timestampString
        //bookmarkButton.setImage(viewModel.bookMarkImage, for: .normal)
        
        postImageView.sd_setImage(with: viewModel.postImageUrl[0]) { image,_,_,_ in
            guard let image = image else { return }
            let ratio = image.size.width / image.size.height
            let newHeight = self.frame.width / ratio

            self.postImageView.setHeight(newHeight)
        }
 
        //postImageView.setDimensions(height: 300, width: frame.width)
        //profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        
        //imagesToDisplay = viewModel.postImageUrl
        
        //usernameLabel.text = viewModel.fullName
        //usernameButton.setTitle(viewModel.fullName, for: .normal)
        
        //likeButton.tintColor = viewModel.likeButtonTintColor
        //likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        
        //configureActionButtons(numberOfComments: "\(viewModel.comments)", numberOfShares: "\(viewModel.shares)")

    }
    
    func addMenuItems() -> UIMenu {
        let menuItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: "Report Post", image: UIImage(systemName: "flag"), handler: { (_) in
                print("Copy")
                guard let viewModel = self.viewModel else { return }
                self.delegate?.cell(self, didPressThreeDotsFor: viewModel.post, withAction: "report")
            })
        
        ])
        return menuItem
        
    }
}
