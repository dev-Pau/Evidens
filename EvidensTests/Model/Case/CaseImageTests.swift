//
//  CaseImageTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CaseImageTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCaseImageInitialization() {
        let mainImage = UIImage(named: "AppIcon")!
        let faceImage = UIImage(named: "AppIcon")!
        
        let caseImageWithFace = CaseImage(image: mainImage, containsFaces: true)
        XCTAssertTrue(caseImageWithFace.containsFaces)
        XCTAssertFalse(caseImageWithFace.isRevealed)
        XCTAssertEqual(caseImageWithFace.getImage(), faceImage)
        
        let caseImageWithoutFace = CaseImage(image: mainImage, containsFaces: false)
        XCTAssertFalse(caseImageWithoutFace.containsFaces)
        XCTAssertTrue(caseImageWithoutFace.isRevealed)
        XCTAssertEqual(caseImageWithoutFace.getImage(), mainImage)
    }

    func testGetImage() {
        let mainImage = UIImage(named: "AppIcon")!
        let faceImage = UIImage(named: "AppIcon")!
        
        let caseImageWithFace = CaseImage(image: mainImage, containsFaces: true)
        XCTAssertEqual(caseImageWithFace.getImage(), faceImage)
        
        let caseImageWithoutFace = CaseImage(image: mainImage, containsFaces: false)
        XCTAssertEqual(caseImageWithoutFace.getImage(), mainImage)
    }
}
