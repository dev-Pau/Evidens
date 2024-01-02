//
//  UserTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 18/9/23.
//

import XCTest
import Firebase
@testable import Evidens

final class UserTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUserInitializer() {
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
    
    func testValidIsCurrentUser() {
        
        let user = User(dictionary: ["uid": "testUID"])
        
        UserDefaults.standard.setValue("testUID", forKey: "uid")
        
        XCTAssertTrue(user.isCurrentUser)
        
        UserDefaults.standard.removeObject(forKey: "uid")
    }
    
    func testInvalidIsCurrentUser() {
        
        let user = User(dictionary: ["uid": "anotherTestUID"])
        
        UserDefaults.standard.setValue("testUID", forKey: "uid")
        
        XCTAssertFalse(user.isCurrentUser)
        
        UserDefaults.standard.removeObject(forKey: "uid")
    }
    
    func testUserDetails() {
        var user = User(dictionary: ["discipline": Discipline.odontology.rawValue, "speciality": Speciality.generalOdontology.rawValue])
        
        XCTAssertEqual(user.details(), Speciality.generalOdontology.name)
        
        user.discipline = .medicine
        user.speciality = .generalMedicine
        
        XCTAssertEqual(user.details(), Speciality.generalMedicine.name)
    }
    
    func testUserErrorDetails() {
        var user = User(dictionary: ["discipline": Discipline.odontology.rawValue, "speciality": Speciality.generalOdontology.rawValue])
        
        XCTAssertNotEqual(user.details(), Discipline.speech.name + AppStrings.Characters.dot + Speciality.generalOdontology.name)
        
        user.discipline = .medicine
        user.speciality = .generalMedicine
        
        XCTAssertNotEqual(user.details(), Discipline.medicine.name + AppStrings.Characters.dot + Speciality.generalSpeech.name)
    }
    
    func testUserName() {
        let user = User(dictionary: ["firstName": "John", "lastName": "Doe"])
        
        XCTAssertEqual(user.name(), "John Doe ")
    }
    
    func testSetIsFollowed() {
        var user = User(dictionary: [:])
        
        XCTAssertFalse(user.isFollowed)
        
        user.set(isFollowed: true)
        
        XCTAssertTrue(user.isFollowed)
        
        user.set(isFollowed: false)
        
        XCTAssertFalse(user.isFollowed)
    }
    
    func testSetConnection() {
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
        
        let conectionData: [String: Any] = [
            "phase": 0,
            "timestamp": Timestamp(date: .now)
        ]
        
        let connection = UserConnection(uid: "12345", dictionary: conectionData)
        
        var user = User(dictionary: userData)
        user.set(connection: connection)
        
        XCTAssertNotNil(user.connection)
        XCTAssertEqual(user.connection?.phase, connection.phase)
    }
    
    func testEditConnectionPhase() {
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
        var user = User(dictionary: userData)
        
        XCTAssertNil(user.connection)
        
        user.set(connection: UserConnection(uid: "12345"))

        user.editConnectionPhase(phase: .pending)
        
        XCTAssertEqual(user.connection?.phase, .pending)

        user.editConnectionPhase(phase: .rejected)
        
        XCTAssertEqual(user.connection?.phase, .rejected)
    }
}
