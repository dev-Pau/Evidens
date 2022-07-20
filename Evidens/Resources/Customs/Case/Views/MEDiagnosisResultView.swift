//
//  MEDiagnosisResultView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/7/22.
//

import UIKit

class MEDiagnosisResultView: UIView {
    
    private let imageUrl: URL
    private let text: String
    
    private let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let diagnosisLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(imageUrl: URL, text: String) {
        self.imageUrl = imageUrl
        self.text = text
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(profileImage, diagnosisLabel)
        
        profileImage.sd_setImage(with: imageUrl)
        diagnosisLabel.text = text
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: topAnchor),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImage.heightAnchor.constraint(equalToConstant: 20),
            profileImage.widthAnchor.constraint(equalToConstant: 20),
            
            diagnosisLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            diagnosisLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 5),
            diagnosisLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            diagnosisLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        profileImage.layer.cornerRadius = 20 / 2
    }
}
