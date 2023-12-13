//
//  AuthCredentialsTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class AuthCredentialsTests: XCTestCase {
    
    var sut: AuthCredentials!
    
    override func setUpWithError() throws {
        sut = AuthCredentials(email: "test@example.com", password: "password", phase: .verified, firstName: "John", lastName: "Doe")
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testInitializeWithEmail() {
        let credentials = AuthCredentials(email: "test@example.com", password: "password", phase: .category, firstName: "John", lastName: "Doe")
        
        XCTAssertEqual(credentials.email, "test@example.com")
        XCTAssertEqual(credentials.password, "password")
        XCTAssertEqual(credentials.phase, UserPhase.category)
        XCTAssertEqual(credentials.firstName, "John")
        XCTAssertEqual(credentials.lastName, "Doe")
        XCTAssertNil(credentials.uid)
        XCTAssertNil(credentials.imageUrl)
        XCTAssertNil(credentials.kind)
        XCTAssertNil(credentials.discipline)
        XCTAssertNil(credentials.speciality)
    }
    
    func testInitializationWithUidAndPhase() {
        let credentials = AuthCredentials(uid: "12345", phase: .verified, kind: .professional, discipline: .medicine, speciality: .generalMedicine)
        
        XCTAssertEqual(credentials.uid, "12345")
        XCTAssertEqual(credentials.phase, .verified)
        XCTAssertEqual(credentials.kind, UserKind.professional)
        XCTAssertEqual(credentials.discipline, .medicine)
        XCTAssertEqual(credentials.speciality, .generalMedicine)
        XCTAssertNil(credentials.email)
        XCTAssertNil(credentials.password)
        XCTAssertNil(credentials.firstName)
        XCTAssertNil(credentials.lastName)
        XCTAssertNil(credentials.imageUrl)
    }
    
    func testInitializationWithUidAndName() {
        let credentials = AuthCredentials(uid: "12345", firstName: "Jane", lastName: "Doe", phase: .pending)
        
        XCTAssertEqual(credentials.uid, "12345")
        XCTAssertEqual(credentials.firstName, "Jane")
        XCTAssertEqual(credentials.lastName, "Doe")
        XCTAssertEqual(credentials.phase, .pending)
        XCTAssertNil(credentials.email)
        XCTAssertNil(credentials.password)
        XCTAssertNil(credentials.imageUrl)
        XCTAssertNil(credentials.kind)
        XCTAssertNil(credentials.discipline)
        XCTAssertNil(credentials.speciality)
    }
    
    func testSetFirstName() {
        sut.set(firstName: "Jane")
        XCTAssertEqual(sut.firstName, "Jane")
    }
    
    func testSetLastName() {
        sut.set(lastName: "Smith")
        XCTAssertEqual(sut.lastName, "Smith")
    }
    
    func testSetEmail() {
        sut.set(email: "newemail@example.com")
        XCTAssertEqual(sut.email, "newemail@example.com")
    }
    
    func testSetImageUrl() {
        sut.set(imageUrl: "https://example.com/image.jpg")
        XCTAssertEqual(sut.imageUrl, "https://example.com/image.jpg")
    }
}
