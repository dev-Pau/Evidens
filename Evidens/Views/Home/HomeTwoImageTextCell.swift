//
//  HomeTwoImageTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/6/22.
//

import UIKit

private let reuseIdentifier = "reuseIdentifier"

class HomeTwoImageTextCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: HomeCellDelegate?
    
    private lazy var categoryPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("  Nutrition  ", for: .normal)
        button.backgroundColor = blackColor
        button.layer.cornerRadius = 11
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        return button
    }()
    
    private lazy var subCategoryPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(blackColor, for: .normal)
        button.setTitle("  Vegetables  ", for: .normal)
        button.backgroundColor = lightGrayColor
        button.layer.cornerRadius = 11
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        return button
    }()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        //button.backgroundColor = UIColor(rgb: 0xF1F4F7)
        button.setDimensions(height: 20, width: 20)
        button.setImage(UIImage(named: "dots"), for: .normal)
        button.tintColor = UIColor(rgb: 0x576670)
        button.addTarget(self, action: #selector(didTapThreeDots), for: .touchUpInside)
        return button
    }()
    
    private lazy var userTypeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(grayColor, for: .normal)
        button.setTitle("  Professional  ", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 11
        button.layer.borderWidth = 1.5
        button.layer.borderColor = grayColor.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        return button
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .lightGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(blackColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = blackColor
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let clockImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "clock")
        iv.setDimensions(height: 9.6, width: 9.6)
        return iv
    }()
    
    private let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0x677987)
        label.text = "Physiotherapist"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = lightGrayColor
        label.setHeight(1.0)
        return label
    }()
    
    private let bottomSeparatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = lightGrayColor
        label.setHeight(1.0)
        return label
    }()
    
    private let postLabel: UILabel = {
        let label = UILabel()
        label.textColor = blackColor
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.contentMode = .scaleAspectFit
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let seeMoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.isUserInteractionEnabled = true
        label.text = ("...see more")
        label.isHidden = true
        return label
    }()
    
    lazy var likesIndicatorImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "heartGray")
        iv.setDimensions(height: 16, width: 16)
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = blackColor
        button.addTarget(self, action: #selector(didTapComments), for: .touchUpInside)
        return button
    }()
    
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .lightGray
        iv.backgroundColor = lightGrayColor
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var postTwoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .lightGray
        iv.backgroundColor = lightGrayColor
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = blackColor
        return button
    }()
    
    private lazy var postImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setHeight(200)
        return iv
    }()
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "bookmark"), for: .normal)
        button.tintColor = blackColor
        button.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "paperplane"), for: .normal)
        button.tintColor = blackColor
        return button
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrowshape.turn.up.left"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .red
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let shareLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let dotSeparator: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "dot")
        iv.contentMode = .scaleAspectFit
        iv.setDimensions(height: 3, width: 3)
        return iv
    }()
        
    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = grayColor
        return label
    }()
        
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white

        addSubview(categoryPostButton)
        categoryPostButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 10, paddingLeft: 15)
        
        addSubview(subCategoryPostButton)
        subCategoryPostButton.anchor(top: topAnchor, left: categoryPostButton.rightAnchor, paddingTop: 10, paddingLeft: 10)
        
        addSubview(dotsImageButton)
        dotsImageButton.centerY(inView: subCategoryPostButton)
        dotsImageButton.anchor(right: rightAnchor, paddingRight: 15)
        
        addSubview(separatorLabel)
        separatorLabel.anchor(top:categoryPostButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10)
        
        //Profile ImageView
        addSubview(profileImageView)
        profileImageView.anchor(top: separatorLabel.bottomAnchor, left: categoryPostButton.leftAnchor, paddingTop: 12)
        profileImageView.setDimensions(height: 47, width: 47)
        profileImageView.layer.cornerRadius = 47 / 2
        
        //Username Button
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, paddingLeft: 8)
        //usernameButton.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        
        addSubview(userCategoryLabel)
        userCategoryLabel.anchor(top: usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor)
        
        addSubview(clockImage)
        clockImage.anchor(top: userCategoryLabel.bottomAnchor, left: userCategoryLabel.leftAnchor, paddingTop: 3)
        
        addSubview(postTimeLabel)
        //postTimeLabel.anchor(top: clockImage.topAnchor, left: clockImage.rightAnchor, paddingLeft: 4)
        postTimeLabel.centerY(inView: clockImage, leftAnchor: clockImage.rightAnchor, paddingLeft: 4)
        
        addSubview(userTypeButton)
        userTypeButton.centerY(inView: usernameLabel)
        userTypeButton.anchor(right: rightAnchor, paddingRight: 15)
        
        
        //Post Label
        addSubview(postLabel)
        postLabel.anchor(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, right: rightAnchor, paddingTop: 12, paddingRight: 15)
        
        
        addSubview(seeMoreLabel)
        seeMoreLabel.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor)
        
        addSubview(postImageView)
        postImageView.anchor(top: postLabel.bottomAnchor, left: leftAnchor, paddingTop: 12)
        postImageView.setHeight(350)
        postImageView.setWidth(UIScreen.main.bounds.size.width / 2 - 4)
        
        addSubview(postTwoImageView)
        postTwoImageView.anchor(top: postLabel.bottomAnchor, left: postImageView.rightAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 2)
        postTwoImageView.setHeight(350)

        /*
        addSubview(likesIndicatorImage)
        likesIndicatorImage.anchor(top: postImageView.bottomAnchor, left: postLabel.leftAnchor, paddingTop: 12)
        
        addSubview(likesLabel)
        likesLabel.centerY(inView: likesIndicatorImage, leftAnchor: likesIndicatorImage.rightAnchor, paddingLeft: 2)
        
        addSubview(bottomSeparatorLabel)
        bottomSeparatorLabel.anchor(top:likesIndicatorImage.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10)
        
        addSubview(likeButton)
        likeButton.anchor(top: bottomSeparatorLabel.bottomAnchor, left: postLabel.leftAnchor, paddingTop: 10)
        
        addSubview(commentButton)
        commentButton.centerY(inView: likeButton, leftAnchor: likeButton.rightAnchor, paddingLeft: 15)
        
        addSubview(sendButton)
        sendButton.centerY(inView: likeButton, leftAnchor: commentButton.rightAnchor, paddingLeft: 15)
        
        addSubview(shareButton)
        shareButton.centerY(inView: likeButton, leftAnchor: sendButton.rightAnchor, paddingLeft: 15)
        
        addSubview(bookmarkButton)
        bookmarkButton.centerY(inView: likeButton)
        bookmarkButton.anchor(right: postLabel.rightAnchor)
*/
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func didTapThreeDots() {
        dotsImageButton.menu = addMenuItems()
        dotsImageButton.showsMenuAsPrimaryAction = true
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

        //collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier!)
        //collectionView.delegate = self
        //collectionView.dataSource = self
        
        
        //Configure post with post info
        postLabel.text = viewModel.postText
        likesLabel.text = viewModel.likesLabelText
        likesIndicatorImage.isHidden = viewModel.isLikesHidden
        postTimeLabel.text = viewModel.timestampString
        bookmarkButton.setImage(viewModel.bookMarkImage, for: .normal)
        
        postImageView.sd_setImage(with: viewModel.postImageUrl[0])
        
        postTwoImageView.sd_setImage(with: viewModel.postImageUrl[1])
 
        //postImageView.setDimensions(height: 300, width: frame.width)
        profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        
        //imagesToDisplay = viewModel.postImageUrl
        
        usernameLabel.text = viewModel.fullName
        //usernameButton.setTitle(viewModel.fullName, for: .normal)
        
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        
        configureActionButtons(numberOfComments: "\(viewModel.comments)", numberOfShares: "\(viewModel.shares)")

    }
    
    func configureActionButtons(numberOfComments: String, numberOfShares: String) {
        //Post has comments & shares

        commentLabel.removeFromSuperview()
        shareLabel.removeFromSuperview()
        dotSeparator.removeFromSuperview()
        let stackView = UIStackView(arrangedSubviews: [commentLabel, dotSeparator, shareLabel])
        commentLabel.text = viewModel?.commentsLabelText
        shareLabel.text = viewModel?.shareLabelText

        if numberOfComments != "0" && numberOfShares != "0" {
            print("is this case")
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            addSubview(stackView)
            stackView.centerY(inView: likesLabel)
            stackView.anchor(right: postLabel.rightAnchor, width: 120, height: 50)
            return
            //stackView.anchor(top: postLabel.bottomAnchor, left: usernameLabel.leftAnchor, width: 200, height: 50)
            
        }
        //Post has shares
        if numberOfComments == "0" && numberOfShares != "0" {
            stackView.removeFromSuperview()
            addSubview(shareLabel)
            shareLabel.centerY(inView: likesLabel)
            shareLabel.anchor(right: postLabel.rightAnchor)
            return
            
        }
        //Post has comments
        if numberOfComments != "0" && numberOfShares == "0" {
            print("only comments")
            stackView.removeFromSuperview()
            addSubview(commentLabel)
            commentLabel.centerY(inView: likesLabel)
            commentLabel.anchor(right: postLabel.rightAnchor)
            return

        }
        //Post doesn't have comments/shares
        stackView.removeFromSuperview()
        commentLabel.removeFromSuperview()
        shareLabel.removeFromSuperview()
        dotSeparator.removeFromSuperview()
            
            
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
