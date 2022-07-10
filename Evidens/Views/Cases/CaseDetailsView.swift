//
//  SpecialitiesView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit

class CaseDetailsView: UIView {
    
    private var title: String?
    
    private lazy var specialitiesInfo: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var specialitiesLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var chevronButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "chevron.right")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        return button
    }()
    
    private lazy var chevronEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "chevron.right")?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withTintColor(grayColor)
        return button
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var editButton: UILabel = {
        let label = UILabel()
        label.text = "Edit"
        label.textColor = primaryColor
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(title: String) {
        super.init(frame: .zero)
        self.title = title
        configure()
    }
    
    init(collectionView: UICollectionView) {
        super.init(frame: .zero)
        configure(collectionView: collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        specialitiesInfo.text = title
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(topView, specialitiesInfo, chevronButton)

        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            topView.heightAnchor.constraint(equalToConstant: 1),
            
            chevronButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            chevronButton.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
            chevronButton.heightAnchor.constraint(equalToConstant: 20),
            chevronButton.widthAnchor.constraint(equalToConstant: 20),
            
            specialitiesInfo.centerYAnchor.constraint(equalTo: chevronButton.centerYAnchor),
            specialitiesInfo.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            specialitiesInfo.trailingAnchor.constraint(equalTo: chevronButton.leadingAnchor, constant: -10),
            specialitiesInfo.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func configure(collectionView: UICollectionView) {
        specialitiesLabel.text = title

        addSubviews(specialitiesLabel, collectionView, editButton, chevronEditButton)
        specialitiesInfo.isHidden = true
        chevronButton.isHidden = true
        
        NSLayoutConstraint.activate([
            
            chevronEditButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            chevronEditButton.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 6),
            chevronEditButton.heightAnchor.constraint(equalToConstant: 10),
            chevronEditButton.widthAnchor.constraint(equalToConstant: 10),
            
            editButton.centerYAnchor.constraint(equalTo: chevronEditButton.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: chevronEditButton.leadingAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 10),
            editButton.widthAnchor.constraint(equalToConstant: 25),
        
            specialitiesLabel.centerYAnchor.constraint(equalTo: chevronEditButton.centerYAnchor),
            specialitiesLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            specialitiesLabel.trailingAnchor.constraint(equalTo: editButton.trailingAnchor),
            specialitiesLabel.heightAnchor.constraint(equalToConstant: 20),
             
            collectionView.topAnchor.constraint(equalTo: specialitiesLabel.bottomAnchor, constant: 3),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}
