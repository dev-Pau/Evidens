//
//  PostTextImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/23.
//

import UIKit

class PostTextImageCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    var isExpanded: Bool = false
    private var user: User?
    weak var delegate: HomeCellDelegate?

    private var userPostView = PrimaryUserView()
    var postTextView = SecondaryTextView()
    let showMoreView = ShowMoreView()
    var actionButtonsView = PrimaryActionButton()
    private var postImage = PostImages(frame: .zero)
    private var contentTimestamp = ContentTimestampView()
    
    private var contentTimestampConstraint: NSLayoutConstraint!
   
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
        
        userPostView.delegate = self
        actionButtonsView.delegate = self
        contentTimestampConstraint = contentTimestamp.heightAnchor.constraint(equalToConstant: 0)
        
        addSubviews(userPostView, postTextView, postImage, contentTimestamp, actionButtonsView)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 67),
            
            postTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 3),
            postTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            postImage.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            postImage.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            postImage.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
            
            contentTimestamp.topAnchor.constraint(equalTo: postImage.bottomAnchor),
            contentTimestamp.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentTimestamp.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentTimestampConstraint,

            actionButtonsView.topAnchor.constraint(equalTo: contentTimestamp.bottomAnchor),
            actionButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 40),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
        ])
        
        postImage.zoomDelegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        postImage.kind = viewModel.kind
        contentTimestamp.isHidden = true
        userPostView.postTimeLabel.text = viewModel.time
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotButton.menu = addMenuItems()
        userPostView.timestampLabel.text = viewModel.timestamp
        userPostView.set(isEdited: viewModel.edited)
       
        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsValue
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage

        if isExpanded {
            postTextView.configureAsExpanded()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText.appending(" "), attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular), .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
            
            contentTimestampConstraint.constant = 40
            layoutIfNeeded()
            contentTimestamp.isHidden = false
        } else {
            let font: UIFont = .systemFont(ofSize: 15, weight: .regular)
            let fitText = viewModel.postText.substringToFit(size: CGSize(width: UIScreen.main.bounds.width - 20 - 200 / 3, height: 3 * font.lineHeight), font: font)
            
            if fitText != viewModel.postText {
                addSubview(showMoreView)
                NSLayoutConstraint.activate([
                    showMoreView.bottomAnchor.constraint(equalTo: postTextView.bottomAnchor),
                    showMoreView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor)
                ])
            } else {
                showMoreView.removeFromSuperview()
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            postTextView.attributedText = NSMutableAttributedString(string: fitText.appending(" "), attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        }
        
        contentTimestamp.set(timestamp: viewModel.detailedTime)
        postTextView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        postTextView.addGestureRecognizer(gestureRecognizer)
        _ = postTextView.hashtags()

        postImage.add(images: viewModel.imageUrl.map { $0! })
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let delegate = delegate else { return nil }
        if let menu = UIMenu.createPostMenu(self, for: viewModel, delegate: delegate) {
            userPostView.dotButton.showsMenuAsPrimaryAction = true
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
                if isExpanded {
                    postTextView.selectedTextRange = nil
                } else {
                    didTapPost()
                }
            }
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    @objc func didTapPost() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, wantsToSeePost: viewModel.post, withAuthor: user)
    }
}

extension PostTextImageCell: PrimaryUserViewDelegate {
    func didTapThreeDots() { return }
    
    func didTapProfile() {
        guard let user = user else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
    }
}

extension PostTextImageCell: PrimaryActionButtonDelegate {
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

extension PostTextImageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension PostTextImageCell: PostImagesDelegate {
    
    func zoomImage(_ image: [UIImageView], index: Int) {
        delegate?.cell(self, didTapImage: image, index: index)
    }
}


extension PostTextImageCell: HomeCellProtocol { }



