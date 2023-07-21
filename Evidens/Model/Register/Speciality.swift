//
//  Speciality.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/7/22.
//

import UIKit
/*
/// The model for a Speciality
struct Speciality: Codable, Hashable {
    var name: String
}

extension Speciality {
    
    /// Gets all the possible specialities.
    ///
    /// - Returns:
    /// An array containing all the specialities.
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

    /// Gets all the possible odontology specialities.
    ///
    /// - Returns:
    /// An array containing all the odontology specialities.
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
    
    /// Gets all the possible psychology specialities.
    ///
    /// - Returns:
    /// An array containing all the psychology specialities.
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
    
    /// Gets all the possible physiotherapy specialities.
    ///
    /// - Returns:
    /// An array containing all the physiotherapy specialities.
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
    
    /// Gets all the possible pharmacy specialities.
    ///
    /// - Returns:
    /// An array containing all the pharmacy specialities.
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
    
    /// Gets all the possible nursing specialities.
    ///
    /// - Returns:
    /// An array containing all the nursing specialities.
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
    
    /// Gets all the possible veterinary specialities.
    ///
    /// - Returns:
    /// An array containing all the veterinary specialities.
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
    
    /// Gets all the possible podiatry specialities.
    ///
    /// - Returns:
    /// An array containing all the podiatry specialities.
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
    
    /// Gets all the possible nutrition specialities.
    ///
    /// - Returns:
    /// An array containing all the nutrition specialities.
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
    
    /// Gets all the possible optics specialities.
    ///
    /// - Returns:
    /// An array containing all the optics specialities.
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
    
    /// Gets all the possible biomedical specialities.
    ///
    /// - Returns:
    /// An array containing all the biomedical specialities.
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
    
    /// Gets all the possible medicine specialities.
    ///
    /// - Returns:
    /// An array containing all the medicine specialities.
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
    
    /// Gets all the possible specialities with a given profession.
    ///
    /// - Parameters:
    ///   - profession: The Profession type.
    ///
    /// - Returns:
    /// An array containing all the specialities for a given profession.
    static func getSpecialitiesByProfession(profession: Discipline) -> [Speciality] {
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
        case .occupational:
            return physiotherapySpecialities()
        }
    }
}
 */

enum Speciality: Int, CaseIterable, Codable, Hashable {

    /// Odontology
    case generalOdontology, academicOdontology, paediatricOdontology, endodontics, orthodontics, prosthodontics, maxillofacialSurgery, maxillofacialRadiology, oralPathology, prothesis, aesthetics
    
    /// Psychology
    case generalPsychology, academicPsychology, neuropsychology, healthPsychology, psychoanalysis, schoolPsychology, clinicalPsychology, childPsychology, counselingPsychology, industrialPsychology, behavioralPsychology, forensicPsychology, familyPsychology, geropsychology, policePsychology, sleepPsychology, rehabilitationPsychology, mentalPsychology, clinicalPsychopharmacology, addictionPsychology, sportPsychology
    
    /// Biomedical
    case generalBiomedical, academicBiomedical, engineeringBiomedical, engineeringBiomechanical, clinicalBiochemistry, vascularScience, clinicalEngineering, medicalElectronics, microbiology
    
    /// Optics
    case generalOptics, academicOptics, corneaContactLenses, ocularDisease, opticsLowVision, opticsPediatrics, opticsGeriatrics, opticsOptometry, opticsVisionTherapy
    
    /// Physiotherapy
    case generalPhysiotherapy, academicPhysiotherapy, geriatricPhysiotherapy, orthopaedicPhysiotherapy, neurologyPhysiotherapy, pediatricPhysiotherapy, oncologyPhysiotherapy, womensPhysiotherapy, electrophysiologicPhysiotherapy, sportsPhysiotherapy, woundPhysiotherapy
    
    /// Pharmacy
    case generalPharmacy, academicPharmacy, ambulatoriPharmacy, cardiologyPharmacy, compoundedPharmacy, criticalPharmacy, emergencyPharmacy, geriatricPharmacy, infectiousPharmacy, nuclearPharmacy, nutritionPharmacy, oncologyPharmacy, pediatricPharmacy, pharmacotherapy, psychiatricPharmacy, organPharmacy
    
