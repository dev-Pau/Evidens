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
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = primaryGray
        label.font = UIFont.addFont(size: 12, scaleStyle: .title2, weight: .regular)
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
        addSubview(contentLabel)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            button.widthAnchor.constraint(equalToConstant: 35),
            button.heightAnchor.constraint(equalToConstant: 35),
            
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: padding / 2),
            titleLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding / 6),
            contentLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: padding),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            
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
        titleLabel.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
        let color = media == .remove ? UIColor.red : UIColor.label
        
        button.configuration?.image = media.image.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal).withTintColor(color)
        titleLabel.textColor = color
        titleLabel.text = media.title
    }
    
    func set(kind: ContentKind) {
        titleLabel.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .semibold)
        titleLabel.text = kind.title
        contentLabel.text = kind.content
        button.configuration?.image = kind.image.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal).withTintColor(.label)
    }
}
