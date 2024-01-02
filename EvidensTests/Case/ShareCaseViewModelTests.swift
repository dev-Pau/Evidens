//
//  ShareCaseViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 19/9/23.
//

import XCTest
@testable import Evidens

final class ShareCaseViewModelTests: XCTestCase {
    
    var sut: ShareCaseViewModel!
    
    override func setUpWithError() throws {
        sut = ShareCaseViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testValidTitle() {
        sut.title = "Non-empty title"
        XCTAssertTrue(sut.hasTitle)
    }
    
    func testEmptyTitle() {
        sut.title = ""
        XCTAssertFalse(sut.hasTitle)
    }
    
    func testWhitespaceTitle() {
        sut.title = "  "
        XCTAssertFalse(sut.hasTitle)
    }
    
    func testValidDescription() {
        sut.description = "Non-empty description"
        XCTAssertTrue(sut.hasDescription)
    }
    
    func testEmptyDescription() {
        sut.description = ""
        XCTAssertFalse(sut.hasDescription)
    }
    
    func testWhitespaceDescription() {
        sut.description = "   "
        XCTAssertFalse(sut.hasDescription)
    }
    
    func testCaseImages() {
        sut.images = [CaseImage(image: UIImage(), faceImage: nil), CaseImage(image: UIImage(), faceImage: nil)]
        XCTAssertTrue(sut.hasImages)
    }
    
    func testEmptyCaseImages() {
        sut.images = []
        XCTAssertFalse(sut.hasImages)
    }
    
    func testValidFields() {
        sut.title = "Valid Title"
        sut.description = "Valid Description"
        sut.specialities = [Speciality.academicBiomedical]
        sut.items = [.multidisciplinary, .diagnostic]
        XCTAssertTrue(sut.caseIsValid)
    }
    
    func testInvalidFields() {
        sut.title = ""
        sut.description = "Valid Description"
        sut.specialities = []
        sut.items = [.multidisciplinary, .diagnostic]
        XCTAssertFalse(sut.caseIsValid)
    }
    
    func testValidImage() {
        let image = sut.privacyImage
        XCTAssertNotNil(image)
    }
    
    func testImageKind() {
        sut.images = [CaseImage(image: UIImage(), faceImage: nil), CaseImage(image: UIImage(), faceImage: nil)]
        XCTAssertEqual(sut.kind, .image)
    }
    
    func testShareCaseViewModel_WhenImagesIsEmpty_ShouldReturnTextKind() {
        sut.images = []
        XCTAssertEqual(sut.kind, .text)
    }
    
    func testRemoveImage() {
        let image1 = CaseImage(image: UIImage(), faceImage: nil)
        let image2 = CaseImage(image: UIImage(), faceImage: nil)
        sut.images = [image1, image2]
        sut.removeImage(at: 0)
        XCTAssertEqual(sut.images.count, 1)
    }
    
    func testSetDiscipline() {
        let disciplines: [Discipline] = [.biomedical, .medicine]
        sut.set(disciplines: disciplines)
        XCTAssertEqual(sut.disciplines, disciplines)
    }
}
