//
//  Education.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/7/22.
//

import UIKit

class UserProfileEducationCell: UICollectionViewCell {
    
    private let educationCenterTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let educationTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let calendarImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let educationIntervalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let educationTypeImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "rosette")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let educationTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
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
        backgroundColor = .systemBackground
        
        addSubviews(educationCenterTitleLabel, educationTitleLabel, calendarImage, educationIntervalLabel, educationTypeImage, educationTypeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            educationCenterTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            educationCenterTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            educationCenterTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            educationTitleLabel.topAnchor.constraint(equalTo: educationCenterTitleLabel.bottomAnchor, constant: 10),
            educationTitleLabel.leadingAnchor.constraint(equalTo: educationCenterTitleLabel.leadingAnchor),
            educationTitleLabel.trailingAnchor.constraint(equalTo: educationCenterTitleLabel.trailingAnchor),
            
            calendarImage.topAnchor.constraint(equalTo: educationTitleLabel.bottomAnchor, constant: 10),
            calendarImage.leadingAnchor.constraint(equalTo: educationTitleLabel.leadingAnchor),
            calendarImage.widthAnchor.constraint(equalToConstant: 15),
            calendarImage.heightAnchor.constraint(equalToConstant: 15),
            
            educationIntervalLabel.centerYAnchor.constraint(equalTo: calendarImage.centerYAnchor),
            educationIntervalLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 10),
            educationIntervalLabel.trailingAnchor.constraint(equalTo: educationTitleLabel.trailingAnchor),
            
            educationTypeImage.topAnchor.constraint(equalTo: educationIntervalLabel.bottomAnchor, constant: 10),
            educationTypeImage.leadingAnchor.constraint(equalTo: educationTitleLabel.leadingAnchor),
            educationTypeImage.widthAnchor.constraint(equalToConstant: 15),
            educationTypeImage.heightAnchor.constraint(equalToConstant: 15),
            
            educationTypeLabel.centerYAnchor.constraint(equalTo: educationTypeImage.centerYAnchor),
            educationTypeLabel.leadingAnchor.constraint(equalTo: educationTypeImage.trailingAnchor, constant: 10),
            educationTypeLabel.trailingAnchor.constraint(equalTo: educationTitleLabel.trailingAnchor),
            educationTypeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func set(education: Education) {
        educationCenterTitleLabel.text = education.school
        educationTitleLabel.text = education.degree
        educationIntervalLabel.text = education.startDate + " - " + education.endDate
        educationTypeLabel.text = education.fieldOfStudy
    }
}
