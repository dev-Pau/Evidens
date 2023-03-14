//
//  NewImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/3/23.
//

import UIKit

class NewImageFooter: UICollectionReusableView {
    
    private let newsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    
    private let newsImageTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
       
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(newsImageView, newsImageTitleLabel)
        
        NSLayoutConstraint.activate([
            newsImageView.topAnchor.constraint(equalTo: topAnchor),
            newsImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            newsImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            newsImageView.heightAnchor.constraint(equalToConstant: 250),

            newsImageTitleLabel.leadingAnchor.constraint(equalTo: newsImageView.leadingAnchor, constant: 5),
            newsImageTitleLabel.trailingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: -5),
            newsImageTitleLabel.bottomAnchor.constraint(equalTo: newsImageView.bottomAnchor, constant: -7)
             
        ])
        
        newsImageView.insertSubview(blurView, at: 0)
        blurView.frame = CGRect(x: 0, y: 200, width: frame.width, height: 50)
        //blurView.contentView.addSubview(newsImageTitleLabel)
        //newsImageTitleLabel.frame = blurView.contentView.bounds
        
        newsImageView.layer.cornerRadius = 15
      /*
        newsImageView.sd_setImage(with: URL(string: "https://firebasestorage.googleapis.com/v0/b/evidens-ec6bd.appspot.com/o/news%2F230213-ohio-train-derailment-2-se-1021a-bcf1b8.jpeg?alt=media&token=92c89015-74dc-4956-bc74-0ec86000d76f"))
        newsImageTitleLabel.text = "Kailey Wood runs a TikTok account sharing her weight loss journey."
       */
    }
    
    func setNewImage(urlImage: [String], captionImage: [String]) {
        newsImageView.sd_setImage(with: URL(string: urlImage.first!))
        newsImageTitleLabel.text = captionImage.first
    }
}
