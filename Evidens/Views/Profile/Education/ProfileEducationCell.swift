//
//  ProfileEducationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/7/22.
//

import UIKit

class ProfileEducationCell: UICollectionViewCell {
    
    private let schoolLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fieldLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let kindLabel: UILabel = {
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
        addSubviews(schoolLabel, fieldLabel, dateLabel, kindLabel, separatorView)
        
        NSLayoutConstraint.activate([
            fieldLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            fieldLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            fieldLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            schoolLabel.topAnchor.constraint(equalTo: fieldLabel.bottomAnchor, constant: 2),
            schoolLabel.leadingAnchor.constraint(equalTo: fieldLabel.leadingAnchor),
            schoolLabel.trailingAnchor.constraint(equalTo: fieldLabel.trailingAnchor),
            
            kindLabel.topAnchor.constraint(equalTo: schoolLabel.bottomAnchor, constant: 2),
            kindLabel.leadingAnchor.constraint(equalTo: schoolLabel.leadingAnchor),
            kindLabel.trailingAnchor.constraint(equalTo: schoolLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }
    
    func set(education: Education) {
        schoolLabel.text = education.school
        fieldLabel.text = education.field

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        dateLabel.text = formatter.string(from: Date(timeIntervalSince1970: education.start))

        if let end = education.end {
            dateLabel.text?.append(AppStrings.Characters.dot + formatter.string(from: Date(timeIntervalSince1970: end)))
        } else {
            dateLabel.text?.append(AppStrings.Characters.dot + AppStrings.Sections.present)
        }
        
        kindLabel.text = education.kind
        
    }
}
