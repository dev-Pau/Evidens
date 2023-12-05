//
//  ProfileExperienceCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/7/22.
//

import UIKit
 
class ProfileExperienceCell: UICollectionViewCell {
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
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
        addSubviews(companyLabel, roleLabel, dateLabel, separatorView)
        
        NSLayoutConstraint.activate([
            roleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            roleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            roleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            companyLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 2),
            companyLabel.leadingAnchor.constraint(equalTo: roleLabel.leadingAnchor),
            companyLabel.trailingAnchor.constraint(equalTo: roleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: companyLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: companyLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: companyLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }
    
    func set(experience: Experience) {
        companyLabel.text = experience.company
        roleLabel.text = experience.role
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        dateLabel.text = formatter.string(from: Date(timeIntervalSince1970: experience.start))

        if let end = experience.end {
            dateLabel.text?.append(AppStrings.Characters.dot + formatter.string(from: Date(timeIntervalSince1970: end)))
        } else {
            dateLabel.text?.append(AppStrings.Characters.dot + AppStrings.Sections.present)
        }
    }
}
