//
//  PostTextImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/23.
//

import UIKit

class PostTextImageExpandedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }

    private var user: User?
    weak var delegate: PostCellDelegate?
    private var buttonTopConstraint: NSLayoutConstraint!
    private var userPostView = PrimaryUserView()
    var postTextView = ExtendedTextView()

    var actionButtonsView = PrimaryActionButton()
    private var postImage = PostImages(frame: .zero)
    private var contentTimestamp = ContentTimestampView()
    private var revisionView = ContentRevisionView()
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
        separator.backgroundColor = K.Colors.separatorColor

        buttonTopConstraint = actionButtonsView.topAnchor.constraint(equalTo: revisionView.bottomAnchor)
        
        addSubviews(userPostView, postTextView, postImage, revisionView, contentTimestamp, actionButtonsView, separator)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
           
            postTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 15),
            postTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Content.horizontalPadding),
            postTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Content.horizontalPadding),

            postImage.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            postImage.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            postImage.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
            
            contentTimestamp.topAnchor.constraint(equalTo: postImage.bottomAnchor),
            contentTimestamp.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            contentTimestamp.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),

            revisionView.topAnchor.constraint(equalTo: contentTimestamp.bottomAnchor),
            revisionView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            revisionView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
           
            buttonTopConstraint,
            actionButtonsView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor, constant: 20),
            actionButtonsView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor, constant: -20),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        postImage.zoomDelegate = self
        revisionView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel, let font = postTextView.font else { return }
        
        postImage.kind = viewModel.kind

        userPostView.dotButton.menu = addMenuItems()
        userPostView.timestampLabel.text = viewModel.timestamp
        userPostView.set(isEdited: viewModel.edited, hasReference: viewModel.reference != nil)
       
        actionButtonsView.likesLabel.text = viewModel.likesText
        actionButtonsView.commentLabel.text = viewModel.commentsValue
        
        actionButtonsView.likeButton.configuration?.image = viewModel.likeImage
        actionButtonsView.bookmarkButton.configuration?.image = viewModel.bookMarkImage
        
        revisionView.reference = viewModel.reference
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 4
        
        postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText.appending(" "), attributes: [.font: font, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])

        contentTimestamp.set(timestamp: viewModel.detailedPost)
        
        if viewModel.reference == nil {
            buttonTopConstraint.constant = -20
            revisionView.isHidden = true
        } else {
            buttonTopConstraint.constant = 0
            revisionView.isHidden = false
        }
        
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
                if hashtag.hasPrefix("hash:") {
                    delegate?.cell(wantsToSeeHashtag: hashtag)
                } else {
                    delegate?.cell(showURL: hashtag)
                }
            } else {
                postTextView.selectedTextRange = nil
            }
        }
    }
    
    @objc func didTapPost() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, wantsToSeePost: viewModel.post, withAuthor: user)
    }
}

extension PostTextImageExpandedCell: PrimaryUserViewDelegate {
   
    func didTapProfile() {
        guard let user = user, user.phase == .verified else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
    }
}

extension PostTextImageExpandedCell: PrimaryActionButtonDelegate {
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

extension PostTextImageExpandedCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension PostTextImageExpandedCell: PostImagesDelegate {
    
    func zoomImage(_ image: UIImageView) {
        guard let _ = image.image else { return }
        delegate?.cell(self, didTapImage: image)
    }
}

extension PostTextImageExpandedCell: ContentRevisionViewDelegate {
    func didTapRevisions() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(didTapMenuOptionsFor: viewModel.post, option: .reference)
    }
}

extension PostTextImageExpandedCell: HomeCellProtocol { }