    /// Nursing
    case generalNurse, registeredNurse, cardiacNurse, certifiedNurse, clinicalNurse, criticalNurse, familyNurse, geriatricNurse, perioperativeNurse, mentalNurse, educatorNurse, midwifeNurse, practitionerNurse, oncologyNurse, pediatricNurse, publicNurse
    
    /// Veterinary
    case generalVeterinary, academicVeterinary, animalWelfare, behavioralVeterinary, pharmacologyVeterinary, dentistryVeterinary, dermatologyVeterinary, emergencyVeterinary, internalVeterinary, laboratoryVeterinary, microbiologyVeterinary, nutritionVeterinary, ophthalmologyVeterinary, pathologyVeterinary, poultryVeterinary, preventiveVeterinary, radiologyVeterinary, speciesVeterinary, sportsVeterinary, surgeryVeterinary, toxicologyVeterinary, zoologicalVeterinary
    
    /// Podiatry
    case generalPodiatry, academicPodiatry, reconstructivePodiatry, medicinePodiatry, orthopedicsPodiatry, sportsPodiatry, riskPodiatry, rheumatologyPodiatry, neuropodiatry, oncopodiatry, vascularPodiatry, dermatologyPodiatry, podoradiology, gerontologyPodiatry, diabetologyPodiatry, podopediatrics, forensicPodiatry

    /// Nutrition
    case generalNutrition, academicNutrition, clinicalNutrition, communityNutrition, proceduralExpertise, sportsNutrition, pediatricNutrition, gerontologicalNutrition, renalNutrition
    
    /// Medicine
    case generalMedicine, academicMedicine, allergologyMedicine, analysesMedicine, pathologicalMedicine, anaesthesiologyMedicine, angiologyMedicine, digestiveMedicine, biochemistryMedicine, cardiologyMedicine, cardiovascularMedicine, digestiveSurgeryMedicine, oralMaxillofacialMedicine, orthopaedicSurgeryMedicine, paediatricMedicine, plasticMedicine, thoracicMedicine, dermatologyMedicine, endocrinologyMedicine, pharmacologyMedicine, geriatricsMedicine, haematologyMedicine, immunologyMedicine, legalForensicMedicine, occupationalMedicine, familyMedicine, physicalMedicine, intensiveMedicine, internalMedicine, nuclearMedicine, preventiveMedicine, microbiologyMedicine, nephrologyMedicine, pneumologyMedicine, neurosurgeryMedicine, neurophysiologyMedicine, neurologyMedicine, obstetricsMedicine, ophthalmologyMedicine, oncologyMedicine, radiationMedicine, otorhinolaryngology, paediatricsMedicine, psychiatryMedicine, radiodiagnosticsMedicine, rheumatologyMedicine, urologyMedicine

    /// Physical Sports & Science
    case generalSports, academicSports, managementSports, trainingSports, healthSports, recreationSports

    /// Speech Therapy
    case generalSpeech, academicSpeech, articulationSpeech, languageSpeech, fluencySpeech, voiceSpeech, oralSpeech, sensorSpeech, autismSpeech, augmentativeSpeech
    
    /// Ocupational Therapy
    case generalTherapy, academicTherapy, gerontologyTherapy, mentalTherapy, pediatricsTherapy, physicalTherapy, drivingTherapy, environmentalTherapy, feedingTherapy, lowVisionTherapy, schoolTherapy
    
