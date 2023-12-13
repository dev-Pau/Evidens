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
    
    func testNameForValidValues() {
        sut.firstName = "John"
        XCTAssertTrue(sut.hasName)
    }
   
    func testNameForEmptyValues() {
        sut.firstName = ""
        XCTAssertFalse(sut.hasName)
    }
  
    func testLastNameForValidValues() {
        sut.lastName = "Doe"
        XCTAssertTrue(sut.hasLastName)
    }
    
    func testLastNameForEmptyValues() {
        sut.lastName = ""
        XCTAssertFalse(sut.hasLastName)
    }
    
    func testSpecialityForValidValue() {
        sut.speciality = .cardiacNurse
        XCTAssertTrue(sut.hasSpeciality)
    }
    
    func testSpecialityForNilValue() {
        sut.speciality = nil
        XCTAssertFalse(sut.hasSpeciality)
    }
    
    func testProfileImageForValidImage() {
        sut.profileImage = UIImage(systemName: AppStrings.Icons.photo)
        XCTAssertTrue(sut.hasProfile)
    }
   
    func testProfileImageForNilImage() {
        sut.profileImage = nil
        XCTAssertFalse(sut.hasProfile)
    }
   
    func testProfileBannerForValidImage() {
        sut.bannerImage = UIImage(systemName: AppStrings.Icons.photo)
        XCTAssertTrue(sut.hasBanner)
    }
    
    func testProfileBannerForNilImage() {
        sut.bannerImage = nil
        XCTAssertFalse(sut.hasBanner)
    }
    
    func testProfileImagesForValidImages() {
        sut.profileImage = UIImage(systemName: AppStrings.Icons.photo)
        sut.bannerImage = UIImage(systemName: AppStrings.Icons.photo)
        XCTAssertTrue(sut.hasBothImages)
    }
   
    func testProfileImagesForInvalidImages() {
        sut.profileImage = UIImage(named: "ProfileImage")
        sut.bannerImage = nil
        XCTAssertFalse(sut.hasBothImages)
    }

    func testProfileIsValid() {
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.speciality = .cardiacNurse
        XCTAssertTrue(sut.profileIsValid)
    }

    func testProfileIsNotValid() {
        sut.firstName = "John"
        sut.lastName = ""
        sut.speciality = nil
        XCTAssertFalse(sut.profileIsValid)
    }
}
