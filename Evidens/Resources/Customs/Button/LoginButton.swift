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
        tintAdjustmentMode = .normal
        translatesAutoresizingMaskIntoConstraints = false
        configuration = .filled()
        configuration?.baseBackgroundColor = .white
        configuration?.background.strokeColor = K.Colors.separatorColor
        configuration?.background.strokeWidth = 1

        configuration?.image = kind.image
        configuration?.imagePadding = 15
        configuration?.baseForegroundColor = .black
        configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .heavy, scales: false)
        configuration?.attributedTitle = AttributedString(kind.title, attributes: container)
    }
}
