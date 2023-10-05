//
//  ProfileHeaderViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit

struct ProfileHeaderViewModel {
    var user: User
    
    var fullName: String {
        return user.name()
    }
    
    var details: String {
        return user.details()
    }
    
    var firstName: String {
        return user.firstName!
    }
    
    var connectionText: String {
        guard let connection = user.connection else { return "" }
        
        return user.isCurrentUser ? AppStrings.Profile.editProfile : connection.phase.title
    }
    
    var connectBackgroundColor: UIColor {
        if user.isCurrentUser {
            return .systemBackground
        } else {
            guard let connection = user.connection else { return .systemBackground }
            
            switch connection.phase {
                
            case .connected, .pending, .received: return .quaternarySystemFill
            case .none, .unconnect, .rejected, .withdraw: return primaryColor
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
            case .none, .unconnect, .rejected, .withdraw: return .white
            }
        }
    }
    
    var connectButtonBorderColor: UIColor {
        return user.isCurrentUser ? .quaternarySystemFill : .clear
    }
    
    var connectButtonBorderWidth: CGFloat {
        return user.isCurrentUser ? 1 : 0
    }
    
    var connectImage: UIImage? {
        guard !user.isCurrentUser else {
            return nil
        }
        
        guard let connection = user.connection else { return nil }
        
        switch connection.phase {
            
        case .connected:
            return UIImage(systemName: AppStrings.Icons.downChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .pending:
            return UIImage(systemName: AppStrings.Icons.clock, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        case .received:
            return UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        case .rejected, .withdraw, .unconnect, .none:
            return nil
        }
    }
    
    var connections: Int {
        return user.stats.connections
    }
    
    var followers: Int {
        return user.stats.followers
    }
    
    var following: Int {
        return user.stats.following
    }
    
    var connectionsText: NSAttributedString {
        return connectText(connections: connections)
    }
    
    func connectText(connections: Int) -> NSAttributedString {
        if connections == 0 {
            let aString = NSMutableAttributedString(string: AppStrings.Network.Connection.unconnected)
            aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: (aString.string as NSString).range(of: AppStrings.Network.Connection.unconnected))
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: (aString.string as NSString).range(of: AppStrings.Network.Connection.unconnected))
            return aString
        } else {
            let text = connections == 1 ? AppStrings.Network.Connection.connection : AppStrings.Network.Connection.connections
            let aString = NSMutableAttributedString(string: String(connections) + " " + text)
            aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: (aString.string as NSString).range(of: String(connections)))
            aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: (aString.string as NSString).range(of: String(connections)))
            return aString
        }
    }
    
    init(user: User) {
        self.user = user
    }
}
