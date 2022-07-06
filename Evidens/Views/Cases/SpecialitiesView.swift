//
//  SpecialitiesView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit

protocol SpecialitiesViewDelegate: AnyObject {
    func didTapAddSpecialities()
}

class SpecialitiesView: UIView {
    
    weak var delegate: SpecialitiesViewDelegate?
    
    private lazy var specialitiesLabel: UILabel = {
        let label = UILabel()
        label.text = "Specialities"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var specialitiesButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.image = UIImage(systemName: "plus")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.white)
        button.configuration?.title = "Tap to add specialities"
        button.configuration?.imagePadding = 5
        button.configuration?.imagePlacement = .leading
        button.configuration?.baseBackgroundColor = primaryColor
        button.alpha = 0.8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddSpecialities), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(specialitiesLabel, specialitiesButton)
        
        NSLayoutConstraint.activate([
            
            specialitiesLabel.topAnchor.constraint(equalTo: topAnchor),
            specialitiesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            specialitiesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            specialitiesButton.topAnchor.constraint(equalTo: specialitiesLabel.bottomAnchor, constant: 5),
            specialitiesButton.leadingAnchor.constraint(equalTo: specialitiesLabel.leadingAnchor),
        ])
    }
    
    func configure(collectionView: UICollectionView) {
        specialitiesButton.removeFromSuperview()
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: specialitiesLabel.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 45)
            
        ])
    }
    
    @objc func handleAddSpecialities() {
        delegate?.didTapAddSpecialities()
    }
}
