//
//  Category.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/11/22.
//

import UIKit

struct Category: Codable, Hashable {
    var name: String
}

extension Category {
    static func allCategories() -> [Category] {
        
        var categories: [Category] = []

        let os1 = Category(name: "General Medicine")
        let os21 = Category(name: "Academic Medicine")
        
        let os2 = Category(name: "Allergology")
        let os3 = Category(name: "Clinical Analyses")
        let os4 = Category(name: "Pathological Anatomy")
        let os5 = Category(name: "Anaesthesiology and Resuscitation")
        let os6 = Category(name: "Angiology and Vascular Surgery")
        let os7 = Category(name: "Digestive System")
        let os8 = Category(name: "Clinical Biochemistry")
        let os9 = Category(name: "Cardiology")
        let os10 = Category(name: "Cardiovascular Surgery")
        let os11 = Category(name: "General and Digestive System Surgery")
        let os12 = Category(name: "Oral and Maxillofacial Surgery")
        let os13 = Category(name: "Orthopaedic Surgery and Traumatology")
        let os14 = Category(name: "Paediatric Surgery")
        let os15 = Category(name: "Plastic, Aesthetic and Reconstructive Surgery")
        let os16 = Category(name: "Thoracic Surgery")
        let os17 = Category(name: "Medical and Surgical Dermatology")
        let os18 = Category(name: "Endocrinology and Nutrition")
        let os19 = Category(name: "Clinical Pharmacology")
        let os20 = Category(name: "Geriatrics")
        
        let os22 = Category(name: "Haematology and Haemotherapy")
        let os23 = Category(name: "Immunology")
        let os24 = Category(name: "Legal and Forensic Medicine")
        let os25 = Category(name: "Occupational Medicine")
        let os26 = Category(name: "Family and Community Medicine")
        let os27 = Category(name: "Physical Medicine and Rehabilitation")
        let os28 = Category(name: "Intensive Care Medicine")
        let os29 = Category(name: "Internal Medicine")
        let os30 = Category(name: "Nuclear Medicine")
        let os31 = Category(name: "Preventive Medicine and Public Health")
        let os32 = Category(name: "Microbiology and Parasitology")
        let os33 = Category(name: "Nephrology")
        let os34 = Category(name: "Pneumology")
        let os35 = Category(name: "Neurosurgery")
        let os36 = Category(name: "Clinical Neurophysiology")
        let os37 = Category(name: "Neurology")
        let os38 = Category(name: "Obstetrics and Gynaecology")
        let os39 = Category(name: "Ophthalmology")
        let os40 = Category(name: "Medical Oncology")
        
        let os41 = Category(name: "Radiation Oncology")
        let os42 = Category(name: "Otorhinolaryngology")
        let os43 = Category(name: "Paediatrics and Specific Areas")
        let os44 = Category(name: "Psychiatry")
        let os45 = Category(name: "Radiodiagnostics")
        let os46 = Category(name: "Rheumatology")
        let os47 = Category(name: "Urology")
        
        categories.append(contentsOf: [os1, os21, os2, os3, os4, os5, os6, os7, os8, os9, os10, os11, os12, os13, os14, os15, os16, os17, os18, os19, os20, os22, os23, os24, os25, os26, os27, os28, os29, os30, os31, os32, os33, os34, os35, os36, os37, os38, os39, os40, os41, os42, os43, os44, os45, os46, os47])
        
        return categories
    }
}
