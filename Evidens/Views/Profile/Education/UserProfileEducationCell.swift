//
//  Education.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/7/22.
//

import UIKit

class UserProfileEducationCell: UICollectionViewCell {
    
    private let educationCenterImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "education.center.profile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let educationCenterTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let educationTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let educationIntervalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let educationTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 3
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
        addSubviews(educationCenterImageView, educationCenterTitleLabel, educationTitleLabel, educationIntervalLabel, educationTypeLabel, separatorView)
        
        NSLayoutConstraint.activate([
            educationCenterImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            educationCenterImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            educationCenterImageView.heightAnchor.constraint(equalToConstant: 55),
            educationCenterImageView.widthAnchor.constraint(equalToConstant: 55),

            educationTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            educationTitleLabel.leadingAnchor.constraint(equalTo: educationCenterImageView.trailingAnchor, constant: 10),
            educationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            educationCenterTitleLabel.topAnchor.constraint(equalTo: educationTitleLabel.bottomAnchor, constant: 2),
            educationCenterTitleLabel.leadingAnchor.constraint(equalTo: educationTitleLabel.leadingAnchor),
            educationCenterTitleLabel.trailingAnchor.constraint(equalTo: educationTitleLabel.trailingAnchor),
            
            educationIntervalLabel.topAnchor.constraint(equalTo: educationCenterTitleLabel.bottomAnchor, constant: 2),
            educationIntervalLabel.leadingAnchor.constraint(equalTo: educationCenterTitleLabel.leadingAnchor),
            educationIntervalLabel.trailingAnchor.constraint(equalTo: educationCenterTitleLabel.trailingAnchor),
            
            educationTypeLabel.topAnchor.constraint(equalTo: educationIntervalLabel.bottomAnchor, constant: 2),
            educationTypeLabel.leadingAnchor.constraint(equalTo: educationIntervalLabel.leadingAnchor),
            educationTypeLabel.trailingAnchor.constraint(equalTo: educationTitleLabel.trailingAnchor),
            educationTypeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func set(education: Education) {
        print(education)
        educationCenterTitleLabel.text = education.school
        educationTitleLabel.text = education.fieldOfStudy
        educationIntervalLabel.text = education.startDate + " - " + education.endDate
        educationTypeLabel.text = education.degree
        
    }
}
