//
//  CommentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/11/21.
//

import UIKit
import SDWebImage

protocol CommentCellDelegate: AnyObject {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: Comment.CommentOptions)
    func didTapProfile(forUser user: User)
    func wantsToSeeRepliesFor(_ cell: UICollectionViewCell, forComment comment: Comment)
    func didTapLikeActionFor(_ cell: UICollectionViewCell, forComment comment: Comment)
}

class CommentCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: CommentViewModel? {
        didSet {
            configure()
        }
    }
    
    private var user: User?
    private var heightAuthorAnchor: NSLayoutConstraint!
    private var heightActionsConstraint: NSLayoutConstraint!
    var showingRepliesForComment: Bool = false
    var isReply: Bool = false

    weak var delegate: CommentCellDelegate?
    
    private let cellContentView = UIView()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "user.profile")
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfile)))
        return iv
    }()
    
    lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = separatorColor
        button.configuration?.cornerStyle = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    var timestampLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var authorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = primaryColor
        button.layer.cornerRadius = 5
        button.isHidden = true
        let title = NSMutableAttributedString(string: "   Author   ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        button.setAttributedTitle(title, for: .normal)
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let commentTextView = MEPostTextView()
    
    let showMoreView = MEShowMoreView()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var commentActionButtons = MECommentActionButtons()

    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let ownerLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    var ownerPostImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        cellContentView.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(profileImageView, dotsImageButton, commentTextView, authorButton, timestampLabel, nameLabel, professionLabel, commentActionButtons, separatorView)

        heightAuthorAnchor = authorButton.heightAnchor.constraint(equalToConstant: 0)
        heightAuthorAnchor.isActive = true
        heightActionsConstraint = commentActionButtons.heightAnchor.constraint(equalToConstant: 40)
        heightActionsConstraint.isActive = true

        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timestampLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 53),
            profileImageView.widthAnchor.constraint(equalToConstant: 53),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor),
            
            timestampLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 15),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 15),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            professionLabel.trailingAnchor.constraint(equalTo: dotsImageButton.trailingAnchor),
            
            authorButton.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 2),
            authorButton.leadingAnchor.constraint(equalTo: professionLabel.leadingAnchor),
            //authorButton.heightAnchor.constraint(equalToConstant: 18),
            //authorButton.widthAnchor.constraint(equalToConstant: 50),
            
            commentTextView.topAnchor.constraint(equalTo: authorButton.bottomAnchor, constant: 2),
            commentTextView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            commentTextView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            //commentLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -30),
            
            commentActionButtons.topAnchor.constraint(equalTo: commentTextView.bottomAnchor),
            commentActionButtons.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            commentActionButtons.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            //commentActionButtons.heightAnchor.constraint(equalToConstant: 40),
            commentActionButtons.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),

            
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
        
        commentActionButtons.delegate = self

        profileImageView.layer.cornerRadius = 53 / 2
        
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
        guard let viewModel = viewModel else {
            return }

        timestampLabel.text = AppStrings.Characters.dot + viewModel.timestampString!
        dotsImageButton.menu = addMenuItems()
        
        commentActionButtons.likeButton.configuration?.image = viewModel.likeButtonImage
        commentActionButtons.likesLabel.text = viewModel.likesLabelText
        commentActionButtons.commentsLabel.text = viewModel.commentsText

        commentTextView.attributedText = NSMutableAttributedString(string: viewModel.commentText, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        
        ownerLineView.isHidden = true
        print(viewModel.comment.visible)
        
        if showingRepliesForComment {
            commentTextView.textContainer.maximumNumberOfLines = 0
            commentActionButtons.ownerPostImageView.removeFromSuperview()
            return
        } else {
            commentTextView.textContainer.maximumNumberOfLines = 4
            
            if viewModel.hasCommentFromAuthor {
                addSubviews(ownerLineView, ownerPostImageView)
                ownerLineView.isHidden = false

                NSLayoutConstraint.activate([
                    ownerLineView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
                    ownerLineView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
                    ownerLineView.widthAnchor.constraint(equalToConstant: 2),
                    ownerLineView.bottomAnchor.constraint(equalTo: commentActionButtons.topAnchor, constant: 2),
                    
                    ownerPostImageView.topAnchor.constraint(equalTo: commentActionButtons.topAnchor, constant: 5),
                    ownerPostImageView.centerXAnchor.constraint(equalTo: ownerLineView.centerXAnchor),
                    ownerPostImageView.heightAnchor.constraint(equalToConstant: 27),
                    ownerPostImageView.widthAnchor.constraint(equalToConstant: 27)
                ])
                
                ownerPostImageView.layer.cornerRadius = 27 / 2

                ownerLineView.layer.cornerRadius = 2/2
            } else {
                ownerLineView.removeFromSuperview()
                ownerPostImageView.removeFromSuperview()
                ownerLineView.isHidden = true
                ownerPostImageView.isHidden = true
            }
        }
        
        if isReply {
            commentActionButtons.commentButton.isHidden = true
        } else {
            commentActionButtons.commentButton.isHidden = false
        }
        
        /*
        if viewModel.isTextFromAuthor {
            commentTextView.textContainer.maximumNumberOfLines = 0
            commentTextView.isSelectable = true
            commentActionButtons.isHidden = true
            heightActionsConstraint.constant = 10
            heightActionsConstraint.isActive = true
        } else {
            commentTextView.textContainer.maximumNumberOfLines = 4
            commentTextView.isSelectable = false
            commentActionButtons.isHidden = false
            heightActionsConstraint.constant = 40
            heightActionsConstraint.isActive = true
        }
         */

        let showMoreSize = 100.0
        
        showMoreView.isHidden = true
        
        let layoutManager = commentTextView.layoutManager
        let textContainer = commentTextView.textContainer
        layoutManager.ensureLayout(for: textContainer)
        
        if commentTextView.isTextTruncated /*&& !viewModel.isTextFromAuthor*/ {
            addSubview(showMoreView)
            showMoreView.isHidden = false

            showMoreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSeeMore)))
            NSLayoutConstraint.activate([
                showMoreView.heightAnchor.constraint(equalToConstant: commentTextView.font?.lineHeight ?? 0.0),
                showMoreView.bottomAnchor.constraint(equalTo: commentTextView.bottomAnchor),
                showMoreView.trailingAnchor.constraint(equalTo: commentTextView.trailingAnchor),
                showMoreView.widthAnchor.constraint(equalToConstant: showMoreSize),
            ])

                let firstLines = self.commentTextView.getFirstLinesText(3)!
                let lastLine = self.commentTextView.getLastLineText(3)!
            let lastLineFits = lastLine.getSubstringThatFitsWidth(width: UIScreen.main.bounds.width - showMoreSize - 80, font: UIFont.systemFont(ofSize: 15, weight: .regular))
             
                self.commentTextView.attributedText = NSMutableAttributedString(string: firstLines.appending(lastLineFits) , attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
                self.showMoreView.isHidden = false
        } else {
            commentTextView.attributedText = NSMutableAttributedString(string: viewModel.commentText, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])

            showMoreView.removeFromSuperview()
            showMoreView.isHidden = true
        }
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        let attributedString = NSMutableAttributedString(string: "Anonymous", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        
        nameLabel.attributedText = viewModel.anonymous ? attributedString : user.userLabelText()
        professionLabel.text = user.profession! + ", " + user.speciality!
        
        if viewModel.anonymous {
            profileImageView.image = UIImage(named: "user.profile.privacy")
        } else {
            if let imageUrl = user.profileImageUrl, imageUrl != "" {
                profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
        }
        
        if viewModel.isAuthor {
            authorButton.isHidden = false
            heightAuthorAnchor.isActive = false
            heightAuthorAnchor = authorButton.heightAnchor.constraint(equalToConstant: 20)
            heightAuthorAnchor.isActive = true
            
        } else {
            authorButton.isHidden = true
            heightAuthorAnchor.isActive = false
            heightAuthorAnchor = authorButton.heightAnchor.constraint(equalToConstant: 0)
            heightAuthorAnchor.isActive = true
        }
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        dotsImageButton.showsMenuAsPrimaryAction = true
        
        if viewModel.commentOnwerUid == uid {
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Comment.CommentOptions.delete.rawValue, image: Comment.CommentOptions.delete.commentOptionsImage, handler: { _ in
                    self.delegate?.didTapComment(self, forComment: viewModel.comment, action: .delete)
                })])
            return menuItems
        } else {
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Comment.CommentOptions.report.rawValue, image: Comment.CommentOptions.report.commentOptionsImage, handler: { _ in
                    self.delegate?.didTapComment(self, forComment: viewModel.comment, action: .report)
                })])
            return menuItems
        }
    }
    
    @objc func didTapProfile() {
        guard let viewModel = viewModel, let user = user else { return }
        if viewModel.anonymous { return } else {
            delegate?.didTapProfile(forUser: user)
        }
    }
    
    @objc func handleSeeMore() {
        guard let viewModel = viewModel, let user = user else { return }
        delegate?.wantsToSeeRepliesFor(self, forComment: viewModel.comment)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

extension CommentCell: MECommentActionButtonsDelegate {
    func wantsToSeeReplies() {
        guard let viewModel = viewModel else { return }
        delegate?.wantsToSeeRepliesFor(self, forComment: viewModel.comment)
    }
    
    func handleLike() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapLikeActionFor(self, forComment: viewModel.comment)
    }
}
