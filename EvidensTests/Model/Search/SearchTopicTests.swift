//
//  SearchTopicTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class SearchTopicTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testTitleFeatured() {
        let topic = SearchTopics.featured
        XCTAssertEqual(topic.title, AppStrings.Search.Topics.featured)
    }
    
    func testTitlePeople() {
        let topic = SearchTopics.people
        XCTAssertEqual(topic.title, AppStrings.Search.Topics.people)
    }
    
    func testTitlePosts() {
        let topic = SearchTopics.posts
        XCTAssertEqual(topic.title, AppStrings.Search.Topics.posts)
    }
    
    func testTitleCases() {
        let topic = SearchTopics.cases
        XCTAssertEqual(topic.title, AppStrings.Search.Topics.cases)
    }
}
