//
//  SecondaryEmptyCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/1/23.
//

import UIKit

protocol SecondaryEmptyCellDelegate: AnyObject {
    func didTapContent(_ content: EmptyContent)
}

class SecondaryEmptyCell: UICollectionViewCell {
    
    weak var delegate: SecondaryEmptyCellDelegate?

    private var content: EmptyContent?
    
    private let image: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 17, scaleStyle: .title2, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.addTarget(self, action: #selector(didTapEmptyCellButton), for: .touchUpInside)
        return button
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        let size: CGFloat = UIDevice.isPad ? UIWindow.visibleScreenWidth / 3.5 : UIWindow.visibleScreenWidth / 2.5
        addSubviews(image, titleLabel, contentLabel, contentButton)
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            image.centerXAnchor.constraint(equalTo: centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: size),
            image.heightAnchor.constraint(equalToConstant: size),
            
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            contentButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            contentButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
        ])
        
        image.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        image.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        image.layer.cornerRadius = size / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage?, title: String, description: String, content: EmptyContent) {
        if let image {
            self.image.image = image
        }
        
        titleLabel.text = title
        contentLabel.text = description
        
        
        var container = AttributeContainer()
        
        container.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .semibold, scales: false)
        contentButton.configuration?.attributedTitle = AttributedString(content.title, attributes: container)
        
        self.content = content
    }
    
    @objc func didTapEmptyCellButton() {
        guard let content = content else { return }
        delegate?.didTapContent(content)
    }
}

