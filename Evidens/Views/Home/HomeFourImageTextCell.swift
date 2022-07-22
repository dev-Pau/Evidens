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
    
    weak var delegate: HomeCellDelegate?
    
    private var headerPostView = MEHeaderPostView(category: "  Nutrition  ", subCategory: "  Vegetables  ")
    
    private var userPostView = MEUserPostView()
    
    private var postTextLabel = MEPostLabel()
    
    private var postStatsView = MEPostStatsView()
    
    private var postInfoView = MEPostInfoView(comments: 0, commentText: "", shares: 0, shareText: "")
    
    private var actionButtonsView = MEPostActionButtons()
    
    private var appended: [Int] = []
    
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
    
    private lazy var postThreeImageView: UIImageView = {
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
    
    private lazy var postFourImageView: UIImageView = {
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
        
        userPostView.delegate = self
        postInfoView.delegate = self
        
        actionButtonsView.delegate = self
        
        addSubviews(headerPostView, userPostView, postTextLabel, postImageView, postTwoImageView, postThreeImageView, postFourImageView, postStatsView, postInfoView, actionButtonsView)
        
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
            
            //350
            
            postImageView.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 200),
            postImageView.widthAnchor.constraint(equalToConstant: frame.width),
            
            postTwoImageView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 2),
            postTwoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            postTwoImageView.widthAnchor.constraint(equalToConstant: frame.width / 3 - 4),
            postTwoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            postFourImageView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 2),
            postFourImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            postFourImageView.heightAnchor.constraint(equalToConstant: 150),
            postFourImageView.widthAnchor.constraint(equalToConstant: frame.width / 3 - 4),
            
            postThreeImageView.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 2),
            postThreeImageView.leadingAnchor.constraint(equalTo: postTwoImageView.trailingAnchor, constant: 2),
            postThreeImageView.trailingAnchor.constraint(equalTo: postFourImageView.leadingAnchor, constant: -2),
            postThreeImageView.heightAnchor.constraint(equalToConstant: 150),
            
            postStatsView.topAnchor.constraint(equalTo: postTwoImageView.bottomAnchor, constant: 10),
            postStatsView.leadingAnchor.constraint(equalTo: postTwoImageView.leadingAnchor, constant: 10),
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
        userPostView.userInfoCategoryLabel.text = "Physiotherapist"
        
        postTextLabel.text = viewModel.postText
        
        postStatsView.likesLabel.text = viewModel.likesLabelText
      
        
        postInfoView.configure(comments: viewModel.comments, commentText: viewModel.commentsLabelText, shares: viewModel.shares, shareText: viewModel.shareLabelText)
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeButtonImage
        actionButtonsView.likeButton.configuration?.baseForegroundColor = viewModel.likeButtonTintColor
        
        viewModel.post.postImageUrl.forEach { url in
            let currentURL = url.replacingOccurrences(of: "https://firebasestorage.googleapis.com:443/v0/b/evidens-ec6bd.appspot.com/o/post_images%2F", with: "")

           
            appended.append(Int(currentURL[0..<1])!)

            if appended.count == viewModel.postImageUrl.count {
                print("DONE")
                print(appended)
                var sortedURL = appended.sorted()
                var index = appended.firstIndex(of: 0)
                postImageView.sd_setImage(with: viewModel.postImageUrl[appended.firstIndex(of: 0)!])
                postTwoImageView.sd_setImage(with: viewModel.postImageUrl[appended.firstIndex(of: 1)!])
                postThreeImageView.sd_setImage(with: viewModel.postImageUrl[appended.firstIndex(of: 2)!])
                postFourImageView.sd_setImage(with: viewModel.postImageUrl[appended.firstIndex(of: 3)!])
                
                //appended.removeAll()
            }
        }
        

    }
    
    
    @objc func handleImageTap(gesture: UITapGestureRecognizer) {
        guard let image = gesture.view as? UIImageView, let viewModel = viewModel else { return }
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
    func didTapThreeDots() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didPressThreeDotsFor: viewModel.post)
    }
    
    func didTapProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowProfileFor: viewModel.post.ownerUid)
    }
}


extension HomeFourImageTextCell: MEPostInfoViewDelegate {
    func wantsToShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
}


extension HomeFourImageTextCell: MEPostActionButtonsDelegate {
    
    func handleComments() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowCommentsFor: viewModel.post)
    }
    
    
    func handleBookmark() {
        print("bookarmk")
    }
    
    
    func handleLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didLike: viewModel.post)
    }
}


extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
