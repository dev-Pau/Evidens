//
//  HomeTwoImageTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/6/22.
//

import UIKit

class HomeTwoImageTextCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private var user: User?
    weak var delegate: HomeCellDelegate?
    private let cellContentView = UIView()
    private var userPostView = PrimaryUserView()
    var postTextView = SecondaryTextView()
    let showMoreView = ShowMoreView()
    var actionButtonsView = PrimaryActionButton()

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
    
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
        backgroundColor = .systemBackground
        
        userPostView.delegate = self
        actionButtonsView.delegate = self
     
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(userPostView, postTextView, postImageView, postTwoImageView, actionButtonsView)
        
        let postImageViewHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 350)
        postImageViewHeightConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            postTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            postTextView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            postImageView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            postImageViewHeightConstraint,
            postImageView.widthAnchor.constraint(equalToConstant: frame.width / 2 - 4),
            
            postTwoImageView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            postTwoImageView.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 2),
            postTwoImageView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            postTwoImageView.bottomAnchor.constraint(equalTo: postImageView.bottomAnchor),
            
            actionButtonsView.topAnchor.constraint(equalTo: postImageView.bottomAnchor),
            actionButtonsView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 40))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func hideSeparatorView() {
        actionButtonsView.separatorView.isHidden = true
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }

        userPostView.postTimeLabel.text = viewModel.time
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotsImageButton.menu = addMenuItems()

        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsValue
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText.appending(" "), attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        postTextView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        postTextView.addGestureRecognizer(gestureRecognizer)
        _ = postTextView.hashtags()
       
        postImageView.sd_setImage(with: viewModel.imageUrl[0])
        postTwoImageView.sd_setImage(with: viewModel.imageUrl[1])
        
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let delegate = delegate else { return nil }
        if let menu = UIMenu.createPostMenu(self, for: viewModel, delegate: delegate) {
            userPostView.dotsImageButton.showsMenuAsPrimaryAction = true
            return menu
        }
        return nil
    }
    
    func set(user: User) {
        self.user = user
        userPostView.set(user: user)
    }
    
    @objc func handleTextViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: postTextView)
        let position = postTextView.closestPosition(to: location)!

        if let range = postTextView.tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: .layout(.left)) {
            let startIndex = postTextView.offset(from: postTextView.beginningOfDocument, to: range.start)
           
            let attributes = postTextView.attributedText.attributes(at: startIndex, effectiveRange: nil)
            
            if attributes.keys.contains(.link), let hashtag = attributes[.link] as? String {
                delegate?.cell(wantsToSeeHashtag: hashtag)
            } else {
                didTapPost()
            }
        }
    }
    
    
    @objc func handleImageTap(gesture: UITapGestureRecognizer) {
        guard let image = gesture.view as? UIImageView else { return }
        if image == postImageView {
            delegate?.cell(self, didTapImage: [postImageView, postTwoImageView], index: 0)
        } else {
            delegate?.cell(self, didTapImage: [postImageView, postTwoImageView], index: 1)
        }
    }
    
    @objc func didTapPost() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, wantsToSeePost: viewModel.post, withAuthor: user)
    }
}


extension HomeTwoImageTextCell: PrimaryUserViewDelegate {
    func didTapThreeDots() { return }
    
    func didTapProfile() {
        guard let user = user else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
    }
}

extension HomeTwoImageTextCell: PrimaryActionButtonDelegate {
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

extension HomeTwoImageTextCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension HomeTwoImageTextCell: HomeCellProtocol { }
