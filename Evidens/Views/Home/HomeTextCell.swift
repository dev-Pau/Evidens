//
//  FeedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import SwiftUI

class HomeTextCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: HomeCellDelegate?
    
    private var headerPostView = MEHeaderPostView(category: "  Nutrition  ", subCategory: "  Vegetables  ")
    
    private var userPostView = MEUserPostView()
    
    private var postTextLabel = MEPostLabel()
    
    private var postStatsView = MEPostStatsView()
    
    private var postInfoView = MEPostInfoView(comments: 0, commentText: "", shares: 0, shareText: "")
    
    private var actionButtonsView = MEPostActionButtons()
    
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        headerPostView.delegate = self
        userPostView.delegate = self
        postStatsView.delegate = self

        addSubviews(headerPostView, userPostView, postTextLabel, postStatsView, postInfoView, actionButtonsView)
        
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
            
            postStatsView.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            postStatsView.leadingAnchor.constraint(equalTo: postTextLabel.leadingAnchor),
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
        
        let postType = viewModel.postType
        
        // New values
        userPostView.usernameLabel.text = viewModel.fullName
        userPostView.profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        userPostView.postTimeLabel.text = viewModel.timestampString
        userPostView.userCategoryLabel.text = "Physiotherapist"
        
        postTextLabel.text = viewModel.postText
        
        postStatsView.likesLabel.text = viewModel.likesLabelText
        postStatsView.likesIndicatorImage.isHidden = viewModel.isLikesHidden
        
        postInfoView.configure(comments: viewModel.comments, commentText: viewModel.commentsLabelText, shares: viewModel.shares, shareText: viewModel.shareLabelText)
        
        actionButtonsView.bookmarkButton.setImage(viewModel.bookMarkImage, for: .normal)
        //bookmarkButton.setImage(viewModel.bookMarkImage, for: .normal)

        // New values
      
        //Configure post with user info
        //profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        
        //usernameLabel.text = viewModel.fullName
        //usernameButton.setTitle(viewModel.fullName, for: .normal)
        
        //likeButton.tintColor = viewModel.likeButtonTintColor
        //likeButton.setImage(viewModel.likeButtonImage, for: .normal)
    }
}


extension HomeTextCell: MEHeaderPostViewDelegate {
    func didTapSubCategory(for subCategory: String) {
        print("Home cell received sub category \(subCategory) to show")
        delegate?.cell(wantsToSeePostsFor: subCategory)
    }
    

    func didTapCategory(for category: String) {
        print("Home cell received \(category) to show")
        delegate?.cell(wantsToSeePostsFor: category)
    }
    
    func didTapThreeDots(withAction action: String) {
        print("Home cell received")
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didPressThreeDotsFor: viewModel.post, withAction: action)
    }
}


extension HomeTextCell: MEUserPostViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowProfileFor: viewModel.post.ownerUid)
    }
}


extension HomeTextCell: MEPostStatsViewDelegate {
    func wantsToShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
    
    
}
