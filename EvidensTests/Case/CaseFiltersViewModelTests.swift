//
//  CaseFiltersViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
@testable import Evidens

final class CaseFiltersViewModelTests: XCTestCase {
    
    var sut: CaseFiltersViewModel!

    override func setUpWithError() throws {
        sut = CaseFiltersViewModel(filter: .latest)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testSetFilter() {
        XCTAssertEqual(sut.filter, .latest)
        
        for filter in CaseFilter.allCases {
            sut.set(filter: filter)
            XCTAssertEqual(sut.filter, filter)
        }
    }
}
