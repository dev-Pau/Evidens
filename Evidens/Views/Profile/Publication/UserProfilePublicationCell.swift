//
//  UserProfilePublicationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class UserProfilePublicationCell: UICollectionViewCell {
    
    private let publicationTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        //label.text = "Estudi observacional de l’efecte del COVID-19 en gent gram amb artorsi de genoll i la seva relació amb la qualitat de vida "
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let calendarImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let publicationDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        //label.text = "31/12/2020"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  
    private let urlImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let publicationUrlLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        //label.text = "https://doi.org/10.1186/s12891-018-2182-8"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        addSubviews(publicationTitleLabel, urlImage, publicationUrlLabel, calendarImage, publicationDateLabel, bottomView)
        
        NSLayoutConstraint.activate([
            publicationTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            publicationTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            publicationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            urlImage.topAnchor.constraint(equalTo: publicationTitleLabel.bottomAnchor, constant: 10),
            urlImage.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            urlImage.widthAnchor.constraint(equalToConstant: 15),
            urlImage.heightAnchor.constraint(equalToConstant: 15),
            
            publicationUrlLabel.centerYAnchor.constraint(equalTo: urlImage.centerYAnchor),
            publicationUrlLabel.leadingAnchor.constraint(equalTo: urlImage.trailingAnchor, constant: 10),
            publicationUrlLabel.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor),
            
            calendarImage.topAnchor.constraint(equalTo: publicationUrlLabel.bottomAnchor, constant: 10),
            calendarImage.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            calendarImage.widthAnchor.constraint(equalToConstant: 15),
            calendarImage.heightAnchor.constraint(equalToConstant: 15),
            
            publicationDateLabel.centerYAnchor.constraint(equalTo: calendarImage.centerYAnchor),
            publicationDateLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 10),
            publicationDateLabel.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor),
            publicationDateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 1),
            bottomView.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor)
        ])
    }
    
    func set(publicationInfo: [String: String]) {
        publicationTitleLabel.text = publicationInfo["title"]
        publicationUrlLabel.text = publicationInfo["url"]
        publicationDateLabel.text = publicationInfo["date"]
    }
}