//
//  ContentLinkCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/12/23.
//

import UIKit
import LinkPresentation
import UniformTypeIdentifiers

protocol ContentLinkCellDelegate: AnyObject {
    func didAddLink()
    func didDeleteLink()
}

class ContentLinkCell: UICollectionViewCell {
    
    weak var delegate: ContentLinkCellDelegate?

    private let linkImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .secondaryLabel
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()

        button.configuration?.image = UIImage(systemName: AppStrings.Icons.xmark, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 13, height: 13))
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = .black.withAlphaComponent(0.8)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let websiteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .black.withAlphaComponent(0.5)
        configuration.baseForegroundColor = .white
        
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        button.configuration = configuration
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 12
        layer.borderWidth = 0.4
        layer.borderColor = UIColor.clear.cgColor
        
        linkImageView.image = nil
        websiteButton.configuration?.attributedTitle = AttributedString("")
        
        addSubviews(linkImageView, deleteButton, websiteButton)
        
        NSLayoutConstraint.activate([
            linkImageView.topAnchor.constraint(equalTo: topAnchor),
            linkImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            linkImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            linkImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            deleteButton.heightAnchor.constraint(equalToConstant: 26),
            deleteButton.widthAnchor.constraint(equalToConstant: 26),
            
            websiteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            websiteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
        ])
    }
    
    @objc func handleDelete() {
        delegate?.didDeleteLink()
    }
    
    func configure(linkMetadata: LPLinkMetadata?) {
        guard let linkMetadata else { return }
        layer.borderColor = separatorColor.cgColor
        
        if let iconProvider = linkMetadata.imageProvider {
            iconProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
                guard let _ = self else { return }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.linkImageView.image = image
                        strongSelf.delegate?.didAddLink()
                    }
                }
            }
        } else {
            delegate?.didDeleteLink()
        }
        
        if let url = linkMetadata.originalURL, let host = url.host {
            let domain = host.replacingOccurrences(of: "^www.", with: "", options: .regularExpression)
            
            var container = AttributeContainer()
            container.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular, scales: false)
            websiteButton.configuration?.attributedTitle = AttributedString(domain, attributes: container)
        }
    }
}
