//
//  UserProfileTitleFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

protocol UserProfileTitleFooterDelegate: AnyObject {
    func didTapFooter(section: String)
}

class UserProfileTitleFooter: UICollectionReusableView {
    
    weak var delegate: UserProfileTitleFooterDelegate?
    
    private lazy var sectionAboutTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFooterTap)))
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .white
        addSubviews(sectionAboutTitle, separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            sectionAboutTitle.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            sectionAboutTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            sectionAboutTitle.trailingAnchor.constraint(equalTo: trailingAnchor),
            sectionAboutTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(title: String) {
        sectionAboutTitle.text = title
    }
    
    @objc func handleFooterTap() {
        guard let text = sectionAboutTitle.text else { return }
        delegate?.didTapFooter(section: text)
    }
}

