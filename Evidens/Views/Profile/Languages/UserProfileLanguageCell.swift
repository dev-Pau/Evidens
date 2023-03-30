//
//  UserProfileLanguageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

protocol UserProfileLanguageCellDelegate: AnyObject {
    func didTapEditLanguage(_ cell: UICollectionViewCell, languageName: String, languageProficiency: String)
}

class UserProfileLanguageCell: UICollectionViewCell {
    
    weak var delegate: UserProfileLanguageCellDelegate?
    
    private let languageTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let languageLevelLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.configuration?.buttonSize = .mini
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEditLanguage), for: .touchUpInside)
        return button
    }()
    
    let separatorView: UIView = {
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
        addSubviews(languageTitleLabel, languageLevelLabel, buttonImage, separatorView)
        
        NSLayoutConstraint.activate([

            languageTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            languageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            languageTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            languageLevelLabel.topAnchor.constraint(equalTo: languageTitleLabel.bottomAnchor, constant: 5),
            languageLevelLabel.leadingAnchor.constraint(equalTo: languageTitleLabel.leadingAnchor),
            languageLevelLabel.trailingAnchor.constraint(equalTo: languageTitleLabel.trailingAnchor),
            languageLevelLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        
            buttonImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            
 
        ])
    }
    
    @objc func handleEditLanguage() {
        guard let languageName = languageTitleLabel.text, let languageProficiency = languageLevelLabel.text else { return }
        delegate?.didTapEditLanguage(self, languageName: languageName, languageProficiency: languageProficiency)
    }
    
    func set(languageInfo: [String: String]) {
        languageTitleLabel.text = languageInfo["languageName"]
        languageLevelLabel.text = languageInfo["languageProficiency"]
    }
}
