//
//  UserProfilePublicationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

protocol UserProfilePublicationCellDelegate: AnyObject {
    func didTapEditPublication(_ cell: UICollectionViewCell, publicationTitle: String, publicationDate: String, publicationUrl: String)
}

class UserProfilePublicationCell: UICollectionViewCell {
    
    weak var delegate: UserProfilePublicationCellDelegate?
    
    private let publicationTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        //label.text = "Estudi observacional de l’efecte del COVID-19 en gent gram amb artorsi de genoll i la seva relació amb la qualitat de vida "
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
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
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.configuration?.buttonSize = .mini
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEditPublication), for: .touchUpInside)
        return button
    }()
    
    private let publicationDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  
    private let urlImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let publicationUrlLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
        addSubviews(publicationTitleLabel, urlImage, publicationUrlLabel, calendarImage, publicationDateLabel, buttonImage, separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor),
            
            
            publicationTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            publicationTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            publicationTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            urlImage.topAnchor.constraint(equalTo: publicationTitleLabel.bottomAnchor, constant: 10),
            urlImage.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            urlImage.widthAnchor.constraint(equalToConstant: 15),
            urlImage.heightAnchor.constraint(equalToConstant: 15),
            
            publicationUrlLabel.centerYAnchor.constraint(equalTo: urlImage.centerYAnchor),
            publicationUrlLabel.leadingAnchor.constraint(equalTo: urlImage.trailingAnchor, constant: 10),
            publicationUrlLabel.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor),
            
            calendarImage.topAnchor.constraint(equalTo: publicationUrlLabel.bottomAnchor, constant: 10),
            calendarImage.leadingAnchor.constraint(equalTo: publicationTitleLabel.leadingAnchor),
            calendarImage.widthAnchor.constraint(equalToConstant: 15),
            calendarImage.heightAnchor.constraint(equalToConstant: 15),
            
            publicationDateLabel.centerYAnchor.constraint(equalTo: calendarImage.centerYAnchor),
            publicationDateLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 10),
            publicationDateLabel.trailingAnchor.constraint(equalTo: publicationTitleLabel.trailingAnchor),
            publicationDateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            buttonImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
    
    @objc func handleEditPublication() {
        guard let title = publicationTitleLabel.text, let date = publicationDateLabel.text, let url = publicationUrlLabel.text else { return }
        delegate?.didTapEditPublication(self, publicationTitle: title, publicationDate: date, publicationUrl: url)
    }
    
    
    
    func set(publicationInfo: [String: Any]) {
        publicationTitleLabel.text = publicationInfo["title"] as? String
        publicationUrlLabel.text = publicationInfo["url"] as? String
        publicationDateLabel.text = publicationInfo["date"] as? String
    }
}
