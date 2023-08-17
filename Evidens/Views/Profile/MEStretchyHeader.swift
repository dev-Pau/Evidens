//
//  ProfileHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit

protocol MEStretchyHeaderDelegate: AnyObject {
    func didTapBanner()
}

class MEStretchyHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    weak var delegate: MEStretchyHeaderDelegate?
    
    private lazy var bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = primaryColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
  
    //MARK:  - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        addSubview(bannerImageView)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBannerTap)))
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setBanner(_ imageUrl: String?) {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            bannerImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    @objc func handleBannerTap() {
        delegate?.didTapBanner()
    }
}
