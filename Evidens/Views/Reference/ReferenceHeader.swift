//
//  ReferenceHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/4/23.
//

import UIKit
import LinkPresentation
import UniformTypeIdentifiers
import SDWebImage

protocol ReferenceHeaderDelegate: AnyObject {
    func didTapEditReference(_ reference: Reference)
    func referenceNotValid()
}

class ReferenceHeader: UICollectionReusableView {
    weak var delegate: ReferenceHeaderDelegate?
    
    private var isLoaded: Bool = false

    var reference: Reference? {
        didSet {
            configure()
        }
    }
    
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .medium
        return indicator
    }()
    
    private let referenceImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        iv.clipsToBounds = true
        return iv
    }()
    
    private let referenceTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .medium, scales: false)
        label.textColor = .label
        label.numberOfLines = UIDevice.isPad ? 1 : 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let referenceContent: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 14, scaleStyle: .body, weight: .regular, scales: false)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLinkPreviewTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let reference = reference else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("PostHeader"), object: nil)
        
        if isLoaded {
            isLoaded.toggle()
            return
        }
        
        layer.cornerRadius = 12
        layer.borderWidth = 0.4
        layer.borderColor = UIColor.clear.cgColor
        
        referenceImage.image = nil
        referenceImage.backgroundColor = .clear
        referenceTitle.text = ""
        referenceContent.text = ""
        
        let height: CGFloat = UIDevice.isPad ? referenceTitle.font.lineHeight + 5 : referenceTitle.font.lineHeight * 2 + 5
        referenceImage.subviews.forEach { $0.removeFromSuperview() }
        
        addSubviews(referenceImage, referenceTitle, referenceContent, activityIndicator)
        NSLayoutConstraint.activate([
            
            referenceImage.topAnchor.constraint(equalTo: topAnchor),
            referenceImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            referenceImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceImage.widthAnchor.constraint(equalToConstant: 75),
            
            referenceTitle.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            referenceTitle.leadingAnchor.constraint(equalTo: referenceImage.trailingAnchor, constant: 10),
            referenceTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            referenceTitle.heightAnchor.constraint(equalToConstant: height),

            referenceContent.topAnchor.constraint(equalTo: referenceTitle.bottomAnchor),
            referenceContent.leadingAnchor.constraint(equalTo: referenceImage.trailingAnchor, constant: 10),
            referenceContent.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            referenceContent.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
                
        switch reference.option {
        case .link:
            activityIndicator.startAnimating()
            fetchPreview(for: reference)
        case .citation:
            activityIndicator.stopAnimating()
            configurePreview(for: reference)
        }
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        isLoaded = true
    }
    
    private func fetchPreview(for reference: Reference) {
        guard let url = URL(string: reference.referenceText) else { return }

        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
            guard let strongSelf = self else { return }
            
            guard let metadata, error == nil, let title = metadata.title else {
                strongSelf.reference = nil
                
                strongSelf.delegate?.referenceNotValid()
                return
            }
            
            if let imageProvider = metadata.imageProvider {
                
                imageProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
                    guard let strongSelf = self else { return }
                    if let data = data, let image = UIImage(data: data) {
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.referenceImage.image = image
                            strongSelf.referenceTitle.text = title
                            strongSelf.referenceContent.text = reference.option.message
                            strongSelf.layer.borderColor = separatorColor.cgColor
                            strongSelf.activityIndicator.stopAnimating()
                        }
                    } else {
                        strongSelf.delegate?.referenceNotValid()
                        return
                    }
                }
            } else if let iconProvider = metadata.iconProvider {
                iconProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
                    guard let strongSelf = self else { return }
                    if let data = data, let image = UIImage(data: data) {
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.referenceImage.image = image
                            strongSelf.referenceTitle.text = title
                            strongSelf.referenceContent.text = reference.option.message
                            strongSelf.layer.borderColor = separatorColor.cgColor
                            strongSelf.activityIndicator.stopAnimating()
                        }
                    } else {
                        strongSelf.delegate?.referenceNotValid()
                        return
                    }
                }
            }
        }
    }
    
    private func configurePreview(for reference: Reference) {
        referenceImage.backgroundColor = primaryColor
        referenceTitle.text = reference.referenceText
        referenceContent.text = reference.option.message
        layer.borderColor = separatorColor.cgColor
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(named: AppStrings.Assets.fillQuote)!.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
        
        referenceImage.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: referenceImage.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: referenceImage.centerYAnchor)
        ])
    }
    
    @objc func handleLinkPreviewTap() {
        guard let reference = reference else { return }
        delegate?.didTapEditReference(reference)
    }
    
    private func formatUrl(_ url: URL?) -> String {
        if let url = url, let host = url.host {
            let domain = host.replacingOccurrences(of: "^www.", with: "", options: .regularExpression)
            return domain
        }
        
        return ""
    }
}
