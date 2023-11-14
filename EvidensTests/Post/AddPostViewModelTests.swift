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
    
    func testAddPostViewModel_WhenTextIsEmpty_ShouldReturnFalse() {
        sut.text = ""
        XCTAssertFalse(sut.hasText)
        
    }
    
    func testAddPostViewModel_WhenTextIsNil_ShouldReturnFalse() {
        sut.text = nil
        XCTAssertFalse(sut.hasText)
    }
    
    func testAddPostViewModel_WhenTextHasOnlyEmptyCharacters_ShouldReturnFalse() {
        sut.text = "     "
        XCTAssertFalse(sut.hasText)
    }
    
    func testAddPostViewModel_WhenTextIsValid_ShouldReturnTrue() {
        sut.text = "Sample text"
        XCTAssertTrue(sut.hasText)
    }
    
    func testAddPostViewModel_WhenHasImages_ShouldReturnTrue() {
        sut.images = [UIImage(systemName: AppStrings.Icons.apple)!, UIImage(systemName: AppStrings.Icons.apple)!]
        XCTAssertTrue(sut.hasImages)
    }
    
    func testAddPostViewModel_WhenHasNoImages_ShouldReturnTrue() {
        sut.images = []
        XCTAssertFalse(sut.hasImages)
    }
    
    func testAddPostViewModel_WhenHasImages_KindShouldRetunImages() {
        sut.images = [UIImage(systemName: AppStrings.Icons.apple)!, UIImage(systemName: AppStrings.Icons.apple)!]
        XCTAssertEqual(sut.kind, .image)
    }
    
    func testAddPostViewModel_WhenHasNoImages_KindShouldRetunPlain() {
        sut.images = []
        XCTAssertEqual(sut.kind, .text)
    }
    
    func testAddPostViewModel_WhenPostHasReference_ShouldReturnnTrue() {
        XCTAssertFalse(sut.hasReference)
        
        sut.reference = Reference(option: .link, referenceText: "https://google.com")
        
        XCTAssertTrue(sut.hasReference)
    }
}
