//
//  RecentNewsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

class RecentNewsCell: UICollectionViewCell {
    
    var viewModel: NewViewModel? {
        didSet {
            configureWithNew()
        }
    }
    
    private let newsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 3
        return label
    }()
    
    private let specialityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryColor
        label.layer.contentsGravity = .bottom
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private let datePublishedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private let separatorView: UIView = {
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
        addSubviews(newsImageView, titleLabel, specialityLabel, datePublishedLabel)
        NSLayoutConstraint.activate([
            newsImageView.topAnchor.constraint(equalTo: topAnchor),
            newsImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newsImageView.heightAnchor.constraint(equalToConstant: 90),
            newsImageView.widthAnchor.constraint(equalToConstant: 90),
            
            specialityLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            specialityLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            datePublishedLabel.trailingAnchor.constraint(equalTo: newsImageView.leadingAnchor, constant: -10),
            datePublishedLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: newsImageView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: newsImageView.leadingAnchor, constant: -10),
        ])
        
        newsImageView.layer.cornerRadius = 10
    }
    
    func addSeparatorView() {
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: newsImageView.leadingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    private func configureWithNew() {
        guard let viewModel = viewModel else { return }
        specialityLabel.text = viewModel.newsCategory
        titleLabel.text = viewModel.newTitle
        datePublishedLabel.text = viewModel.timestampString
        newsImageView.sd_setImage(with: URL(string: viewModel.mainImageUrl))
    }
}
