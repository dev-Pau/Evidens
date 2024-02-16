//
//  EllipsisButton.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/23.
//

import UIKit

class EllipsisButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: AppStrings.Icons.ellipsis)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        configuration.baseForegroundColor = .white
        configuration.buttonSize = .small
        self.tintAdjustmentMode = .normal
        self.configuration = configuration
        
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
