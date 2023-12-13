//
//  UserFollowTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class UserFollowTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitializationFromDictionary() {
        let dictionary: [String: Any] = ["uid": "testUID", "isFollow": true]
        let userFollow = UserFollow(dictionary: dictionary)
        
        XCTAssertEqual(userFollow.uid, "testUID")
        XCTAssertTrue(userFollow.isFollow)
    }
}
