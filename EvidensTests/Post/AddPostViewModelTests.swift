//
//  AddPostViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 19/9/23.
//

import XCTest
@testable import Evidens

final class AddPostViewModelTests: XCTestCase {
    
    var sut: AddPostViewModel!
    
    override func setUpWithError() throws {
        sut = AddPostViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testEmptyText() {
        sut.text = ""
        XCTAssertFalse(sut.hasText)
        
    }
    
    func testNilText() {
        sut.text = nil
        XCTAssertFalse(sut.hasText)
    }
    
    func testWhitespaceText() {
        sut.text = "     "
        XCTAssertFalse(sut.hasText)
    }
    
    func testValidText() {
        sut.text = "Sample text"
        XCTAssertTrue(sut.hasText)
    }
    
    func testValidImages() {
        sut.images = [UIImage(systemName: AppStrings.Icons.apple)!, UIImage(systemName: AppStrings.Icons.apple)!]
        XCTAssertTrue(sut.hasImages)
    }
    
    func testEmptyImages() {
        sut.images = []
        XCTAssertFalse(sut.hasImages)
    }
    
    func testKindWithImages() {
        sut.images = [UIImage(systemName: AppStrings.Icons.apple)!, UIImage(systemName: AppStrings.Icons.apple)!]
        XCTAssertEqual(sut.kind, .image)
    }
    
    func testKindWithOnlyText() {
        sut.images = []
        XCTAssertEqual(sut.kind, .text)
    }
    
    func testPostReference() {
        XCTAssertFalse(sut.hasReference)
        
        sut.reference = Reference(option: .link, referenceText: "https://google.com")
        
        XCTAssertTrue(sut.hasReference)
    }
    
    func testAddDisciplines() {
        sut.set(disciplines: [.medicine, .pharmacy])
        XCTAssertEqual(sut.disciplines, [.medicine, .pharmacy])
    }
    
    func testLinkKind() {
        XCTAssertFalse(sut.hasLinks)
        
        sut.links = ["www.evidens.app"]
        sut.linkLoaded = true
        
        XCTAssertTrue(sut.hasLinks)
        
        XCTAssertEqual(sut.kind, .link)
    }
}
