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
    
    private var heightAuthorAnchor: NSLayoutConstraint!
    private var heightActionsConstraint: NSLayoutConstraint!
    
    weak var delegate: CommentCellDelegate?
    
    private var userPostView = PrimaryUserView()
   
    private let authorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = primaryColor
        config.baseForegroundColor = .white
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 12.0, scaleStyle: .title3, weight: .medium)
       
        config.attributedTitle = AttributedString(AppStrings.Content.Reply.author, attributes: container)
        config.cornerStyle = .capsule
        
        button.configuration = config
        
        return button
    }()
    
    let commentTextView = SecondaryTextView()
    
    var commentActionButtons = CommentActionButtonView()

    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubviews(userPostView, authorButton, commentTextView, commentActionButtons, separatorView)

        heightAuthorAnchor = authorButton.heightAnchor.constraint(equalToConstant: 0)
        heightAuthorAnchor.isActive = true
        heightActionsConstraint = commentActionButtons.heightAnchor.constraint(equalToConstant: 40)
        heightActionsConstraint.isActive = true

        NSLayoutConstraint.activate([
            userPostView.topAnchor.constraint(equalTo: topAnchor),
            userPostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userPostView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            authorButton.topAnchor.constraint(equalTo: userPostView.bottomAnchor, constant: 3),
            authorButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 55),

            commentTextView.topAnchor.constraint(equalTo: authorButton.bottomAnchor, constant: 3),
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
        commentActionButtons.likeButton.configuration?.image = viewModel.likeImage
        commentActionButtons.likesLabel.text = viewModel.likesText
        commentActionButtons.commentsLabel.text = viewModel.numberOfCommentsText

        commentTextView.attributedText = NSMutableAttributedString(string: viewModel.content, attributes: [.font: font, .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle])
        commentTextView.isSelectable = true
    }
    
    func set(user: User) {
        
        guard let viewModel = viewModel else { return }
        self.user = user
        userPostView.set(user: user)
       
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
        
        layoutIfNeeded()
    }
    
    private func addMenuItems() -> UIMenu? {
        guard let viewModel = viewModel else { return nil }
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        userPostView.dotButton.showsMenuAsPrimaryAction = true
        
        if viewModel.uid == uid {
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
    
    @objc func handleSeeMore() {
        guard let viewModel = viewModel else { return }
        delegate?.wantsToSeeRepliesFor(self, forComment: viewModel.comment)
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
        guard let viewModel = viewModel, let user = user else { return }
        if viewModel.anonymous { return } else {
            delegate?.didTapProfile(forUser: user)
        }
    }
}

extension CommentPostExtendedCell: CommentPostProtocol { }
