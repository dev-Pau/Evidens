//
//  GroupVisibilityCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/11/22.
//

import UIKit

class GroupVisibilityCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    private var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let visibleView = GroupVisibilityView(optionTitle: "Listed", optionDescription: "Group will be visible in search results and can be displayed in your profile.")
    private let nonVisibleView = GroupVisibilityView(optionTitle: "Non listed", optionDescription: "Group does not appear either in search results or in your profile.")
    
    private var separatorView: UIView = {
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
        addSubview(cellContentView)
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        visibleView.delegate = self
        nonVisibleView.delegate = self
        
        addSubviews(topSeparatorView, visibleView, separatorView, nonVisibleView)
        NSLayoutConstraint.activate([
            topSeparatorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            visibleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visibleView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor),
            visibleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visibleView.heightAnchor.constraint(equalToConstant: 70),
            
            separatorView.topAnchor.constraint(equalTo: visibleView.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: visibleView.leadingAnchor, constant: 40),
            separatorView.trailingAnchor.constraint(equalTo: visibleView.trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
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
    
    func setVisibility(visibility: Group.Visibility) {
        switch visibility {
        case .visible:
            break
        case .nonVisible:
            visibleView.updateVisibility()
            nonVisibleView.updateVisibility()
        }
    }
}

extension GroupVisibilityCell: GroupVisibilityViewDelegate {
    func handleVisibilityChange(isSelected: Bool) {
        if isSelected { return }
        visibleView.updateVisibility()
        nonVisibleView.updateVisibility()
    }
}

protocol GroupVisibilityViewDelegate: AnyObject {
    func handleVisibilityChange(isSelected: Bool)
}

class GroupVisibilityView: UIView {
    
    weak var delegate: GroupVisibilityViewDelegate?
    
    private var optionTitle: String
    private var optionDescription: String
    
    private var privacyOptionIsSelected: Bool = false
    
    private let selectionImage: UIImageView = {
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
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let visibilityDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = grayColor
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
