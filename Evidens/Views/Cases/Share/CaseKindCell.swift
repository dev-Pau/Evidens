//
//  CaseKindCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/7/22.
//

import UIKit

class CaseKindCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectionImage.image = UIImage(systemName: isSelected ? AppStrings.Icons.checkmarkCircleFill : AppStrings.Icons.circle)?.withRenderingMode(.alwaysOriginal).withTintColor(isSelected ? primaryColor : primaryGray)
        }
    }

    private let itemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private let selectionImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: AppStrings.Icons.circle)?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
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
        addSubviews(itemLabel, selectionImage, separatorView)
        
        NSLayoutConstraint.activate([
            selectionImage.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            selectionImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            selectionImage.heightAnchor.constraint(equalToConstant: 25),
            selectionImage.widthAnchor.constraint(equalToConstant: 25),
            
            itemLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            itemLabel.trailingAnchor.constraint(equalTo: selectionImage.leadingAnchor, constant: 10),
            itemLabel.heightAnchor.constraint(equalToConstant: 20),
            
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func set(item: CaseItem) {
        itemLabel.text = item.title
    }
    
    func set(phase: CasePhase) {
        itemLabel.text = phase.title
    }
}
