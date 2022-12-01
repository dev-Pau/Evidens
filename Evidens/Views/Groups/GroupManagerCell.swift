//
//  GroupManagerCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/11/22.
//

import UIKit

protocol GroupManagerCellDelegate: AnyObject {
    func didTapBrosweGroups()
}

class GroupManagerCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    var viewModel: GroupViewModel? {
        didSet {
            configureGroup()
        }
    }
    
    weak var delegate: GroupManagerCellDelegate?
    
    private let profileGroupImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "user.profile")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var groupNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = .black
        
        button.configuration?.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18))
        button.configuration?.imagePadding = 10
        button.configuration?.imagePlacement = .trailing
        
        button.contentHorizontalAlignment = .left
        button.tintAdjustmentMode = .normal
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleBrowseGroups), for: .touchUpInside)
        return button
    }()
    
    private let groupSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        cellContentView.backgroundColor = .white
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.backgroundColor = .white
        cellContentView.addSubviews(profileGroupImageView, groupNameButton, groupSizeLabel, separatorView)
        
        NSLayoutConstraint.activate([

            profileGroupImageView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            profileGroupImageView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            profileGroupImageView.heightAnchor.constraint(equalToConstant: 50),
            profileGroupImageView.widthAnchor.constraint(equalToConstant: 50),
            
            groupNameButton.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            groupNameButton.leadingAnchor.constraint(equalTo: profileGroupImageView.trailingAnchor),
            groupNameButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10 - 50 - 50),
           
            groupSizeLabel.topAnchor.constraint(equalTo: groupNameButton.bottomAnchor),
            groupSizeLabel.leadingAnchor.constraint(equalTo: profileGroupImageView.trailingAnchor, constant: 12),
            groupSizeLabel.trailingAnchor.constraint(equalTo: groupNameButton.trailingAnchor),
            groupSizeLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10)
        ])
        profileGroupImageView.layer.cornerRadius = 5
    }
    
    func configureGroup() {
        guard let viewModel = viewModel else { return }
        profileGroupImageView.sd_setImage(with: URL(string: viewModel.groupProfileUrl!))
        groupSizeLabel.text = viewModel.groupSizeString
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        groupNameButton.configuration?.attributedTitle = AttributedString(viewModel.groupName, attributes: container)
    }
    
    @objc func handleBrowseGroups() {
        delegate?.didTapBrosweGroups()
    }
    
}
