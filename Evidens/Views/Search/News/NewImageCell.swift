//
//  NewImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/3/23.
//

import UIKit

class NewImageCell: UICollectionViewCell {
    
    private let newsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(newsImageView)
        NSLayoutConstraint.activate([
            newsImageView.topAnchor.constraint(equalTo: topAnchor),
            newsImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newsImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newsImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        newsImageView.layer.cornerRadius = 15
        newsImageView.sd_setImage(with: URL(string: "https://firebasestorage.googleapis.com/v0/b/evidens-ec6bd.appspot.com/o/news%2F230213-ohio-train-derailment-2-se-1021a-bcf1b8.jpeg?alt=media&token=92c89015-74dc-4956-bc74-0ec86000d76f"))
    }
}
