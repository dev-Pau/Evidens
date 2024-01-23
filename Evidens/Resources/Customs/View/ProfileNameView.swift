//
//  ProfileNameView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/1/24.
//

import UIKit

class ProfileNameView: UIView {
    
    
    private let name: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.addFont(size: 23, scaleStyle: .largeTitle, weight: .bold, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private let discipline: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var connections: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular, scales: false)
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowFollowers)))
        label.isUserInteractionEnabled = true
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
   
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false

        addSubviews(name, discipline, connections)
        
        NSLayoutConstraint.activate([
            
            name.topAnchor.constraint(equalTo: topAnchor),
            name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            name.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            discipline.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5),
            discipline.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            discipline.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            
            connections.topAnchor.constraint(equalTo: discipline.bottomAnchor),
            connections.leadingAnchor.constraint(equalTo: discipline.leadingAnchor),
            connections.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            connections.bottomAnchor.constraint(equalTo: bottomAnchor)
            
        ])
    }
    
    func set(viewModel: UserProfileViewModel) {
        name.text = viewModel.user.name()
        discipline.text = viewModel.user.details()
    }
    
    func configure(viewModel: ProfileHeaderViewModel) {
        connections.attributedText = viewModel.connectionsText
    }
}

