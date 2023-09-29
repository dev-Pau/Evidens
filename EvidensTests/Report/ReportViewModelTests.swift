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
    
    func testReportViewModel_WhenReportIsCreated_ShouldAssignValues() {
        XCTAssertEqual(sut.contentId, "contentId")
        XCTAssertEqual(sut.contentUid, "contentUid")
        XCTAssertEqual(sut.uid, "uid")
        XCTAssertEqual(sut.source, ReportSource.clinicalCase)
        XCTAssertNil(sut.target)
        XCTAssertNil(sut.topic)
    }
    
    func testReportViewModel_WhenReportContentIsEdited_ShouldEditContent() {
        sut.edit(content: "Updated Content")
        
        XCTAssertEqual(sut.content, "Updated Content")
    }
    
    func testReportViewModel_WhenReportTargetIsEdited_ShouldEditTarget() {
        sut.edit(target: .group)
        
        XCTAssertEqual(sut.target, ReportTarget.group)
    }
    
    func testReportViewModel_WhenReportTopicIsEdited_ShouldEditTopic() {
        sut.edit(topic: .evidence)
        
        XCTAssertEqual(sut.topic, ReportTopic.evidence)
    }
}
