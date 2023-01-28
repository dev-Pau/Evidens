//
//  UserProfileTitleHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

protocol UserProfileTitleHeaderDelegate: AnyObject {
    func didTapEditSection(sectionTitle: String)
}

class UserProfileTitleHeader: UICollectionReusableView {
    
    weak var delegate: UserProfileTitleHeaderDelegate?
    
    private var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        view.layer.shadowColor = UIColor.quaternarySystemFill.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 5.0
        view.layer.shadowOpacity = 1
        view.layer.masksToBounds = false
        return view
    }()
    
    var sectionTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.configuration?.buttonSize = .mini
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
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
        addSubviews(separatorView, buttonImage, sectionTitle)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 5),
            
            sectionTitle.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            sectionTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            sectionTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sectionTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            buttonImage.centerYAnchor.constraint(equalTo: sectionTitle.centerYAnchor),
            buttonImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
    
    @objc func handleEdit() {
        guard let text = sectionTitle.text else { return }
        delegate?.didTapEditSection(sectionTitle: text)
    }
    
    func set(title: String) {
        sectionTitle.text = title
    }
}
