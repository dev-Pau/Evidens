//
//  UserProfilePatentsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

class UserProfilePatentCell: UICollectionViewCell {
    
    private let patentTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Estudi observacional de l’efecte del COVID-19 en gent gram amb artorsi de genoll i la seva relació amb la qualitat de vida "
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patentNumberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "US-193958BN"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let patentDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 3
        label.text = "A registered nurse must go through specialty training in nursing, which can be done through a bachelor’s degree, an associate’s degree or an approved certificate program. The skills required vary from job to job"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
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
        backgroundColor = .white
        addSubviews(patentTitleLabel, patentNumberLabel, patentDescriptionLabel, separatorView)
        
        NSLayoutConstraint.activate([
            patentTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            patentTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            patentTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            patentNumberLabel.topAnchor.constraint(equalTo: patentTitleLabel.bottomAnchor, constant: 5),
            patentNumberLabel.leadingAnchor.constraint(equalTo: patentTitleLabel.leadingAnchor),
            patentNumberLabel.trailingAnchor.constraint(equalTo: patentTitleLabel.trailingAnchor),
            
            patentDescriptionLabel.topAnchor.constraint(equalTo: patentNumberLabel.bottomAnchor, constant: 10),
            patentDescriptionLabel.leadingAnchor.constraint(equalTo: patentNumberLabel.leadingAnchor),
            patentDescriptionLabel.trailingAnchor.constraint(equalTo: patentNumberLabel.trailingAnchor),
            patentDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: patentTitleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: patentTitleLabel.trailingAnchor)
        ])
    }
    
    func set(patentInfo: [String: Any]) {
        patentTitleLabel.text = patentInfo["title"] as? String
        patentNumberLabel.text = patentInfo["number"] as? String
        
        if let description = patentInfo["description"] as? String, description.count != 0 {
            patentDescriptionLabel.text = description
        } else {
            patentDescriptionLabel.setHeightConstraint(toConstant: 0)
            patentDescriptionLabel.removeFromSuperview()
            patentNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
    }
}
