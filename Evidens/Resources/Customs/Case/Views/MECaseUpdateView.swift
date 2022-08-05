//
//  MECaseDiagnosisView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/22.
//

import UIKit

class MECaseUpdateView: UIView {
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var diagnosisLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(profileImageView, diagnosisLabel)
    
        // change for the profile image of the user, not the current user of app
        guard let imageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String else { return }
        profileImageView.sd_setImage(with: URL(string: imageUrl))

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 20),
            
            diagnosisLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            diagnosisLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            diagnosisLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            //diagnosisLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        profileImageView.layer.cornerRadius = 20 / 2
    }
}
