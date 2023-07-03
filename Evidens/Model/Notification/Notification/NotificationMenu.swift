//
//  NotificationMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/7/23.
//

import UIKit

/// An enum mapping the notification menu options.
enum NotificationMenu {
    case delete
    
    var content: String {
        switch self {
        case .delete: return "Delete Notification"
        }
    }
    
    var image: UIImage {
        switch self {
        case .delete: return UIImage(systemName: AppStrings.Icons.trash)!
        }
    }
}
