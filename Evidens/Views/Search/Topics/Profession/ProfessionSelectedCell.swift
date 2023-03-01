//
//  ProfessionSelectedCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/3/23.
//

import UIKit

class ProfessionSelectedCell: UICollectionViewCell {
    
    //weak var delegate: FilterCasesCellDelegate?

    var tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.textColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = false
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "arrowtriangle.down.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.backgroundColor = .clear
        return button
    }()
    
    @objc func tapButton() {
        print("omegakek")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
       
        layer.cornerRadius = 15
        //layer.borderWidth = 1
        //layer.borderColor = UIColor.quaternarySystemFill.cgColor
        backgroundColor = .label
        
        addSubviews(tagsLabel, arrowImageView, button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            
            tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            tagsLabel.topAnchor.constraint(equalTo: topAnchor),
            
            arrowImageView.centerYAnchor.constraint(equalTo: tagsLabel.centerYAnchor),
            arrowImageView.leadingAnchor.constraint(equalTo: tagsLabel.trailingAnchor, constant: 5),
            arrowImageView.heightAnchor.constraint(equalToConstant: 11),
            arrowImageView.widthAnchor.constraint(equalToConstant: 11)
        ])
    }
    
    /*
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 layer.borderColor = UIColor.quaternarySystemFill.cgColor
             }
         }
    }
     */
    
    @objc func handleImageTap() {
        //delegate?.didTapFilterImage(self)
    }
}


