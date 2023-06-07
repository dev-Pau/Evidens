//
//  MessageMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/5/23.
//

import Foundation
import UIKit

/// An enum mapping the photo menu prompts of a message.
enum MessageMenu {
    case copy, share, delete, resend
    
    var label: String {
        switch self {
        case .share: return AppStrings.Menu.sharePhoto
        case .copy: return AppStrings.Menu.copy
        case .delete: return AppStrings.Menu.deleteMessage
        case .resend: return AppStrings.Menu.resendMessage
        }
    }
    
    var image: UIImage {
        switch self {
        case .share: return UIImage(systemName: AppStrings.Icons.share)!
        case .copy: return UIImage(systemName: AppStrings.Icons.copy)!
        case .delete: return UIImage(systemName: AppStrings.Icons.trash)!
        case .resend: return UIImage(systemName: AppStrings.Icons.clockwiseArrow)!
        }
    }
}
