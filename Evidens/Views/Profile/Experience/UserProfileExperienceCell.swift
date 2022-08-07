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
        //label.text = "Kinevic"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionJobTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        //label.text = "Physiotherapist"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
    
    private let jobIntervalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        //label.text = "2016 - Present"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = grayColor
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
        addSubviews(professionCenterTitleLabel, professionJobTitleLabel, calendarImage, jobIntervalLabel, bottomView)
        
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
            

            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 1),
            bottomView.leadingAnchor.constraint(equalTo: professionCenterTitleLabel.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: professionCenterTitleLabel.trailingAnchor)
        ])
    }
    
    func set(experienceInfo: [String: String]) {
        professionCenterTitleLabel.text = experienceInfo["company"]
        professionJobTitleLabel.text = experienceInfo["role"]
        jobIntervalLabel.text = experienceInfo["startDate"]! + " - " + experienceInfo["endDate"]!
    }
    
}
