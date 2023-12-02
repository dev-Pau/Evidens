//
//  UITextViewTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 28/9/23.
//

import XCTest
@testable import Evidens

final class UITextViewTests: XCTestCase {
    
    var sut: UITextView!

    override func setUpWithError() throws {
        sut = UITextView()
        sut.font = .preferredFont(forTextStyle: .body)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testHashtagsWithHashtags() {
        sut.text = "Evidens is leading the #healthcare #industry"
        
        let hashtags = sut.hashtags()
        
        XCTAssertEqual(hashtags, ["healthcare", "industry"], "Data hashtags should match")
    }
    
    func testHashtagsWithoutHashtags() {
        sut.text = "Evidens is leading the healthcare industry"
        
        let hashtags = sut.hashtags()
        
        XCTAssertEqual(hashtags, [], "Data hashtags should be empty")
    }
    
    func testHashtagsWithColorAndHashtags() {
        sut.text = "Evidens is leading the #healthcare #industry"
        
        sut.addHashtags(withColor: primaryColor)
        let hashtags = sut.hashtags()
        
        XCTAssertEqual(hashtags, ["healthcare", "industry"], "Data hashtags should match")
    }
    
    func testHashtagsWithColorAndWithoutHashtags() {
        sut.text = "Evidens is leading the healthcare industry"
        
        sut.addHashtags(withColor: primaryColor)
        let hashtags = sut.hashtags()
        
        XCTAssertEqual(hashtags, [], "Data hashtags should be empty")
    }
}
