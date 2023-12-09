//
//  ReportViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 29/9/23.
//

import XCTest
@testable import Evidens

final class ReportViewModelTests: XCTestCase {
    
    var sut: ReportViewModel!
    
    override func setUpWithError() throws {
        let report = Report(contentId: "contentId", contentUid: "contentUid", uid: "uid", source: .clinicalCase)
        sut = ReportViewModel(report: report)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testAssignmentAtReportCreation() {
        XCTAssertEqual(sut.contentId, "contentId")
        XCTAssertEqual(sut.contentUid, "contentUid")
        XCTAssertEqual(sut.uid, "uid")
        XCTAssertEqual(sut.source, ReportSource.clinicalCase)
        XCTAssertNil(sut.target, "Data should be nil")
        XCTAssertNil(sut.topic, "Data should be nil")
    }
    
    func testContentIdGetter() {
        XCTAssertEqual(sut.contentId, "contentId")
    }

    func testContentUidGetter() {
        XCTAssertEqual(sut.contentUid, "contentUid")
    }

    func testUidGetter() {
        XCTAssertEqual(sut.uid, "uid")
    }

    func testTargetGetter() {
        let target = ReportTarget.everyone
        sut.edit(target: target)
        XCTAssertEqual(sut.target, target)
    }

    func testTopicGetter() {
        let topic = ReportTopic.evidence
        sut.edit(topic: topic)
        XCTAssertEqual(sut.topic, topic)
    }

    func testSourceGetter() {
        XCTAssertEqual(sut.source, .clinicalCase)
    }

    func testContentAddition() {
        sut.edit(content: "This is the report content added by the user")
        XCTAssertEqual(sut.content, "This is the report content added by the user", "Data should be equal")
    }
    
    func testTargetChange() {
        sut.edit(target: .group)
        
        XCTAssertEqual(sut.target, ReportTarget.group)
    }
    
    func testTopicChange() {
        sut.edit(topic: .evidence)
        
        XCTAssertEqual(sut.topic, ReportTopic.evidence)
    }
}
