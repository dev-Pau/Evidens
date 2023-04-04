//
//  BrowseCompanyCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit

class BrowseCompanyCell: UICollectionViewCell {
    
    var company: Company? {
        didSet {
            configureWithCompany()
        }
    }
    
    private let companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .quaternarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let companyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let companyDetailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
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
        addSubviews(companyImageView, companyTitleLabel, companyDetailsLabel, separatorView)
        NSLayoutConstraint.activate([
            companyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            companyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            companyImageView.heightAnchor.constraint(equalToConstant: 45),
            companyImageView.widthAnchor.constraint(equalToConstant: 45),
            
            companyTitleLabel.topAnchor.constraint(equalTo: companyImageView.topAnchor, constant: 2),
            companyTitleLabel.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            companyTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            companyDetailsLabel.bottomAnchor.constraint(equalTo: companyImageView.bottomAnchor, constant: -2),
            companyDetailsLabel.leadingAnchor.constraint(equalTo: companyTitleLabel.leadingAnchor),
            companyDetailsLabel.trailingAnchor.constraint(equalTo: companyTitleLabel.trailingAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: companyTitleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        companyImageView.layer.cornerRadius = 7
    }
    
    private func configureWithCompany() {
        guard let company = company else { return }
        companyImageView.sd_setImage(with: URL(string: company.companyImageUrl!))
        companyTitleLabel.text = company.name
        companyDetailsLabel.text = "Company" + " • " + company.industry + " • " + company.specialities.joined(separator: ", ")
        
    }
}
