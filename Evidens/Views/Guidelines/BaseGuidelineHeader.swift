//
//  BaseGuidelineHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/12/23.
//

import UIKit

class BaseGuidelineHeader: UICollectionReusableView {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.addFont(size: 29, scaleStyle: .largeTitle, weight: .black, scales: false)
        label.numberOfLines = 0
        return label
    }()
    
    private var topPaddingLayoutConstraint: NSLayoutConstraint!
    private var paddingView: QuarterCircleView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = primaryColor
        paddingView = QuarterCircleView()
        paddingView.backgroundColor = .systemBackground
        paddingView.translatesAutoresizingMaskIntoConstraints = false

        addSubviews(paddingView, titleLabel)
        
        topPaddingLayoutConstraint = paddingView.topAnchor.constraint(equalTo: topAnchor)
        NSLayoutConstraint.activate([
            topPaddingLayoutConstraint,
            paddingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            paddingView.widthAnchor.constraint(equalToConstant: frame.width),
            paddingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: paddingView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
    
    func offsetDidMove(_ y: CGFloat) {
        topPaddingLayoutConstraint.constant = -y
        layoutIfNeeded()
    }
    
    func set(kind: ContentKind) {
        switch kind {
            
        case .post:
            titleLabel.text = AppStrings.Guidelines.Post.title
        case .clinicalCase:
            titleLabel.text = AppStrings.Guidelines.Case.title
        }
    }
}
