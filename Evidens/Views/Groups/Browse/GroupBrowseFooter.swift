//
//  GroupBrowseFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/12/22.
//

import UIKit

protocol GroupBrowseFooterDelegate: AnyObject {
    func didTapDiscoverGroups()
}

class GroupBrowseFooter: UICollectionReusableView {
    
    weak var delegate: GroupBrowseFooterDelegate?
    
    private lazy var discoverLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDiscoverGroups)))
        return label
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
        addSubview(discoverLabel)
        
        NSLayoutConstraint.activate([
            discoverLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            discoverLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            discoverLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 30 - 70/2),
        ])
        
        let atrString = NSMutableAttributedString(string: "Discover", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: UIColor.systemBlue])
        atrString.append(NSAttributedString(string: " other listed groups or communities that share your interests, vision or goals.", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular)]))
        
        discoverLabel.attributedText = atrString
    }
    
    @objc func handleDiscoverGroups() {
        delegate?.didTapDiscoverGroups()
    }
    
}
