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
    
    func testOnboardingViewModel_WhenProfileImageIsNil_ReturnsFalse() {
        XCTAssertFalse(sut.hasProfile)
    }
    
    func testOnboardingViewModel_WhenProfileImageIsNotNil_ReturnsTrue() {
        sut.profileImage = UIImage(named: AppStrings.Assets.profile)
        XCTAssertTrue(sut.hasProfile)
    }
    
    func testOnboardingViewModel_WhenBannerImageIsNil_ReturnsFalse() {
        XCTAssertFalse(sut.hasBanner)
    }
    
    func testOnboardingViewModel_WhenBannerImageIsNotNil_ReturnsTrue() {
        sut.bannerImage = UIImage(named: AppStrings.Assets.profile)
        XCTAssertTrue(sut.hasBanner)
    }
    
    func testOnboardingViewModel_WhenAboutTextIsNil_ReturnsFalse() {
        XCTAssertFalse(sut.hasAbout)
    }
    
    func testOnboardingViewModel_WhenAboutTextIsEmpty_ReturnsFalse() {
        sut.aboutText = ""
        XCTAssertFalse(sut.hasAbout)
    }
    
    func testOnboardingViewModel_WhenAboutTextIsWhitespace_ReturnsFalse() {
        sut.aboutText = "    "
        XCTAssertFalse(sut.hasAbout)
    }
    
    func testOnboardingViewModel_WhenAboutTextIsNotEmpty_ReturnsTrue() {
        sut.aboutText = "This is some about text."
        XCTAssertTrue(sut.hasAbout)
    }
}
