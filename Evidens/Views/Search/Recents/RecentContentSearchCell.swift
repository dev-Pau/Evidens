//
//  RecentContentSearchCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/2/23.
//

import UIKit

class RecentContentSearchCell: UICollectionViewCell {
    
    var viewModel: RecentTextCellViewModel? {
        didSet {
            configure()
        }
    }
    
    private let recentSearchedTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()
    
    private lazy var goToTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.left"), for: .normal)
        button.tintColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        addSubviews(recentSearchedTextLabel, goToTextButton,  separatorView)
        NSLayoutConstraint.activate([
            recentSearchedTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            recentSearchedTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            recentSearchedTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            goToTextButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            goToTextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            goToTextButton.heightAnchor.constraint(equalToConstant: 15),
            goToTextButton.widthAnchor.constraint(equalToConstant: 15),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: recentSearchedTextLabel.leadingAnchor)
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


/*
 
 class RecentTextCell: UITableViewCell {
     
     //MARK: - Properties
     
     var viewModel: RecentTextCellViewModel? {
         didSet {
             configure()
         }
     }
     
     private let recentSearchedTextLabel: UILabel = {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
         label.numberOfLines = 1
         label.textColor = .label
         return label
     }()
     
     private lazy var goToTextButton: UIButton = {
         let button = UIButton(type: .system)
         button.setImage(UIImage(systemName: "arrow.up.left"), for: .normal)
         button.tintColor = .label
         button.translatesAutoresizingMaskIntoConstraints = false
         button.isUserInteractionEnabled = false
         //button.addTarget(self, action: #selector(didTapRecentText), for: .touchUpInside)
         return button
     }()
     
     //MARK: - Lifecycle
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
        
         NSLayoutConstraint.activate([
             recentSearchedTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             recentSearchedTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
             
             goToTextButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             goToTextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
         ])
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     //MARK: - Helpers
     
     func configure() {
         guard let viewModel = viewModel else { return }
         recentSearchedTextLabel.text = viewModel.textToDisplay
     }
 }

 */
