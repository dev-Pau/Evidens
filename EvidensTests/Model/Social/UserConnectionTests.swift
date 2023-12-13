//
//  UserConnectionTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
import Firebase
@testable import Evidens

final class UserConnectionTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitializationWithDictionary() {
        let timestamp = Timestamp(date: Date())
        let uid = "testUID"
        let dictionary: [String: Any] = ["phase": 1, "timestamp": timestamp]
        
        let userConnection = UserConnection(uid: uid, dictionary: dictionary)
        
        XCTAssertEqual(userConnection.uid, uid)
        XCTAssertEqual(userConnection.phase, .pending)
        XCTAssertEqual(userConnection.timestamp, timestamp)
    }
    
    func testInitializationWithoutDictionary() {
        let uid = "testUID"
        let userConnection = UserConnection(uid: uid)
        
        XCTAssertEqual(userConnection.uid, uid)
        XCTAssertEqual(userConnection.phase, .none)
    }
}
