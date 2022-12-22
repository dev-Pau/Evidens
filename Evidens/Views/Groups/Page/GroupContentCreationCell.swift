//
//  GroupCreatePostCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/12/22.
//

import UIKit

protocol GroupContentCreationCellDelegate: AnyObject {
    func didTapUploadPost()
    func didTapUploadCase()
}

class GroupContentCreationCell: UICollectionViewCell {
    
    weak var delegate: GroupContentCreationCellDelegate?
    
    private lazy var createContentButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(named: "post")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleUploadPost), for: .touchUpInside)
        return button
    }()
    
    private let shareContentLabel: UILabel = {
        let label = UILabel()
        label.text = "Start a post or share a case in this group"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private lazy var createCaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(named: "cases")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleUploadCase), for: .touchUpInside)
        return button
    }()
    
    private let shareInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Content posted here will only be visible by group members."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = grayColor
        return view
    }()
    
    private let horizontalSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lightColor
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
        addSubviews(createContentButton, separatorView, createCaseButton, shareContentLabel, horizontalSeparatorView, shareInfoLabel)
        NSLayoutConstraint.activate([
            createContentButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            createContentButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            createContentButton.heightAnchor.constraint(equalToConstant: 20),
            createContentButton.widthAnchor.constraint(equalToConstant: 20),
            
            separatorView.centerYAnchor.constraint(equalTo: createContentButton.centerYAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 25),
            separatorView.widthAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: createContentButton.trailingAnchor, constant: 10),
            
            createCaseButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            createCaseButton.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: 10),
            createCaseButton.heightAnchor.constraint(equalToConstant: 20),
            createCaseButton.widthAnchor.constraint(equalToConstant: 20),
            
            shareContentLabel.centerYAnchor.constraint(equalTo: createContentButton.centerYAnchor),
            shareContentLabel.leadingAnchor.constraint(equalTo: createCaseButton.trailingAnchor, constant: 10),
            shareContentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            horizontalSeparatorView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 5),
            horizontalSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            horizontalSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            shareInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            shareInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            shareInfoLabel.topAnchor.constraint(equalTo: horizontalSeparatorView.bottomAnchor, constant: 10),
            shareInfoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)

        ])
    }
    
    @objc func handleUploadPost() {
        delegate?.didTapUploadPost()
    }
    
    @objc func handleUploadCase() {
        delegate?.didTapUploadCase()
    }
}
