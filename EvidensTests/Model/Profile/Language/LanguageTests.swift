//
//  LanguageTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class LanguageTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testInitializerWithDictionary() {
        let dictionary: [String: Any] = [
            "kind": LanguageKind.english,
            "proficiency": LanguageProficiency.advanced.rawValue
        ]
        
        let language = Language(dictionary: dictionary)
        
        XCTAssertEqual(language.kind, .english)
        XCTAssertEqual(language.proficiency, .advanced)
    }
    
    func testInitializerWithRequiredProperties() {
        let language = Language(kind: .english, proficiency: .advanced)
        
        XCTAssertEqual(language.kind, .english)
        XCTAssertEqual(language.proficiency, .advanced)
    }
}
