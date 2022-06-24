//
//  PostAttachementHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/6/22.
//

import UIKit


class PostAttachementHeader: UICollectionReusableView {
       
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = grayColor
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
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}


