//
//  CreateJobHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/2/23.
//

import UIKit

protocol CreateJobHeaderDelegate: AnyObject {
    func didTapAddExistingCompany()
    func didTappCreateNewCompany()
}

class CreateJobHeader: UICollectionReusableView {
    
    weak var delegate: CreateJobHeaderDelegate?
    
    private lazy var companyImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "building.2", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 30, height: 30))
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = .quaternarySystemFill
        button.configuration?.background.strokeWidth = 2
        button.addTarget(self, action: #selector(handleAddExistingCompany), for: .touchUpInside)
        return button
    }()
    
    private lazy var companyImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var addImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22))
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = .quaternarySystemFill
        button.configuration?.background.strokeWidth = 2
        button.addTarget(self, action: #selector(handleCreateCompany), for: .touchUpInside)
        return button
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryColor
        label.text = "Select or create a company"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(companyImageButton, addImageButton, companyLabel)
        NSLayoutConstraint.activate([
            companyImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            companyImageButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -10),
            companyImageButton.heightAnchor.constraint(equalToConstant: 70),
            companyImageButton.widthAnchor.constraint(equalToConstant: 70),
            
            addImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            addImageButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 10),
            addImageButton.heightAnchor.constraint(equalToConstant: 70),
            addImageButton.widthAnchor.constraint(equalToConstant: 70),
            
            companyLabel.topAnchor.constraint(equalTo: companyImageButton.bottomAnchor, constant: 20),
            companyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            companyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    func setWithCompany(company: Company) {
        companyImageButton.isHidden = true
        addImageButton.isHidden = true
        addSubview(companyImageView)
        
        NSLayoutConstraint.activate([
            companyImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            companyImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            companyImageView.heightAnchor.constraint(equalToConstant: 70),
            companyImageView.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        companyLabel.text = company.name
        companyImageView.sd_setImage(with: URL(string: company.companyImageUrl!))
    }
    
    @objc func handleAddExistingCompany() {
        delegate?.didTapAddExistingCompany()
    }
    
    @objc func handleCreateCompany() {
        delegate?.didTappCreateNewCompany()
    }
}
