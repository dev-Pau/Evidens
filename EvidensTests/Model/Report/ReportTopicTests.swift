//
//  ReportTopicTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class ReportTopicTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testIdentityTitle() {
        let reportTopic = ReportTopic.identity
        XCTAssertEqual(reportTopic.title, AppStrings.Report.Topics.identityTitle)
    }
    
    func testIdentityContent() {
        let reportTopic = ReportTopic.identity
        XCTAssertEqual(reportTopic.content, AppStrings.Report.Topics.identityContent)
    }
    
    func testHarassTitle() {
        let reportTopic = ReportTopic.harass
        XCTAssertEqual(reportTopic.title, AppStrings.Report.Topics.harassTitle)
    }
    
    func testHarassContent() {
        let reportTopic = ReportTopic.harass
        XCTAssertEqual(reportTopic.content, AppStrings.Report.Topics.harrassContent)
    }
    
    func testSpamTitle() {
        let reportTopic = ReportTopic.spam
        XCTAssertEqual(reportTopic.title, AppStrings.Report.Topics.spamTitle)
    }
    
    func testSpamContent() {
        let reportTopic = ReportTopic.spam
        XCTAssertEqual(reportTopic.content, AppStrings.Report.Topics.spamContent)
    }
    
    func testSensibleTitle() {
        let reportTopic = ReportTopic.sensible
        XCTAssertEqual(reportTopic.title, AppStrings.Report.Topics.sensibleTitle)
    }
    
    func testSensibleContent() {
        let reportTopic = ReportTopic.sensible
        XCTAssertEqual(reportTopic.content, AppStrings.Report.Topics.sensibleContent)
    }
    
    func testEvidenceTitle() {
        let reportTopic = ReportTopic.evidence
        XCTAssertEqual(reportTopic.title, AppStrings.Report.Topics.evidenceTitle)
    }
    
    func testEvidenceContent() {
        let reportTopic = ReportTopic.evidence
        XCTAssertEqual(reportTopic.content, AppStrings.Report.Topics.evidenceContent)
    }
    
    func testTipsTitle() {
        let reportTopic = ReportTopic.tips
        XCTAssertEqual(reportTopic.title, AppStrings.Report.Topics.tipsTitle)
    }
    
    func testTipsContent() {
        let reportTopic = ReportTopic.tips
        XCTAssertEqual(reportTopic.content, AppStrings.Report.Topics.tipsContent)
    }
}
