//
//  Speciality.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/7/22.
//

import UIKit

struct Speciality: Codable, Hashable {
    var name: String
}

extension Speciality {
    static func allSpecialities() -> [Speciality] {
        var speciality: [Speciality] = []
        
        //MARK: - Allergy and Immunology
        
        let ai1 = Speciality(name: "Allergy & Immunology")
        speciality.append(ai1)
        
        let ai2 = Speciality(name: "Otolaryngic Allergy")
        speciality.append(ai2)
        
        let ai3 = Speciality(name: "Pediatric Allergy & Immunology")
        speciality.append(ai3)

        //MARK: - Anesthesiology
        
        let a1 = Speciality(name: "Critical Care Medicine")
        speciality.append(a1)
        
        let a2 = Speciality(name: "Hospice and Palliative Care")
        speciality.append(a2)
        
        let a3 = Speciality(name: "Pain Medicine")
        speciality.append(a3)
                             
        let a4 = Speciality(name: "Pediatric Anesthesiology")
        speciality.append(a4)
        
        let a5 = Speciality(name: "Sleep Medicine")
        speciality.append(a5)
        
        //MARK: - Dermatology
        
        let d1 = Speciality(name: "Dermatopathology")
        speciality.append(d1)
        
        let d2 = Speciality(name: "Pediatric Dermatology")
        speciality.append(d2)
        
        let d3 = Speciality(name: "Procedural Dermatology")
        speciality.append(d3)
        
        //MARK: - Diagnostic radiology
        
        let dr1 = Speciality(name: "Abdominal Radiology")
        speciality.append(dr1)
        
        let dr2 = Speciality(name: "Breast imaging")
        speciality.append(dr2)
        
        let dr3 = Speciality(name: "Cardiothoracic Radiology")
        speciality.append(dr3)
        
        let dr4 = Speciality(name: "Cardiovascular radiology")
        speciality.append(dr4)
        
        let dr5 = Speciality(name: "Chest radiology")
        speciality.append(dr5)
        
        let dr6 = Speciality(name: "Emergency radiology")
        speciality.append(dr6)
        
        let dr7 = Speciality(name: "Endovascular surgical neuroradiology")
        speciality.append(dr7)
        
        let dr8 = Speciality(name: "Gastrointestinal radiology")
        speciality.append(dr8)
        
        let dr9 = Speciality(name: "Genitourinary radiology")
        speciality.append(dr9)
        
        let dr10 = Speciality(name: "Head and neck radiology")
        speciality.append(dr10)
        
        let dr11 = Speciality(name: "Interventional radiology")
        speciality.append(dr11)
        
        let dr12 = Speciality(name: "Musculoskeletal radiology")
        speciality.append(dr12)
        
        let dr13 = Speciality(name: "Neuroradiology")
        speciality.append(dr13)
        
        let dr14 = Speciality(name: "Nuclear radiology")
        speciality.append(dr14)
        
        let dr15 = Speciality(name: "Pediatric radiology")
        speciality.append(dr15)
        
        let dr16 = Speciality(name: "Radiation oncology")
        speciality.append(dr16)
        
        let dr17 = Speciality(name: "Vascular and interventional radiology")
        speciality.append(dr17)
        
        return speciality
    }
    
    static func isHighlighted(speciality: [Speciality]) -> [Bool] {
        var highlight: [Bool] = []
        speciality.forEach { _ in highlight.append(false) }
        return highlight
    }
}
