//
//  ConnectPhaseTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens


final class ConnectPhaseTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitleForConnected() {
        XCTAssertEqual(ConnectPhase.connected.title, AppStrings.Network.Connection.connected)
    }
    
    func testTitleForPending() {
        XCTAssertEqual(ConnectPhase.pending.title, AppStrings.Network.Connection.pending)
    }
    
    func testTitleForReceived() {
        XCTAssertEqual(ConnectPhase.received.title, AppStrings.Network.Connection.received)
    }
    
    func testTitleForRejected() {
        XCTAssertEqual(ConnectPhase.rejected.title, AppStrings.Network.Connection.none)
    }
    
    func testTitleForWithdraw() {
        XCTAssertEqual(ConnectPhase.withdraw.title, AppStrings.Network.Connection.none)
    }
    
    func testTitleForUnconnect() {
        XCTAssertEqual(ConnectPhase.unconnect.title, AppStrings.Network.Connection.none)
    }
    
    func testTitleForNone() {
        XCTAssertEqual(ConnectPhase.none.title, AppStrings.Network.Connection.none)
    }
}
