//
//  ProfileHeaderViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit

/// The viewModel for a ProfileHeader.
struct ProfileHeaderViewModel {
    
    var user: User
    
    var connectionText: String {
        
        if user.isCurrentUser {
            return AppStrings.Profile.editProfile
        } else {
            guard let connection = user.connection else { return "" }
            return connection.phase.title
        }
    }
    
    var connectBackgroundColor: UIColor {
        if user.isCurrentUser {
            return .systemBackground
        } else {
            guard let connection = user.connection else { return .systemBackground }
            
            switch connection.phase {
                
            case .connected, .pending, .received: return .quaternarySystemFill
            case .none, .unconnect, .rejected, .withdraw: return .label
            }
        }
    }
    
    var connectTextColor: UIColor {
        if user.isCurrentUser {
            return .label
        } else {
            guard let connection = user.connection else { return .systemBackground }
            
            switch connection.phase  {
            case .connected, .pending, .received: return .label
            case .none, .unconnect, .rejected, .withdraw: return .systemBackground
            }
        }
    }
    
    var connectButtonBorderColor: UIColor {
        return user.isCurrentUser ? separatorColor : .clear
    }
    
    var connectImage: UIImage? {
        guard !user.isCurrentUser else {
            return nil
        }
        
        guard let connection = user.connection else { return nil }
        
        switch connection.phase {
            
        case .connected:
            return UIImage(systemName: AppStrings.Icons.downChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        case .pending:
            return UIImage(systemName: AppStrings.Icons.clock, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        case .received:
            return UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label).scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        case .rejected, .withdraw, .unconnect, .none:
            return nil
        }
    }
    
    var connectImagePlacement: NSDirectionalRectEdge {
        guard let connection = user.connection else { return .trailing }
        
        switch connection.phase  {
        case .connected: return .trailing
        case .none, .unconnect, .rejected, .withdraw, .pending, .received: return .leading
        }
    }
        
    var connectionsText: NSAttributedString {
        return connectText(connections: connections)
    }
    
    func website(_ url: String) -> AttributedString {
        var container = AttributeContainer()

        container.font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .medium)
        container.foregroundColor = .label
        
        return AttributedString(url, attributes: container)
    }
    
    init(user: User) {
        self.user = user
    }
}

//MARK: - Miscellaneous

extension ProfileHeaderViewModel {
    
    var connections: Int {
        return user.stats.connections
    }
    
    func connectText(connections: Int) -> NSAttributedString {
        
        let font = UIFont.addFont(size: 13, scaleStyle: .largeTitle, weight: .bold)
        
        if connections == 0 {
            let aString = NSMutableAttributedString(string: AppStrings.Network.Connection.unconnected)
            aString.addAttribute(NSAttributedString.Key.font, value: font, range: (aString.string as NSString).range(of: AppStrings.Network.Connection.unconnected))
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: (aString.string as NSString).range(of: AppStrings.Network.Connection.unconnected))
            return aString
        } else {
            let text = connections == 1 ? AppStrings.Network.Connection.connection.lowercased() : AppStrings.Network.Connection.connections.lowercased()
            
            let aString = NSMutableAttributedString(string: String(connections) + " " + text)
            aString.addAttribute(NSAttributedString.Key.font, value: font, range: (aString.string as NSString).range(of: String(connections)))
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: (aString.string as NSString).range(of: String(connections)))
            return aString
        }
    }
}
