//
//  UserNetworkViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
import Firebase
@testable import Evidens

final class UserNetworkViewModelTests: XCTestCase {

    var sut: UserNetworkViewModel!
    
    override func setUpWithError() throws {
        let userData: [String: Any] = [
            "firstName": "John",
            "lastName": "Doe",
            "email": "john.doe@example.com",
            "uid": "12345",
            "imageUrl": "profile_image_url",
            "bannerUrl": "banner_image_url",
            "kind": 0,
            "phase": 2,
            "discipline": 0,
            "speciality": 0,
        ]

        let user = User(dictionary: userData)

        sut = UserNetworkViewModel(user: user)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testHasWeeksPassedSince() {
        let currentDate = Timestamp(date: Date())
        
        let threeWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!
        let timestampThreeWeeksAgo = Timestamp(date: threeWeeksAgo)
        
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let timestampOneWeekAgo = Timestamp(date: oneWeekAgo)
        
        XCTAssertTrue(sut.hasWeeksPassedSince(forWeeks: 2, timestamp: timestampThreeWeeksAgo))
        XCTAssertFalse(sut.hasWeeksPassedSince(forWeeks: 2, timestamp: timestampOneWeekAgo))
        XCTAssertFalse(sut.hasWeeksPassedSince(forWeeks: 2, timestamp: currentDate))
    }
}
