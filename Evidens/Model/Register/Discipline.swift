//
//  Profession.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

/// The enum for a Discipline
enum Discipline: Int, Codable, Hashable, CaseIterable {
    case medicine, odontology, pharmacy, physiotherapy, nursing, veterinary, psychology, podiatry, nutrition, optics, biomedical, physical, speech
    
    var name: String {
        switch self {
        case .medicine: return AppStrings.Health.Discipline.medicine
        case .odontology: return AppStrings.Health.Discipline.odontology
        case .pharmacy: return AppStrings.Health.Discipline.pharmacy
        case .physiotherapy: return AppStrings.Health.Discipline.physiotherapy
        case .nursing: return AppStrings.Health.Discipline.nursing
        case .veterinary: return AppStrings.Health.Discipline.veterinary
        case .psychology: return AppStrings.Health.Discipline.psychology
        case .podiatry: return AppStrings.Health.Discipline.podiatry
        case .nutrition: return AppStrings.Health.Discipline.nutrition
        case .optics: return AppStrings.Health.Discipline.optics
        case .biomedical: return AppStrings.Health.Discipline.biomedical
        case .physical: return AppStrings.Health.Discipline.physical
        case .speech: return AppStrings.Health.Discipline.speech
        }
    }
    
    var color: UIColor {
        switch self {
        case .medicine: return .systemTeal
        case .odontology: return .systemBlue
        case .pharmacy: return .systemPink
        case .physiotherapy: return .systemPurple
        case .nursing: return .systemCyan
        case .veterinary: return .systemIndigo
        case .psychology: return .systemMint
        case .podiatry: return .systemOrange
        case .nutrition: return .systemGreen
        case .optics: return .systemYellow
        case .biomedical: return .systemGray
        case .physical: return .systemBrown
        case .speech: return .systemRed
        }
    }
}
