//
//  Profession.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

/// The enum for a Discipline
enum Discipline: Int, Codable, Hashable, CaseIterable {
    case medicine, odontology, pharmacy, physiotherapy, nursing, veterinary, psychology, podiatry, nutrition, optics, biomedical, physical, speech, occupational
    
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
        case .occupational: return AppStrings.Health.Discipline.occupational
        }
    }
    
    var specialities: [Speciality] {
        switch self {
        case .medicine:
            return [.generalMedicine, .academicMedicine, .allergologyMedicine, .analysesMedicine, .pathologicalMedicine, .anaesthesiologyMedicine, .angiologyMedicine, .digestiveMedicine, .biochemistryMedicine, .cardiologyMedicine, .cardiovascularMedicine, .digestiveSurgeryMedicine, .oralMaxillofacialMedicine, .orthopaedicSurgeryMedicine, .paediatricMedicine, .plasticMedicine, .thoracicMedicine, .dermatologyMedicine, .endocrinologyMedicine, .pharmacologyMedicine, .geriatricsMedicine, .haematologyMedicine, .immunologyMedicine, .legalForensicMedicine, .occupationalMedicine, .familyMedicine, .physicalMedicine, .intensiveMedicine, .internalMedicine, .nuclearMedicine, .preventiveMedicine, .microbiologyMedicine, .nephrologyMedicine, .pneumologyMedicine, .neurosurgeryMedicine, .neurophysiologyMedicine, .neurologyMedicine, .obstetricsMedicine, .ophthalmologyMedicine, .oncologyMedicine, .radiationMedicine, .otorhinolaryngology, .paediatricsMedicine, .psychiatryMedicine, .radiodiagnosticsMedicine, .rheumatologyMedicine, .urologyMedicine]
        case .odontology:
            return [.generalOdontology, .academicOdontology, .paediatricOdontology, .endodontics, .orthodontics, .prosthodontics, .maxillofacialSurgery, .maxillofacialRadiology, .oralPathology, .prothesis, .aesthetics]
        case .pharmacy:
            return [.generalPharmacy, .academicPharmacy, .ambulatoriPharmacy, .cardiologyPharmacy, .compoundedPharmacy, .criticalPharmacy, .emergencyPharmacy, .geriatricPharmacy, .infectiousPharmacy, .nuclearPharmacy, .nutritionPharmacy, .oncologyPharmacy, .pediatricPharmacy, .pharmacotherapy, .psychiatricPharmacy, .organPharmacy]
        case .physiotherapy:
            return [.generalPhysiotherapy, .academicPhysiotherapy, .geriatricPhysiotherapy, .orthopaedicPhysiotherapy, .neurologyPhysiotherapy, .pediatricPhysiotherapy, .oncologyPhysiotherapy, .womensPhysiotherapy, .electrophysiologicPhysiotherapy, .sportsPhysiotherapy, .woundPhysiotherapy]
        case .nursing:
            return [.generalNurse, .registeredNurse, .cardiacNurse, .certifiedNurse, .clinicalNurse, .criticalNurse, .familyNurse, .geriatricNurse, .perioperativeNurse, .mentalNurse, .educatorNurse, .midwifeNurse, .practitionerNurse, .oncologyNurse, .pediatricNurse, .publicNurse]
        case .veterinary:
            return [.generalVeterinary, .academicVeterinary, .animalWelfare, .behavioralVeterinary, .pharmacologyVeterinary, .dentistryVeterinary, .dermatologyVeterinary, .emergencyVeterinary, .internalVeterinary, .laboratoryVeterinary, .microbiologyVeterinary, .nutritionVeterinary, .ophthalmologyVeterinary, .pathologyVeterinary, .poultryVeterinary, .preventiveVeterinary, .radiologyVeterinary, .speciesVeterinary, .sportsVeterinary, .surgeryVeterinary, .toxicologyVeterinary, .zoologicalVeterinary]
        case .psychology:
            return [.generalPsychology, .academicPsychology, .neuropsychology, .healthPsychology, .psychoanalysis, .schoolPsychology, .clinicalPsychology, .childPsychology, .counselingPsychology, .industrialPsychology, .behavioralPsychology, .forensicPsychology, .familyPsychology, .geropsychology, .policePsychology, .sleepPsychology, .rehabilitationPsychology, .mentalPsychology, .clinicalPsychopharmacology, .addictionPsychology, .sportPsychology]
        case .podiatry:
            return [.generalPodiatry, .academicPodiatry, .reconstructivePodiatry, .medicinePodiatry, .orthopedicsPodiatry, .sportsPodiatry, .riskPodiatry, .rheumatologyPodiatry, .neuropodiatry, .oncopodiatry, .vascularPodiatry, .dermatologyPodiatry, .podoradiology, .gerontologyPodiatry, .diabetologyPodiatry, .podopediatrics, .forensicPodiatry]
        case .nutrition:
            return [.generalNutrition, .academicNutrition, .clinicalNutrition, .communityNutrition, .proceduralExpertise, .sportsNutrition, .pediatricNutrition, .gerontologicalNutrition, .renalNutrition]
        case .optics:
            return [.generalOptics, .academicOptics, .corneaContactLenses, .ocularDisease, .opticsLowVision, .opticsPediatrics, .opticsGeriatrics, .opticsOptometry, .opticsVisionTherapy]
        case .biomedical:
            return [.generalBiomedical, .academicBiomedical, .engineeringBiomedical, .engineeringBiomechanical, .clinicalBiochemistry, .vascularScience, .clinicalEngineering, .medicalElectronics, .microbiology]
        case .physical:
            return [.generalSports, .academicSports, .managementSports, .trainingSports, .healthSports, .recreationSports]
        case .speech:
            return [.generalSpeech, .academicSpeech, .articulationSpeech, .languageSpeech, .fluencySpeech, .voiceSpeech, .oralSpeech, .sensorSpeech, .autismSpeech, .augmentativeSpeech]
        case .occupational:
            return [.generalTherapy, .academicTherapy, .gerontologyTherapy, .mentalTherapy, .pediatricsTherapy, .physicalTherapy, .drivingTherapy, .environmentalTherapy, .feedingTherapy, .lowVisionTherapy, .schoolTherapy]
        }
    }
}
