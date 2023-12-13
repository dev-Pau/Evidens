//
//  UserDefaultsTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 29/9/23.
//

import XCTest
@testable import Evidens

final class UserDefaultsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        UserDefaults.resetDefaults()
    }
    
    func testResetsUserDefaults() {
        UserDefaults.standard.set("Evidens", forKey: "AppName")
        
        UserDefaults.resetDefaults()
        
        XCTAssertNil(UserDefaults.standard.value(forKey: "AppName"))
    }
    
    func testAuthValueOnLogIn() {
        UserDefaults.logUserIn()
        
        XCTAssertTrue(UserDefaults.getAuth())
    }
    
    func testLogInValuesWhenUserIsLoggedIn() {
        UserDefaults.standard.set("testUid", forKey: "uid")
        UserDefaults.logUserIn()
        
        XCTAssertTrue(UserDefaults.checkIfUserIsLoggedIn())
    }
    
    func testLogInValuesWhenUserIsNotLoggedIn() {
        UserDefaults.logUserIn()
        
        XCTAssertFalse(UserDefaults.checkIfUserIsLoggedIn())
    }
    
    func testAuthNotSetWhenUserIsLoggedIn() {
        UserDefaults.standard.set("testUid", forKey: "uid")
        
        XCTAssertFalse(UserDefaults.checkIfUserIsLoggedIn())
    }
    
    func testUserIsLoggedInWithNoDefaultValuesSet() {
        XCTAssertFalse(UserDefaults.checkIfUserIsLoggedIn())
    }
    
    func testGetUserUid() {
        UserDefaults.standard.set("testUid", forKey: "uid")
        
        XCTAssertEqual(UserDefaults.getUid(), "testUid")
    }
    
    func testGetUserUidWhenUidIsNotSet() {
        XCTAssertNil(UserDefaults.getUid())
    }
    
    func testGetUserUidWhenUidIsSet() {
        UserDefaults.standard.set(true, forKey: "auth")
        
        XCTAssertTrue(UserDefaults.getAuth())
    }
    
    func testAuthValueForResetDefaults() {
        UserDefaults.resetDefaults()
        XCTAssertFalse(UserDefaults.getAuth())
    }
}