    var name: String {
        switch self {
        
            /// Odontology
        case .generalOdontology: return AppStrings.Health.Speciality.Odontology.generalOdontology
        case .academicOdontology: return AppStrings.Health.Speciality.Odontology.academicOdontology
        case .paediatricOdontology: return AppStrings.Health.Speciality.Odontology.paediatricOdontology
        case .endodontics: return AppStrings.Health.Speciality.Odontology.endodontics
        case .orthodontics: return AppStrings.Health.Speciality.Odontology.orthodontics
        case .prosthodontics: return AppStrings.Health.Speciality.Odontology.prosthodontics
        case .maxillofacialSurgery: return AppStrings.Health.Speciality.Odontology.maxillofacialSurgery
        case .maxillofacialRadiology: return AppStrings.Health.Speciality.Odontology.maxillofacialRadiology
        case .oralPathology: return AppStrings.Health.Speciality.Odontology.oralPathology
        case .prothesis: return AppStrings.Health.Speciality.Odontology.prothesis
        case .aesthetics: return AppStrings.Health.Speciality.Odontology.aesthetics
            
            /// Psychology
        case .generalPsychology: return AppStrings.Health.Speciality.Psychology.generalPsychology
        case .academicPsychology: return AppStrings.Health.Speciality.Psychology.academicPsychology
        case .neuropsychology: return AppStrings.Health.Speciality.Psychology.neuropsychology
        case .healthPsychology: return AppStrings.Health.Speciality.Psychology.healthPsychology
        case .psychoanalysis: return AppStrings.Health.Speciality.Psychology.psychoanalysis
        case .schoolPsychology: return AppStrings.Health.Speciality.Psychology.schoolPsychology
        case .clinicalPsychology: return AppStrings.Health.Speciality.Psychology.clinicalPsychology
        case .childPsychology: return AppStrings.Health.Speciality.Psychology.childPsychology
        case .counselingPsychology: return AppStrings.Health.Speciality.Psychology.counselingPsychology
        case .industrialPsychology: return AppStrings.Health.Speciality.Psychology.industrialPsychology
        case .behavioralPsychology: return AppStrings.Health.Speciality.Psychology.behavioralPsychology
        case .forensicPsychology: return AppStrings.Health.Speciality.Psychology.forensicPsychology
        case .familyPsychology: return AppStrings.Health.Speciality.Psychology.familyPsychology
        case .geropsychology: return AppStrings.Health.Speciality.Psychology.geropsychology
        case .policePsychology: return AppStrings.Health.Speciality.Psychology.policePsychology
        case .sleepPsychology: return AppStrings.Health.Speciality.Psychology.sleepPsychology
        case .rehabilitationPsychology: return AppStrings.Health.Speciality.Psychology.rehabilitationPsychology
        case .mentalPsychology: return AppStrings.Health.Speciality.Psychology.mentalPsychology
        case .clinicalPsychopharmacology: return AppStrings.Health.Speciality.Psychology.clinicalPsychopharmacology
        case .addictionPsychology: return AppStrings.Health.Speciality.Psychology.addictionPsychology
        case .sportPsychology: return AppStrings.Health.Speciality.Psychology.sportPsychology
            
            /// Biomedical
        case .generalBiomedical: return AppStrings.Health.Speciality.Biomedical.generalBiomedical
        case .academicBiomedical: return AppStrings.Health.Speciality.Biomedical.academicBiomedical
        case .engineeringBiomedical: return AppStrings.Health.Speciality.Biomedical.engineeringBiomedical
        case .engineeringBiomechanical: return AppStrings.Health.Speciality.Biomedical.engineeringBiomechanical
        case .clinicalBiochemistry: return AppStrings.Health.Speciality.Biomedical.clinicalBiochemistry
        case .vascularScience: return AppStrings.Health.Speciality.Biomedical.vascularScience
        case .clinicalEngineering: return AppStrings.Health.Speciality.Biomedical.clinicalEngineering
        case .medicalElectronics: return AppStrings.Health.Speciality.Biomedical.medicalElectronics
        case .microbiology: return AppStrings.Health.Speciality.Biomedical.microbiology
        
            /// Optics
        case .generalOptics: return AppStrings.Health.Speciality.Optics.generalOptics
        case .academicOptics: return AppStrings.Health.Speciality.Optics.academicOptics
        case .corneaContactLenses: return AppStrings.Health.Speciality.Optics.corneaContactLenses
        case .ocularDisease: return AppStrings.Health.Speciality.Optics.ocularDisease
        case .opticsLowVision: return AppStrings.Health.Speciality.Optics.opticsLowVision
        case .opticsPediatrics: return AppStrings.Health.Speciality.Optics.opticsPediatrics
        case .opticsGeriatrics: return AppStrings.Health.Speciality.Optics.opticsGeriatrics
        case .opticsOptometry: return AppStrings.Health.Speciality.Optics.opticsOptometry
        case .opticsVisionTherapy: return AppStrings.Health.Speciality.Optics.opticsVisionTherapy
            
            /// Physiotherapy
        case .generalPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.generalPhysiotherapy
        case .academicPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.academicPhysiotherapy
        case .geriatricPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.geriatricPhysiotherapy
        case .orthopaedicPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.orthopaedicPhysiotherapy
        case .neurologyPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.neurologyPhysiotherapy
        case .pediatricPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.pediatricPhysiotherapy
        case .oncologyPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.oncologyPhysiotherapy
        case .womensPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.womensPhysiotherapy
        case .electrophysiologicPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.electrophysiologicPhysiotherapy
        case .sportsPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.sportsPhysiotherapy
        case .woundPhysiotherapy: return AppStrings.Health.Speciality.Physiotherapy.woundPhysiotherapy
            
            /// Pharmacy
        case .generalPharmacy: return AppStrings.Health.Speciality.Pharmacy.generalPharmacy
        case .academicPharmacy: return AppStrings.Health.Speciality.Pharmacy.academicPharmacy
        case .ambulatoriPharmacy: return AppStrings.Health.Speciality.Pharmacy.ambulatoriPharmacy
        case .cardiologyPharmacy: return AppStrings.Health.Speciality.Pharmacy.cardiologyPharmacy
        case .compoundedPharmacy: return AppStrings.Health.Speciality.Pharmacy.compoundedPharmacy
        case .criticalPharmacy: return AppStrings.Health.Speciality.Pharmacy.criticalPharmacy
        case .emergencyPharmacy: return AppStrings.Health.Speciality.Pharmacy.emergencyPharmacy
        case .geriatricPharmacy: return AppStrings.Health.Speciality.Pharmacy.geriatricPharmacy
        case .infectiousPharmacy: return AppStrings.Health.Speciality.Pharmacy.infectiousPharmacy
        case .nuclearPharmacy: return AppStrings.Health.Speciality.Pharmacy.nuclearPharmacy
        case .nutritionPharmacy: return AppStrings.Health.Speciality.Pharmacy.nutritionPharmacy
        case .oncologyPharmacy: return AppStrings.Health.Speciality.Pharmacy.oncologyPharmacy
        case .pediatricPharmacy: return AppStrings.Health.Speciality.Pharmacy.pediatricPharmacy
        case .pharmacotherapy: return AppStrings.Health.Speciality.Pharmacy.pharmacotherapy
        case .psychiatricPharmacy: return AppStrings.Health.Speciality.Pharmacy.psychiatricPharmacy
        case .organPharmacy: return AppStrings.Health.Speciality.Pharmacy.organPharmacy
            
            /// Nursing
        case .generalNurse: return AppStrings.Health.Speciality.Nursing.generalNurse
        case .registeredNurse: return AppStrings.Health.Speciality.Nursing.registeredNurse
        case .cardiacNurse: return AppStrings.Health.Speciality.Nursing.cardiacNurse
        case .certifiedNurse: return AppStrings.Health.Speciality.Nursing.certifiedNurse
        case .clinicalNurse: return AppStrings.Health.Speciality.Nursing.clinicalNurse
        case .criticalNurse: return AppStrings.Health.Speciality.Nursing.criticalNurse
        case .familyNurse: return AppStrings.Health.Speciality.Nursing.familyNurse
        case .geriatricNurse: return AppStrings.Health.Speciality.Nursing.geriatricNurse
        case .perioperativeNurse: return AppStrings.Health.Speciality.Nursing.perioperativeNurse
        case .mentalNurse: return AppStrings.Health.Speciality.Nursing.mentalNurse
        case .educatorNurse: return AppStrings.Health.Speciality.Nursing.educatorNurse
        case .midwifeNurse: return AppStrings.Health.Speciality.Nursing.midwifeNurse
        case .practitionerNurse: return AppStrings.Health.Speciality.Nursing.practitionerNurse
        case .oncologyNurse: return AppStrings.Health.Speciality.Nursing.oncologyNurse
        case .publicNurse: return AppStrings.Health.Speciality.Nursing.publicNurse
            
            /// Veterinary
        case .generalVeterinary: return AppStrings.Health.Speciality.Veterinary.generalVeterinary
        case .academicVeterinary: return AppStrings.Health.Speciality.Veterinary.academicVeterinary
        case .animalWelfare: return AppStrings.Health.Speciality.Veterinary.animalWelfare
        case .behavioralVeterinary: return AppStrings.Health.Speciality.Veterinary.behavioralVeterinary
        case .pharmacologyVeterinary: return AppStrings.Health.Speciality.Veterinary.pharmacologyVeterinary
        case .dentistryVeterinary: return AppStrings.Health.Speciality.Veterinary.dentistryVeterinary
        case .dermatologyVeterinary: return AppStrings.Health.Speciality.Veterinary.dermatologyVeterinary
        case .emergencyVeterinary: return AppStrings.Health.Speciality.Veterinary.emergencyVeterinary
        case .internalVeterinary: return AppStrings.Health.Speciality.Veterinary.internalVeterinary
        case .laboratoryVeterinary: return AppStrings.Health.Speciality.Veterinary.laboratoryVeterinary
        case .microbiologyVeterinary: return AppStrings.Health.Speciality.Veterinary.microbiologyVeterinary
        case .nutritionVeterinary: return AppStrings.Health.Speciality.Veterinary.nutritionVeterinary
        case .ophthalmologyVeterinary: return AppStrings.Health.Speciality.Veterinary.ophthalmologyVeterinary
        case .pathologyVeterinary: return AppStrings.Health.Speciality.Veterinary.pathologyVeterinary
        case .poultryVeterinary: return AppStrings.Health.Speciality.Veterinary.poultryVeterinary
        case .preventiveVeterinary: return AppStrings.Health.Speciality.Veterinary.preventiveVeterinary
        case .radiologyVeterinary: return AppStrings.Health.Speciality.Veterinary.radiologyVeterinary
        case .speciesVeterinary: return AppStrings.Health.Speciality.Veterinary.speciesVeterinary
        case .sportsVeterinary: return AppStrings.Health.Speciality.Veterinary.sportsVeterinary
        case .surgeryVeterinary: return AppStrings.Health.Speciality.Veterinary.surgeryVeterinary
        case .toxicologyVeterinary: return AppStrings.Health.Speciality.Veterinary.toxicologyVeterinary
        case .zoologicalVeterinary: return AppStrings.Health.Speciality.Veterinary.zoologicalVeterinary
            
            /// Podiatry
        case .generalPodiatry: return AppStrings.Health.Speciality.Podiatry.generalPodiatry
        case .academicPodiatry: return AppStrings.Health.Speciality.Podiatry.academicPodiatry
        case .reconstructivePodiatry: return AppStrings.Health.Speciality.Podiatry.reconstructivePodiatry
        case .medicinePodiatry: return AppStrings.Health.Speciality.Podiatry.medicinePodiatry
        case .orthopedicsPodiatry: return AppStrings.Health.Speciality.Podiatry.orthopedicsPodiatry
        case .sportsPodiatry: return AppStrings.Health.Speciality.Podiatry.sportsPodiatry
        case .riskPodiatry: return AppStrings.Health.Speciality.Podiatry.riskPodiatry
        case .rheumatologyPodiatry: return AppStrings.Health.Speciality.Podiatry.rheumatologyPodiatry
        case .neuropodiatry: return AppStrings.Health.Speciality.Podiatry.neuropodiatry
        case .oncopodiatry: return AppStrings.Health.Speciality.Podiatry.oncopodiatry
        case .vascularPodiatry: return AppStrings.Health.Speciality.Podiatry.vascularPodiatry
        case .dermatologyPodiatry: return AppStrings.Health.Speciality.Podiatry.dermatologyPodiatry
        case .podoradiology: return AppStrings.Health.Speciality.Podiatry.podoradiology
        case .gerontologyPodiatry: return AppStrings.Health.Speciality.Podiatry.gerontologyPodiatry
        case .diabetologyPodiatry: return AppStrings.Health.Speciality.Podiatry.diabetologyPodiatry
        case .podopediatrics: return AppStrings.Health.Speciality.Podiatry.podopediatrics
        case .forensicPodiatry: return AppStrings.Health.Speciality.Podiatry.forensicPodiatry
            
            /// Nutrition
        case .generalNutrition: return AppStrings.Health.Speciality.Nutrition.generalNutrition
        case .academicNutrition: return AppStrings.Health.Speciality.Nutrition.academicNutrition
        case .clinicalNutrition: return AppStrings.Health.Speciality.Nutrition.clinicalNutrition
        case .communityNutrition: return AppStrings.Health.Speciality.Nutrition.communityNutrition
        case .proceduralExpertise: return AppStrings.Health.Speciality.Nutrition.proceduralExpertise
        case .sportsNutrition: return AppStrings.Health.Speciality.Nutrition.sportsNutrition
        case .pediatricNutrition: return AppStrings.Health.Speciality.Nutrition.pediatricNutrition
        case .gerontologicalNutrition: return AppStrings.Health.Speciality.Nutrition.gerontologicalNutrition
        case .renalNutrition: return AppStrings.Health.Speciality.Nutrition.renalNutrition
            
            /// Medicine
        case .generalMedicine: return AppStrings.Health.Speciality.Medicine.generalMedicine
        case .academicMedicine: return AppStrings.Health.Speciality.Medicine.academicMedicine
        case .allergologyMedicine: return AppStrings.Health.Speciality.Medicine.allergologyMedicine
        case .analysesMedicine: return AppStrings.Health.Speciality.Medicine.analysesMedicine
        case .pathologicalMedicine: return AppStrings.Health.Speciality.Medicine.pathologicalMedicine
        case .anaesthesiologyMedicine: return AppStrings.Health.Speciality.Medicine.anaesthesiologyMedicine
        case .angiologyMedicine: return AppStrings.Health.Speciality.Medicine.angiologyMedicine
        case .digestiveMedicine: return AppStrings.Health.Speciality.Medicine.digestiveMedicine
        case .biochemistryMedicine: return AppStrings.Health.Speciality.Medicine.biochemistryMedicine
        case .cardiologyMedicine: return AppStrings.Health.Speciality.Medicine.cardiologyMedicine
        case .cardiovascularMedicine: return AppStrings.Health.Speciality.Medicine.cardiovascularMedicine
        case .digestiveSurgeryMedicine: return AppStrings.Health.Speciality.Medicine.digestiveSurgeryMedicine
        case .oralMaxillofacialMedicine: return AppStrings.Health.Speciality.Medicine.oralMaxillofacialMedicine
        case .orthopaedicSurgeryMedicine: return AppStrings.Health.Speciality.Medicine.orthopaedicSurgeryMedicine
        case .paediatricMedicine: return AppStrings.Health.Speciality.Medicine.paediatricMedicine
        case .plasticMedicine: return AppStrings.Health.Speciality.Medicine.plasticMedicine
        case .thoracicMedicine: return AppStrings.Health.Speciality.Medicine.thoracicMedicine
        case .intensiveMedicine: return AppStrings.Health.Speciality.Medicine.intensiveMedicine
        case .dermatologyMedicine: return AppStrings.Health.Speciality.Medicine.dermatologyMedicine
        case .endocrinologyMedicine: return AppStrings.Health.Speciality.Medicine.endocrinologyMedicine
        case .pharmacologyMedicine: return AppStrings.Health.Speciality.Medicine.pharmacologyMedicine
        case .geriatricsMedicine: return AppStrings.Health.Speciality.Medicine.geriatricsMedicine
        case .haematologyMedicine: return AppStrings.Health.Speciality.Medicine.haematologyMedicine
        case .immunologyMedicine: return AppStrings.Health.Speciality.Medicine.immunologyMedicine
        case .legalForensicMedicine: return AppStrings.Health.Speciality.Medicine.legalForensicMedicine
        case .occupationalMedicine: return AppStrings.Health.Speciality.Medicine.occupationalMedicine
        case .familyMedicine: return AppStrings.Health.Speciality.Medicine.familyMedicine
        case .physicalMedicine: return AppStrings.Health.Speciality.Medicine.physicalMedicine
        case .internalMedicine: return AppStrings.Health.Speciality.Medicine.internalMedicine
        case .nuclearMedicine: return AppStrings.Health.Speciality.Medicine.nuclearMedicine
        case .preventiveMedicine: return AppStrings.Health.Speciality.Medicine.preventiveMedicine
        case .microbiologyMedicine: return AppStrings.Health.Speciality.Medicine.microbiologyMedicine
        case .nephrologyMedicine: return AppStrings.Health.Speciality.Medicine.nephrologyMedicine
        case .pneumologyMedicine: return AppStrings.Health.Speciality.Medicine.pneumologyMedicine
        case .neurosurgeryMedicine: return AppStrings.Health.Speciality.Medicine.neurosurgeryMedicine
        case .neurophysiologyMedicine: return AppStrings.Health.Speciality.Medicine.neurophysiologyMedicine
        case .neurologyMedicine: return AppStrings.Health.Speciality.Medicine.neurologyMedicine
        case .obstetricsMedicine: return AppStrings.Health.Speciality.Medicine.obstetricsMedicine
        case .ophthalmologyMedicine: return AppStrings.Health.Speciality.Medicine.ophthalmologyMedicine
        case .oncologyMedicine: return AppStrings.Health.Speciality.Medicine.oncologyMedicine
        case .radiationMedicine: return AppStrings.Health.Speciality.Medicine.radiationMedicine
        case .otorhinolaryngology: return AppStrings.Health.Speciality.Medicine.otorhinolaryngology
        case .paediatricsMedicine: return AppStrings.Health.Speciality.Medicine.paediatricMedicine
        case .psychiatryMedicine: return AppStrings.Health.Speciality.Medicine.psychiatryMedicine
        case .radiodiagnosticsMedicine: return AppStrings.Health.Speciality.Medicine.radiodiagnosticsMedicine
        case .rheumatologyMedicine: return AppStrings.Health.Speciality.Medicine.rheumatologyMedicine
        case .urologyMedicine: return AppStrings.Health.Speciality.Medicine.urologyMedicine
            
            // Sports
        case .generalSports: return AppStrings.Health.Speciality.Physical.generalSports
        case .academicSports: return AppStrings.Health.Speciality.Physical.academicSports
        case .managementSports: return AppStrings.Health.Speciality.Physical.managementSports
        case .trainingSports: return AppStrings.Health.Speciality.Physical.trainingSports
        case .healthSports: return AppStrings.Health.Speciality.Physical.healthSports
        case .recreationSports: return AppStrings.Health.Speciality.Physical.recreationSports
            
            /// Speech
        case .generalSpeech: return AppStrings.Health.Speciality.Speech.generalSpeech
        case .academicSpeech: return AppStrings.Health.Speciality.Speech.academicSpeech
        case .articulationSpeech: return AppStrings.Health.Speciality.Speech.articulationSpeech
        case .languageSpeech: return AppStrings.Health.Speciality.Speech.languageSpeech
        case .fluencySpeech: return AppStrings.Health.Speciality.Speech.fluencySpeech
        case .voiceSpeech: return AppStrings.Health.Speciality.Speech.voiceSpeech
        case .oralSpeech: return AppStrings.Health.Speciality.Speech.oralSpeech
        case .sensorSpeech: return AppStrings.Health.Speciality.Speech.sensorSpeech
        case .autismSpeech: return AppStrings.Health.Speciality.Speech.autismSpeech
        case .augmentativeSpeech: return AppStrings.Health.Speciality.Speech.augmentativeSpeech
            
            /// Occupational
        case .generalTherapy: return AppStrings.Health.Speciality.Occupational.generalTherapy
        case .academicTherapy: return AppStrings.Health.Speciality.Occupational.academicTherapy
        case .gerontologyTherapy: return AppStrings.Health.Speciality.Occupational.gerontologyTherapy
        case .mentalTherapy: return AppStrings.Health.Speciality.Occupational.mentalTherapy
        case .pediatricsTherapy: return AppStrings.Health.Speciality.Occupational.pediatricsTherapy
        case .physicalTherapy: return AppStrings.Health.Speciality.Occupational.physicalTherapy
        case .drivingTherapy: return AppStrings.Health.Speciality.Occupational.drivingTherapy
        case .environmentalTherapy: return AppStrings.Health.Speciality.Occupational.environmentalTherapy
        case .feedingTherapy: return AppStrings.Health.Speciality.Occupational.feedingTherapy
        case .lowVisionTherapy: return AppStrings.Health.Speciality.Occupational.lowVisionTherapy
        case .pediatricNurse: return AppStrings.Health.Speciality.Occupational.pediatricsTherapy
        case .schoolTherapy: return AppStrings.Health.Speciality.Occupational.schoolTherapy
        }
    }
}
