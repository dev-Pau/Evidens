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
    /*
    static func isHighlighted(speciality: [Speciality]) -> [Bool] {
        var highlight: [Bool] = []
        speciality.forEach { _ in highlight.append(false) }
        return highlight
    }
     */
    
    //MARK: - Student Specialities
    
    static func odontologySpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Odontology")
        let os12 = Speciality(name: "Academic Odontology")
        let os2 = Speciality(name: "Paediatric Odontology")
        let os3 = Speciality(name: "Endodontics")
        let os4 = Speciality(name: "Orthodontics")
        let os5 = Speciality(name: "Prosthodontics")
        let os6 = Speciality(name: "Periodontics")
        let os7 = Speciality(name: "Maxillofacial and Oral Surgery")
        let os8 = Speciality(name: "Maxillofacial and Oral Radiology")
        let os9 = Speciality(name: "Oral and Maxillofacial Pathology")
        let os10 = Speciality(name: "Dental Prothesis")
        let os11 = Speciality(name: "Dental Aesthetics")

        specialities.append(contentsOf: [os1, os12, os2, os3, os4, os5, os6, os7, os8, os9, os10, os11])
        
        return specialities
    }
    
    static func psychologySpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Psychology")
        let os21 = Speciality(name: "Academic Psychology")
        let os2 = Speciality(name: "Clinical Neuropsychology")
        let os3 = Speciality(name: "Clinical Health Psychology")
        let os4 = Speciality(name: "Psychoanalysis")
        let os5 = Speciality(name: "School Psychology")
        let os6 = Speciality(name: "Clinical Psychology")
        let os7 = Speciality(name: "Clinical Child and Adolescent Psychology")
        let os8 = Speciality(name: "Counseling Psychology")
        let os9 = Speciality(name: "Industrial-Organizational Psychology")
        let os10 = Speciality(name: "Behavioral and Cognitive Psychology")
        let os11 = Speciality(name: "Forensic Psychology")
        let os12 = Speciality(name: "Couple and Family Psychology")
        let os13 = Speciality(name: "Geropsychology")
        let os14 = Speciality(name: "Police and Public Safety Psychology")
        let os15 = Speciality(name: "Sleep Psychology")
        let os16 = Speciality(name: "Rehabilitation Psychology")
        let os17 = Speciality(name: "Serious Mental Illness Psychology")
        let os18 = Speciality(name: "Clinical Psychopharmacology")
        let os19 = Speciality(name: "Addiction Psychology")
        let os20 = Speciality(name: "Sport Psychology")

        specialities.append(contentsOf: [os1, os21, os2, os3, os4, os5, os6, os7, os8, os9, os10, os11, os12, os13, os14, os15, os16, os17, os18, os19, os20])
        
        return specialities
    }
    

    static func physiotherapySpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Physiotherapy")
        let os11 = Speciality(name: "Academic Physiotherapy")
        let os2 = Speciality(name: "Geriatric")
        let os3 = Speciality(name: "Orthopaedic")
        let os4 = Speciality(name: "Neurology")
        let os5 = Speciality(name: "Pediatric")
        let os6 = Speciality(name: "Oncology")
        let os7 = Speciality(name: "Women’s Health")
        let os8 = Speciality(name: "Electrophysiologic")
        let os9 = Speciality(name: "Sports")
        let os10 = Speciality(name: "Wound Management")
    
        specialities.append(contentsOf: [os1, os11, os2, os3, os4, os5, os6, os7, os8, os9, os10])
        
        return specialities
    }
    
    static func pharmacySpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Pharmacy")
        let os11 = Speciality(name: "Academic Pharmacy")
        let os2 = Speciality(name: "Ambulatory Care Pharmacy")
        let os3 = Speciality(name: "Cardiology Pharmacy")
        let os4 = Speciality(name: "Compounded Sterile Preparations Pharmacy")
        let os5 = Speciality(name: "Critical Care Pharmacy")
        let os6 = Speciality(name: "Emergency Medicine Pharmacy")
        let os7 = Speciality(name: "Geriatric Pharmacy")
        let os8 = Speciality(name: "Infectious Diseases Pharmacy")
        let os9 = Speciality(name: "Nuclear Pharmacy")
        let os10 = Speciality(name: "Nutrition Support Pharmacy")

        let os12 = Speciality(name: "Oncology Pharmacy")
        let os13 = Speciality(name: "Pediatric Pharmacy")
        let os14 = Speciality(name: "Pharmacotherapy")
        let os15 = Speciality(name: "Psychiatric Pharmacy")
        let os16 = Speciality(name: "Solid Organ Transplantation Pharmacy")
    
        specialities.append(contentsOf: [os1, os11, os2, os3, os4, os5, os6, os7, os8, os9, os10, os12, os13, os14, os15, os16])
        
        return specialities
    }
    
    static func nursingSpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Nurse")
        let os11 = Speciality(name: "Registered Nurse")
        let os2 = Speciality(name: "Cardiac Nurse")
        let os3 = Speciality(name: "Certified Registered Nurse Anesthetist")
        let os4 = Speciality(name: "Clinical Nurse Specialist")
        let os5 = Speciality(name: "Critical Care Nurse")
        let os6 = Speciality(name: "Family Nurse Practitioner")
        let os7 = Speciality(name: "Geriatric Nursing")
        let os8 = Speciality(name: "Perioperative Nurse")
        let os9 = Speciality(name: "Mental Health Nurse")
        let os10 = Speciality(name: "Nurse Educator")

        let os12 = Speciality(name: "Nurse Midwife")
        let os13 = Speciality(name: "Nurse Practitioner")
        let os14 = Speciality(name: "Oncology Nurse")
        let os15 = Speciality(name: "Pediatric Nurse")
        let os16 = Speciality(name: "Public Health Nurse")
    
        specialities.append(contentsOf: [os1, os11, os2, os3, os4, os5, os6, os7, os8, os9, os10, os12, os13, os14, os15, os16])
        
        return specialities
    }
    
    static func veterinarySpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Veterinary")
        let os11 = Speciality(name: "Academic Veterinary")
        let os2 = Speciality(name: "Animal Welfare")
        let os3 = Speciality(name: "Behavioral Medicine")
        let os4 = Speciality(name: "Clinical Pharmacology")
        let os5 = Speciality(name: "Dentistry")
        let os6 = Speciality(name: "Dermatology")
        let os7 = Speciality(name: "Emergency and Critical Care")
        let os8 = Speciality(name: "Internal Medicine")
        let os9 = Speciality(name: "Laboratory Animal Medicine")
        let os10 = Speciality(name: "Microbiology")

        let os12 = Speciality(name: "Nutrition")
        let os13 = Speciality(name: "Ophthalmology")
        let os14 = Speciality(name: "Pathology")
        let os15 = Speciality(name: "Poultry Veterinary Medicine")
        let os16 = Speciality(name: "Preventive Medicine")
    
        let os17 = Speciality(name: "Radiology")
        let os18 = Speciality(name: "Species-specialized Veterinary Practice")
        let os19 = Speciality(name: "Sports Medicine and Rehabilitation")
        let os20 = Speciality(name: "Surgery")
        let os21 = Speciality(name: "Toxicology")
        let os22 = Speciality(name: "Zoological Medicine")

        specialities.append(contentsOf: [os1, os11, os2, os3, os4, os5, os6, os7, os8, os9, os10, os12, os13, os14, os15, os16, os17, os18, os19, os20, os21, os22])
        
        return specialities
    }
    
    static func podiatrySpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Podiatry")
        let os11 = Speciality(name: "Academic Podiatry")
        let os2 = Speciality(name: "Reconstructive Surgery")
        let os3 = Speciality(name: "Podiatric medicine")
        let os4 = Speciality(name: "Podiatric orthopedics")
        let os5 = Speciality(name: "Podiatric sports medicine")
        let os6 = Speciality(name: "High-risk wound care")
        let os7 = Speciality(name: "Podiatric rheumatology")
        let os8 = Speciality(name: "Neuropodiatry")
        let os9 = Speciality(name: "Oncopodiatry")
        let os10 = Speciality(name: "Podiatric vascular medicine")

        let os12 = Speciality(name: "Podiatric dermatology")
        let os13 = Speciality(name: "Podoradiology")
        let os14 = Speciality(name: "Podiatric gerontology")
        let os15 = Speciality(name: "Podiatric diabetology")
        let os16 = Speciality(name: "Podopediatrics")
    
        let os17 = Speciality(name: "Forensic podiatry")
    
        specialities.append(contentsOf: [os1, os11, os2, os3, os4, os5, os6, os7, os8, os9, os10, os12, os13, os14, os15, os16, os17])
        
        return specialities
    }
    
    static func nutritionSpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Nutrition & Dietetics")
        let os11 = Speciality(name: "Academic Nutrition & Dietetics")
        let os2 = Speciality(name: "Clinical Nutrition")
        let os3 = Speciality(name: "Community Nutrition")
        let os4 = Speciality(name: "Procedural Expertise")
        let os5 = Speciality(name: "Sports Nutritionist")
        let os6 = Speciality(name: "Pediatric Nutritionist")
        let os7 = Speciality(name: "Gerontological Nutritionist")
        let os8 = Speciality(name: "Renal or Nephrology Nutritionist")
      
        specialities.append(contentsOf: [os1, os11, os2, os3, os4, os5, os6, os7, os8])
        
        return specialities
    }
    
    static func opticsSpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Optics & Optometry")
        let os11 = Speciality(name: "Academic Optics & Optometry")
        let os2 = Speciality(name: "Cornea and Contact Lenses")
        let os3 = Speciality(name: "Ocular Disease")
        let os4 = Speciality(name: "Low Vision")
        let os5 = Speciality(name: "Pediatrics")
        let os6 = Speciality(name: "Geriatrics")
        let os7 = Speciality(name: "Neuro-Optometry")
        let os8 = Speciality(name: "Behavioral Optometry/Vision Therapy")
      
        specialities.append(contentsOf: [os1, os11, os2, os3, os4, os5, os6, os7, os8])
        
        return specialities
    }
    
    static func biomedicalSpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Biomedical Science")
        let os11 = Speciality(name: "Academic Biomedical Science")
        let os2 = Speciality(name: "Biomechanical Engineering")
        let os3 = Speciality(name: "Biomedical Engineering")
        let os4 = Speciality(name: "Clinical Biochemistry")
        let os5 = Speciality(name: "Vascular Science")
        let os6 = Speciality(name: "Clinical Engineering")
        let os7 = Speciality(name: "Medical Electronics")
        let os8 = Speciality(name: "Microbiology")

    
        specialities.append(contentsOf: [os1, os11, os2, os3, os4, os5, os6, os7, os8])
        
        return specialities
    }
    
    static func medicineSpecialities() -> [Speciality] {
        var specialities: [Speciality] = []
        
        let os1 = Speciality(name: "General Medicine")
        let os21 = Speciality(name: "Academic Medicine")
        
        let os2 = Speciality(name: "Allergology")
        let os3 = Speciality(name: "Clinical Analyses")
        let os4 = Speciality(name: "Pathological Anatomy")
        let os5 = Speciality(name: "Anaesthesiology and Resuscitation")
        let os6 = Speciality(name: "Angiology and Vascular Surgery")
        let os7 = Speciality(name: "Digestive System")
        let os8 = Speciality(name: "Clinical Biochemistry")
        let os9 = Speciality(name: "Cardiology")
        let os10 = Speciality(name: "Cardiovascular Surgery")
        let os11 = Speciality(name: "General and Digestive System Surgery")
        let os12 = Speciality(name: "Oral and Maxillofacial Surgery")
        let os13 = Speciality(name: "Orthopaedic Surgery and Traumatology")
        let os14 = Speciality(name: "Paediatric Surgery")
        let os15 = Speciality(name: "Plastic, Aesthetic and Reconstructive Surgery")
        let os16 = Speciality(name: "Thoracic Surgery")
        let os17 = Speciality(name: "Medical and Surgical Dermatology")
        let os18 = Speciality(name: "Endocrinology and Nutrition")
        let os19 = Speciality(name: "Clinical Pharmacology")
        let os20 = Speciality(name: "Geriatrics")
        
        let os22 = Speciality(name: "Haematology and Haemotherapy")
        let os23 = Speciality(name: "Immunology")
        let os24 = Speciality(name: "Legal and Forensic Medicine")
        let os25 = Speciality(name: "Occupational Medicine")
        let os26 = Speciality(name: "Family and Community Medicine")
        let os27 = Speciality(name: "Physical Medicine and Rehabilitation")
        let os28 = Speciality(name: "Intensive Care Medicine")
        let os29 = Speciality(name: "Internal Medicine")
        let os30 = Speciality(name: "Nuclear Medicine")
        let os31 = Speciality(name: "Preventive Medicine and Public Health")
        let os32 = Speciality(name: "Microbiology and Parasitology")
        let os33 = Speciality(name: "Nephrology")
        let os34 = Speciality(name: "Pneumology")
        let os35 = Speciality(name: "Neurosurgery")
        let os36 = Speciality(name: "Clinical Neurophysiology")
        let os37 = Speciality(name: "Neurology")
        let os38 = Speciality(name: "Obstetrics and Gynaecology")
        let os39 = Speciality(name: "Ophthalmology")
        let os40 = Speciality(name: "Medical Oncology")
        
        let os41 = Speciality(name: "Radiation Oncology")
        let os42 = Speciality(name: "Otorhinolaryngology")
        let os43 = Speciality(name: "Paediatrics and Specific Areas")
        let os44 = Speciality(name: "Psychiatry")
        let os45 = Speciality(name: "Radiodiagnostics")
        let os46 = Speciality(name: "Rheumatology")
        let os47 = Speciality(name: "Urology")
     
        specialities.append(contentsOf: [os1, os21, os2, os3, os4, os5, os6, os7, os8, os9, os10, os11, os12, os13, os14, os15, os16, os17, os18, os19, os20, os22, os23, os24, os25, os26, os27, os28, os29, os30, os31, os32, os33, os34, os35, os36, os37, os38, os39, os40, os41, os42, os43, os44, os45, os46, os47])
        
        return specialities
    }
    
    static func getSpecialitiesByProfession(profession: Profession.Professions) -> [Speciality] {
        switch profession {
        case .medicine:
            return medicineSpecialities()
        case .odontology:
            return odontologySpecialities()
        case .pharmacy:
            return pharmacySpecialities()
        case .physiotherapy:
            return physiotherapySpecialities()
        case .nursing:
            return nursingSpecialities()
        case .veterinary:
            return veterinarySpecialities()
        case .psychology:
            return psychologySpecialities()
        case .podiatry:
            return podiatrySpecialities()
        case .nutrition:
            return nutritionSpecialities()
        case .optics:
            return opticsSpecialities()
        case .biomedical:
            return biomedicalSpecialities()
        case .physical:
            #warning("pending to configure physical ones")
            return physiotherapySpecialities()
        case .speech:
#warning("pending to configure speech ones")
            return physiotherapySpecialities()
        } 
    }
}
