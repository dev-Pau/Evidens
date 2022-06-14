//
//  MEPostStatsView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

class MEPostStatsView: UIView {
    
    lazy var likesIndicatorImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "heartGray")
        return iv
    }()
    
    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let bottomSeparatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = lightGrayColor
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
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(likesIndicatorImage, likesLabel, bottomSeparatorLabel)
        
        NSLayoutConstraint.activate([
            likesIndicatorImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            likesIndicatorImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            likesIndicatorImage.heightAnchor.constraint(equalToConstant: 16),
            likesIndicatorImage.widthAnchor.constraint(equalToConstant: 16),
            
            likesLabel.centerYAnchor.constraint(equalTo: likesIndicatorImage.centerYAnchor),
            likesLabel.leadingAnchor.constraint(equalTo: likesIndicatorImage.trailingAnchor, constant: 3),
            likesLabel.heightAnchor.constraint(equalToConstant: 20),
            likesLabel.widthAnchor.constraint(equalToConstant: 20),
        ])
    }
}

