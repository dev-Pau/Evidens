//
//  GroupVisibilityCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/11/22.
//

import UIKit

protocol GroupVisibilityCellDelegate: AnyObject {
    func didTapVisibility()
}

class GroupVisibilityCell: UICollectionViewCell {
    
    weak var delegate: GroupVisibilityCellDelegate?
    
    private let cellContentView = UIView()
    
    private var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let discoverabilityTitle: UILabel = {
        let label = UILabel()
        label.text = "Discoverability"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private let visibleView = GroupVisibilityView(optionTitle: "Listed", optionDescription: "Group will be visible in search results and can be displayed in your profile.")
    private let nonVisibleView = GroupVisibilityView(optionTitle: "Non listed", optionDescription: "Group does not appear either in search results or in your profile.")
    
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
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        visibleView.delegate = self
        nonVisibleView.delegate = self
        
        addSubviews(topSeparatorView, discoverabilityTitle, visibleView, separatorView, nonVisibleView)
        NSLayoutConstraint.activate([
            topSeparatorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            discoverabilityTitle.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 5),
            discoverabilityTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            discoverabilityTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            visibleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visibleView.topAnchor.constraint(equalTo: discoverabilityTitle.bottomAnchor),
            visibleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visibleView.heightAnchor.constraint(equalToConstant: 70),
            
            separatorView.topAnchor.constraint(equalTo: visibleView.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: visibleView.leadingAnchor, constant: 40),
            separatorView.trailingAnchor.constraint(equalTo: visibleView.trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            nonVisibleView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            nonVisibleView.leadingAnchor.constraint(equalTo: visibleView.leadingAnchor),
            nonVisibleView.trailingAnchor.constraint(equalTo: visibleView.trailingAnchor),
            nonVisibleView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        visibleView.updateVisibility()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func setVisibility(visibility: GroupVisibility) {
        switch visibility {
        case .visible:
            break
        case .nonVisible:
            visibleView.updateVisibility()
            nonVisibleView.updateVisibility()
            delegate?.didTapVisibility()
        }
    }
}

extension GroupVisibilityCell: GroupVisibilityViewDelegate {
    func handleVisibilityChange(isSelected: Bool) {
        if isSelected { return }
        delegate?.didTapVisibility()
        visibleView.updateVisibility()
        nonVisibleView.updateVisibility()
    }
}

protocol GroupVisibilityViewDelegate: AnyObject {
    func handleVisibilityChange(isSelected: Bool)
}

protocol GroupPermissionsViewDelegate: AnyObject {
    func handlePermissionChange(isEnabled: Bool)
}

class GroupVisibilityView: UIView {
    
    weak var delegate: GroupVisibilityViewDelegate?
    weak var permissionDelegate: GroupPermissionsViewDelegate?
    
    private var optionTitle: String
    private var optionDescription: String
    
    var privacyOptionIsSelected: Bool = false
    
    var selectionImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        return iv
    }()
    
    private let visibilityTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let visibilityDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    init(optionTitle: String, optionDescription: String) {
        self.optionTitle = optionTitle
        self.optionDescription = optionDescription
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleVisibilityChange)))
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(selectionImage, visibilityTitle, visibilityDescription)
        NSLayoutConstraint.activate([
            selectionImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            selectionImage.heightAnchor.constraint(equalToConstant: 17),
            selectionImage.widthAnchor.constraint(equalToConstant: 17),
            
            visibilityTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            visibilityTitle.leadingAnchor.constraint(equalTo: selectionImage.trailingAnchor, constant: 10),
            visibilityTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            visibilityDescription.topAnchor.constraint(equalTo: visibilityTitle.bottomAnchor),
            visibilityDescription.leadingAnchor.constraint(equalTo: visibilityTitle.leadingAnchor),
            visibilityDescription.trailingAnchor.constraint(equalTo: visibilityTitle.trailingAnchor)
        ])
        
        visibilityTitle.text = optionTitle
        visibilityDescription.text = optionDescription
    }
    
    @objc func handleVisibilityChange() {
        delegate?.handleVisibilityChange(isSelected: privacyOptionIsSelected)
    }
    
    func updateVisibility() {
        privacyOptionIsSelected.toggle()
        selectionImage.image = UIImage(systemName: privacyOptionIsSelected ? "smallcircle.fill.circle.fill" : "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
    }
    
}
