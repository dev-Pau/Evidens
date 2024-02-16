//
//  CommentCaseExpandedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/1/24.
//

import UIKit
import SDWebImage

class CommentCaseExpandedCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: CommentViewModel? {
        didSet {
            configure()
        }
    }
    
    private var user: User?
    
    weak var delegate: CommentCellDelegate?
    private var contentTopConstraint: NSLayoutConstraint!
    private var userPostView = PrimaryUserView()
   
    private let authorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintAdjustmentMode = .normal
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = primaryColor
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
        view.backgroundColor = separatorColor
        return view
    }()
    
    //MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        contentTopConstraint = commentTextView.topAnchor.constraint(equalTo: authorButton.bottomAnchor)
        
        addSubviews(userPostView, commentTextView, authorButton, commentActionButtons, separatorView)
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
    
    func set(user: User? = nil) {
        guard let viewModel = viewModel else { return }
        self.user = user
        
        switch viewModel.visible {
        case .regular:
            guard let user = self.user else { return }
            userPostView.set(user: user)
        case .anonymous:
            userPostView.anonymize()
        case .deleted:
            fatalError()
        }
       
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
}

extension CommentCaseExpandedCell: CommentActionButtonViewDelegate {
    func wantsToSeeReplies() {
        guard let viewModel = viewModel else { return }
        delegate?.wantsToSeeRepliesFor(self, forComment: viewModel.comment)
    }
    
    func handleLike() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapLikeActionFor(self, forComment: viewModel.comment)
    }
}

extension CommentCaseExpandedCell: PrimaryUserViewDelegate {
 
    func didTapProfile() {
        guard let viewModel = viewModel, let user = user, user.phase == .verified else { return }
        if viewModel.anonymous { return } else {
            delegate?.didTapProfile(forUser: user)
        }
    }
}

extension CommentCaseExpandedCell: CommentCaseProtocol { }
