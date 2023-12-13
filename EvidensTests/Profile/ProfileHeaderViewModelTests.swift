//
//  ProfileHeaderViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens
import Firebase

final class ProfileHeaderViewModelTests: XCTestCase {
    
    var sut: ProfileHeaderViewModel!
    
    override func setUpWithError() throws {
        
        let values: [String: Any] = [
            "firstName": "John",
            "lastName": "Doe",
            "email": "john.doe@example.com",
            "uid": "123456789",
            "imageUrl": "https://example.com/profile.jpg",
            "bannerUrl": "https://example.com/banner.jpg",
            "kind": 1,
            "phase": 2,
            "discipline": 0,
            "speciality": 1
        ]
        
        var user = User(dictionary: values)
        
        let connection: [String: Any] = [
            "phase": 4,
            "timestamp": Timestamp(date: .now)
        ]
        
        user.set(connection: UserConnection(uid: "123456789", dictionary: connection))
        
        sut = ProfileHeaderViewModel(user: user)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testConnectionsTextForCurrentUser() {
        UserDefaults.standard.set("123456789", forKey: "uid")
        
        XCTAssertEqual(sut.connectionText, AppStrings.Profile.editProfile)
    }
    
    func testConnectionsTextForOtherUser() {
        UserDefaults.standard.set("987654321", forKey: "uid")
        
        XCTAssertNotEqual(sut.connectionText, AppStrings.Profile.editProfile)
        XCTAssertEqual(sut.connectionText, ConnectPhase.none.title)
    }
    
    func testConnectBackgroundColorCurrentUser() {
        UserDefaults.standard.set("123456789", forKey: "uid")
        XCTAssertEqual(sut.connectBackgroundColor, .systemBackground)
    }
    
    func testConnectBackgroundColorConnected() {
        UserDefaults.standard.set("987654321", forKey: "uid")
        XCTAssertEqual(sut.connectBackgroundColor, .label)
    }
    
    func testConnectButtonBorderColorCurrentUser() {
        UserDefaults.standard.set("123456789", forKey: "uid")
        XCTAssertEqual(sut.connectButtonBorderColor, .separatorColor)
    }
    
    func testConnectButtonBorderolorConnected() {
        UserDefaults.standard.set("987654321", forKey: "uid")
        XCTAssertEqual(sut.connectButtonBorderColor, .clear)
    }
}
