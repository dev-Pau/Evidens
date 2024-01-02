//
//  OnboardingViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 15/9/23.
//

import XCTest
@testable import Evidens

final class OnboardingViewModelTests: XCTestCase {
    
    var sut: OnboardingViewModel!
    
    override func setUpWithError() throws {
        sut = OnboardingViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testNilProfileImage() {
        XCTAssertFalse(sut.hasProfile)
    }
    
    func testValidProfileImage() {
        sut.profileImage = UIImage(named: AppStrings.Assets.profile)
        XCTAssertTrue(sut.hasProfile)
    }
    
    func testNilBannerImage() {
        XCTAssertFalse(sut.hasBanner)
    }
    
    func testValidBannerImage() {
        sut.bannerImage = UIImage(named: AppStrings.Assets.profile)
        XCTAssertTrue(sut.hasBanner)
    }
    
    func tesNilAboutText() {
        XCTAssertFalse(sut.hasAbout)
    }
    
    func testEmptyAboutTest() {
        sut.aboutText = ""
        XCTAssertFalse(sut.hasAbout)
    }
    
    func testSpaceAboutText() {
        sut.aboutText = "    "
        XCTAssertFalse(sut.hasAbout)
    }
    
    func testValidAboutText() {
        sut.aboutText = "This is some about text."
        XCTAssertTrue(sut.hasAbout)
    }
}
