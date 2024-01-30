//
//  PostLinkExpandedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/12/23.
//

import UIKit
import LinkPresentation
import UniformTypeIdentifiers

class PostLinkExpandedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }

    private var user: User?
    
    weak var delegate: PostCellDelegate?
    private var userPostView = PrimaryUserView()
    private var referenceHeightAnchor: NSLayoutConstraint!
    var postTextView = ExtendedTextView()
    var actionButtonsView = PrimaryActionButton()
    private var contentTimestamp = ContentTimestampView()
    private var revisionView = ContentRevisionView()
    private var linkView = LinkView()
    private var separator: UIView!
    
    // MARK: - Lifecycle
    
    override init (frame: CGRect) {
        super.init(frame: frame)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))

        userPostView.delegate = self
        actionButtonsView.delegate = self
        
        separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = separatorColor
        
        referenceHeightAnchor = revisionView.heightAnchor.constraint(equalToConstant: 0)
        referenceHeightAnchor.isActive = true
        
        let textPadding: CGFloat = UIDevice.isPad ? 65 : 55
        
        let linkWidth: CGFloat = frame.width - (textPadding + 10)
        let linkSize: CGFloat = linkWidth * 0.78
        
        backgroundColor = .systemBackground
        addSubviews(userPostView, postTextView, linkView, revisionView, contentTimestamp, actionButtonsView, separator)
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userPostView.heightAnchor.constraint(equalToConstant: 50),
            
            postTextView.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 15),
            postTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            linkView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 10),
            linkView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            linkView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor),
            linkView.heightAnchor.constraint(equalToConstant: linkSize),
            
            contentTimestamp.topAnchor.constraint(equalTo: linkView.bottomAnchor),
            contentTimestamp.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentTimestamp.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            //contentTimestamp.heightAnchor.constraint(equalToConstant: 40),
            
            referenceHeightAnchor,
            revisionView.topAnchor.constraint(equalTo: contentTimestamp.bottomAnchor),
            revisionView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor),
            revisionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
           
            actionButtonsView.topAnchor.constraint(equalTo: contentTimestamp.bottomAnchor),
            actionButtonsView.leadingAnchor.constraint(equalTo: postTextView.leadingAnchor, constant: 20),
            actionButtonsView.trailingAnchor.constraint(equalTo: postTextView.trailingAnchor, constant: -20),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 40),
            actionButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),

            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])

        linkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLinkTap)))
        revisionView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    func configure() {
        guard let viewModel = viewModel, let font = postTextView.font else { return }
       
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
        
        contentTimestamp.set(timestamp: viewModel.detailedPost)
        
        if viewModel.reference == nil {
            referenceHeightAnchor.constant = 0
            revisionView.isHidden = true
        } else {
            revisionView.isHidden = false
            referenceHeightAnchor.constant = 40
        }
        
        postTextView.attributedText = NSMutableAttributedString(string: viewModel.postText.appending(" "), attributes: [.font: font, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        
        postTextView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        postTextView.addGestureRecognizer(gestureRecognizer)
        _ = postTextView.hashtags()
        
        if let link = viewModel.linkUrl {
            linkView.configure(withLink: link)
            
        }
    }

    func set(user: User) {
        self.user = user
        userPostView.set(user: user)
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel, let delegate = delegate else { return nil }
        if let menu = UIMenu.createPostMenu(self, for: viewModel, delegate: delegate) {
            userPostView.dotButton.showsMenuAsPrimaryAction = true
            return menu
        }
        return nil
    }
    
    @objc func didTapPost() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.cell(self, wantsToSeePost: viewModel.post, withAuthor: user)
    }
    
    @objc func handleLinkTap() {
        guard let viewModel = viewModel, let link = viewModel.linkUrl else { return }
        delegate?.cell(showURL: link)
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
}

extension PostLinkExpandedCell: PrimaryUserViewDelegate {
    
    func didTapProfile() {
        guard let user = user else { return }
        delegate?.cell(self, wantsToShowProfileFor: user)
    }
}

extension PostLinkExpandedCell: PrimaryActionButtonDelegate {
    
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
    
    func handleShowLikes() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(wantsToSeeLikesFor: viewModel.post)
    }
}

extension PostLinkExpandedCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension PostLinkExpandedCell: ContentRevisionViewDelegate {
    func didTapRevisions() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(didTapMenuOptionsFor: viewModel.post, option: .reference)
    }
}

extension PostLinkExpandedCell: HomeCellProtocol { }
