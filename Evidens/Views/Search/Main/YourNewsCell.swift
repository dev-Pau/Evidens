//
//  YourNewsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

class YourNewsCell: UICollectionViewCell {
    
    private let newsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let specialityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryColor

        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let readingTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let readingTimeImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "stopwatch", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(newsImageView, titleLabel, specialityLabel, readingTimeImageView, readingTimeLabel)
        NSLayoutConstraint.activate([
            newsImageView.topAnchor.constraint(equalTo: topAnchor),
            newsImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newsImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newsImageView.heightAnchor.constraint(equalToConstant: 190),
            
            titleLabel.topAnchor.constraint(equalTo: newsImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            specialityLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            specialityLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            readingTimeImageView.centerYAnchor.constraint(equalTo: specialityLabel.centerYAnchor),
            readingTimeImageView.leadingAnchor.constraint(equalTo: specialityLabel.trailingAnchor, constant: 15),
            readingTimeImageView.heightAnchor.constraint(equalToConstant: 15),
            readingTimeImageView.widthAnchor.constraint(equalToConstant: 15),
            
            readingTimeLabel.centerYAnchor.constraint(equalTo: readingTimeImageView.centerYAnchor),
            readingTimeLabel.leadingAnchor.constraint(equalTo: readingTimeImageView.trailingAnchor, constant: 5)
        ])
        
        newsImageView.layer.cornerRadius = 15
        titleLabel.text = "Residents near Ohio train derailment diagnosed with ailments associated with chemical exposure, including bronchitis"
        specialityLabel.text = "Medicine"
        newsImageView.sd_setImage(with: URL(string: "https://firebasestorage.googleapis.com/v0/b/evidens-ec6bd.appspot.com/o/news%2F230213-ohio-train-derailment-2-se-1021a-bcf1b8.jpeg?alt=media&token=92c89015-74dc-4956-bc74-0ec86000d76f"))
        readingTimeLabel.text = "6 minutes"
    }
    
    

}
