//
//  ApplicantDocumentCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/2/23.
//

import UIKit

protocol ApplicantDocumentCellDelegate: AnyObject {
    func didTapAttachementsButton()
}

class ApplicantDocumentCell: UICollectionViewCell {
    weak var delegate: ApplicantDocumentCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Resume"
        label.font = .systemFont(ofSize: 16, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var uploadResumeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = UIColor(rgb: 0xF40F02)
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        button.configuration?.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        button.configuration?.imagePadding = 5
        button.configuration?.imagePlacement = .leading
        
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
        addSubviews(titleLabel, uploadResumeButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60),
            
            uploadResumeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            uploadResumeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            uploadResumeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            uploadResumeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc func handleButtonTap() {
        delegate?.didTapAttachementsButton()
    }
}
