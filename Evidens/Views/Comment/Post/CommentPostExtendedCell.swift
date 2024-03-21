//
//  CommentPostExtendedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/1/24.
//

import UIKit

class CommentPostExtendedCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: CommentViewModel? {
        didSet {
            configure()
        }
    }
    
    private var user: User?
    private var contentTopConstraint: NSLayoutConstraint!
    weak var delegate: CommentCellDelegate?
    
    private var userPostView = PrimaryUserView()
   
    private let authorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintAdjustmentMode = .normal
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = K.Colors.primaryColor
        config.baseForegroundColor = .white
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 12.0, scaleStyle: .title3, weight: .medium)
       
        config.attributedTitle = AttributedString(AppStrings.Content.Reply.author, attributes: container)
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        button.configuration = config
        
        return button
    }()
    
    let commentTextView = SecondaryTextView()
    
    var commentActionButtons = CommentActionButtonView()

    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubviews(userPostView, authorButton, commentTextView, commentActionButtons, separatorView)

        contentTopConstraint = commentTextView.topAnchor.constraint(equalTo: authorButton.bottomAnchor)
        let commentPadding: CGFloat = UIDevice.isPad ? 65 : 55
        
        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            authorButton.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 5),
            authorButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: commentPadding),

            contentTopConstraint,
            commentTextView.leadingAnchor.constraint(equalTo: authorButton.leadingAnchor),
            commentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            commentActionButtons.topAnchor.constraint(equalTo: commentTextView.bottomAnchor),
            commentActionButtons.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentActionButtons.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentActionButtons.bottomAnchor.constraint(equalTo: bottomAnchor),

            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        commentActionButtons.delegate = self
        commentActionButtons.ownerPostImageView.removeFromSuperview()
        userPostView.delegate = self
        commentTextView.textContainer.maximumNumberOfLines = 0
        commentTextView.delegate = self
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapComment)))

    }
    
    @objc func didTapComment() {
        guard let viewModel = viewModel else { return }
        delegate?.wantsToSeeRepliesFor(self, forComment: viewModel.comment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        let font = UIFont.addFont(size: 17.0, scaleStyle: .title2, weight: .regular)
        
        userPostView.dotButton.menu = addMenuItems()
        userPostView.timestampLabel.text = viewModel.time
        userPostView.set(isEdited: false, hasReference: false)
        
        commentActionButtons.likeButton.configuration?.image = viewModel.likeImage
        commentActionButtons.likesLabel.text = viewModel.likesText
        commentActionButtons.commentsLabel.text = viewModel.numberOfCommentsText

        commentTextView.attributedText = NSMutableAttributedString(string: viewModel.content, attributes: [.font: font, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        commentTextView.isSelectable = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        commentTextView.addGestureRecognizer(gestureRecognizer)
        
        (_, _) = commentTextView.hashtags()
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        userPostView.set(user: user)

         if viewModel.isAuthor {
             contentTopConstraint.constant = 5
             authorButton.isHidden = false
         } else {
             contentTopConstraint.constant = -25
             authorButton.isHidden = true
         }
         
        layoutIfNeeded()
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        userPostView.dotButton.showsMenuAsPrimaryAction = true
        
        if viewModel.uid == uid {
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: CommentMenu.edit.title, image: CommentMenu.edit.image, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.didTapComment(strongSelf, forComment: viewModel.comment, action: .edit)
                }),
                UIAction(title: CommentMenu.delete.title, image: CommentMenu.delete.image, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.didTapComment(strongSelf, forComment: viewModel.comment, action: .delete)
                }),
                UIAction(title: CommentMenu.back.title, image: CommentMenu.back.image, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.didTapComment(strongSelf, forComment: viewModel.comment, action: .back)
                })
            ])
            return menuItems
        } else {
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: CommentMenu.report.title, image: CommentMenu.report.image, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.didTapComment(strongSelf, forComment: viewModel.comment, action: .report)
                }),
                UIAction(title: CommentMenu.back.title, image: CommentMenu.back.image, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.didTapComment(strongSelf, forComment: viewModel.comment, action: .back)
                })
            ])
            return menuItems
        }
    }
    
    @objc func handleSeeMore() {
        guard let viewModel = viewModel else { return }
        delegate?.wantsToSeeRepliesFor(self, forComment: viewModel.comment)
    }
    
    @objc func handleTextViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: commentTextView)
        let position = commentTextView.closestPosition(to: location)!

        if let range = commentTextView.tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: .layout(.left)) {
            let startIndex = commentTextView.offset(from: commentTextView.beginningOfDocument, to: range.start)
           
            let attributes = commentTextView.attributedText.attributes(at: startIndex, effectiveRange: nil)
            
            if attributes.keys.contains(.link), let hashtag = attributes[.link] as? String {
                if hashtag.hasPrefix("hash:") {
                    delegate?.didTapHashtag(hashtag)
                }
            } else {
                commentTextView.selectedTextRange = nil
            }
        }
    }
}

extension CommentPostExtendedCell: CommentActionButtonViewDelegate {
    
    func wantsToSeeReplies() {
        guard let viewModel = viewModel else { return }
        delegate?.wantsToSeeRepliesFor(self, forComment: viewModel.comment)
    }
    
    func handleLike() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapLikeActionFor(self, forComment: viewModel.comment)
    }
}

extension CommentPostExtendedCell: PrimaryUserViewDelegate {

    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, user.phase == .verified else { return }
        if viewModel.anonymous { return } else {
            delegate?.didTapProfile(forUser: user)
        }
    }
}

extension CommentPostExtendedCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}

extension CommentPostExtendedCell: CommentPostProtocol { }
