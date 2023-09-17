//
//  VerificationViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class VerificationViewModelTests: XCTestCase {
    
    var sut: VerificationViewModel!
    
    override func setUpWithError() throws {
        sut = VerificationViewModel(user: User(dictionary: [:]))
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testVerificationViewModel_WhenSetKind_KindShouldBeEqual() {
        XCTAssertEqual(sut.kind, .doc)
    }

    func testVerificationViewModel_initialDocImage_IsNil() {
        XCTAssertNil(sut.docImage)
    }

    func test_initialIdImage_IsNil() {
        XCTAssertNil(sut.idImage)
    }

    func testVerificationViewModel_WhenImagesAreNil_ReturnsFalse() {
        XCTAssertFalse(sut.isValid)
    }

    func testVerificationViewModel_WhenWeSetDocImage_DocImageShouldBeSet() {
        let image = UIImage(systemName: AppStrings.Assets.profile) ?? UIImage()
        sut.setDocImage(image)
        XCTAssertEqual(sut.docImage, image)
    }

    func testVerificationViewModel_WhenWeSetIdImage_IdImageShouldBeSet() {
        let image = UIImage(systemName: AppStrings.Assets.profile) ?? UIImage()
        sut.setIdImage(image)
        XCTAssertEqual(sut.idImage, image)
    }
}
