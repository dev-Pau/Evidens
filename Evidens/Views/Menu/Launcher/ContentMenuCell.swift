//
//  PostMenuCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/6/22.
//

import UIKit


class ContentMenuCell: UICollectionViewCell {
    
    private let padding: CGFloat = 15

    lazy var button: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .callout)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
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
        addSubview(button)
        addSubview(titleLabel)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            button.widthAnchor.constraint(equalToConstant: 35),
            button.heightAnchor.constraint(equalToConstant: 35),
            
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func set(withText text: String, withImage image: UIImage, withBaseColor color: UIColor? = .label) {
        button.configuration?.image = image.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal).withTintColor(color ?? .label)
        titleLabel.text = text
    }
    
    func set(media: MediaKind) {
        button.configuration?.image = media.image.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal).withTintColor(.label)
        titleLabel.text = media.title
    }
}
