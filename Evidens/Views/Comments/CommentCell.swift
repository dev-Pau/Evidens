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
}

class CommentCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: CommentViewModel? {
        didSet { configure() }
    }
    
    private var user: User?
    
    private var timeLabelLeadingConstraint: NSLayoutConstraint!
    
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
        button.configuration?.baseForegroundColor = .label
        button.configuration?.cornerStyle = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    var timestampLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.sizeToFit()
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
        let title = NSMutableAttributedString(string: "Author", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        button.setAttributedTitle(title, for: .normal)
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
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
        cellContentView.addSubviews(profileImageView, dotsImageButton, commentLabel, authorButton, timestampLabel, nameLabel, professionLabel, separatorView)
        
        //timeLabelLeadingConstraint = timestampLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10)
        //timeLabelLeadingConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 15),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 15),
            
            timestampLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
            //timeStampLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
           
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor, constant: -5),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            professionLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor, constant: -5),
            
            authorButton.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 2),
            authorButton.leadingAnchor.constraint(equalTo: professionLabel.leadingAnchor),
            authorButton.heightAnchor.constraint(equalToConstant: 18),
            authorButton.widthAnchor.constraint(equalToConstant: 50),
            
            commentLabel.topAnchor.constraint(equalTo: authorButton.bottomAnchor, constant: 10),
            commentLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            commentLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            commentLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            
            //separatorView.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 3),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 40 / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    //MARK: - Helpers
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        commentLabel.text = viewModel.commentText
        timestampLabel.text = viewModel.timestampString
        //dotsImageButton.isHidden = viewModel.isTextFromAuthor ? true : false
        dotsImageButton.menu = addMenuItems()
        
        /*
        if viewModel.isTextFromAuthor {
            dotsImageButton.isHidden = true
            //timeLabelLeadingConstraint = timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            //timeLabelLeadingConstraint.isActive = true
            //layoutIfNeeded()
        } else {
            dotsImageButton.isHidden = false
            //timeLabelLeadingConstraint = timestampLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10)
            //timeLabelLeadingConstraint.isActive = true
            //layoutIfNeeded()
        }
         */
    }
    
    
    func set(user: User) {
        guard let viewModel = viewModel else { return }
        self.user = user
        let attributedString = NSMutableAttributedString(string: "Anonymous", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        nameLabel.attributedText = viewModel.anonymousComment ? attributedString : user.userLabelText()
        professionLabel.text = user.profession! + ", " + user.speciality!
        
        if viewModel.anonymousComment {
            profileImageView.image = UIImage(named: "user.profile.privacy")
        } else {
            if let imageUrl = user.profileImageUrl, imageUrl != "" {
                profileImageView.sd_setImage(with: URL(string: imageUrl))
            }
        }
        
        if viewModel.isAuthor {
            authorButton.isHidden = false
            
        } else {
            authorButton.isHidden = true
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
        
        
        
        /*
        if viewModel.isTextFromAuthor {
            let menuItems = UIMenu(options: .displayInline, children: [
                UIAction(title: Comment.CommentOptions.back.rawValue, image: Comment.CommentOptions.back.commentOptionsImage, handler: { _ in
                    self.delegate?.didTapComment(self, forComment: viewModel.comment, action: .back)
                })])
            return menuItems
        } else if viewModel.isAuthor {
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
         */
    }
    
    @objc func didTapProfile() {
        guard let viewModel = viewModel, let user = user else { return }
        if viewModel.anonymousComment { return } else {
            delegate?.didTapProfile(forUser: user)
        }
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
