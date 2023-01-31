//
//  GroupMemberUserCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/1/23.
//

import UIKit

protocol GroupInvitedUserCellDelegate: AnyObject {
    func didUnsendInvitation(_ cell: UICollectionViewCell, user: User)
}

protocol GroupBlockedUserCellDelegate: AnyObject {
    func didUnblockUser(_ cell: UICollectionViewCell, user: User)
}

protocol GroupMemberUserCellDelegate: AnyObject {
    func promoteToOwner(_ cell: UICollectionViewCell, user: User)
    func promoteToManager(_ cell: UICollectionViewCell, user: User)
    func removeFromGroup(_ cell: UICollectionViewCell, user: User)
    func blockFromGroup(_ cell: UICollectionViewCell, user: User)
}

class GroupMemberUserCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            configureWithUser()
        }
    }
    
    weak var delegate: GroupMemberUserCellDelegate?
    weak var blockDelegate: GroupBlockedUserCellDelegate?
    weak var invitedDelegate: GroupInvitedUserCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let userCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var threeDotsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        
        button.configuration?.buttonSize = .mini
        button.configuration?.baseForegroundColor = .label
        
        button.configuration?.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        
        //button.addTarget(self, action: #selector(didTapThreeDots), for: .touchUpInside)
        button.showsMenuAsPrimaryAction = true
        button.isUserInteractionEnabled = true
        
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
        addSubviews(profileImageView, threeDotsButton, nameLabel, userCategoryLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            
            threeDotsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            threeDotsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            threeDotsButton.widthAnchor.constraint(equalToConstant: 30),
            threeDotsButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: threeDotsButton.leadingAnchor, constant: -10),
            
            userCategoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            userCategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userCategoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 45 / 2
    }
    
    private func configureWithUser() {
        guard let user = user else { return }
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        nameLabel.text = user.firstName! + " " + user.lastName!
        if user.category == .student {
            userCategoryLabel.text = user.profession! + ", " + user.speciality! + " · Student"
        } else {
            userCategoryLabel.text = user.profession! + ", " + user.speciality!
        }
    }
    
    private func createMenu(currentUserType: Group.MemberType, userType: Group.MemberType) -> UIMenu? {
        guard let user = user, let name = user.firstName else { return nil }
        switch currentUserType {
        case .owner:
            switch userType {
            case .owner:
                return nil
            case .admin:
                return nil
            case .member:
                let menuItems = UIMenu(options: .displayInline, children: [
                    UIAction(title: "Promote \(name) to manager", image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.delegate?.promoteToManager(self, user: user)
                    }),
                    UIAction(title: "Promote \(name) to owner", image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.delegate?.promoteToOwner(self, user: user)
                    }),
                    UIAction(title: "Remove \(name)", image: UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.delegate?.removeFromGroup(self, user: user)
                        
                    }),
                    UIAction(title: "Block \(name)", image: UIImage(systemName: "exclamationmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.delegate?.blockFromGroup(self, user: user)
                    })
                ])
                
                return menuItems
            case .pending:
                return nil
            case .external:
                return nil
            case .invited:
                let menuItems = UIMenu(options: .displayInline, children: [
                    UIAction(title: "Remove \(name)'s invitation", image: UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.invitedDelegate?.didUnsendInvitation(self, user: user)
                    })
                ])
                return menuItems
            case .blocked:
                let menuItems = UIMenu(options: .displayInline, children: [
                    UIAction(title: "Unblock \(name)", image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.blockDelegate?.didUnblockUser(self, user: user)
                    })
                ])
                
                return menuItems
            }
            
        case .admin:
            switch userType {
            case .owner:
                return nil
            case .admin:
                return nil
            case .member:
                let menuItems = UIMenu(options: .displayInline, children: [
                    UIAction(title: "Remove \(name)", image: UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.delegate?.removeFromGroup(self, user: user)
                        
                    }),
                    UIAction(title: "Block \(name)", image: UIImage(systemName: "exclamationmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.delegate?.blockFromGroup(self, user: user)
                    })
                ])
                return menuItems
            case .pending:
                return nil
            case .external:
                return nil
            case .invited:
                let menuItems = UIMenu(options: .displayInline, children: [
                    UIAction(title: "Remove \(name)'s invitation", image: UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.invitedDelegate?.didUnsendInvitation(self, user: user)
                    })
                ])
                return menuItems
            case .blocked:
                let menuItems = UIMenu(options: .displayInline, children: [
                    UIAction(title: "Unblock \(name)", image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                        self.blockDelegate?.didUnblockUser(self, user: user)
                    })
                ])
                
                return menuItems
            }
            
            
        case .member:
            return nil
        case .pending:
            return nil
        case .external:
            return nil
        case .invited:
            return nil
        case .blocked:
            return nil
        }
    }
    
    func configureMemberType(currentUserType: Group.MemberType, userType: Group.MemberType) {
        threeDotsButton.menu = createMenu(currentUserType: currentUserType, userType: userType)
    }
}
