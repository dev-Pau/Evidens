//
//  DeletedCommentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/23.
//

import UIKit

protocol DeletedCommentCellDelegate: AnyObject {
    func didTapReplies(_ cell: UICollectionViewCell, forComment comment: Comment)
    func didTapLearnMore()
}

class DeletedCommentCell: UICollectionViewCell {
    
    var viewModel: CommentViewModel? {
        didSet {
            configureWithComment()
        }
    }
    weak var delegate: DeletedCommentCellDelegate?
    
    private let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 7
        view.layer.borderWidth = 0.4
        view.layer.borderColor = separatorColor.cgColor
        view.backgroundColor = .quaternarySystemFill.withAlphaComponent(0.1)
        return view
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var help: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = primaryColor
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSeeMore)))
        return label
    }()
    
    private let replies: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: 0)
        label.numberOfLines = 1
        return label
    }()
    
    private let line: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(bgView, title, help, replies, line)
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            title.bottomAnchor.constraint(equalTo: bgView.centerYAnchor, constant: -1),
            title.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10),
            
            help.topAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 1),
            help.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            
            replies.leadingAnchor.constraint(equalTo: help.trailingAnchor, constant: 10),
            replies.centerYAnchor.constraint(equalTo: help.centerYAnchor),
            
            line.bottomAnchor.constraint(equalTo: bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.4),
            line.leadingAnchor.constraint(equalTo: leadingAnchor),
            line.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        title.text = AppStrings.Content.Comment.deleted
        help.text = AppStrings.Content.Empty.learn
        replies.text = AppStrings.Title.replies
        replies.isHidden = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSeeReplies)))
    }
    
    private func configureWithComment() {
        guard let viewModel = viewModel else { return }
        replies.isHidden = viewModel.numberOfComments > 0 ? false : true
    }
                             
    @objc func handleSeeReplies() {
        guard let viewModel = viewModel else { return }
        delegate?.didTapReplies(self, forComment: viewModel.comment)
    }
    
    @objc func handleSeeMore() {
        delegate?.didTapLearnMore()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 70)
        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.required)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
