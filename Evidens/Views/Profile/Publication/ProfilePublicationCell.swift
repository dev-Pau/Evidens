//
//  ProfilePublicationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

private let userCellReuseIdentifier = "UserCellReuseIdentifier"

protocol ProfilePublicationCellDelegate: AnyObject {
    func didTapURL(_ url: URL)
}

class ProfilePublicationCell: UICollectionViewCell {
    
    private var users = [User]()
    weak var delegate: ProfilePublicationCellDelegate?
    private var publication: Publication?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .label
        label.textAlignment = .left
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  
    private let publicationButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
        container.foregroundColor = primaryColor
        button.configuration?.attributedTitle = AttributedString(AppStrings.Sections.showPublication, attributes: container)
        
        button.configuration?.contentInsets = NSDirectionalEdgeInsets.zero
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        addSubviews(titleLabel, publicationButton, dateLabel, separatorView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            publicationButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            publicationButton.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 3),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
        
        publicationButton.addTarget(self, action: #selector(handleUrlTap), for: .touchUpInside)
    }
    
    func set(publication: Publication) {
        self.publication = publication
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let date = Date(timeIntervalSince1970: publication.timestamp)
        
        let dateString = dateFormatter.string(from: date)
        
        titleLabel.text = publication.title
        dateLabel.text = dateString + AppStrings.Characters.dot
    }
    
    @objc func handleUrlTap() {
        guard let publication = publication else { return }
        if let url = URL(string: publication.url) {
            delegate?.didTapURL(url)
        }
    }
}
