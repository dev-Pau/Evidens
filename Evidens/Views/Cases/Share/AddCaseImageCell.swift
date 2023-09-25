//
//  AddCaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/9/23.
//

import UIKit

protocol AddCaseImageCellDelegate: AnyObject {
    func didTapAddImage()
}

class AddCaseImageCell: UICollectionViewCell {
    
    weak var delegate: AddCaseImageCellDelegate?
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        configuration.baseBackgroundColor = primaryColor
        configuration.buttonSize = .mini
        configuration.cornerStyle = .capsule
        button.configuration = configuration
        button.addTarget(self, action: #selector(handleAddImage), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(addButton)
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 35),
            addButton.widthAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    @objc func handleAddImage() {
        delegate?.didTapAddImage()
    }
}
