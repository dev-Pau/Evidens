//
//  EditProfileViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 19/9/23.
//

import XCTest
@testable import Evidens

final class EditProfileViewModelTests: XCTestCase {
    
    var sut: EditProfileViewModel!
    
    override func setUpWithError() throws {
        sut = EditProfileViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testProfileViewModel_WhenFirstNameIsNonEmpty_ShouldReturnTrueForHasName() {
        sut.firstName = "John"
        XCTAssertTrue(sut.hasName)
    }
   
    func testProfileViewModel_WhenFirstNameIsEmpty_ShouldReturnFalseForHasName() {
        sut.firstName = ""
        XCTAssertFalse(sut.hasName)
    }
  
    func testProfileViewModel_WhenLastNameIsNonEmpty_ShouldReturnTrueForHasLastName() {
        sut.lastName = "Doe"
        XCTAssertTrue(sut.hasLastName)
    }
    
    func testProfileViewModel_WhenLastNameIsEmpty_ShouldReturnFalseForHasLastName() {
        sut.lastName = ""
        XCTAssertFalse(sut.hasLastName)
    }
    
    func testProfileViewModel_WhenSpecialityIsNotNil_ShouldReturnTrueForHasSpeciality() {
        sut.speciality = .cardiacNurse
        XCTAssertTrue(sut.hasSpeciality)
    }
    
    func testProfileViewModel_WhenSpecialityIsNil_ShouldReturnFalseForHasSpeciality() {
        sut.speciality = nil
        XCTAssertFalse(sut.hasSpeciality)
    }
    
    func testProfileViewModel_WhenProfileImageIsNotNil_ShouldReturnTrueForHasProfile() {
        sut.profileImage = UIImage(systemName: AppStrings.Icons.photo)
        XCTAssertTrue(sut.hasProfile)
    }
   
    func testProfileViewModel_WhenProfileImageIsNil_ShouldReturnFalseForHasProfile() {
        sut.profileImage = nil
        XCTAssertFalse(sut.hasProfile)
    }
   
    func testProfileViewModel_WhenBannerImageIsNotNil_ShouldReturnTrueForHasBanner() {
        sut.bannerImage = UIImage(systemName: AppStrings.Icons.photo)
        XCTAssertTrue(sut.hasBanner)
    }
    
    func testProfileViewModel_WhenBannerImageIsNil_ShouldReturnFalseForHasBanner() {
        sut.bannerImage = nil
        XCTAssertFalse(sut.hasBanner)
    }
    
    func testProfileViewModel_WhenBothImagesAreNotNil_ShouldReturnTrueForHasBothImages() {
        sut.profileImage = UIImage(systemName: AppStrings.Icons.photo)
        sut.bannerImage = UIImage(systemName: AppStrings.Icons.photo)
        XCTAssertTrue(sut.hasBothImages)
    }
   
    func testProfileViewModel_WhenEitherImageIsNil_ShouldReturnFalseForHasBothImages() {
        sut.profileImage = UIImage(named: "ProfileImage")
        sut.bannerImage = nil
        XCTAssertFalse(sut.hasBothImages)
    }

    func testProfileViewModel_WhenAllRequiredPropertiesNonEmpty_ShouldReturnTrueForProfileIsValid() {
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.speciality = .cardiacNurse
        XCTAssertTrue(sut.profileIsValid)
    }

    func testProfileViewModel_WhenAnyRequiredPropertyIsEmptyOrNil_ShouldReturnFalseForProfileIsValid() {
        sut.firstName = "John"
        sut.lastName = ""
        sut.speciality = nil
        XCTAssertFalse(sut.profileIsValid)
    }
}
