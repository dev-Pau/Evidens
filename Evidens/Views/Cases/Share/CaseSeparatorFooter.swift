//
//  CaseSeparatorFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/5/23.
//

import UIKit

class CaseSeparatorFooter: UICollectionReusableView {
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
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
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
}
