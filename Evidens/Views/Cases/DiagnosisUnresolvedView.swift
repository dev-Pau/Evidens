//
//  DiagnosisUnresolvedView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/7/22.
//

import UIKit

class DiagnosisUnresolvedView: UIView {
    
    private var isExpanded: Bool = false
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let diagnosisTitle: UILabel = {
        let label = UILabel()
        label.text = "You will ask MyEvidens community for their medical advice on this case"
        label.textColor = .label
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let diagnosisSubtitle: UILabel = {
        let label = UILabel()
        label.text = "You will be able to edit the case and add a diagnosis later"
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    private lazy var bottomSeparatorView: UIView = {
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
        translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [diagnosisTitle, diagnosisSubtitle])
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubviews(profileImageView, stackView, separatorView, bottomSeparatorView)

        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),

            stackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            bottomSeparatorView.topAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
        profileImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
    }
}

