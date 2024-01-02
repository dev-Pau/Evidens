//
//  RecentTextViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
@testable import Evidens

final class RecentTextViewModelTests: XCTestCase {

    var sut: RecentTextViewModel!
    
    override func setUpWithError() throws {
        sut = RecentTextViewModel(text: "Recent text should go here...")
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testGetText() {
        XCTAssertEqual(sut.textToDisplay, "Recent text should go here...")
    }
}
