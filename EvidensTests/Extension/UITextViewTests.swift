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
        
        let (hashtags, _) = sut.hashtags()
        
        XCTAssertEqual(hashtags, ["healthcare", "industry"], "Data hashtags should match")
    }
    
    func testHashtagsWithoutHashtags() {
        sut.text = "Evidens is leading the healthcare industry"
        
        let (hashtags, _) = sut.hashtags()
        
        XCTAssertEqual(hashtags, [], "Data hashtags should be empty")
    }
    
    func testHashtagsWithColorAndHashtags() {
        sut.text = "Evidens is leading the #healthcare #industry"
        
        sut.addHashtags(withColor: primaryColor)
        let (hashtags, _) = sut.hashtags()
        
        XCTAssertEqual(hashtags, ["healthcare", "industry"], "Data hashtags should match")
    }
    
    func testHashtagsWithColorAndWithoutHashtags() {
        sut.text = "Evidens is leading the healthcare industry"
        
        sut.addHashtags(withColor: primaryColor)
        let (hashtags, _) = sut.hashtags()
        
        XCTAssertEqual(hashtags, [], "Data hashtags should be empty")
    }
    
    func testProcessHashtagLinkWithoutAny() {
        sut.text = "Evidens is leading the healthcare industry"
        
        let (hashtag, link) = sut.processHashtagLink()
        XCTAssertEqual(hashtag, [], "Data hashtags should be empty")
        XCTAssertEqual(link, [], "Data links should be empty")
    }
    
    func testProcessHashtagLinkWithHashtag() {
        sut.text = "Evidens is leading the #healthcare #industry"
        
        let (hashtag, link) = sut.processHashtagLink()
        XCTAssertEqual(hashtag, ["healthcare", "industry"], "Data hashtags should match")
        XCTAssertEqual(link, [], "Data links should be empty")
    }
    
    func testProcessHashtagLinkWithLinks() {
        sut.text = "Evidens is leading the healthcare industry. Go check evidens.app or www.evidens.com or https://www.evidens.es"
        
        let (hashtag, link) = sut.processHashtagLink()
        XCTAssertEqual(hashtag, [], "Data hashtags should be empty")
        XCTAssertEqual(link, ["https://evidens.app", "https://www.evidens.com", "https://www.evidens.es"], "Data links should match")
    }
    
    func testProcessHashtagLinkWithHashtagLinks() {
        sut.text = "Evidens is leading the #healthcare #industry. Go check evidens.app or www.evidens.com or https://www.evidens.es"
        
        let (hashtag, link) = sut.processHashtagLink()
        XCTAssertEqual(hashtag, ["healthcare", "industry"], "Data hashtags should match")
        XCTAssertEqual(link, ["https://evidens.app", "https://www.evidens.com", "https://www.evidens.es"], "Data links should match")
    }
}
