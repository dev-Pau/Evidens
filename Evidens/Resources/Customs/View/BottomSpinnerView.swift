//
//  BottomSpinnerView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/8/23.
//

import UIKit

class BottomSpinnerView: UIActivityIndicatorView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        stopAnimating()
        hidesWhenStopped = true
    }
}
