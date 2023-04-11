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
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.text = "Recently searched"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private lazy var clearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryColor
        label.text = "Clear"
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleClearSearches)))
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
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
        addSubviews(emptyTitleLabel, clearLabel, separatorView)
        NSLayoutConstraint.activate([
            emptyTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            clearLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            clearLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            separatorView.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: emptyTitleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: clearLabel.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    @objc func handleClearSearches() {
        delegate?.didTapClearSearches()
    }
}
