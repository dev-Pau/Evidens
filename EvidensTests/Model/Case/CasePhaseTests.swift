//
//  CasePhaseTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CasePhaseTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCasePhaseTitle() {
        XCTAssertEqual(CasePhase.solved.title, AppStrings.Content.Case.Phase.solved)
        XCTAssertEqual(CasePhase.unsolved.title, AppStrings.Content.Case.Phase.unsolved)
    }

    func testAllCasePhaseTitles() {
        CasePhase.allCases.forEach { phase in
            XCTAssertFalse(phase.title.isEmpty, "Title should not be empty for \(phase)")
        }
    }
}
