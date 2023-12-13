//
//  ReportTargetTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class ReportTargetTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testMyselfTitle() {
        let reportTarget = ReportTarget.myself
        XCTAssertEqual(reportTarget.title, AppStrings.Report.Target.myselfTitle)
    }
    
    func testMyselfContent() {
        let reportTarget = ReportTarget.myself
        XCTAssertEqual(reportTarget.content, AppStrings.Report.Target.myselfContent)
    }
    
    func testMyselfSummary() {
        let reportTarget = ReportTarget.myself
        XCTAssertEqual(reportTarget.summary, AppStrings.Report.Target.myselfSummary)
    }
    
    func testGroupTitle() {
        let reportTarget = ReportTarget.group
        XCTAssertEqual(reportTarget.title, AppStrings.Report.Target.groupTitle)
    }
    
    func testGroupContent() {
        let reportTarget = ReportTarget.group
        XCTAssertEqual(reportTarget.content, AppStrings.Report.Target.groupContent)
    }
    
    func testGroupSummary() {
        let reportTarget = ReportTarget.group
        XCTAssertEqual(reportTarget.summary, AppStrings.Report.Target.groupSummary)
    }
    
    func testEveryoneTitle() {
        let reportTarget = ReportTarget.everyone
        XCTAssertEqual(reportTarget.title, AppStrings.Report.Target.everyoneTitle)
    }
    
    func testEveryoneContent() {
        let reportTarget = ReportTarget.everyone
        XCTAssertEqual(reportTarget.content, AppStrings.Report.Target.everyoneContent)
    }
    
    func testEveryoneSummary() {
        let reportTarget = ReportTarget.everyone
        XCTAssertEqual(reportTarget.summary, AppStrings.Report.Target.everyoneSummary)
    }
}
