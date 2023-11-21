//
//  PostTextImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/11/23.
//

import UIKit

class PostTextImageCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }

    private var user: User?
    weak var delegate: PostCellDelegate?
    
    private var userPostView = PrimaryUserView()
    var postTextView = SecondaryTextView()
    var actionButtonsView = PrimaryActionButton()
    private var postImage = PostImages(frame: .zero)
    private var separator: UIView!

    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))
        
        userPostView.delegate = self
        actionButtonsView.delegate = self
        
        separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = separatorColor
        
        addSubviews(userPostView, postTextView, postImage, actionButtonsView, separator)

        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 50),
            
            postImage.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            postImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 55),
            postImage.widthAnchor.constraint(equalToConstant: frame.width - 65),
            
            postTextView.topAnchor.constraint(equalTo: postImage.bottomAnchor, constant: 10),
            postTextView.leadingAnchor.constraint(equalTo: postImage.leadingAnchor),
            postTextView.trailingAnchor.constraint(equalTo: postImage.trailingAnchor),
            
            actionButtonsView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 3),
            actionButtonsView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 30),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),

            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        postTextView.textContainer.lineBreakMode = .byTruncatingTail
        postImage.zoomDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        postImage.kind = viewModel.kind
        userPostView.postTimeLabel.text = viewModel.time
        userPostView.privacyImage.configuration?.image = viewModel.privacyImage.withTintColor(.label)
        userPostView.dotButton.menu = addMenuItems()
        userPostView.timestampLabel.text = viewModel.timestamp
        userPostView.set(isEdited: viewModel.edited, hasReference: viewModel.reference != nil)
        
        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsValue
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        let font: UIFont = .systemFont(ofSize: 15, weight: .regular)

        postTextView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        postTextView.addGestureRecognizer(gestureRecognizer)
        
        let fitText = viewModel.postText.substringToFit(size: CGSize(width: frame.width - 65, height: CGFloat(postTextView.textContainer.maximumNumberOfLines) * font.lineHeight), font: font)
        
        if fitText == viewModel.postText {
            postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText.appending(" "), attributes: [.font: font, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
            _ = postTextView.hashtags()
        } else {

            var text = fitText.trimmingCharacters(in: .whitespacesAndNewlines)

            if let last = text.last {
                if last == "." {
                    text.append("..")
                } else if last != "…" {
                    text.append("...")
                }
               
                postTextView.attributedText = NSMutableAttributedString(string: text, attributes: [.font: font, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
            } else {
                postTextView.attributedText = NSMutableAttributedString(string: text, attributes: [.font: font, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
            }

            _ = postTextView.hashtags()
        }

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
                if hashtag.hasPrefix("hash:") {
                    delegate?.cell(wantsToSeeHashtag: hashtag)
                } else {
                    delegate?.cell(showURL: hashtag)
                }
            } else {
                didTapPost()
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



