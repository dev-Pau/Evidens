//
//  PostMenuHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/6/22.
//

import UIKit

class PostMenuHeader: UICollectionReusableView {
    
    
    private let padding: CGFloat = 10
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.layer.cornerRadius = 3
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
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            
            separator.centerXAnchor.constraint(equalTo: centerXAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
}
