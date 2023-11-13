//
//  ReferenceHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/4/23.
//

import UIKit
import LinkPresentation

protocol ReferenceHeaderDelegate: AnyObject {
    func didTapEditReference(_ reference: Reference)
}

class ReferenceHeader: UICollectionReusableView {
    weak var delegate: ReferenceHeaderDelegate?

    var reference: Reference? {
        didSet {
            configure()
        }
    }
    
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
        
        switch reference.option {
        case .link:
            fetchPreview(for: reference)
        case .citation:
            configurePreview(for: reference)
        }
    }
    
    private func fetchPreview(for reference: Reference) {
        guard let url = URL(string: reference.referenceText) else { return }
        let linkPreview = LPLinkView()
        linkPreview.isUserInteractionEnabled = false
        linkPreview.translatesAutoresizingMaskIntoConstraints = false
        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
            guard let _ = self else { return }
            guard let data = metadata, error == nil else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                data.videoProvider = nil
                data.remoteVideoURL = nil
                data.imageProvider = nil
                
                linkPreview.metadata = data

                strongSelf.addSubview(linkPreview)
                NSLayoutConstraint.activate([
                    linkPreview.leadingAnchor.constraint(equalTo: strongSelf.leadingAnchor),
                    linkPreview.topAnchor.constraint(equalTo: strongSelf.topAnchor),
                    linkPreview.bottomAnchor.constraint(equalTo: strongSelf.bottomAnchor),
                    linkPreview.trailingAnchor.constraint(equalTo: strongSelf.trailingAnchor)
                ])
                
                strongSelf.layoutIfNeeded()
            }
        }
    }
    
    private func configurePreview(for reference: Reference) {
        let linkPreview = LPLinkView()
        linkPreview.isUserInteractionEnabled = false
        linkPreview.translatesAutoresizingMaskIntoConstraints = false
        
        let data = LPLinkMetadata()
        data.title = reference.referenceText
        
        //let iconImage = UIImage(named: AppStrings.Assets.quote)
        let iconImage = UIImage(systemName: AppStrings.Icons.fillHeart, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        data.iconProvider = NSItemProvider(object: iconImage)
        linkPreview.metadata = data
        
        addSubview(linkPreview)
        NSLayoutConstraint.activate([
            linkPreview.leadingAnchor.constraint(equalTo: leadingAnchor),
            linkPreview.topAnchor.constraint(equalTo: topAnchor),
            linkPreview.bottomAnchor.constraint(equalTo: bottomAnchor),
            linkPreview.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        layoutIfNeeded()
    }
    
    @objc func handleLinkPreviewTap() {
        guard let reference = reference else { return }
        delegate?.didTapEditReference(reference)
    }
}
