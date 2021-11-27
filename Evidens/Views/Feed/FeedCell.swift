//
//  FeedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post)
}

class FeedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: FeedCellDelegate?
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(didTapUsername), for: .touchUpInside)
        return button
    }()
    
    private let postLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.contentMode = .scaleAspectFit
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = UIColor(rgb: 0x79CBBF)
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
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
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
        label.text = "2 days ago"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()

    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        //Profile ImageView
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        //Username Button
        addSubview(usernameButton)
        usernameButton.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        
        //Post Label
        addSubview(postLabel)
        postLabel.anchor(top: profileImageView.bottomAnchor, left: usernameButton.leftAnchor, right: rightAnchor, paddingTop: 1)
        postLabel.setDimensions(height: 30, width: frame.width)
        
        configureActionButtons()
        
        //Time Label
        addSubview(postTimeLabel)
        postTimeLabel.centerY(inView: profileImageView, leftAnchor: shareButton.rightAnchor, paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func didTapUsername() {
        print("DEBUG: did tap username")
    }
    
    @objc func didTapComments() {
        //Delegate the action to FeedViewController
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToShowCommentsFor: viewModel.post)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        //Configure post with post info
        postLabel.text = viewModel.postText
        likesLabel.text = viewModel.likesLabelText
        
        //Configure post with user info
        usernameButton.setTitle(viewModel.fullName, for: .normal)
        let url = viewModel.userProfileImageUrl
        guard let url = url else { return }
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.profileImageView.image = UIImage(data: data!)
            }
        }
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
        stackView.anchor(top: postLabel.bottomAnchor, left: usernameButton.leftAnchor, width: 200, height: 50)
    }
}
