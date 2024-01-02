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
    
    func testVerificationKind() {
        XCTAssertEqual(sut.kind, .doc)
    }

    func testNilDocImage() {
        XCTAssertNil(sut.docImage)
    }

    func testNilIdImage() {
        XCTAssertNil(sut.idImage)
    }

    func testNilImages() {
        XCTAssertFalse(sut.isValid)
    }

    func testValidDocImage() {
        let image = UIImage(systemName: AppStrings.Assets.profile) ?? UIImage()
        sut.setDocImage(image)
        XCTAssertEqual(sut.docImage, image)
    }

    func testValidIdImage() {
        let image = UIImage(systemName: AppStrings.Assets.profile) ?? UIImage()
        sut.setIdImage(image)
        XCTAssertEqual(sut.idImage, image)
    }
}
