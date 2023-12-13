//
//  DisciplineTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class DisciplineTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testName() {
        XCTAssertEqual(Discipline.medicine.name, AppStrings.Health.Discipline.medicine)
        XCTAssertEqual(Discipline.odontology.name, AppStrings.Health.Discipline.odontology)
        XCTAssertEqual(Discipline.pharmacy.name, AppStrings.Health.Discipline.pharmacy)
        XCTAssertEqual(Discipline.physiotherapy.name, AppStrings.Health.Discipline.physiotherapy)
        XCTAssertEqual(Discipline.nursing.name, AppStrings.Health.Discipline.nursing)
        XCTAssertEqual(Discipline.veterinary.name, AppStrings.Health.Discipline.veterinary)
        XCTAssertEqual(Discipline.psychology.name, AppStrings.Health.Discipline.psychology)
        XCTAssertEqual(Discipline.podiatry.name, AppStrings.Health.Discipline.podiatry)
        XCTAssertEqual(Discipline.nutrition.name, AppStrings.Health.Discipline.nutrition)
        XCTAssertEqual(Discipline.optics.name, AppStrings.Health.Discipline.optics)
        XCTAssertEqual(Discipline.biomedical.name, AppStrings.Health.Discipline.biomedical)
        XCTAssertEqual(Discipline.physical.name, AppStrings.Health.Discipline.physical)
        XCTAssertEqual(Discipline.speech.name, AppStrings.Health.Discipline.speech)
        XCTAssertEqual(Discipline.occupational.name, AppStrings.Health.Discipline.occupational)
    }
    
    func testSpecialities() {
        XCTAssertEqual(Discipline.medicine.specialities, [
            .generalMedicine, .academicMedicine, .allergologyMedicine, .analysesMedicine, .pathologicalMedicine, .anaesthesiologyMedicine,
            .angiologyMedicine, .digestiveMedicine, .biochemistryMedicine, .cardiologyMedicine, .cardiovascularMedicine, .digestiveSurgeryMedicine,
            .oralMaxillofacialMedicine, .orthopaedicSurgeryMedicine, .paediatricMedicine, .plasticMedicine, .thoracicMedicine, .dermatologyMedicine,
            .endocrinologyMedicine, .pharmacologyMedicine, .geriatricsMedicine, .haematologyMedicine, .immunologyMedicine, .legalForensicMedicine,
            .occupationalMedicine, .familyMedicine, .physicalMedicine, .intensiveMedicine, .internalMedicine, .nuclearMedicine, .preventiveMedicine,
            .microbiologyMedicine, .nephrologyMedicine, .pneumologyMedicine, .neurosurgeryMedicine, .neurophysiologyMedicine, .neurologyMedicine,
            .obstetricsMedicine, .ophthalmologyMedicine, .oncologyMedicine, .radiationMedicine, .otorhinolaryngology, .paediatricsMedicine,
            .psychiatryMedicine, .radiodiagnosticsMedicine, .rheumatologyMedicine, .urologyMedicine
        ])
        
        XCTAssertEqual(Discipline.odontology.specialities, [
            .generalOdontology, .academicOdontology, .paediatricOdontology, .endodontics, .orthodontics, .prosthodontics, .maxillofacialSurgery,
            .maxillofacialRadiology, .oralPathology, .prothesis, .aesthetics
        ])
        
        XCTAssertEqual(Discipline.pharmacy.specialities, [
            .generalPharmacy, .academicPharmacy, .ambulatoriPharmacy, .cardiologyPharmacy, .compoundedPharmacy, .criticalPharmacy, .emergencyPharmacy,
            .geriatricPharmacy, .infectiousPharmacy, .nuclearPharmacy, .nutritionPharmacy, .oncologyPharmacy, .pediatricPharmacy, .pharmacotherapy,
            .psychiatricPharmacy, .organPharmacy
        ])
        
        XCTAssertEqual(Discipline.physiotherapy.specialities, [
            .generalPhysiotherapy, .academicPhysiotherapy, .geriatricPhysiotherapy, .orthopaedicPhysiotherapy, .neurologyPhysiotherapy,
            .pediatricPhysiotherapy, .oncologyPhysiotherapy, .womensPhysiotherapy, .electrophysiologicPhysiotherapy, .sportsPhysiotherapy,
            .woundPhysiotherapy
        ])
        
        XCTAssertEqual(Discipline.nursing.specialities, [
            .generalNurse, .cardiacNurse, .certifiedNurse, .clinicalNurse, .criticalNurse, .geriatricNurse, .perioperativeNurse, .mentalNurse,
            .educatorNurse, .midwifeNurse, .oncologyNurse, .pediatricNurse, .publicNurse
        ])
        
        XCTAssertEqual(Discipline.veterinary.specialities, [
            .generalVeterinary, .academicVeterinary, .animalWelfare, .behavioralVeterinary, .pharmacologyVeterinary, .dentistryVeterinary,
            .dermatologyVeterinary, .emergencyVeterinary, .internalVeterinary, .laboratoryVeterinary, .microbiologyVeterinary, .nutritionVeterinary,
            .ophthalmologyVeterinary, .pathologyVeterinary, .poultryVeterinary, .preventiveVeterinary, .radiologyVeterinary, .speciesVeterinary,
            .sportsVeterinary, .surgeryVeterinary, .toxicologyVeterinary, .zoologicalVeterinary
        ])
        
        XCTAssertEqual(Discipline.psychology.specialities, [
            .generalPsychology, .academicPsychology, .neuropsychology, .healthPsychology, .psychoanalysis, .schoolPsychology, .clinicalPsychology,
            .childPsychology, .counselingPsychology, .industrialPsychology, .behavioralPsychology, .forensicPsychology, .familyPsychology,
            .geropsychology, .policePsychology, .sleepPsychology, .rehabilitationPsychology, .clinicalPsychopharmacology, .addictionPsychology,
            .sportPsychology
        ])
        
        XCTAssertEqual(Discipline.podiatry.specialities, [
            .generalPodiatry, .academicPodiatry, .reconstructivePodiatry, .medicinePodiatry, .orthopedicsPodiatry, .sportsPodiatry, .riskPodiatry,
            .rheumatologyPodiatry, .neuropodiatry, .oncopodiatry, .vascularPodiatry, .dermatologyPodiatry, .podoradiology, .gerontologyPodiatry,
            .diabetologyPodiatry, .podopediatrics, .forensicPodiatry
        ])
        
        XCTAssertEqual(Discipline.nutrition.specialities, [
            .generalNutrition, .academicNutrition, .clinicalNutrition, .communityNutrition, .proceduralExpertise, .sportsNutrition, .pediatricNutrition,
            .gerontologicalNutrition, .renalNutrition
        ])
        
        XCTAssertEqual(Discipline.optics.specialities, [
            .generalOptics, .academicOptics, .corneaContactLenses, .ocularDisease, .opticsLowVision, .opticsPediatrics, .opticsGeriatrics,
            .opticsOptometry, .opticsVisionTherapy
        ])
        
        XCTAssertEqual(Discipline.biomedical.specialities, [
            .generalBiomedical, .academicBiomedical, .engineeringBiomedical, .engineeringBiomechanical, .clinicalBiochemistry, .clinicalEngineering,
            .medicalElectronics, .microbiology
        ])
        
        XCTAssertEqual(Discipline.physical.specialities, [
            .generalSports, .academicSports, .managementSports, .trainingSports, .healthSports, .recreationSports
        ])
        
        XCTAssertEqual(Discipline.speech.specialities, [
            .generalSpeech, .academicSpeech, .articulationSpeech, .languageSpeech, .oralSpeech, .sensorSpeech, .autismSpeech, .augmentativeSpeech
        ])
        
        XCTAssertEqual(Discipline.occupational.specialities, [
            .generalTherapy, .academicTherapy, .gerontologyTherapy, .mentalTherapy, .pediatricsTherapy, .physicalTherapy, .drivingTherapy,
            .lowVisionTherapy, .schoolTherapy
        ])
        
    }
}
