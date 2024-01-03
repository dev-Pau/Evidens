//
//  ProfileImageViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
@testable import Evidens

final class ProfileImageViewModelTests: XCTestCase {
    
    var sut: ProfileImageViewModel!

    override func setUpWithError() throws {
        sut = ProfileImageViewModel(isBanner: false)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testIsBanner() {
        XCTAssertEqual(sut.isBanner, false)
        
        let viewModel = ProfileImageViewModel(isBanner: true)
        
        XCTAssertEqual(viewModel.isBanner, true)
    }
}
