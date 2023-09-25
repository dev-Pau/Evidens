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
    
    private var caseImageWith: NSLayoutConstraint!
    
    let cellImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let placeholderImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = false
        iv.image = UIImage(named: AppStrings.Assets.image)?.withTintColor(.label)
        return iv
    }()
    
    lazy var deleteImageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()

        button.configuration?.image = UIImage(systemName: AppStrings.Icons.xmark, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 13, height: 13))
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = .black.withAlphaComponent(0.8)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var editImageButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()

        button.configuration?.image = UIImage(systemName: AppStrings.Icons.paintbrush, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18))
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
        
        addSubviews(cellImage, placeholderImage)
        caseImageWith = cellImage.widthAnchor.constraint(equalToConstant: frame.width)
        caseImageWith.isActive = true
        
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: topAnchor),
            cellImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            placeholderImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderImage.heightAnchor.constraint(equalToConstant: 50),
            placeholderImage.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func set(image: CaseImage) {
        if let faceImage = image.faceImage {
            if image.isRevealed == false {
                cellImage.alpha = 0.3
                cellImage.image = image.image
                configureWithFaceImage(image.image)
            } else {
                cellImage.alpha = 1
                cellImage.image = faceImage
                configureWithCaseImage(faceImage)
            }
            
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
        let ratio = image.size.width / image.size.height
        let newWidth = min(UIScreen.main.bounds.width * 0.8, ratio * scale)
        cellImage.image = image.scalePreservingAspectRatio(targetSize: CGSize(width: newWidth, height: frame.height))
        caseImageWith.isActive = false
        placeholderImage.isHidden = true
        editImageButton.isHidden = true
        cellImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(deleteImageButton)
        NSLayoutConstraint.activate([
            deleteImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            deleteImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            deleteImageButton.heightAnchor.constraint(equalToConstant: 26),
            deleteImageButton.widthAnchor.constraint(equalToConstant: 26)
        ])
    }
    
    private func configureWithFaceImage(_ image: UIImage) {
        let ratio = image.size.width / image.size.height
        let newWidth = ratio * scale
        cellImage.image = image.scalePreservingAspectRatio(targetSize: CGSize(width: newWidth, height: frame.height))
        caseImageWith.isActive = false
        placeholderImage.isHidden = true
        editImageButton.isHidden = false
        cellImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        addSubviews(editImageButton, deleteImageButton)
        
        NSLayoutConstraint.activate([
            deleteImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            deleteImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            deleteImageButton.heightAnchor.constraint(equalToConstant: 26),
            deleteImageButton.widthAnchor.constraint(equalToConstant: 26),
            
            editImageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            editImageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            editImageButton.heightAnchor.constraint(equalToConstant: 33),
            editImageButton.widthAnchor.constraint(equalToConstant: 33)
        ])
    }
    
    func restartCellConfiguration() {
        cellImage.image = nil
        deleteImageButton.removeFromSuperview()
        editImageButton.removeFromSuperview()
        cellImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = false
        placeholderImage.isHidden = false
        caseImageWith.isActive = true
    }
    
    @objc func handleDelete() {
        delegate?.delete(self)
    }
}
