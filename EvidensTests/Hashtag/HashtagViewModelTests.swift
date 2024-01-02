//
//  HashtagViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 27/12/23.
//

import XCTest
@testable import Evidens

final class HashtagViewModelTests: XCTestCase {
    
    var sut: HashtagViewModel!

    override func setUpWithError() throws {
        sut = HashtagViewModel(hashtag: "hash:healthcare")
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testGetTitleForHashtag() {
        XCTAssertEqual(sut.title(), "#healthcare")
    }
}
