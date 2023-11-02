//
//  UserTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 18/9/23.
//

import XCTest
@testable import Evidens

final class UserTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUser_WhenUserIsCreated_ShouldReturnUser() {
        let userData: [String: Any] = [
            "firstName": "John",
            "lastName": "Doe",
            "email": "john.doe@example.com",
            "uid": "12345",
            "imageUrl": "profile_image_url",
            "bannerUrl": "banner_image_url",
            "kind": 0,
            "phase": 2,
            "discipline": 0,
            "speciality": 0,
        ]

        let user = User(dictionary: userData)

        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.email, "john.doe@example.com")
        XCTAssertEqual(user.uid, "12345")
        XCTAssertEqual(user.profileUrl, "profile_image_url")
        XCTAssertEqual(user.bannerUrl, "banner_image_url")
        XCTAssertEqual(user.kind, .professional)
        XCTAssertEqual(user.phase, .identity)
        XCTAssertEqual(user.discipline, .medicine)
        XCTAssertEqual(user.speciality, .generalMedicine)
    }
    
    func testUser_UserIsCurrentUserForValidUid_ShouldReturnTrue() {

        let user = User(dictionary: ["uid": "testUID"])
        
        UserDefaults.standard.setValue("testUID", forKey: "uid")

        XCTAssertTrue(user.isCurrentUser)

        UserDefaults.standard.removeObject(forKey: "uid")
    }
    
    func testUser_UserIsCurrentUserForInvalidUid_ShouldReturnFalse() {

        let user = User(dictionary: ["uid": "anotherTestUID"])
        
        UserDefaults.standard.setValue("testUID", forKey: "uid")

        XCTAssertFalse(user.isCurrentUser)

        UserDefaults.standard.removeObject(forKey: "uid")
    }
    
    func testUser_WhenRetrievingDetails_DetailsShouldMatch() {
        var user = User(dictionary: ["discipline": Discipline.odontology.rawValue, "speciality": Speciality.generalOdontology.rawValue])
        
        // Check that the details method returns the expected string
        XCTAssertEqual(user.details(), Discipline.odontology.name + AppStrings.Characters.dot + Speciality.generalOdontology.name)
        
        // Change the profession and speciality
        user.discipline = .medicine
        user.speciality = .generalMedicine
        
        // Check that the details method returns the updated string
        XCTAssertEqual(user.details(), Discipline.medicine.name + AppStrings.Characters.dot + Speciality.generalMedicine.name)
    }
    
    func testUser_WhenRetrievingErroneousDetails_DetailsShouldNotMatch() {
        var user = User(dictionary: ["discipline": Discipline.odontology.rawValue, "speciality": Speciality.generalOdontology.rawValue])
        
        // Check that the details method returns the expected string
        XCTAssertNotEqual(user.details(), Discipline.speech.name + AppStrings.Characters.dot + Speciality.generalOdontology.name)
        
        // Change the profession and speciality
        user.discipline = .medicine
        user.speciality = .generalMedicine
        
        // Check that the details method returns the updated string
        XCTAssertNotEqual(user.details(), Discipline.medicine.name + AppStrings.Characters.dot + Speciality.generalSpeech.name)
    }
    
    func testUser_WhenRetrievingNameDetails_NameDetailsShouldMatch() {
        let user = User(dictionary: ["firstName": "John", "lastName": "Doe"])
        
        XCTAssertEqual(user.name(), "John Doe")
    }
    
    func testSetIsFollowed() {
        var user = User(dictionary: [:])

        XCTAssertFalse(user.isFollowed)
 
        user.set(isFollowed: true)

        XCTAssertTrue(user.isFollowed)

        user.set(isFollowed: false)

        XCTAssertFalse(user.isFollowed)
    }
}
