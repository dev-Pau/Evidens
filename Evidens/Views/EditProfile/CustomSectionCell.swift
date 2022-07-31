//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/7/22.
//

import UIKit

protocol CustomSectionCellDelegate: AnyObject {
    func didTapConfigureSections()
}

class CustomSectionCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    weak var delegate: CustomSectionCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 1
        label.text = "Configure custom sections"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let tf = UILabel()
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.text = "Build on custom sections to your profile will  help you grow your network, get discovered easily and build more relationships"
        label.textColor = grayColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addSectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleConfigureSections), for: .touchUpInside)
        return button
    }()
    
    /*
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
     */
        
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
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
        backgroundColor = .white
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(titleLabel, subtitleLabel, separatorView, addSectionButton)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            addSectionButton.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            addSectionButton.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            addSectionButton.heightAnchor.constraint(equalToConstant: 20),
            addSectionButton.widthAnchor.constraint(equalToConstant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: addSectionButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: addSectionButton.leadingAnchor, constant: -10),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 1))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    @objc func handleConfigureSections() {
        delegate?.didTapConfigureSections()
    }
}
