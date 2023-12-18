//
//  LinkView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/12/23.
//

import UIKit
import LinkPresentation
import UniformTypeIdentifiers


class LinkView: UIView {
    
    private let linkImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 16, scaleStyle: .largeTitle, weight: .medium)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .regular)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.borderWidth = 0.4
        layer.borderColor = separatorColor.cgColor
        layer.cornerRadius = 12
        
        addSubviews(linkImageView, urlLabel, titleLabel)
        NSLayoutConstraint.activate([
            linkImageView.topAnchor.constraint(equalTo: topAnchor),
            linkImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            linkImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            linkImageView.heightAnchor.constraint(equalToConstant: 180),
            
            urlLabel.topAnchor.constraint(equalTo: linkImageView.bottomAnchor, constant: 10),
            urlLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            urlLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    func configure(withLink link: String) {
        fetchPreview(for: link)
    }
    
    private func fetchPreview(for link: String) {
        guard let url = URL(string: link) else { return }
        
        if let cachedLink = ECache.shared.getObject(key: link as AnyObject) as? BaseLink {
            urlLabel.text = cachedLink.url
            titleLabel.text = cachedLink.title
            linkImageView.image = cachedLink.image
            return
        } else {
            urlLabel.text = String()
            titleLabel.text = String()
            linkImageView.image = nil
        }

        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
            guard let _ = self else { return }
            
            guard let metadata, error == nil, let title = metadata.title else {
                
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.urlLabel.text = link
                strongSelf.titleLabel.text = title
            }

            if let imageProvider = metadata.imageProvider {
                
                imageProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
                    guard let _ = self else { return }
                    if let data = data, let image = UIImage(data: data) {
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.linkImageView.image = image
                            
                            let postLink = BaseLink(title: title, url: link, image: image)
                            ECache.shared.saveObject(object: postLink, key: link as AnyObject)
                        }
                    } else {
                        return
                    }
                }
            }
        }
    }
}
