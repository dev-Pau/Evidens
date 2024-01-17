//
//  Speciality.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/7/22.
//

import UIKit

/// An enum mapping all the speciality options.
enum Speciality: Int, CaseIterable, Codable, Hashable {
    
    /// Medicine
    case generalMedicine = 1, academicMedicine = 2, allergologyMedicine = 3, analysesMedicine = 4, pathologicalMedicine = 5, anaesthesiologyMedicine = 6, angiologyMedicine = 7, digestiveMedicine = 8, biochemistryMedicine = 9, cardiologyMedicine = 10, cardiovascularMedicine = 11, digestiveSurgeryMedicine = 12, oralMaxillofacialMedicine = 13, orthopaedicSurgeryMedicine = 14, paediatricMedicine = 15, plasticMedicine = 16, thoracicMedicine = 17, dermatologyMedicine = 18, endocrinologyMedicine = 19, pharmacologyMedicine = 20, geriatricsMedicine = 21, haematologyMedicine = 22, immunologyMedicine = 23, legalForensicMedicine = 24, occupationalMedicine = 25, familyMedicine = 26, physicalMedicine = 27, intensiveMedicine = 28, internalMedicine = 29, nuclearMedicine = 30, preventiveMedicine = 31, microbiologyMedicine = 32, nephrologyMedicine = 33, pneumologyMedicine = 34, neurosurgeryMedicine = 35, neurophysiologyMedicine = 36, neurologyMedicine = 37, obstetricsMedicine = 38, ophthalmologyMedicine = 39, oncologyMedicine = 40, radiationMedicine = 41, otorhinolaryngology = 42, paediatricsMedicine = 43, psychiatryMedicine = 44, radiodiagnosticsMedicine = 45, rheumatologyMedicine = 46, urologyMedicine = 47

    /// Odontology
    case generalOdontology = 101, academicOdontology = 102, paediatricOdontology = 103, endodontics = 104, orthodontics = 105, prosthodontics = 106, maxillofacialSurgery = 107, maxillofacialRadiology = 108, oralPathology = 109, prothesis = 110, aesthetics = 111
    
    /// Psychology
    case generalPsychology = 201, academicPsychology = 202, neuropsychology = 203, healthPsychology = 204, psychoanalysis = 205, schoolPsychology = 206, clinicalPsychology = 207, childPsychology = 208, counselingPsychology = 209, industrialPsychology = 210, behavioralPsychology = 211, forensicPsychology = 212, familyPsychology = 213, geropsychology = 214, policePsychology = 215, sleepPsychology = 216, rehabilitationPsychology = 217, clinicalPsychopharmacology = 218, addictionPsychology = 219, sportPsychology = 220
    
    /// Biomedical
    case generalBiomedical = 301, academicBiomedical = 302, engineeringBiomedical = 303, engineeringBiomechanical = 304, clinicalBiochemistry = 305, clinicalEngineering = 306, medicalElectronics = 307, microbiology = 308
    
    /// Optics
    case generalOptics = 401, academicOptics = 402, corneaContactLenses = 403, ocularDisease = 404, opticsLowVision = 405, opticsPediatrics = 406, opticsGeriatrics = 407, opticsOptometry = 408, opticsVisionTherapy = 409
    
    /// Physiotherapy
    case generalPhysiotherapy = 501, academicPhysiotherapy = 502, geriatricPhysiotherapy = 503, orthopaedicPhysiotherapy = 504, neurologyPhysiotherapy = 505, pediatricPhysiotherapy = 506, oncologyPhysiotherapy = 507, womensPhysiotherapy = 508, electrophysiologicPhysiotherapy = 509, sportsPhysiotherapy = 510, woundPhysiotherapy = 511
    
    /// Pharmacy
    case generalPharmacy = 601, academicPharmacy = 602, ambulatoriPharmacy = 603, cardiologyPharmacy = 604, compoundedPharmacy = 605, criticalPharmacy = 606, emergencyPharmacy = 607, geriatricPharmacy = 608, infectiousPharmacy = 609, nuclearPharmacy = 610, nutritionPharmacy = 611, oncologyPharmacy = 612, pediatricPharmacy = 613, pharmacotherapy = 614, psychiatricPharmacy = 615, organPharmacy = 616
    
    /// Nursing
    case generalNurse = 701, cardiacNurse = 702, certifiedNurse = 703, clinicalNurse = 704, criticalNurse = 705, geriatricNurse = 706, perioperativeNurse = 707, mentalNurse = 708, educatorNurse = 709, midwifeNurse = 710, oncologyNurse = 711, pediatricNurse = 712, publicNurse = 713
    
