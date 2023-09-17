//
//  PublicationViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class PublicationViewModelTests: XCTestCase {
    
    var sut: PublicationViewModel!
    
    override func setUpWithError() throws {
        sut = PublicationViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testPublicationViewModel_WhenTitleUrlAndTimestampAreNil_ReturnsFalse() {
        XCTAssertFalse(sut.isValid)
    }
    
    func testPublicationViewModel_WhenTitleIsNotNilAndUrlIsNil_ReturnsFalse() {
        sut.set(title: "Sample Title")
        XCTAssertFalse(sut.isValid)
    }
    
    func testPublicationViewModel_WhenTitleIsNilAndUrlIsNotNil_ReturnsFalse() {
        sut.set(url: "https://example.com")
        XCTAssertFalse(sut.isValid)
    }
    
    func testPublicationViewModel_WhenTitleUrlAndTimestampAreNotNil_ReturnsTrue() {
        sut.set(title: "Sample Title")
        sut.set(url: "https://example.com")
        sut.set(timestamp: Date().timeIntervalSince1970)
        XCTAssertTrue(sut.isValid)
    }
    
    func testPublicationViewModel_SetsAllProperties_ReturnsEqualValues() {
        let publication = Publication(id: "123", title: "Sample Title", url: "https://example.com", timestamp: Date().timeIntervalSince1970, uids: ["uid1", "uid2"])
        sut.set(publication: publication)
        
        XCTAssertEqual(sut.id, "123")
        XCTAssertEqual(sut.title, "Sample Title")
        XCTAssertEqual(sut.url, "https://example.com")
        XCTAssertNotNil(sut.timestamp)
        XCTAssertEqual(sut.uids, ["uid1", "uid2"])
    }
    
    func testPublicationViewModel_WhenTitleIsSet_ShouldReturnSameTitle() {
        sut.set(title: "New Title")
        XCTAssertEqual(sut.title, "New Title")
    }
    
    func testPublicationViewModel_WhenURLIsSet_ShouldReturnSameUrl() {
        sut.set(url: "https://new-url.com")
        XCTAssertEqual(sut.url, "https://new-url.com")
    }
    
    func testPublicationViewModel_WhenTimestampIsSet_ShouldReturnSameTimestamp() {
        let timestamp = Date().timeIntervalSince1970
        sut.set(timestamp: timestamp)
        XCTAssertEqual(sut.timestamp, timestamp)
    }
}
