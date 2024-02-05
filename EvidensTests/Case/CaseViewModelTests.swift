//
//  CaseViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
import Firebase
@testable import Evidens

final class CaseViewModelTests: XCTestCase {
    
    var sut: CaseViewModel!

    override func setUpWithError() throws {
        let caseId = "123"
        let dictionary: [String: Any] = [
            "title": "Case Title",
            "content": "Case Content",
            "hashtags": ["tag1", "tag2"],
            "disciplines": [0, 1],
            "specialities": [1, 2],
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
        
        sut = CaseViewModel(clinicalCase: clinicalCase)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testTitle() {
        XCTAssertEqual(sut.title, "Case Title")
    }
    
    func testAnonymous() {
        XCTAssertEqual(sut.anonymous, true)
    }
    
    func testContent() {
        XCTAssertEqual(sut.content, "Case Content")
    }
    
    func testSpecialities() {
        XCTAssertEqual(sut.specialities.map { $0.rawValue }, [1, 2])
    }
    
    func testItems() {
        XCTAssertEqual(sut.items.map { $0.rawValue }, [0, 1])
    }
    
    func testLikes() {
        sut.clinicalCase.likes = 3
        XCTAssertEqual(sut.likes, 3)
    }
    
    func testComments() {
        sut.clinicalCase.numberOfComments = 2
        XCTAssertEqual(sut.comments, 2)
    }
    
    func testPhaseTitle() {
        XCTAssertEqual(sut.phaseTitle, AppStrings.Content.Case.Phase.unsolved)
    }
    
    func testDisciplines() {
        XCTAssertEqual(sut.disciplines.map { $0.rawValue }, [0, 1])
    }
    
    func testBaseColor() {
        XCTAssertEqual(sut.baseColor, primaryColor)
    }
    
    func testNumberOfImages() {
        XCTAssertEqual(sut.numberOfImages, 2)
    }
    
    func testKind() {
        XCTAssertEqual(sut.kind.rawValue, 1)
    }
    
    func testImages() {
        XCTAssertEqual(sut.images, ["image1", "image2"])
    }
    
    func testLikesText() {
        sut.clinicalCase.likes = 3
        XCTAssertEqual(sut.likesText, String(3))
        
        sut.clinicalCase.likes = 0
        XCTAssertEqual(sut.likesText, String())
    }
    
    func testCommentsText() {
        sut.clinicalCase.numberOfComments = 3
        XCTAssertEqual(sut.commentsText, String(3))
        
        sut.clinicalCase.numberOfComments = 0
        XCTAssertEqual(sut.commentsText, String())
    }
    
    func testLikeColor() {
        XCTAssertEqual(sut.likeColor, primaryGray)
        
        sut.clinicalCase.didLike = true
        
        XCTAssertEqual(sut.likeColor, primaryRed)
    }
    
    func testHasRevisions() {
        XCTAssertEqual(sut.hasRevisions, true)
    }
}
