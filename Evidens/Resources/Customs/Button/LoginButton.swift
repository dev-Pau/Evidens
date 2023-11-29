//
//  LoginButton.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/9/23.
//

import UIKit

class LoginButton: UIButton {
    
    private var kind: LoginKind?
    
    init(kind: LoginKind) {
        self.kind = kind
        super.init(frame: .zero)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let kind = kind else { return }
        translatesAutoresizingMaskIntoConstraints = false
        configuration = .filled()
        configuration?.baseBackgroundColor = .white
        configuration?.background.strokeColor = separatorColor
        configuration?.background.strokeWidth = 1

        configuration?.image = kind.image
        configuration?.imagePadding = 15
        configuration?.baseForegroundColor = .black
        configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .heavy)
        configuration?.attributedTitle = AttributedString(kind.title, attributes: container)
    }
}
