//
//  DiagnosisCaseCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/10/22.
//

import UIKit

class DiagnosisCaseCell: UICollectionViewCell {
    
    
    var viewModel: RevisionKindViewModel? {
        didSet {
            configureWithRevision()
        }
    }
    
    var authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    var revisionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "user.profile.privacy")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    var timestamp: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
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
        addSubviews(authorLabel, imageView, revisionLabel, contentLabel, separatorView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            
            authorLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            authorLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            
            revisionLabel.topAnchor.constraint(equalTo: authorLabel.topAnchor),
            revisionLabel.leadingAnchor.constraint(equalTo: authorLabel.trailingAnchor),

            contentLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        imageView.layer.cornerRadius = 40 / 2
    }
    
    private func configureWithRevision() {
        guard let viewModel = viewModel else { return }
        contentLabel.text = viewModel.content
        revisionLabel.text = AppStrings.Characters.dot + viewModel.timestamp
        authorLabel.text = viewModel.kind
    }

    func set(user: User) {
        if let imageUrl = user.profileUrl, imageUrl != "" {
            imageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            imageView.image = UIImage(named: "user.profile")
        }
    }
    
    func set(date: Date) {
        guard let viewModel = viewModel else { return }
        revisionLabel.text?.append(viewModel.elapsedTimestamp(from: date))
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
