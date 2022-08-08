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
        label.text = "English"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let languageLevelLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Proficiency level"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        button.configuration?.buttonSize = .mini
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEditLanguage), for: .touchUpInside)
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lightGrayColor
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
        backgroundColor = .white
        addSubviews(languageTitleLabel, languageLevelLabel, buttonImage, separatorView)
        
        NSLayoutConstraint.activate([
            languageTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            languageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            languageTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            languageLevelLabel.topAnchor.constraint(equalTo: languageTitleLabel.bottomAnchor, constant: 5),
            languageLevelLabel.leadingAnchor.constraint(equalTo: languageTitleLabel.leadingAnchor),
            languageLevelLabel.trailingAnchor.constraint(equalTo: languageTitleLabel.trailingAnchor),
            languageLevelLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: languageTitleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: languageTitleLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            buttonImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
            
            
 
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
