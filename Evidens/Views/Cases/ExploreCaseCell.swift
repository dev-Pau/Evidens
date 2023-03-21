//
//  ExploreCaseCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/3/23.
//

import UIKit

class ExploreCaseCell: UICollectionViewCell {
    
    var viewModel: CaseViewModel? {
        didSet {
            configureWithCase()
        }
    }
    
    private let caseImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemPink
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "case.image.empty")
        return iv
    }()
    
    private let caseTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "We herein report a case of a 38 y/o male with an unusual case of disease. The disease consisted of features typical of respiratory, with additional knee pain, signifying a heart attack."
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
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
        addSubviews(caseImageView, caseTitleLabel)
        NSLayoutConstraint.activate([
            caseImageView.topAnchor.constraint(equalTo: topAnchor),
            caseImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            caseImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseImageView.heightAnchor.constraint(equalToConstant: bounds.width),
            
            caseTitleLabel.topAnchor.constraint(equalTo: caseImageView.bottomAnchor, constant: 5),
            caseTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            caseTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        caseImageView.layer.cornerRadius = 7
    }
    
    private func configureWithCase() {
        guard let viewModel = viewModel else { return }
    }
}
