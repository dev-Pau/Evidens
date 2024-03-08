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
        sut = ProfileImageViewModel(kind: .banner)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testIsBanner() {
        XCTAssertEqual(sut.kind, .banner)
        
        let viewModel = ProfileImageViewModel(kind: .profile)
        
        XCTAssertEqual(viewModel.kind, .profile)
    }
}
