//
//  FeedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post)
    func cell(_ cell: FeedCell, didLike post: Post)
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String)
    func cell(_ cell: FeedCell, didPressThreeDotsFor post: Post, withAction action: String)
}

class FeedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: FeedCellDelegate?
    
    private lazy var categoryPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
        button.setTitle("  Nutrition  ", for: .normal)
        button.backgroundColor = UIColor(rgb: 0x2B2D42)
        button.layer.cornerRadius = 2
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 12)
        return button
    }()
    
    private lazy var subCategoryPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(rgb: 0x2B2D42), for: .normal)
        button.setTitle("  Vegetables  ", for: .normal)
        button.backgroundColor = UIColor(rgb: 0xF1F4F7)
        button.layer.cornerRadius = 2
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 12)
        return button
    }()
    
    /*
    private lazy var dotsImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(named: "dots")
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapThreeDots))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
     */
    
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
        button.setTitleColor(UIColor(rgb: 0x677987), for: .normal)
        button.setTitle("  Professional  ", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 2
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(rgb: 0x677987).cgColor
        button.titleLabel?.font = UIFont(name: "Raleway-SemiBold", size: 12)
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
        button.setTitleColor(UIColor(rgb: 0x2B2D42), for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 16)
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0x2B2D42)
        label.font = UIFont(name: "Raleway-Bold", size: 16)
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
        label.text = "Researcher"
        label.font = UIFont(name: "Raleway-SemiBold", size: 12)
        return label
    }()
    
    private let postLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.contentMode = .scaleAspectFit
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bubble.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapComments), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .black
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
        label.setDimensions(height: 50, width: 100)
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.text = "120"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
        
    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-SemiBold", size: 12)
        label.textColor = UIColor(rgb: 0x677987)
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
        
        //Profile ImageView
        addSubview(profileImageView)
        profileImageView.anchor(top: categoryPostButton.bottomAnchor, left: categoryPostButton.leftAnchor, paddingTop: 12)
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
        //addSubview(postLabel)
        //postLabel.anchor(top: profileImageView.bottomAnchor, left: usernameButton.leftAnchor, right: rightAnchor, paddingTop: 1)
        //postLabel.setDimensions(height: 30, width: frame.width)
        
        //configureActionButtons()
        
        //Time Label
        //addSubview(postTimeLabel)
        //postTimeLabel.centerY(inView: profileImageView, leftAnchor: shareButton.rightAnchor, paddingLeft: 8)
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
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        //Configure post with post info
        postLabel.text = viewModel.postText
        likesLabel.text = viewModel.likesLabelText
        postTimeLabel.text = viewModel.timestampString
        
        //Configure post with user info
        profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        usernameLabel.text = viewModel.fullName
        //usernameButton.setTitle(viewModel.fullName, for: .normal)
        
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)

    }
    
    func configureActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, likesLabel, commentButton, commentLabel, shareButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        likeButton.setDimensions(height: 50, width: 30)
        likesLabel.setDimensions(height: 50, width: 50)
        commentButton.setDimensions(height: 50, width: 30)
        commentLabel.setDimensions(height: 50, width: 50)
        shareButton.setDimensions(height: 50, width: 30)
        
        addSubview(stackView)
        stackView.anchor(top: postLabel.bottomAnchor, left: usernameLabel.leftAnchor, width: 200, height: 50)
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
