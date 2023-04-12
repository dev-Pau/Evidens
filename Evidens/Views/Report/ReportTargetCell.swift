//
//  ReportTargetCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

class ReportTargetCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectionImageView.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")?.withRenderingMode(.alwaysOriginal).withTintColor(isSelected ? primaryColor : .secondaryLabel)
        }
    }
    
    private let reportTargetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .heavy)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reportTargetDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let selectionImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
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
        addSubviews(reportTargetLabel, reportTargetDescriptionLabel, selectionImageView)
        NSLayoutConstraint.activate([
            selectionImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            selectionImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            selectionImageView.heightAnchor.constraint(equalToConstant: 25),
            selectionImageView.widthAnchor.constraint(equalToConstant: 25),
            
            reportTargetLabel.topAnchor.constraint(equalTo: selectionImageView.topAnchor, constant: 3),
            reportTargetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            reportTargetLabel.trailingAnchor.constraint(equalTo: selectionImageView.leadingAnchor, constant: -20),
            
            reportTargetDescriptionLabel.topAnchor.constraint(equalTo: reportTargetLabel.bottomAnchor, constant: 5),
            reportTargetDescriptionLabel.leadingAnchor.constraint(equalTo: reportTargetLabel.leadingAnchor),
            reportTargetDescriptionLabel.trailingAnchor.constraint(equalTo: reportTargetLabel.trailingAnchor),
            reportTargetDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func configure(withTitle title: String, withDescription description: String) {
        reportTargetLabel.text = title
        reportTargetDescriptionLabel.text = description
    }
    
    func hideSelectionHints() {
        selectionImageView.isHidden = true
    }
}
