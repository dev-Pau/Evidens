//
//  JobHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/2/23.
//

import UIKit

class JobHeaderCell: UICollectionViewCell {
    
    var viewModel: JobViewModel? {
        didSet {
            configureWithJob()
        }
    }
    
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
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    

    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let locationCompanyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
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
        addSubviews(jobNameLabel, companyImageView, companyNameLabel, locationCompanyLabel, timestampLabel, separatorView)
        NSLayoutConstraint.activate([
            jobNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            jobNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            jobNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            companyImageView.leadingAnchor.constraint(equalTo: jobNameLabel.leadingAnchor),
            companyImageView.topAnchor.constraint(equalTo: jobNameLabel.bottomAnchor, constant: 10),
            companyImageView.widthAnchor.constraint(equalToConstant: 50),
            companyImageView.heightAnchor.constraint(equalToConstant: 50),
            
            companyNameLabel.topAnchor.constraint(equalTo: companyImageView.topAnchor),
            companyNameLabel.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 5),
            companyNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            locationCompanyLabel.topAnchor.constraint(equalTo: companyNameLabel.bottomAnchor),
            locationCompanyLabel.leadingAnchor.constraint(equalTo: companyNameLabel.leadingAnchor),
            locationCompanyLabel.trailingAnchor.constraint(equalTo: companyNameLabel.trailingAnchor),
            
            timestampLabel.topAnchor.constraint(equalTo: companyImageView.bottomAnchor, constant: 10),
            timestampLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configureWithJob() {
        guard let viewModel = viewModel else { return }
        jobNameLabel.text = viewModel.jobName
        timestampLabel.text = viewModel.jobTimestampString
    }
}
