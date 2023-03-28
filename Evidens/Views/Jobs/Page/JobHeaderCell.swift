//
//  JobHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/2/23.
//

import UIKit

class JobHeaderCell: UICollectionViewCell {
    
    private let jobNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private let companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "building.2.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    

    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let industryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let jobTypeImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "case.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        return iv
    }()
    
    private let locationImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        return iv
    }()
    
    private let jobTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let specialitiesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        addSubviews(jobNameLabel, companyImageView, companyNameLabel, industryLabel, specialitiesLabel, locationImageView, locationLabel, jobTypeImageView, jobTypeLabel, timestampLabel, separatorView)
        NSLayoutConstraint.activate([
            jobNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            jobNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            jobNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            companyImageView.leadingAnchor.constraint(equalTo: jobNameLabel.leadingAnchor),
            companyImageView.topAnchor.constraint(equalTo: jobNameLabel.bottomAnchor, constant: 10),
            companyImageView.widthAnchor.constraint(equalToConstant: 50),
            companyImageView.heightAnchor.constraint(equalToConstant: 50),
            
            companyNameLabel.topAnchor.constraint(equalTo: companyImageView.topAnchor, constant: 5),
            companyNameLabel.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 5),
            companyNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            industryLabel.bottomAnchor.constraint(equalTo: companyImageView.bottomAnchor, constant: -5),
            industryLabel.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 5),
            industryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            
            /*
            locationCompanyLabel.topAnchor.constraint(equalTo: companyNameLabel.bottomAnchor),
            locationCompanyLabel.leadingAnchor.constraint(equalTo: companyNameLabel.leadingAnchor),
            locationCompanyLabel.trailingAnchor.constraint(equalTo: companyNameLabel.trailingAnchor),
            */
            locationImageView.topAnchor.constraint(equalTo: companyImageView.bottomAnchor, constant: 10),
            locationImageView.leadingAnchor.constraint(equalTo: companyImageView.leadingAnchor),
            locationImageView.heightAnchor.constraint(equalToConstant: 23),
            locationImageView.widthAnchor.constraint(equalToConstant: 20),
            
            locationLabel.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: 5),
            locationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            jobTypeImageView.topAnchor.constraint(equalTo: locationImageView.bottomAnchor, constant: 10),
            jobTypeImageView.leadingAnchor.constraint(equalTo: companyImageView.leadingAnchor),
            jobTypeImageView.heightAnchor.constraint(equalToConstant: 20),
            jobTypeImageView.widthAnchor.constraint(equalToConstant: 20),
            
            jobTypeLabel.centerYAnchor.constraint(equalTo: jobTypeImageView.centerYAnchor),
            jobTypeLabel.leadingAnchor.constraint(equalTo: jobTypeImageView.trailingAnchor, constant: 5),
            jobTypeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            specialitiesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            specialitiesLabel.topAnchor.constraint(equalTo: jobTypeImageView.bottomAnchor, constant: 10),
            specialitiesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            timestampLabel.topAnchor.constraint(equalTo: specialitiesLabel.bottomAnchor, constant: 10),
            timestampLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        companyImageView.layer.cornerRadius = 7
    }
    
    func configure(withJob viewModel: JobViewModel, withCompany company: Company) {
        if let companyUrl = company.companyImageUrl, companyUrl != "" {
            companyImageView.sd_setImage(with: URL(string: companyUrl))
        }
        
        jobNameLabel.text = viewModel.jobName
        industryLabel.text = company.industry
        companyNameLabel.text = company.name
        specialitiesLabel.text = company.specialities.joined(separator: " · ")
        jobTypeLabel.text = viewModel.jobType
        locationLabel.text = viewModel.jobLocation + " · " + viewModel.jobWorkplaceType
        timestampLabel.text = viewModel.jobTimestampString! + " ago"
    }
}
