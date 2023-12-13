//
//  PostMenuTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class PostMenuTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testPostMenuTitleDelete() {
        XCTAssertEqual(PostMenu.delete.title, AppStrings.Menu.deletePost)
    }
    
    func testPostMenuTitleEdit() {
        XCTAssertEqual(PostMenu.edit.title, AppStrings.Menu.editPost)
    }
    
    func testPostMenuTitleReport() {
        XCTAssertEqual(PostMenu.report.title, AppStrings.Menu.reportPost)
    }
    
    func testPostMenuTitleReference() {
        XCTAssertEqual(PostMenu.reference.title, AppStrings.Menu.reference)
    }
}
