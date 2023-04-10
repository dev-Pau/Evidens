//
//  PostGroupCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/12/22.
//

import UIKit

class PostGroupCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectionOptionButton.configuration?.image = isSelected ? UIImage(systemName: "smallcircle.fill.circle.fill") : UIImage(systemName: "circle")
        }
    }
    
    var viewModel: GroupViewModel? {
        didSet {
            configureGroup()
        }
    }
    
    private let groupImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "group.profile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let groupNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let selectionOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = primaryColor
        return button
    }()
    
    private var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
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

        addSubviews(groupImageView, selectionOptionButton, groupNameLabel, separatorView)
        
        NSLayoutConstraint.activate([
            groupImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            groupImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            groupImageView.widthAnchor.constraint(equalToConstant: 40),
            groupImageView.heightAnchor.constraint(equalToConstant: 40),
            
            selectionOptionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionOptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            selectionOptionButton.heightAnchor.constraint(equalToConstant: 15),
            selectionOptionButton.widthAnchor.constraint(equalToConstant: 15),
            
            groupNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            groupNameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 10),
            groupNameLabel.trailingAnchor.constraint(equalTo: selectionOptionButton.leadingAnchor, constant: -10),
            groupNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: groupNameLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func configureGroup() {
        guard let viewModel = viewModel else { return }
        groupNameLabel.text = viewModel.groupName
        selectionOptionButton.configuration?.image = UIImage(systemName: "circle")
        if let url = viewModel.groupProfileUrl, url != "" {
            groupImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        }
    }
}
