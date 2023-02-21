//
//  BrowseJobCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit

class BrowseJobCell: UICollectionViewCell {
    
    var viewModel: JobViewModel {
        didSet {
            configureWithJob()
        }
    }
    
    private let companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let jobPositionName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        return button
    }()
    
    private let jobLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(companyImageView, bookmarkButton, jobPositionName, companyNameLabel, jobLocationLabel, timestampLabel)
        NSLayoutConstraint.activate([
            companyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            companyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            companyImageView.widthAnchor.constraint(equalToConstant: 60),
            companyImageView.heightAnchor.constraint(equalToConstant: 60),
            
            bookmarkButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bookmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 25),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 25),
            
            jobPositionName.topAnchor.constraint(equalTo: companyImageView.topAnchor),
            jobPositionName.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            jobPositionName.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -10),
            
            companyNameLabel.topAnchor.constraint(equalTo: jobPositionName.bottomAnchor, constant: 10),
            companyNameLabel.leadingAnchor.constraint(equalTo: jobPositionName.leadingAnchor),
            companyNameLabel.trailingAnchor.constraint(equalTo: jobPositionName.trailingAnchor),
            
            jobLocationLabel.topAnchor.constraint(equalTo: companyNameLabel.bottomAnchor, constant: 10),
            jobLocationLabel.leadingAnchor.constraint(equalTo: companyNameLabel.leadingAnchor),
            jobLocationLabel.trailingAnchor.constraint(equalTo: companyNameLabel.trailingAnchor),
            
            timestampLabel.topAnchor.constraint(equalTo: jobLocationLabel.bottomAnchor, constant: 10),
            timestampLabel.leadingAnchor.constraint(equalTo: jobLocationLabel.leadingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: jobLocationLabel.trailingAnchor)
        ])
    }
    
    private func configureWithJob() {
        
    }
    
    @objc func handleBookmark() {
        
    }
}
