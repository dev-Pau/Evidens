//
//  DisplayContent.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// An enum mapping all the DisplayContent types.
enum DisplayContent: Int, CaseIterable {
    case groupPrivacy, jobPrivacy, join, email, password, comment
    
    var title: String {
        switch self {
        case .groupPrivacy: return AppStrings.Display.groupPrivacyTitle
        case .jobPrivacy: return AppStrings.Display.jobPrivacyTitle
        case .join: return AppStrings.Display.joinTitle
        case .email: return AppStrings.Display.emailChangeTitle
        case .password: return AppStrings.Display.passwordChangeTitle
        case .comment: return AppStrings.Display.commentTitle
        }
    }
    
    var description: String {
        switch self {
        case .groupPrivacy: return AppStrings.Display.groupPrivacyContent
        case .jobPrivacy: return AppStrings.Display.jobPrivacyContent
        case .join: return AppStrings.Display.joinContent
        case .email: return AppStrings.Display.emailChangeContent
        case .password: return AppStrings.Display.passwordChangeContent
        case .comment: return AppStrings.Display.commentContent
        }
    }
}
