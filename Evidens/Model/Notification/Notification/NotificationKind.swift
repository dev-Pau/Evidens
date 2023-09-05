//
//  NotificationKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/6/23.
//

import Foundation

/// An enum mapping the notification kind.
enum NotificationKind: Int16, CaseIterable {
    
    case likePost, likeCase, follow, replyPost, replyCase, replyPostComment, replyCaseComment, likePostReply, likeCaseReply
    
    var message: String {
        switch self {
        case .likePost: return AppStrings.Notifications.Display.likePost
        case .likeCase: return AppStrings.Notifications.Display.likeCase
        case .follow: return AppStrings.Notifications.Display.follow
        case .replyPost: return AppStrings.Notifications.Display.replyPost
        case .replyCase: return AppStrings.Notifications.Display.replyCase
        case .replyPostComment: return AppStrings.Notifications.Display.replyComment
        case .replyCaseComment: return AppStrings.Notifications.Display.replyComment
        case .likePostReply: return AppStrings.Notifications.Display.likeReply
        case .likeCaseReply: return AppStrings.Notifications.Display.likeReply
        }
    }
}


// quan hi ha un like el pujo a la db amb el field sync a false. quan inicio sessió agafo aquestsa noti, miro el like count i ho guardo a a user defaults junt a la notificació.
// després al pròxim like al veure que està sync en crearà un altre i quan l'usuari entri farà fetch dels likes que hi ha des del moment de la creació de la nova, d'aquesta manera  es va fent tot progressiu

// comments i replies es guarden tots

// llavors tema de connections que funcioni igual que likes,

// a la hora de notificar comments i replies com es guarden tots doncs es notifiquen tots i als likes igual es manté i ja es millorarà.
