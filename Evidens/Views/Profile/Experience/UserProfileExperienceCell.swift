//
//  Experience.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/7/22.
//

import UIKit
 
class UserProfileExperienceCell: UICollectionViewCell {
    
    private let companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "company.profile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let professionCenterTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionJobTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let jobIntervalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
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
        addSubviews(companyImageView, professionCenterTitleLabel, professionJobTitleLabel, jobIntervalLabel, separatorView)
        
        NSLayoutConstraint.activate([
            companyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            companyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            companyImageView.heightAnchor.constraint(equalToConstant: 55),
            companyImageView.widthAnchor.constraint(equalToConstant: 55),

            professionJobTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            professionJobTitleLabel.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            professionJobTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionCenterTitleLabel.topAnchor.constraint(equalTo: professionJobTitleLabel.bottomAnchor, constant: 2),
            professionCenterTitleLabel.leadingAnchor.constraint(equalTo: professionJobTitleLabel.leadingAnchor),
            professionCenterTitleLabel.trailingAnchor.constraint(equalTo: professionJobTitleLabel.trailingAnchor),
            
            jobIntervalLabel.topAnchor.constraint(equalTo: professionCenterTitleLabel.bottomAnchor, constant: 2),
            jobIntervalLabel.leadingAnchor.constraint(equalTo: professionCenterTitleLabel.leadingAnchor),
            jobIntervalLabel.trailingAnchor.constraint(equalTo: professionCenterTitleLabel.trailingAnchor),
            jobIntervalLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }
    
    func set(experience: Experience) {
        professionCenterTitleLabel.text = experience.company
        professionJobTitleLabel.text = experience.role
        jobIntervalLabel.text = experience.startDate + " - " + experience.endDate
    }
}
