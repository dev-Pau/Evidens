//
//  HomeTwoImageTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/6/22.
//

import UIKit
import SwiftUI

class HomeTwoImageTextCell: UICollectionViewCell {
    
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
    
    private var postStatsView = MEPostStatsView()
    
    private var postInfoView = MEPostInfoView(comments: 0, commentText: "", shares: 0, shareText: "")
    
    private var actionButtonsView = MEPostActionButtons()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = lightGrayColor
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
        iv.backgroundColor = lightGrayColor
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap(gesture:))))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        headerPostView.delegate = self
        userPostView.delegate = self
        postStatsView.delegate = self
        
        actionButtonsView.delegate = self
        
        addSubviews(headerPostView, userPostView, postTextLabel, postImageView, postTwoImageView, postStatsView, postInfoView, actionButtonsView)
        
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
            postImageView.heightAnchor.constraint(equalToConstant: 350),
            postImageView.widthAnchor.constraint(equalToConstant: frame.width / 2 - 4),
            
            postTwoImageView.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            postTwoImageView.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 2),
            postTwoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            postTwoImageView.heightAnchor.constraint(equalToConstant: 350),
            
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
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage
        actionButtonsView.likeButton.configuration?.baseForegroundColor = viewModel.likeButtonTintColor
        
        postImageView.sd_setImage(with: viewModel.postImageUrl[0])
        postTwoImageView.sd_setImage(with: viewModel.postImageUrl[1])
    }
    
    
    @objc func handleImageTap(gesture: UITapGestureRecognizer) {
        guard let image = gesture.view as? UIImageView, let viewModel = viewModel else { return }
        if image == postImageView {
            //delegate?.cell(self, didTapImage: image, withHeight: viewModel.post.imagesHeight.first!)
        } else {
            //delegate?.cell(self, didTapImage: image, withHeight: viewModel.post.imagesHeight[1])
        }
    }
}


extension HomeTwoImageTextCell: MEHeaderPostViewDelegate {
    
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


extension HomeTwoImageTextCell: MEUserPostViewDelegate {
    func didTapProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowProfileFor: viewModel.post.ownerUid)
    }
}


extension HomeTwoImageTextCell: MEPostStatsViewDelegate {
    func wantsToShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
}


extension HomeTwoImageTextCell: MEPostActionButtonsDelegate {
    
    func handleComments() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowCommentsFor: viewModel.post)
    }
    
    
    func handleShare() {
        print("Did tap share")
    }
    
    
    func handleSend() {
        print("Did tap send")
    }
    
    
    func handleLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didLike: viewModel.post)
    }
}


