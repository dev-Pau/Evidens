//
//  MEProfileImageView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/22.
//

import UIKit

class MEProfileImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFill
        clipsToBounds = true
        isUserInteractionEnabled = true
        image = UIImage(named: "user.profile")
    }
}
