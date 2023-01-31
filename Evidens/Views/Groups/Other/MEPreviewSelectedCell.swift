//
//  MEPreviewSelectedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/1/23.
//

import UIKit


class MEPreviewSelectedCell: UICollectionViewCell {
    
    private let categoriesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .secondarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .label

        button.configuration?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.imagePlacement = .trailing
        button.configuration?.imagePadding = 5

        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = .quaternarySystemFill
        button.configuration?.background.strokeWidth = 1
        button.isUserInteractionEnabled = false
        return button
    }()
    
    var selectedName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.sizeToFit()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private let xmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        iv.clipsToBounds = true
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
        backgroundColor = primaryColor
        layer.cornerRadius = 30 / 2

        addSubviews(selectedName, xmarkImageView)
        NSLayoutConstraint.activate([
            selectedName.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            selectedName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -35),
            
            xmarkImageView.centerYAnchor.constraint(equalTo: selectedName.centerYAnchor),
            xmarkImageView.leadingAnchor.constraint(equalTo: selectedName.trailingAnchor, constant: 10),
            xmarkImageView.widthAnchor.constraint(equalToConstant: 15),
            
        ])
    }
    
    func configure(with category: String) {
        backgroundColor = primaryColor
        selectedName.text = category
        selectedName.textColor = .white
        xmarkImageView.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
    }
    
    func configureWithDefaultValues() {
        backgroundColor = .quaternarySystemFill
        selectedName.text = "Select up to 5 users"
        selectedName.textColor = .secondaryLabel
        xmarkImageView.image = UIImage(systemName: "arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.label)
    }
}

