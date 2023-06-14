//
//  LineSplitView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/6/23.
//

import UIKit

class SpacingView: UIView {
    
    private let leadingView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let trailingView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
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

        addSubviews(leadingView, trailingView)
        backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            leadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingView.topAnchor.constraint(equalTo: topAnchor),
            leadingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingView.widthAnchor.constraint(equalToConstant: 0.4),
            
            trailingView.topAnchor.constraint(equalTo: topAnchor),
            trailingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailingView.widthAnchor.constraint(equalToConstant: 0.4),
            trailingView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
