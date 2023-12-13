//
//  UserNetworkTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class UserNetworkTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitleConnections() {
        let userNetwork = UserNetwork.connections
        XCTAssertEqual(userNetwork.title, AppStrings.Network.Connection.connections.capitalized)
    }
    
    func testTitleFollowers() {
        let userNetwork = UserNetwork.followers
        XCTAssertEqual(userNetwork.title, AppStrings.Network.Follow.followers.capitalized)
    }
    
    func testTitleFollowing() {
        let userNetwork = UserNetwork.following
        XCTAssertEqual(userNetwork.title, AppStrings.Network.Follow.following.capitalized)
    }
}
