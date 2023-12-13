//
//  ReferenceTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class ReferenceTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitializerWithOptionAndReferenceText() {
        let reference = Reference(option: .link, referenceText: "Example reference text")
        XCTAssertEqual(reference.option, .link)
        XCTAssertEqual(reference.referenceText, "Example reference text")
    }
    
    func testInitializerWithDictionaryAndKind() {
        let dictionary: [String: Any] = ["content": "Example reference text"]
        let reference = Reference(dictionary: dictionary, kind: .citation)
        XCTAssertEqual(reference.option, .citation)
        XCTAssertEqual(reference.referenceText, "Example reference text")
    }
}
