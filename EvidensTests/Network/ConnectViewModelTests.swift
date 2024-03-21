//
//  ConnectViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
@testable import Evidens

final class ConnectViewModelTests: XCTestCase {
    
    var sut: ConnectViewModel!

    override func setUpWithError() throws {
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
        
        user.set(connection: UserConnection(uid: "12345"))

        sut = ConnectViewModel(user: user)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testUserConnection() {
        sut.set(phase: .connected)
        XCTAssertNotNil(sut.connection)
        XCTAssertNotNil(sut.user.connection)
    }
    
    func testProfileUrl() {
        XCTAssertNotNil(sut.profileUrl)
        XCTAssertEqual(sut.profileUrl, "profile_image_url")
    }
    
    func testName() {
        XCTAssertEqual(sut.name, sut.user.name())
    }
    
    func testDetails() {
        XCTAssertEqual(sut.details, sut.user.details())
    }
    
    func testTitle() {

        sut.set(phase: .connected)
        
        XCTAssertNotNil(sut.user.connection)
        XCTAssertEqual(sut.title, sut.user.connection?.phase.title)
    }
    
    func testTitleColorAndStroke() {
        sut.set(phase: .connected)
        
        XCTAssertEqual(sut.color, .systemBackground)
        XCTAssertEqual(sut.foregroundColor, .label)
        XCTAssertEqual(sut.strokeColor, K.Colors.separatorColor)
        XCTAssertEqual(sut.strokeWidth, 1)
        
        sut.set(phase: .pending)
        
        XCTAssertEqual(sut.color, .systemBackground)
        XCTAssertEqual(sut.foregroundColor, .label)
        XCTAssertEqual(sut.strokeColor, K.Colors.separatorColor)
        XCTAssertEqual(sut.strokeWidth, 1)
        
        sut.set(phase: .rejected)
        
        XCTAssertEqual(sut.color, .label)
        XCTAssertEqual(sut.foregroundColor, .systemBackground)
        XCTAssertEqual(sut.strokeColor, .clear)
        XCTAssertEqual(sut.strokeWidth, 0)
        
        sut.set(phase: .withdraw)
        
        XCTAssertEqual(sut.color, .label)
        XCTAssertEqual(sut.foregroundColor, .systemBackground)
        XCTAssertEqual(sut.strokeColor, .clear)
        XCTAssertEqual(sut.strokeWidth, 0)
        
        sut.set(phase: .unconnect)
        
        XCTAssertEqual(sut.color, .label)
        XCTAssertEqual(sut.foregroundColor, .systemBackground)
        XCTAssertEqual(sut.strokeColor, .clear)
        XCTAssertEqual(sut.strokeWidth, 0)
        
        sut.set(phase: .none)
        
        XCTAssertEqual(sut.color, .label)
        XCTAssertEqual(sut.foregroundColor, .systemBackground)
        XCTAssertEqual(sut.strokeColor, .clear)
        XCTAssertEqual(sut.strokeWidth, 0)
    }
}
