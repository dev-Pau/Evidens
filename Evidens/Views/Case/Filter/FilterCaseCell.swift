//
//  FilterCaseCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/11/23.
//

import UIKit

class FilterCaseCell: UICollectionViewCell {
    
    private let targetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let targetImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: AppStrings.Icons.circle)?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {

        isUserInteractionEnabled = true
        addSubviews(targetLabel, targetImageView)
        NSLayoutConstraint.activate([
            targetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            targetLabel.trailingAnchor.constraint(equalTo: targetImageView.leadingAnchor, constant: -10),
            targetLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            targetImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            targetImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            targetImageView.heightAnchor.constraint(equalToConstant: 25),
            targetImageView.widthAnchor.constraint(equalToConstant: 25)
        ])
    }

    func set(isOn: Bool) {
        targetImageView.image = UIImage(systemName: isOn ? AppStrings.Icons.checkmarkCircleFill : AppStrings.Icons.circle)?.withRenderingMode(.alwaysOriginal).withTintColor((isOn ? primaryColor : separatorColor))
    }
    
    func set(filter: CaseFilter) {
        targetLabel.text = filter.title
    }
}
