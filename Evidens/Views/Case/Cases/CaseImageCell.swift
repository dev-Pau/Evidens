//
//  CaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

protocol CaseImageCellDelegate: AnyObject {
    func didTapImage(_ imageView: UIImageView)
}

class CaseImageCell: UICollectionViewCell {
    
    weak var delegate: CaseImageCellDelegate?
    
    lazy var caseImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 12
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(caseImageView)
        
        NSLayoutConstraint.activate([
            caseImageView.topAnchor.constraint(equalTo: topAnchor),
            caseImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            caseImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            caseImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        layer.borderWidth = 0.4
        layer.borderColor = separatorColor.cgColor
        layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(maskedCorners: CACornerMask) {
        layer.maskedCorners = maskedCorners
        caseImageView.layer.maskedCorners = maskedCorners
    }
    
    @objc func handleImageTap() {
        guard let _ = caseImageView.image else { return }
        delegate?.didTapImage(caseImageView)
    }
}