    /// Veterinary
    case generalVeterinary = 801, academicVeterinary = 802, animalWelfare = 803, behavioralVeterinary = 804, pharmacologyVeterinary = 805, dentistryVeterinary = 806, dermatologyVeterinary = 807, emergencyVeterinary = 808, internalVeterinary = 809, laboratoryVeterinary = 810, microbiologyVeterinary = 811, nutritionVeterinary = 812, ophthalmologyVeterinary = 813, pathologyVeterinary = 814, poultryVeterinary = 815, preventiveVeterinary = 816, radiologyVeterinary = 817, speciesVeterinary = 818, sportsVeterinary = 819, surgeryVeterinary = 820, toxicologyVeterinary = 821, zoologicalVeterinary = 822
    
    /// Podiatry
    case generalPodiatry = 901, academicPodiatry = 902, reconstructivePodiatry = 903, medicinePodiatry = 904, orthopedicsPodiatry = 905, sportsPodiatry = 906, riskPodiatry = 907, rheumatologyPodiatry = 908, neuropodiatry = 909, oncopodiatry = 910, vascularPodiatry = 911, dermatologyPodiatry = 912, podoradiology = 913, gerontologyPodiatry = 914, diabetologyPodiatry = 915, podopediatrics = 916, forensicPodiatry = 917

    /// Nutrition
    case generalNutrition = 1001, academicNutrition = 1002, clinicalNutrition = 1003, communityNutrition = 1004, proceduralExpertise = 1005, sportsNutrition = 1006, pediatricNutrition = 1007, gerontologicalNutrition = 1008, renalNutrition = 1009
    
    /// Physical Sports & Science
    case generalSports = 1101, academicSports = 1102, managementSports = 1103, trainingSports = 1104, healthSports = 1105, recreationSports = 1106

    /// Speech Therapy
    case generalSpeech = 1201, academicSpeech = 1202, articulationSpeech = 1203, languageSpeech = 1204, oralSpeech = 1205, sensorSpeech = 1206, autismSpeech = 1207, augmentativeSpeech = 1208
    
    /// Ocupational Therapy
    case generalTherapy = 1301, academicTherapy = 1302, gerontologyTherapy = 1303, mentalTherapy = 1304, pediatricsTherapy = 1305, physicalTherapy = 1306, drivingTherapy = 1307, lowVisionTherapy = 1308, schoolTherapy = 1309
    
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
        case .clinicalPsychopharmacology: return AppStrings.Health.Speciality.Psychology.clinicalPsychopharmacology
        case .addictionPsychology: return AppStrings.Health.Speciality.Psychology.addictionPsychology
        case .sportPsychology: return AppStrings.Health.Speciality.Psychology.sportPsychology
            
            /// Biomedical
        case .generalBiomedical: return AppStrings.Health.Speciality.Biomedical.generalBiomedical
        case .academicBiomedical: return AppStrings.Health.Speciality.Biomedical.academicBiomedical
        case .engineeringBiomedical: return AppStrings.Health.Speciality.Biomedical.engineeringBiomedical
        case .engineeringBiomechanical: return AppStrings.Health.Speciality.Biomedical.engineeringBiomechanical
        case .clinicalBiochemistry: return AppStrings.Health.Speciality.Biomedical.clinicalBiochemistry
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

        case .cardiacNurse: return AppStrings.Health.Speciality.Nursing.cardiacNurse
        case .certifiedNurse: return AppStrings.Health.Speciality.Nursing.certifiedNurse
        case .clinicalNurse: return AppStrings.Health.Speciality.Nursing.clinicalNurse
        case .criticalNurse: return AppStrings.Health.Speciality.Nursing.criticalNurse
        case .geriatricNurse: return AppStrings.Health.Speciality.Nursing.geriatricNurse
        case .perioperativeNurse: return AppStrings.Health.Speciality.Nursing.perioperativeNurse
        case .mentalNurse: return AppStrings.Health.Speciality.Nursing.mentalNurse
        case .educatorNurse: return AppStrings.Health.Speciality.Nursing.educatorNurse
        case .midwifeNurse: return AppStrings.Health.Speciality.Nursing.midwifeNurse
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
        case .lowVisionTherapy: return AppStrings.Health.Speciality.Occupational.lowVisionTherapy
        case .pediatricNurse: return AppStrings.Health.Speciality.Occupational.pediatricsTherapy
        case .schoolTherapy: return AppStrings.Health.Speciality.Occupational.schoolTherapy
        }
    }
}
