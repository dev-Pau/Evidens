//
//  ProfileImageView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/7/23.
//

import UIKit

class ProfileImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        image = UIImage(named: AppStrings.Assets.profile)
    }
}
