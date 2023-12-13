//
//  DatabaseErrorTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class DatabaseErrorTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNetworkError() {
        let error = DatabaseError.network
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.network)
    }
    
    func testUnknownError() {
        let error = DatabaseError.unknown
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.unknown)
    }
    
    func testExistsError() {
        let error = DatabaseError.exists
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, "")
    }
    
    func testEmptyError() {
        let error = DatabaseError.empty
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, "")
    }
    
    
}
