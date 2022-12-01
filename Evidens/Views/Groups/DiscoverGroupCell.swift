//
//  GroupManagerHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/22.
//

import UIKit

protocol DiscoverGroupCellDelegate: AnyObject {
    func didTapDiscover()
}

class DiscoverGroupCell: UICollectionViewCell {
    
    weak var delegate: DiscoverGroupCellDelegate?
    
    private let cellContentView = UIView()
    
    private let exploreImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "safari", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        return iv
    }()
    
    private let exploreTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover groups"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let exploreDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Find trusted communities that other members created"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private lazy var exploreGroupsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = primaryColor
        button.tintAdjustmentMode = .normal
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 15)
        button.configuration?.attributedTitle = AttributedString("Discover", attributes: container)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleDiscover), for: .touchUpInside)
        
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightColor
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
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        cellContentView.backgroundColor = .white
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 130),
        ])
        
        cellContentView.addSubviews(exploreImage, exploreTitleLabel, exploreDescriptionLabel, exploreGroupsButton, separatorView)
        
        NSLayoutConstraint.activate([
            exploreImage.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            exploreImage.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            exploreImage.heightAnchor.constraint(equalToConstant: 30),
            exploreImage.widthAnchor.constraint(equalToConstant: 30),
            
            exploreTitleLabel.topAnchor.constraint(equalTo: exploreImage.topAnchor),
            exploreTitleLabel.leadingAnchor.constraint(equalTo: exploreImage.trailingAnchor, constant: 10),
            exploreTitleLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            
            exploreDescriptionLabel.topAnchor.constraint(equalTo: exploreTitleLabel.bottomAnchor, constant: 5),
            exploreDescriptionLabel.leadingAnchor.constraint(equalTo: exploreTitleLabel.leadingAnchor),
            exploreDescriptionLabel.trailingAnchor.constraint(equalTo: exploreTitleLabel.trailingAnchor),
            
            exploreGroupsButton.topAnchor.constraint(equalTo: exploreDescriptionLabel.bottomAnchor, constant: 10),
            exploreGroupsButton.leadingAnchor.constraint(equalTo: exploreDescriptionLabel.leadingAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        exploreImage.layer.cornerRadius = 30 / 2
    }
    
    @objc func handleDiscover() {
        delegate?.didTapDiscover()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
