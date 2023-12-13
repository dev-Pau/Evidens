//
//  HumanBody.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/10/23.
//

import Foundation

enum Body: Int {
    
    case head
    
    case rightShoulder, leftShoulder, rightChest, leftChest
    
    case stomach, hips
    
    case rightThigh, leftThigh, rightKnee, leftKnee
    
    case rightShin, leftShin
    
    case rightFoot, leftFoot
    
    case rightArm, leftArm
    
    case rightHand, leftHand
    
    
    var frontName: String {
        switch self {
            
        case .head: return AppStrings.Health.Body.Human.Front.head
        case .rightShoulder: return AppStrings.Health.Body.Human.Front.rightShoulder
        case .leftShoulder: return AppStrings.Health.Body.Human.Front.leftShoulder
        case .rightChest: return AppStrings.Health.Body.Human.Front.rightChest
        case .leftChest:return AppStrings.Health.Body.Human.Front.leftChest
        case .stomach:return AppStrings.Health.Body.Human.Front.stomach
        case .hips: return AppStrings.Health.Body.Human.Front.hips
        case .rightThigh: return AppStrings.Health.Body.Human.Front.rightThigh
        case .leftThigh: return AppStrings.Health.Body.Human.Front.leftThigh
        case .rightKnee: return AppStrings.Health.Body.Human.Front.rightKnee
        case .leftKnee: return AppStrings.Health.Body.Human.Front.leftKnee
        case .rightShin: return AppStrings.Health.Body.Human.Front.rightShin
        case .leftShin: return AppStrings.Health.Body.Human.Front.leftShin
        case .rightFoot: return AppStrings.Health.Body.Human.Front.rightFoot
        case .leftFoot: return AppStrings.Health.Body.Human.Front.leftFoot
        case .rightArm: return AppStrings.Health.Body.Human.Front.rightArm
        case .leftArm: return AppStrings.Health.Body.Human.Front.leftArm
        case .rightHand: return AppStrings.Health.Body.Human.Front.rightHand
        case .leftHand: return AppStrings.Health.Body.Human.Front.leftHand
        }
    }
    
    var backName: String {
        switch self {
            
        case .head: return AppStrings.Health.Body.Human.Back.head
        case .rightShoulder: return AppStrings.Health.Body.Human.Back.rightShoulder
        case .leftShoulder: return AppStrings.Health.Body.Human.Back.leftShoulder
        case .rightChest: return AppStrings.Health.Body.Human.Back.rightChest
        case .leftChest:return AppStrings.Health.Body.Human.Back.leftChest
        case .stomach:return AppStrings.Health.Body.Human.Back.stomach
        case .hips: return AppStrings.Health.Body.Human.Back.hips
        case .rightThigh: return AppStrings.Health.Body.Human.Back.rightThigh
        case .leftThigh: return AppStrings.Health.Body.Human.Back.leftThigh
        case .rightKnee: return AppStrings.Health.Body.Human.Back.rightKnee
        case .leftKnee: return AppStrings.Health.Body.Human.Back.leftKnee
        case .rightShin: return AppStrings.Health.Body.Human.Back.rightShin
        case .leftShin: return AppStrings.Health.Body.Human.Back.leftShin
        case .rightFoot: return AppStrings.Health.Body.Human.Back.rightFoot
        case .leftFoot: return AppStrings.Health.Body.Human.Back.leftFoot
        case .rightArm: return AppStrings.Health.Body.Human.Back.rightArm
        case .leftArm: return AppStrings.Health.Body.Human.Back.leftArm
        case .rightHand: return AppStrings.Health.Body.Human.Back.rightHand
        case .leftHand: return AppStrings.Health.Body.Human.Back.leftHand
        }
    }
    
    var height: CGFloat {
        switch self {
            
        case .head: return 0.18
            
        case .rightShoulder, .leftShoulder: return 0.07
            
        case .rightChest, .leftChest: return 0.11
            
        case .stomach: return 0.15
            
        case .hips: return 0.12
            
        case .rightThigh, .leftThigh: return 0.09
            
        case .rightKnee, .leftKnee: return 0.1
            
        case .rightShin, .leftShin: return 0.12
            
        case .rightFoot, .leftFoot: return 0.08
            
        case .rightArm, .leftArm, .rightHand, .leftHand: return 0.0
            
        }
    }
    
    var width: CGFloat {
        switch self {
            
        case .head: return 0.67
            
        case .rightShoulder, .leftShoulder: return 0.90
            
        case .rightChest, .leftChest: return 0.5
            
        case .stomach: return 0.5

        case .hips: return 0.5
            
        case .rightThigh, .leftThigh: return 0.5
            
        case .rightKnee, .leftKnee: return 0.5
            
        case .rightShin, .leftShin: return 0.5
            
        case .rightFoot, .leftFoot: return 0.7
            
        case .rightArm, .leftArm, .rightHand, .leftHand: return 0.0
        }
    }
}
