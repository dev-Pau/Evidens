//
//  CaseExplorerViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
@testable import Evidens

final class CaseExplorerViewModelTests: XCTestCase {

    var sut: CaseExplorerViewModel!
    
    override func setUpWithError() throws {
        sut = CaseExplorerViewModel()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testAddSpecialities() {
        XCTAssertEqual(sut.specialities, [Speciality]())
        sut.addSpecialities(forDiscipline: .nutrition)
        XCTAssertEqual(sut.specialities, Discipline.nutrition.specialities)
    }
}
