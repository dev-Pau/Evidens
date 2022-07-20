//
//  CaseImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

class CaseImageCell: UICollectionViewCell {
    
    lazy var caseImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
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
            caseImageView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
