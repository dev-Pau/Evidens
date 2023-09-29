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
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testUITextView_WhenTextViewHasHashtags_ShouldDetectHashtags() {
        sut.text = "Evidens is leading the #healthcare #industry"
        
        let hashtags = sut.hashtags()
        
        XCTAssertEqual(hashtags, ["healthcare", "industry"])
    }
    
    func testUITextView_WhenTextViewHasNoHashtags_ShouldBeEmpty() {
        sut.text = "Evidens is leading the healthcare industry"
        
        let hashtags = sut.hashtags()
        
        XCTAssertEqual(hashtags, [])
    }
    
    func testUITextView_WhenAddingHashtags_ShouldAddHashtags() {
        sut.text = "Evidens is leading the #healthcare #industry"
        
        sut.addHashtags(withColor: primaryColor)
        let hashtags = sut.hashtags()
        
        XCTAssertEqual(hashtags, ["healthcare", "industry"])
    }
    
    func testUITextView_WhenAddingEmptyHashtags_ShouldBeEmpty() {
        sut.text = "Evidens is leading the healthcare industry"
        
        sut.addHashtags(withColor: primaryColor)
        let hashtags = sut.hashtags()
        
        XCTAssertEqual(hashtags, [])
    }
}
