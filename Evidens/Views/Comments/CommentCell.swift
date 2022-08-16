//
//  CommentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/11/21.
//

import UIKit
import SDWebImage

protocol CommentCellDelegate: AnyObject {
    func didTapComment(_ cell: UICollectionViewCell, forComment comment: Comment)
}

class CommentCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: CommentViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: CommentCellDelegate?
    
    var ownerUid: String = ""
    
    private let cellContentView = UIView()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = lightColor
        return iv
    }()
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = grayColor
        button.configuration?.cornerStyle = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleThreeDots), for: .touchUpInside)
        return button
    }()
    
    private let timeStampLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.textAlignment = .right
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorButton: UIButton = {
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
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lightGrayColor
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        cellContentView.addSubviews(profileImageView, dotsImageButton, commentLabel, authorButton, timeStampLabel, nameLabel, professionLabel, separatorView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 15),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 15),
            
            timeStampLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            timeStampLabel.trailingAnchor.constraint(equalTo: dotsImageButton.leadingAnchor, constant: -10),
           
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: timeStampLabel.leadingAnchor, constant: -5),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            professionLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            professionLabel.trailingAnchor.constraint(equalTo: timeStampLabel.leadingAnchor, constant: -5),
            
            authorButton.topAnchor.constraint(equalTo: professionLabel.bottomAnchor),
            authorButton.leadingAnchor.constraint(equalTo: professionLabel.leadingAnchor),
            authorButton.heightAnchor.constraint(equalToConstant: 18),
            authorButton.widthAnchor.constraint(equalToConstant: 50),
            
            commentLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            commentLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            commentLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            //commentLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
            
            separatorView.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 3),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
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

        if viewModel.anonymousComment {
            profileImageView.image = UIImage(systemName: "hand.raised.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        } else {
            profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        }
        
        if ownerUid == viewModel.commentOnwerUid {
            // Comment from the owner of the case
            authorButton.isHidden = false
        }
        //authorButton.isHidden = viewModel.comment.uid == user.isCurrentUser
        
        commentLabel.text = viewModel.commentText
        nameLabel.attributedText = viewModel.userLabelText()
        timeStampLabel.text = viewModel.timestampString
        professionLabel.text = viewModel.profession + " · " + viewModel.speciality
    }
    
    @objc func handleThreeDots() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapComment(self, forComment: viewModel.comment)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 15))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
