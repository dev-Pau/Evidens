//
//  CoreDataManagerTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 17/9/23.
//

import XCTest
@testable import Evidens

final class CoreDataManagerTests: XCTestCase {
    
    var sut: CoreDataManager!

    override func setUpWithError() throws {
        sut = CoreDataManager.shared
    }

    override func tearDownWithError() throws {
        sut.reset()
        sut = nil
    }
    
    func testCoreDataManager_WhenSetupCoordinator_ShouldNotBeNil() {
        let userId = "userId"
        sut.setupCoordinator(forUserId: userId)
        
        let coordinator = sut.coordinator(forUserId: userId)
        XCTAssertNotNil(coordinator)
    }
    
    func testCoreDataManager_WhenResetCoordinators_ShouldBeNil() {
        let userId = "anotherUserId"
        sut.setupCoordinator(forUserId: userId)
        sut.reset()
        XCTAssertNil(sut.coordinator(forUserId: userId))
    }
}
