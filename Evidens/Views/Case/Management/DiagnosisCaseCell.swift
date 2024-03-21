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
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .medium)
        return label
    }()
    
    var revisionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        return label
    }()
    
    var imageView = ProfileImageView(frame: .zero)
    
    var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
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
            
            contentLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            revisionLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            revisionLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            revisionLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            revisionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
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
        revisionLabel.text = viewModel.timestamp
        authorLabel.text = viewModel.kind
    }

    func set(user: User) {
        imageView.addImage(forUser: user, size: 40)
    }
    
    func anonymize() {
        imageView.anonymize()
    }
    
    func set(date: Date) {
        guard let _ = viewModel else { return }
        //revisionLabel.text?.append(viewModel.elapsedTimestamp(from: date))
    }
}
