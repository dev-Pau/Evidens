//
//  ReportMainHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

class ReportMainHeader: UICollectionReusableView {
    
    private let reportHeaderTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let reportHeaderDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
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
        addSubviews(reportHeaderTitleLabel, reportHeaderDescriptionLabel, separatorView)
        NSLayoutConstraint.activate([
            reportHeaderTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            reportHeaderTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            reportHeaderTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            reportHeaderDescriptionLabel.topAnchor.constraint(equalTo: reportHeaderTitleLabel.bottomAnchor, constant: 10),
            reportHeaderDescriptionLabel.leadingAnchor.constraint(equalTo: reportHeaderTitleLabel.leadingAnchor),
            reportHeaderDescriptionLabel.trailingAnchor.constraint(equalTo: reportHeaderTitleLabel.trailingAnchor),
            reportHeaderDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func configure(withTitle title: String, withDescription description: String) {
        reportHeaderTitleLabel.text = title
        reportHeaderDescriptionLabel.text = description
    }
}
