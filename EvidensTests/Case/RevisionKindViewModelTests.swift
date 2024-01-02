//
//  RevisionKindViewModelTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 2/1/24.
//

import XCTest
import Firebase
@testable import Evidens

final class RevisionKindViewModelTests: XCTestCase {
    
    var sut: RevisionKindViewModel!
    
    override func setUpWithError() throws {
        var revision = CaseRevision(title: "Title for the revision", content: "This is the content", kind: .update)
        sut = RevisionKindViewModel(revision: revision)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testTitle() {
        XCTAssertEqual(sut.title, "Title for the revision")
    }
    
    func testContent() {
        XCTAssertEqual(sut.content, "This is the content")
    }
    
    func testKind() {
        XCTAssertEqual(sut.kind, AppStrings.Content.Case.Share.revision)
    }
}
