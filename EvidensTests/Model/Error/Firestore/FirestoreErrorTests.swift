//
//  FirestoreErrorTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class FirestoreErrorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNetworkError() {
        let error = StorageError.network
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.network)
    }

    func testUnknownError() {
        let error = StorageError.unknown
        XCTAssertEqual(error.title, AppStrings.Error.title)
        XCTAssertEqual(error.content, AppStrings.Error.unknown)
    }

}
