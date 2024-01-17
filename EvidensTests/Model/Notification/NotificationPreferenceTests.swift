//
//  NotificationPreferenceTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class NotificationPreferenceTests: XCTestCase {
    
    var sut: NotificationPreference!
    
    override func setUpWithError() throws {
        let dictionary: [String: Any] = [
            "enabled": true,
            "reply": ["value": true, "target": 1],
            "like": ["value": false, "target": 0],
            "connection": false,
            "message": true,
            "trackCase": false
        ]
        
        sut = NotificationPreference(dictionary: dictionary)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitWithDictionary() {

        XCTAssertEqual(sut.enabled, true)
        XCTAssertEqual(sut.reply, true)
        XCTAssertEqual(sut.replyTarget, .anyone)
        XCTAssertEqual(sut.like, false)
        XCTAssertEqual(sut.likeTarget, .follow)
        XCTAssertEqual(sut.connection, false)
        XCTAssertEqual(sut.trackCase, false)
    }
    
    func testUpdateReply() {
        sut.update(keyPath: \.reply, value: true)
        
        XCTAssertEqual(sut.reply, true)
    }
    
    func testUpdateLikeTarget() {
        sut.update(keyPath: \.likeTarget, value: .follow)
        
        XCTAssertEqual(sut.likeTarget, .follow)
    }
}
