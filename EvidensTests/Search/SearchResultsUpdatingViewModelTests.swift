//
//  SearchResultsUpdatingViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
import Firebase
@testable import Evidens

final class SearchResultsUpdatingViewModelTests: XCTestCase {
    
    var sut: SearchResultsUpdatingViewModel!
    
    override func setUpWithError() throws {
        sut = SearchResultsUpdatingViewModel()
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
    
    func testReset() {
        sut.reset()

        XCTAssertTrue(sut.isFetchingOrDidFetchPosts)
        XCTAssertTrue(sut.isFetchingOrDidFetchCases)
        XCTAssertTrue(sut.isFetchingOrDidFetchPeople)

        XCTAssertEqual(sut.scrollIndex, 0)

        XCTAssertTrue(sut.topUsers.isEmpty)
        XCTAssertTrue(sut.topCases.isEmpty)
        XCTAssertTrue(sut.topPosts.isEmpty)
        XCTAssertTrue(sut.topCaseUsers.isEmpty)
        XCTAssertTrue(sut.topPostUsers.isEmpty)
        XCTAssertTrue(sut.people.isEmpty)
        XCTAssertTrue(sut.posts.isEmpty)
        XCTAssertTrue(sut.postUsers.isEmpty)
        XCTAssertTrue(sut.cases.isEmpty)
        XCTAssertTrue(sut.caseUsers.isEmpty)

        XCTAssertFalse(sut.featuredLoaded)
        XCTAssertFalse(sut.peopleLoaded)
        XCTAssertFalse(sut.postsLoaded)
        XCTAssertFalse(sut.casesLoaded)
        XCTAssertTrue(sut.firstPeopleLoad)
        XCTAssertTrue(sut.firstPostsLoad)
        XCTAssertTrue(sut.firstCasesLoad)

        XCTAssertEqual(sut.pagePeople, 1)
        XCTAssertEqual(sut.pagePosts, 1)
        XCTAssertEqual(sut.pageCases, 1)
    }
}
