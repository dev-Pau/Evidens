//
//  SearchViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
import Firebase
@testable import Evidens

final class SearchViewModelTests: XCTestCase {
    
    var sut: SearchViewModel!

    override func setUpWithError() throws {
        sut = SearchViewModel()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testHasWeeksPassedSince() {
        let currentDate = Timestamp(date: Date())
        
        let threeWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!
        let timestampThreeWeeksAgo = Timestamp(date: threeWeeksAgo)
        
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let timestampOneWeekAgo = Timestamp(date: oneWeekAgo)
        
        XCTAssertTrue(sut.hasWeeksPassedSince(forWeeks: 2, timestamp: timestampThreeWeeksAgo))
        XCTAssertFalse(sut.hasWeeksPassedSince(forWeeks: 2, timestamp: timestampOneWeekAgo))
        XCTAssertFalse(sut.hasWeeksPassedSince(forWeeks: 2, timestamp: currentDate))
    }
}
