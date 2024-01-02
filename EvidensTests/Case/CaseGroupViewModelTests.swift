//
//  CaseGroupViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
@testable import Evidens

final class CaseGroupViewModelTests: XCTestCase {
    
    var sut: CaseGroupViewModel!
    
    override func setUpWithError() throws {
        sut = CaseGroupViewModel(group: CaseGroup.body(.head, .front))
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testGetTitle() {
        XCTAssertEqual(sut.getTitle(), Body.head.frontName)
        
        let backLeftFootGroup = CaseGroupViewModel(group: CaseGroup.body(.leftFoot, .back))
        XCTAssertEqual(backLeftFootGroup.getTitle(), Body.leftFoot.backName)
        
        let biomedicalGroup = CaseGroupViewModel(group: .discipline(.biomedical))
        XCTAssertEqual(biomedicalGroup.getTitle(), Discipline.biomedical.name)
        
        let academicOdontologyGroup = CaseGroupViewModel(group: .speciality(.academicOdontology))
        XCTAssertEqual(academicOdontologyGroup.getTitle(), Speciality.academicOdontology.name)
    }
    
    func testSetCaseFilter() {
        sut.set(filter: CaseFilter.featured)
        XCTAssertTrue(sut.cases.isEmpty)
        XCTAssertTrue(sut.users.isEmpty)
        XCTAssertFalse(sut.casesLoaded)
        XCTAssertNil(sut.casesLastSnapshot)
        XCTAssertFalse(sut.isFetchingMoreCases)
    }
}
