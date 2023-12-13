//
//  UserStatsTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class UserStatsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInit() {
        let userStats = UserStats()
        XCTAssertEqual(userStats.connections, 0)
        XCTAssertEqual(userStats.followers, 0)
        XCTAssertEqual(userStats.following, 0)
        XCTAssertEqual(userStats.posts, 0)
        XCTAssertEqual(userStats.cases, 0)
    }
    
    func testSetConnections() {
        var userStats = UserStats()
        userStats.set(connections: 10)
        XCTAssertEqual(userStats.connections, 10)
    }
    
    func testSetFollowers() {
        var userStats = UserStats()
        userStats.set(followers: 20)
        XCTAssertEqual(userStats.followers, 20)
    }
    
    func testSetFollowing() {
        var userStats = UserStats()
        userStats.set(following: 30)
        XCTAssertEqual(userStats.following, 30)
    }
    
    func testSetPosts() {
        var userStats = UserStats()
        userStats.set(posts: 40)
        XCTAssertEqual(userStats.posts, 40)
    }
    
    func testSetCases() {
        var userStats = UserStats()
        userStats.set(cases: 50)
        XCTAssertEqual(userStats.cases, 50)
    }
}
