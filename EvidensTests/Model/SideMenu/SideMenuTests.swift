//
//  SideMenuTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class SideMenuTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testProfileTitle() {
        let sideMenu = SideMenu.profile
        XCTAssertEqual(sideMenu.title, AppStrings.SideMenu.profile)
    }
    
    func testProfileImage() {
        let sideMenu = SideMenu.profile
        let expectedImage = UIImage(systemName: AppStrings.Icons.person)?.withRenderingMode(.alwaysOriginal)
        XCTAssertEqual(sideMenu.image, expectedImage)
    }
    
    func testProfileColor() {
        let sideMenu = SideMenu.profile
        XCTAssertEqual(sideMenu.color, UIColor.label)
    }
    
    func testBookmarkTitle() {
        let sideMenu = SideMenu.bookmark
        XCTAssertEqual(sideMenu.title, AppStrings.SideMenu.bookmark)
    }
    
    func testBookmarkImage() {
        let sideMenu = SideMenu.bookmark
        let expectedImage = UIImage(named: AppStrings.Assets.bookmark)?.withRenderingMode(.alwaysTemplate)
        XCTAssertEqual(sideMenu.image, expectedImage)
    }
    
    func testBookmarkColor() {
        let sideMenu = SideMenu.bookmark
        XCTAssertEqual(sideMenu.color, UIColor.label)
    }
    
    func testCreateTitle() {
        let sideMenu = SideMenu.create
        XCTAssertEqual(sideMenu.title, AppStrings.SideMenu.create)
    }
    
    func testCreateImage() {
        let sideMenu = SideMenu.create
        let expectedImage = UIImage(named: AppStrings.Assets.fillPost)?.withRenderingMode(.alwaysTemplate)
        XCTAssertEqual(sideMenu.image, expectedImage)
    }
    
    func testCreateColor() {
        let sideMenu = SideMenu.create
        XCTAssertEqual(sideMenu.color, primaryColor)
    }
    
    func testDraftTitle() {
        let sideMenu = SideMenu.create
        XCTAssertEqual(sideMenu.title, AppStrings.SideMenu.draft)
    }
    
    func testDraftImage() {
        let sideMenu = SideMenu.draft
        let expectedImage = UIImage(systemName: AppStrings.Icons.squareOnSquare)?.withRenderingMode(.alwaysOriginal)
        XCTAssertEqual(sideMenu.image, expectedImage)
    }
    
    func testDraftColor() {
        let sideMenu = SideMenu.draft
        XCTAssertEqual(sideMenu.color, UIColor.label)
    }
}
