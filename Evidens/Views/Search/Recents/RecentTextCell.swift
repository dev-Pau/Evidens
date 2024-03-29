//
//  RecentTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/5/22.
//

import UIKit

class RecentTextCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: RecentTextViewModel? {
        didSet {
            configure()
        }
    }
    
    private let recentSearchedTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()
    
    private lazy var goToTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: AppStrings.Icons.leftUpArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
        button.tintColor = K.Colors.primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        addSubviews(recentSearchedTextLabel, goToTextButton)
        
        NSLayoutConstraint.activate([
            recentSearchedTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            recentSearchedTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            recentSearchedTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            recentSearchedTextLabel.trailingAnchor.constraint(equalTo: goToTextButton.leadingAnchor, constant: -10),
            
            goToTextButton.centerYAnchor.constraint(equalTo: recentSearchedTextLabel.centerYAnchor),
            goToTextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            goToTextButton.heightAnchor.constraint(equalToConstant: 15),
            goToTextButton.widthAnchor.constraint(equalToConstant: 15),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        recentSearchedTextLabel.text = viewModel.textToDisplay
    }
}
