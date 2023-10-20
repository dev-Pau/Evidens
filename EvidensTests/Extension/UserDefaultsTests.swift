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
    
    func testUserDefaults_WhenResetUserDefaults_ShouldRemovePersistentDomain() {
        UserDefaults.standard.set("Evidens", forKey: "AppName")
        
        UserDefaults.resetDefaults()
        
        XCTAssertNil(UserDefaults.standard.value(forKey: "AppName"))
    }
    
    func testUserDefaults_WhenUserLogsIn_ShouldSetAuthToTrue() {
        UserDefaults.logUserIn()
        
        XCTAssertTrue(UserDefaults.getAuth())
    }
    
    func testUserDefaults_WhenUidAndAuthAreSet_ShouldReturnTrue() {
        UserDefaults.standard.set("testUid", forKey: "uid")
        UserDefaults.logUserIn()
        
        XCTAssertTrue(UserDefaults.checkIfUserIsLoggedIn())
    }
    
    func testUserDefaults_WhenUserIsLoggedInAndUidIsNotSet_ShouldReturnFalse() {
        UserDefaults.logUserIn()
        
        XCTAssertFalse(UserDefaults.checkIfUserIsLoggedIn())
    }
    
    func testUserDefaults_WhenUserIsLoggedInAndAuthIsNotSet_ShouldReturnFalse() {
        UserDefaults.standard.set("testUid", forKey: "uid")
        
        XCTAssertFalse(UserDefaults.checkIfUserIsLoggedIn())
    }
    
    func testUserDefaults_WhenUserIsLoggedInAndNeitherUidNorAuthIsSet_ShouldReturnFalse() {
        XCTAssertFalse(UserDefaults.checkIfUserIsLoggedIn())
    }
    
    func testUserDefaults_WhenUidIsSet_ShouldReturnUid() {
        UserDefaults.standard.set("testUid", forKey: "uid")
        
        XCTAssertEqual(UserDefaults.getUid(), "testUid")
    }
    
    func testUserDefaults_WhenUidIsNotSet_ShouldReturnNil() {
        XCTAssertNil(UserDefaults.getUid())
    }
    
    func testUserDefaults_WhenAuthIsSet_AuthShouldReturnTrue() {
        UserDefaults.standard.set(true, forKey: "auth")
        
        XCTAssertTrue(UserDefaults.getAuth())
    }
    
    func testUserDefaults_WhenAuthIsNotSet_AuthShouldReturnFalse() {
        UserDefaults.resetDefaults()
        XCTAssertFalse(UserDefaults.getAuth())
    }
}
