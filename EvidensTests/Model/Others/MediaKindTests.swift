//
//  MediaKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class MediaKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitle() {
        XCTAssertEqual(MediaKind.camera.title, AppStrings.Menu.importCamera)
        XCTAssertEqual(MediaKind.gallery.title, AppStrings.Menu.chooseGallery)
    }
    
    func testImage() {
        let expectedCameraImage = UIImage(systemName: AppStrings.Icons.camera, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        let expectedGalleryImage = UIImage(systemName: AppStrings.Icons.photo, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        
        XCTAssertEqual(MediaKind.camera.image, expectedCameraImage)
        XCTAssertEqual(MediaKind.gallery.image, expectedGalleryImage)
    }
}
