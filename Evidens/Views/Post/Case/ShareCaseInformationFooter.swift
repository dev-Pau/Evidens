//
//  PostCaseInformationFooter.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/4/23.
//

import UIKit

class ShareCaseInformationFooter: UICollectionReusableView {
    
    private lazy var attributedImageInfo: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "Images can help others interpretation on what has happened to the patinent. Protecting patient privacy is our top priority. Visit our Patient Privacy Policy.")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12, weight: .bold), range: (aString.string as NSString).range(of: "Patient Privacy Policy"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Patient Privacy Policy"))
        return aString
    }()
    
    private lazy var privacyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.attributedText = attributedImageInfo
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
        addSubviews(privacyLabel, separatorView)
        NSLayoutConstraint.activate([
            privacyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            privacyLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            privacyLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            privacyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
}
