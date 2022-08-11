//
//  CasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/6/22.
//

import UIKit

protocol CasesCellDelegate: AnyObject {
    func delete(_ cell: CasesCell)
}

class CasesCell: UICollectionViewCell {
    
    weak var delegate: CasesCellDelegate?
    
    let cellImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.backgroundColor = lightGrayColor
        return iv
    }()
    
    lazy var deleteImageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = .red.withAlphaComponent(0.7)
        button.configuration?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18)).withTintColor(.white)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        layer.cornerRadius = 10
        
        addSubviews(cellImage, deleteImageButton)
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: topAnchor),
            cellImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            deleteImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            deleteImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            deleteImageButton.heightAnchor.constraint(equalToConstant: 26),
            deleteImageButton.widthAnchor.constraint(equalToConstant: 26)
        ])
    }
    
    func set(image: UIImage) {
        cellImage.image = image
    }
    
    @objc func handleDelete() {
        delegate?.delete(self)
    }
}
