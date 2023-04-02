//
//  Experience.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/7/22.
//

import UIKit
 
class UserProfileExperienceCell: UICollectionViewCell {
    
    private let professionCenterTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionJobTitleLabel: UILabel = {
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
    
    private let jobIntervalLabel: UILabel = {
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
        addSubviews(professionCenterTitleLabel, professionJobTitleLabel, calendarImage, jobIntervalLabel, separatorView)
        
        NSLayoutConstraint.activate([
            professionCenterTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            professionCenterTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            professionCenterTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionJobTitleLabel.topAnchor.constraint(equalTo: professionCenterTitleLabel.bottomAnchor, constant: 5),
            professionJobTitleLabel.leadingAnchor.constraint(equalTo: professionCenterTitleLabel.leadingAnchor),
            professionJobTitleLabel.trailingAnchor.constraint(equalTo: professionCenterTitleLabel.trailingAnchor),
            
            calendarImage.topAnchor.constraint(equalTo: professionJobTitleLabel.bottomAnchor, constant: 10),
            calendarImage.leadingAnchor.constraint(equalTo: professionJobTitleLabel.leadingAnchor),
            calendarImage.widthAnchor.constraint(equalToConstant: 15),
            calendarImage.heightAnchor.constraint(equalToConstant: 15),
            
            jobIntervalLabel.centerYAnchor.constraint(equalTo: calendarImage.centerYAnchor),
            jobIntervalLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 10),
            jobIntervalLabel.trailingAnchor.constraint(equalTo: professionJobTitleLabel.trailingAnchor),
            jobIntervalLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func set(experience: Experience) {
        professionCenterTitleLabel.text = experience.company
        professionJobTitleLabel.text = experience.role
        jobIntervalLabel.text = experience.startDate + " - " + experience.endDate
    }
}
