//
//  CasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/6/22.
//

import UIKit

protocol ShareCaseImageCellDelegate: AnyObject {
    func delete(_ cell: ShareCaseImageCell)
}

class ShareCaseImageCell: UICollectionViewCell {
    
    weak var delegate: ShareCaseImageCellDelegate?
    
    let cellImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .quaternarySystemFill
        iv.layer.borderWidth = 0.4
        iv.layer.borderColor = separatorColor.cgColor
        return iv
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()

        button.configuration?.image = UIImage(systemName: AppStrings.Icons.xmark, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 13, height: 13))
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = .black.withAlphaComponent(0.8)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var imageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()

        button.configuration?.image = UIImage(systemName: AppStrings.Icons.exclamation, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18))
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = .black.withAlphaComponent(0.8)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let scale = 200.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 10
        layer.borderWidth = 0.4
        layer.borderColor = separatorColor.cgColor

        addSubviews(cellImage)

        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: topAnchor),
            cellImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            cellImage.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func set(image: CaseImage) {
        if image.containsFaces {
            cellImage.alpha = 0.3
            cellImage.image = image.image
            configureWithFaceImage(image.image)
        } else {
            cellImage.alpha = 1
            cellImage.image = image.image
            configureWithCaseImage(image.image)
        }
    }
    
    func set(image: UIImage) {
        cellImage.image = image
        configureWithCaseImage(image)
    }
    
    private func configureWithCaseImage(_ image: UIImage) {
        imageButton.isHidden = true
        
        addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            deleteButton.heightAnchor.constraint(equalToConstant: 26),
            deleteButton.widthAnchor.constraint(equalToConstant: 26)
        ])
    }
    
    private func configureWithFaceImage(_ image: UIImage) {

        imageButton.isHidden = false

        addSubviews(imageButton, deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            deleteButton.heightAnchor.constraint(equalToConstant: 26),
            deleteButton.widthAnchor.constraint(equalToConstant: 26),
            
            imageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageButton.heightAnchor.constraint(equalToConstant: 33),
            imageButton.widthAnchor.constraint(equalToConstant: 33)
        ])
    }
    
    func restartCellConfiguration() {
        cellImage.image = nil
        deleteButton.removeFromSuperview()
        imageButton.removeFromSuperview()
    }
    
    @objc func handleDelete() {
        delegate?.delete(self)
    }
}
