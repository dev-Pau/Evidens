//
//  ProviderTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class ProviderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPasswordTitle() {
        let provider = Provider.password
        XCTAssertEqual(provider.title, String())
    }
    
    func testGoogleTitle() {
        let provider = Provider.google
        XCTAssertEqual(provider.title, AppStrings.User.Changes.googleTitle)
    }
    
    func testAppleTitle() {
        let provider = Provider.apple
        XCTAssertEqual(provider.title, AppStrings.User.Changes.appleTitle)
    }
    
    func testUndefinedTitle() {
        let provider = Provider.undefined
        XCTAssertEqual(provider.title, String())
    }
    
    func testPasswordContent() {
        let provider = Provider.password
        XCTAssertEqual(provider.content, String())
    }
    
    func testGoogleContent() {
        let provider = Provider.google
        XCTAssertEqual(provider.content, AppStrings.User.Changes.googleContent)
    }
    
    func testAppleContent() {
        let provider = Provider.apple
        XCTAssertEqual(provider.content, AppStrings.User.Changes.appleContent)
    }
    
    func testUndefinedContent() {
        let provider = Provider.undefined
        XCTAssertEqual(provider.content, AppStrings.User.Changes.undefined)
    }
    
    func testPasswordId() {
        let provider = Provider.password
        XCTAssertEqual(provider.id, AppStrings.User.Changes.passwordId)
    }
    
    func testGoogleId() {
        let provider = Provider.google
        XCTAssertEqual(provider.id, AppStrings.User.Changes.googleId)
    }
    
    func testAppleId() {
        let provider = Provider.apple
        XCTAssertEqual(provider.id, AppStrings.User.Changes.appleId)
    }
    
    func testUndefinedId() {
        let provider = Provider.undefined
        XCTAssertEqual(provider.id, "")
    }
    
    func testPasswordLogin() {
        let provider = Provider.password
        XCTAssertEqual(provider.login, String())
    }
    
    func testGoogleLogin() {
        let provider = Provider.google
        XCTAssertEqual(provider.login, AppStrings.User.Changes.loginGoogle)
    }
    
    func testAppleLogin() {
        let provider = Provider.apple
        XCTAssertEqual(provider.login, AppStrings.User.Changes.loginApple)
    }
    
    func testUndefinedLogin() {
        let provider = Provider.undefined
        XCTAssertEqual(provider.login, AppStrings.User.Changes.undefined)
    }
    

}
