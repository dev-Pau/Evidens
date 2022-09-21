//
//  DraftPostCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/9/22.
//

import UIKit

class DraftPostCell: UITableViewCell {
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private var postTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var timestampLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.textAlignment = .right
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        contentView.addSubviews(timestampLabel, postTextLabel)
        
        NSLayoutConstraint.activate([
            postTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            postTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            postTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            timestampLabel.topAnchor.constraint(equalTo: postTextLabel.bottomAnchor, constant: 10),
            timestampLabel.leadingAnchor.constraint(equalTo: postTextLabel.leadingAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        postTextLabel.text = viewModel.postText
        timestampLabel.text = viewModel.timestampString
    }
}



