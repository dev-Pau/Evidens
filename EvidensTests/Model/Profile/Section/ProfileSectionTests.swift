//
//  ProfileSectionTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class ProfileSectionTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testPostsTitle() {
        let profileSection = ProfileSection.posts
        XCTAssertEqual(profileSection.title, AppStrings.Profile.Section.post)
    }
    
    func testCasesTitle() {
        let profileSection = ProfileSection.cases
        XCTAssertEqual(profileSection.title, AppStrings.Profile.Section.cases)
    }
    
    func testReplyTitle() {
        let profileSection = ProfileSection.reply
        XCTAssertEqual(profileSection.title, AppStrings.Profile.Section.reply)
    }
    
    func testAboutTitle() {
        let profileSection = ProfileSection.about
        XCTAssertEqual(profileSection.title, AppStrings.Profile.Section.about)
    }
}
