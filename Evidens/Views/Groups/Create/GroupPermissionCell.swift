//
//  GroupPermissionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/1/23.
//

import UIKit

protocol GroupPermissionCellDelegate: AnyObject {
    func didUpdatePermissions(permissions: Group.Permissions)
}

class GroupPermissionCell: UICollectionViewCell {
    
    weak var delegate: GroupPermissionCellDelegate?
    
    private let cellContentView = UIView()
    
    private var permissions: Group.Permissions = .invite
    
    private var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let discoverabilityTitle: UILabel = {
        let label = UILabel()
        label.text = "Permissions"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private lazy var invitePermissionView = GroupVisibilityView(optionTitle: "Allow members to invite their connections", optionDescription: "If disabled, only group admins will be able to invite connections to the group.")
    private lazy var reviewPermissionView = GroupVisibilityView(optionTitle: "Require posts to be reviewed by admins", optionDescription: "If enabled, member posts will require admin approval before they become visible to others.")
    
    private var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
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
        invitePermissionView.updateVisibility()
        
        invitePermissionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleInvitePermissionTap)))
        reviewPermissionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleReviewPermissionTap)))
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        addSubviews(topSeparatorView, discoverabilityTitle, invitePermissionView, separatorView, reviewPermissionView)
        NSLayoutConstraint.activate([
            topSeparatorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            discoverabilityTitle.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: 5),
            discoverabilityTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            discoverabilityTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            invitePermissionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            invitePermissionView.topAnchor.constraint(equalTo: discoverabilityTitle.bottomAnchor),
            invitePermissionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            invitePermissionView.heightAnchor.constraint(equalToConstant: 70),
            
            separatorView.topAnchor.constraint(equalTo: invitePermissionView.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: invitePermissionView.leadingAnchor, constant: 40),
            separatorView.trailingAnchor.constraint(equalTo: invitePermissionView.trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            reviewPermissionView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            reviewPermissionView.leadingAnchor.constraint(equalTo: invitePermissionView.leadingAnchor),
            reviewPermissionView.trailingAnchor.constraint(equalTo: invitePermissionView.trailingAnchor),
            reviewPermissionView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        //visibleView.updateVisibility()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func checkPermissions() -> Group.Permissions {
        let invitePermission = invitePermissionView.privacyOptionIsSelected
        let reviewPermission = reviewPermissionView.privacyOptionIsSelected
        
        if invitePermission && reviewPermission {
            permissions = .all
        } else if invitePermission && !reviewPermission {
            permissions = .invite
        } else if !invitePermission && reviewPermission {
            permissions = .review
        } else {
            permissions = .none
        }
        
        return permissions
    }
    
    func setPermissions(permissions: Group.Permissions) {
        if permissions == .all {
            reviewPermissionView.updateVisibility()
        } else if permissions == .review {
            invitePermissionView.updateVisibility()
            reviewPermissionView.updateVisibility()
        } else if permissions == .none {
            invitePermissionView.updateVisibility()
        } else {
            
        }
    }
    
    @objc func handleInvitePermissionTap() {
        invitePermissionView.updateVisibility()
        delegate?.didUpdatePermissions(permissions: checkPermissions())
        
        
    }
    
    @objc func handleReviewPermissionTap() {
        reviewPermissionView.updateVisibility()
        delegate?.didUpdatePermissions(permissions: checkPermissions())
    }
}
