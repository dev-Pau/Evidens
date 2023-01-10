//
//  UserProfilePatentsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

protocol UserProfilePatentCellDelegate: AnyObject {
    func didTapEditPatent(_ cell: UICollectionViewCell, patentTitle: String, patentNumber: String, patentDescription: String)
}

class UserProfilePatentCell: UICollectionViewCell {
    
    weak var delegate: UserProfilePatentCellDelegate?
    
    private let patentTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patentNumberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.configuration?.buttonSize = .mini
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEditPatent), for: .touchUpInside)
        return button
    }()
    
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        addSubviews(patentTitleLabel, patentNumberLabel, separatorView, buttonImage)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: patentTitleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: patentTitleLabel.trailingAnchor),
            
            patentTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            patentTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            patentTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            patentNumberLabel.topAnchor.constraint(equalTo: patentTitleLabel.bottomAnchor, constant: 5),
            patentNumberLabel.leadingAnchor.constraint(equalTo: patentTitleLabel.leadingAnchor),
            patentNumberLabel.trailingAnchor.constraint(equalTo: patentTitleLabel.trailingAnchor),
            patentNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            buttonImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
    
    func set(patentInfo: [String: Any]) {
        patentTitleLabel.text = patentInfo["title"] as? String
        patentNumberLabel.text = patentInfo["number"] as? String
    }
    
    @objc func handleEditPatent() {
        guard let title = patentTitleLabel.text, let number = patentNumberLabel.text else { return }
        delegate?.didTapEditPatent(self, patentTitle: title, patentNumber: number, patentDescription: description)
    }
}
