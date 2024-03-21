//
//  SearchRecentsHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/2/23.
//

import UIKit

protocol SearchRecentsHeaderDelegate: AnyObject {
    func didTapClearSearches()
}

class SearchRecentsHeader: UICollectionReusableView {
    
    weak var delegate: SearchRecentsHeaderDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.text = AppStrings.Content.Filters.recents
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .bold)
        return label
    }()
    
    private lazy var clearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryColor
        label.text = AppStrings.Miscellaneous.clear
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleClearSearches)))
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .bold)
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        addSubviews(titleLabel, clearLabel, separatorView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            clearLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            clearLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: clearLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    @objc func handleClearSearches() {
        delegate?.didTapClearSearches()
    }
}
