//
//  ManageJobHeaderCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit

protocol ManageJobHeaderCellDelegate: AnyObject {
    func didTapShowParticipants()
}

class ManageJobHeaderCell: UICollectionReusableView {
    weak var delegate: ManageJobHeaderCellDelegate?
    
    private let companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let jobTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let locationWorksplaceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let jobStageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .systemYellow
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let applicantsImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        return iv
    }()
    
    private lazy var applicantsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowApplicants)))
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
        addSubviews(companyImageView, jobTitle, locationWorksplaceLabel, jobStageButton, timestampLabel, applicantsImageView, applicantsLabel, separatorView)
        
        NSLayoutConstraint.activate([
            companyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            companyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            companyImageView.heightAnchor.constraint(equalToConstant: 65),
            companyImageView.widthAnchor.constraint(equalToConstant: 65),
            
            jobTitle.topAnchor.constraint(equalTo: companyImageView.topAnchor, constant: 2),
            jobTitle.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            jobTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            locationWorksplaceLabel.topAnchor.constraint(equalTo: jobTitle.bottomAnchor),
            locationWorksplaceLabel.leadingAnchor.constraint(equalTo: jobTitle.leadingAnchor),
            locationWorksplaceLabel.trailingAnchor.constraint(equalTo: jobTitle.trailingAnchor),
            
            jobStageButton.topAnchor.constraint(equalTo: locationWorksplaceLabel.bottomAnchor, constant: 10),
            jobStageButton.leadingAnchor.constraint(equalTo: jobTitle.leadingAnchor),
            jobStageButton.widthAnchor.constraint(equalToConstant: 50),
            
            timestampLabel.centerYAnchor.constraint(equalTo: jobStageButton.centerYAnchor),
            timestampLabel.leadingAnchor.constraint(equalTo: jobStageButton.trailingAnchor, constant: 3),
            timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            applicantsImageView.topAnchor.constraint(equalTo: companyImageView.bottomAnchor, constant: 10),
            applicantsImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            applicantsImageView.heightAnchor.constraint(equalToConstant: 20),
            applicantsImageView.widthAnchor.constraint(equalToConstant: 20),
            
            applicantsLabel.centerYAnchor.constraint(equalTo: applicantsImageView.centerYAnchor),
            applicantsLabel.leadingAnchor.constraint(equalTo: applicantsImageView.trailingAnchor, constant: 3),
            applicantsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(withJob viewModel: JobViewModel, withCompany company: Company) {
        companyImageView.sd_setImage(with: URL(string: company.companyImageUrl!))
        jobTitle.text = viewModel.jobName
        locationWorksplaceLabel.text = viewModel.jobLocation + " · " + viewModel.jobWorkplaceType
        timestampLabel.text = "· Created " + viewModel.jobTimestampString! + " ago"
        applicantsLabel.text = "4 applicants"
    }
    
    @objc func handleShowApplicants() {
        delegate?.didTapShowParticipants()
    }
}
