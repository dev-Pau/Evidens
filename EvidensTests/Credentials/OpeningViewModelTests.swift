//
//  OpeningViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 28/9/23.
//

import XCTest
@testable import Evidens

final class OpeningViewModelTests: XCTestCase {
    
    var viewModel: OpeningViewModel!

    override func setUpWithError() throws {
        viewModel = OpeningViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testOpeningViewModel_WhenNonceHasPositiveLength_ShouldReturnPositiveNonce() {
        let length = 16
        let nonce = viewModel.randomNonceString(length: length)
        XCTAssertEqual(nonce.count, length)
    }
    
    func testOpeningViewModel_WhenNonEmptyInput_HashShouldBeNonEmpty() {
        let input = "Evidens"
        let expectedHash = "353279abd765813b3f3c6ebed9770d0b80c26b5dc8e0cca908a1831f907b7c4a"
        let hash = viewModel.sha256(input)
        XCTAssertEqual(hash, expectedHash)
    }
    
    func testOpeningViewModel_WhenCurrentNonceIsNil_ShouldReturnNil() {
        XCTAssertNil(viewModel.currentNonce)
    }
    
    func testOpeningViewModel_WhenCurrentNonceIsNonNil_ShouldReturnNonNil() {
        viewModel.edit(currentNonce: viewModel.randomNonceString(length: 16))
        XCTAssertNotNil(viewModel.currentNonce)
    }
}
