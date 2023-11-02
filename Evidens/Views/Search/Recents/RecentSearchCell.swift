//
//  RecentSearchCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/2/23.
//

import UIKit

class RecentSearchCell: UICollectionViewCell {
    
    var viewModel: RecentTextViewModel?
    
    var searchedText: String? {
        didSet {
            configureWithText()
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
        button.setImage(UIImage(systemName: AppStrings.Icons.leftUpArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
        button.tintColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        addSubviews(recentSearchedTextLabel, goToTextButton)
        NSLayoutConstraint.activate([
            recentSearchedTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            recentSearchedTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            recentSearchedTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            goToTextButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            goToTextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            goToTextButton.heightAnchor.constraint(equalToConstant: 15),
            goToTextButton.widthAnchor.constraint(equalToConstant: 15),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureWithText() {
        guard let viewModel = viewModel, let searchedText = searchedText else { return }
        
        let attrString = NSMutableAttributedString(string: viewModel.textToDisplay, attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 15, weight: .regular)])
        
        let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        let range = (viewModel.textToDisplay as NSString).range(of: searchedText, options: options)
        
        attrString.addAttributes([.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 15, weight: .bold)], range: range)
        
        recentSearchedTextLabel.attributedText = attrString
    }
}
