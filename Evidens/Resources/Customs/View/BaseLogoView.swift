//
//  BaseLogoView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/8/23.
//

import UIKit

class BaseLogoView: UIView {
    
    private var widthImageAnchor: NSLayoutConstraint!
    private var heightImageAnchor: NSLayoutConstraint!
    
    let image: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.image = UIImage(named: AppStrings.Assets.whiteLogo)
        iv.contentMode = .scaleAspectFit
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
        addSubview(image)
        heightImageAnchor = image.heightAnchor.constraint(equalToConstant: 200)
        widthImageAnchor = image.widthAnchor.constraint(equalToConstant: 300)
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: centerXAnchor),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightImageAnchor,
            widthImageAnchor,
        ])
    }
    
    func hideLogo(completion: @escaping() -> Void) {
        
    }
}
