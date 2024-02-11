//
//  SectionTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class SectionTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAboutTitle() {
        let section = Section.about
        XCTAssertEqual(section.title, AppStrings.Sections.aboutSection)
    }
    
    func testAboutContent() {
        let section = Section.about
        XCTAssertEqual(section.content, AppStrings.Sections.aboutContent)
    }
    
    func testAboutImage() {
        let section = Section.about
        XCTAssertEqual(section.image, AppStrings.Icons.person)
    }
    
    func testWebsiteTitle() {
        let section = Section.website
        XCTAssertEqual(section.title, AppStrings.Sections.websiteSection)
    }
    
    func testWebsiteContent() {
        let section = Section.website
        XCTAssertEqual(section.content, AppStrings.Sections.websiteContent)
    }
    
    func testWebsiteImage() {
        let section = Section.website
        XCTAssertEqual(section.image, AppStrings.Icons.paperclip)
    }
}
