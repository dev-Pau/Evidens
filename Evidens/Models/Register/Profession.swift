//
//  Profession.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

struct Profession: Codable, Hashable {
    var profession: String
}

extension Profession {
    
    enum Professions: String, CaseIterable {
        case medicine = "Medicine"
        case odontology = "Odontology"
        case pharmacy = "Pharmacy"
        case physiotherapy = "Physiotherapy"
        case nursing = "Nursing"
        case veterinary = "Veterinary Medicine"
        case psychology = "Psychology"
        case podiatry = "Podiatry"
        case nutrition = "Human Nutrition & Dietetics"
        case optics = "Optics & Optometry"
        case biomedical = "Biomedical Science"
        case physical = "Physical Activity & Sport Science"
        case speech = "Speech Therapy"
        
        var professionColor: UIColor {
            switch self {
            case .medicine:
                return .systemTeal
            case .odontology:
                return .systemBlue
            case .pharmacy:
                return .systemPink
            case .physiotherapy:
                return .systemPurple
            case .nursing:
                return .systemCyan
            case .veterinary:
                return .systemIndigo
            case .psychology:
                return .systemMint
            case .podiatry:
                return .systemOrange
            case .nutrition:
                return .systemGreen
            case .optics:
                return .systemYellow
            case .biomedical:
                return .systemGray
            case .physical:
                return .systemBrown
            case .speech:
                return .systemRed
                
            }
            
        }
    }
    
    static func professionalProfessions() -> [Profession] {
        var profession: [Profession] = []
        
        return profession
    }
    
    static func getAllProfessions() -> [Profession] {
        var profession: [Profession] = []
        let sp1 = Profession(profession: "Medicine")
        let sp2 = Profession(profession: "Odontology")
        let sp3 = Profession(profession: "Pharmacy")
        let sp4 = Profession(profession: "Physiotherapy")
        let sp5 = Profession(profession: "Nursing")
        let sp6 = Profession(profession: "Veterinary Medicine")
        let sp7 = Profession(profession: "Psychology")
        let sp8 = Profession(profession: "Podiatry")
        let sp9 = Profession(profession: "Human Nutrition & Dietetics")
        let sp10 = Profession(profession: "Optics & Optometry")
        let sp11 = Profession(profession: "Biomedical Science")
        let sp12 = Profession(profession: "Physical Activity & Sport Science")
        let sp13 = Profession(profession: "Speech Therapy")
        
        profession.append(contentsOf: [sp1, sp2, sp3, sp4, sp5, sp6, sp7, sp8, sp9, sp10, sp11, sp12, sp13])
        return profession
        
        
    }
    
    static func professorProfessions() -> [Profession] {
        var profession: [Profession] = []
        
        return profession
    }
    
    static func researcherProfessions() -> [Profession] {
        var profession: [Profession] = []
        
        return profession
    }
}

