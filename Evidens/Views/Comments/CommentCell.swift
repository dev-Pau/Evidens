//
//  CommentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/11/21.
//

import UIKit
import SDWebImage

protocol CommentCellDelegate: AnyObject {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment, action: CommentMenu)
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
    
    private lazy var profileImageView = ProfileImageView(frame: .zero)
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.ellipsis)
        button.configuration?.baseForegroundColor = separatorColor
        button.configuration?.cornerStyle = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = primaryColor
        config.baseForegroundColor = .white
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .medium)
        config.attributedTitle = AttributedString(AppStrings.Content.Reply.author, attributes: container)
        config.cornerStyle = .medium
        
        button.configuration = config

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
        label.textColor = .label
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
            dotsImageButton.heightAnchor.constraint(equalToConstant: 20),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 20),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            professionLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            
            authorButton.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 2),
            authorButton.leadingAnchor.constraint(equalTo: professionLabel.leadingAnchor),

            commentTextView.topAnchor.constraint(equalTo: authorButton.bottomAnchor, constant: 2),
            commentTextView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            commentTextView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),

            commentActionButtons.topAnchor.constraint(equalTo: commentTextView.bottomAnchor),
            commentActionButtons.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            commentActionButtons.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
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
        guard let viewModel = viewModel else { return }

        timestampLabel.text = AppStrings.Characters.dot + viewModel.timestampString!
        dotsImageButton.menu = addMenuItems()
        
        commentActionButtons.likeButton.configuration?.image = viewModel.likeButtonImage
        commentActionButtons.likesLabel.text = viewModel.likesLabelText
        commentActionButtons.commentsLabel.text = viewModel.commentsText

        commentTextView.attributedText = NSMutableAttributedString(string: viewModel.commentText, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.label])
        
        ownerLineView.isHidden = true
        
        if showingRepliesForComment {
            commentTextView.textContainer.maximumNumberOfLines = 0
            commentActionButtons.ownerPostImageView.removeFromSuperview()
            return
        } else {
            commentTextView.textContainer.maximumNumberOfLines = 7
            
            if viewModel.hasCommentFromAuthor {
                
                addSubviews(ownerLineView, ownerPostImageView)
                ownerLineView.isHidden = false
                ownerPostImageView.isHidden = false
                
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
        
    }
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        
         nameLabel.text = viewModel.anonymous ? AppStrings.Content.Case.Privacy.anonymousTitle : user.name()
         professionLabel.text = user.details()
         
        if viewModel.anonymous {
            profileImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
        } else {
            if let imageUrl = user.profileUrl, imageUrl != "" {
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
        
        if viewModel.hasCommentFromAuthor {
            if viewModel.visible == .anonymous {
                ownerPostImageView.image = UIImage(named: AppStrings.Assets.privacyProfile)
            } else {
                if let image = user.profileUrl, image != "" {
                    ownerPostImageView.sd_setImage(with: URL(string: image))
                }
            }
        } else {
            commentActionButtons.ownerPostImageView.isHidden = true
        }
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        dotsImageButton.showsMenuAsPrimaryAction = true
        
        if viewModel.commentOnwerUid == uid {
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: CommentMenu.delete.title, image: CommentMenu.delete.image, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.didTapComment(strongSelf, forComment: viewModel.comment, action: .delete)
                })])
            return menuItems
        } else {
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: CommentMenu.report.title, image: CommentMenu.report.image, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.didTapComment(strongSelf, forComment: viewModel.comment, action: .report)
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
        guard let viewModel = viewModel else { return }
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
