//
//  CaseTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
import Firebase
@testable import Evidens

final class CaseTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testInitWithDictionary() {
        let caseId = "123"
        let dictionary: [String: Any] = [
            "title": "Case Title",
            "content": "Case Content",
            "hashtags": ["tag1", "tag2"],
            "disciplines": [0, 1],
            "specialities": [0, 1],
            "items": [0, 1],
            "phase": 1,
            "revision": 1,
            "imageUrl": ["image1", "image2"],
            "kind": 1,
            "uid": "user123",
            "timestamp": Timestamp(date: Date()),
            "privacy": 1,
            "visible": 0,
            "body": [0, 1],
            "orientation": 1
        ]
        
        let clinicalCase = Case(caseId: caseId, dictionary: dictionary)
        
        XCTAssertEqual(clinicalCase.caseId, caseId)
        XCTAssertEqual(clinicalCase.title, "Case Title")
        XCTAssertEqual(clinicalCase.content, "Case Content")
        XCTAssertEqual(clinicalCase.hashtags, ["tag1", "tag2"])
        XCTAssertEqual(clinicalCase.disciplines, [.medicine, .odontology])
        XCTAssertEqual(clinicalCase.specialities, [.generalMedicine, .academicMedicine])
        XCTAssertEqual(clinicalCase.items, [.general, .teaching])
        XCTAssertEqual(clinicalCase.phase, .unsolved)
        XCTAssertEqual(clinicalCase.revision, .update)
        XCTAssertEqual(clinicalCase.imageUrl, ["image1", "image2"])
        XCTAssertEqual(clinicalCase.kind, .image)
        XCTAssertEqual(clinicalCase.uid, "user123")
        XCTAssertEqual(clinicalCase.privacy, .anonymous)
        XCTAssertEqual(clinicalCase.visible, .regular)
        
        XCTAssertEqual(clinicalCase.orientation, .back)
        XCTAssertEqual(clinicalCase.body, [.head, .rightShoulder])
    }
}
