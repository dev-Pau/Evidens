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
        label.textColor = primaryGray
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title3, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var help: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title3, weight: .regular)
        label.textColor = primaryColor
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSeeMore)))
        return label
    }()
    
    private let replies: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryGray
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title3, weight: .medium)
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
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bgView.bottomAnchor.constraint(equalTo: help.bottomAnchor, constant: 10),

            title.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10),
            
            help.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2),
            help.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            help.trailingAnchor.constraint(lessThanOrEqualTo: title.trailingAnchor),
            help.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            
            line.bottomAnchor.constraint(equalTo: bottomAnchor),
            line.leadingAnchor.constraint(equalTo: leadingAnchor),
            line.trailingAnchor.constraint(equalTo: trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.4),
        
            replies.leadingAnchor.constraint(equalTo: help.trailingAnchor, constant: 10),
            replies.centerYAnchor.constraint(equalTo: help.centerYAnchor),
        ])
        
        title.text = AppStrings.Content.Comment.deleted
        help.text = AppStrings.Content.Empty.learn
        replies.text = AppStrings.Title.replies
        replies.isHidden = true
        help.isHidden = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSeeReplies)))
    }
    
    private func configureWithComment() {
        guard let viewModel = viewModel else { return }
        replies.isHidden = viewModel.numberOfComments > 0 ? false : true
    }
                             
    @objc func handleSeeReplies() {
        guard let viewModel = viewModel, viewModel.numberOfComments > 0 else { return }
        delegate?.didTapReplies(self, forComment: viewModel.comment)
    }
    
    @objc func handleSeeMore() {
        delegate?.didTapLearnMore()
    }
}
