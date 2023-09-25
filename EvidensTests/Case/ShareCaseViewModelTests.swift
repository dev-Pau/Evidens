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
    
    func testShareCaseViewModel_WhenTitleIsNonEmpty_ShouldReturnTrue() {
        sut.title = "Non-empty title"
        XCTAssertTrue(sut.hasTitle)
    }
    
    func testShareCaseViewModel_WhenTitleIsEmpty_ShouldReturnFalse() {
        sut.title = ""
        XCTAssertFalse(sut.hasTitle)
    }
    
    func testShareCaseViewModel_WhenTitleIsOnlyWhitespacesEmpty_ShouldReturnFalse() {
        sut.title = "  "
        XCTAssertFalse(sut.hasTitle)
    }
    
    func testShareCaseViewModel_WhenDescriptionIsNonEmpty_ShouldReturnTrue() {
        sut.description = "Non-empty description"
        XCTAssertTrue(sut.hasDescription)
    }
    
    func testShareCaseViewModel_WhenDescriptionIsEmpty_ShouldReturnFalse() {
        sut.description = ""
        XCTAssertFalse(sut.hasDescription)
    }
    
    func testShareCaseViewModel_WhenDescriptionIsWhitespacesOnly_ShouldReturnFalse() {
        sut.description = "   "
        XCTAssertFalse(sut.hasDescription)
    }
    
    func testShareCaseViewModel_WhenImagesNotEmpty_ShouldReturnTrue() {
        sut.images = [CaseImage(image: UIImage(), faceImage: nil), CaseImage(image: UIImage(), faceImage: nil)]
        XCTAssertTrue(sut.hasImages)
    }
    
    func testShareCaseViewModel_WhenImagesIsEmpty_ShouldReturnFalse() {
        sut.images = []
        XCTAssertFalse(sut.hasImages)
    }
    
    func testShareCaseViewModel_WhenAllRequiredFieldsNotEmpty_ShouldReturnTrue() {
        sut.title = "Valid Title"
        sut.description = "Valid Description"
        sut.specialities = [Speciality.academicBiomedical]
        sut.items = [.multidisciplinary, .diagnostic]
        XCTAssertTrue(sut.caseIsValid)
    }
    
    func testShareCaseViewModel_WhenAnyRequiredFieldIsEmpty_ShouldReturnFalse() {
        sut.title = ""
        sut.description = "Valid Description"
        sut.specialities = []
        sut.items = [.multidisciplinary, .diagnostic]
        XCTAssertFalse(sut.caseIsValid)
    }
    
    func testShareCaseViewModel_ShouldReturnImage() {
        let image = sut.privacyImage
        XCTAssertNotNil(image)
    }
    
    func testShareCaseViewModel_WhenImagesNotEmpty_ShouldReturnImageKind() {
        sut.images = [CaseImage(image: UIImage(), faceImage: nil), CaseImage(image: UIImage(), faceImage: nil)]
        XCTAssertEqual(sut.kind, .image)
    }
    
    func testShareCaseViewModel_WhenImagesIsEmpty_ShouldReturnTextKind() {
        sut.images = []
        XCTAssertEqual(sut.kind, .text)
    }
    
    func testShareCaseViewModel_WhenValidIndex_ShouldRemoveImage() {
        let image1 = CaseImage(image: UIImage(), faceImage: nil)
        let image2 = CaseImage(image: UIImage(), faceImage: nil)
        sut.images = [image1, image2]
        sut.removeImage(at: 0)
        XCTAssertEqual(sut.images.count, 1)
    }
    
    func testShareCaseViewModel_ShouldSetDisciplines() {
        let disciplines: [Discipline] = [.biomedical, .medicine]
        sut.set(disciplines: disciplines)
        XCTAssertEqual(sut.disciplines, disciplines)
    }
}
