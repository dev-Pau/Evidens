//
//  PermissionKindTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 12/12/23.
//

import XCTest
@testable import Evidens

final class PermissionKindTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testShareTitle() {
        let permissionKind = PermissionKind.share
        XCTAssertEqual(permissionKind.title, AppStrings.Permission.share)
    }
    
    func testProfileTitle() {
        let permissionKind = PermissionKind.profile
        XCTAssertEqual(permissionKind.title, AppStrings.Permission.profile)
    }
    
    func testConnectionsTitle() {
        let permissionKind = PermissionKind.connections
        XCTAssertEqual(permissionKind.title, AppStrings.Permission.connections)
    }
    
    func testReactionTitle() {
        let permissionKind = PermissionKind.reaction
        XCTAssertEqual(permissionKind.title, AppStrings.Permission.reaction)
    }
    
    func testCommentTitle() {
        let permissionKind = PermissionKind.comment
        XCTAssertEqual(permissionKind.title, AppStrings.Permission.comment)
    }
}
