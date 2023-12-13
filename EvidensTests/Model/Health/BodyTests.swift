//
//  BodyTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class BodyTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testFrontName() {
        XCTAssertEqual(Body.head.frontName, AppStrings.Health.Body.Human.Front.head)
        XCTAssertEqual(Body.rightShoulder.frontName, AppStrings.Health.Body.Human.Front.rightShoulder)
        XCTAssertEqual(Body.leftShoulder.frontName, AppStrings.Health.Body.Human.Front.leftShoulder)
        XCTAssertEqual(Body.rightChest.frontName, AppStrings.Health.Body.Human.Front.rightChest)
        XCTAssertEqual(Body.leftChest.frontName, AppStrings.Health.Body.Human.Front.leftChest)
        XCTAssertEqual(Body.stomach.frontName, AppStrings.Health.Body.Human.Front.stomach)
        XCTAssertEqual(Body.hips.frontName, AppStrings.Health.Body.Human.Front.hips)
        XCTAssertEqual(Body.rightThigh.frontName, AppStrings.Health.Body.Human.Front.rightThigh)
        XCTAssertEqual(Body.leftThigh.frontName, AppStrings.Health.Body.Human.Front.leftThigh)
        XCTAssertEqual(Body.rightKnee.frontName, AppStrings.Health.Body.Human.Front.rightKnee)
        XCTAssertEqual(Body.leftKnee.frontName, AppStrings.Health.Body.Human.Front.leftKnee)
        XCTAssertEqual(Body.rightShin.frontName, AppStrings.Health.Body.Human.Front.rightShin)
        XCTAssertEqual(Body.leftShin.frontName, AppStrings.Health.Body.Human.Front.leftShin)
        XCTAssertEqual(Body.rightFoot.frontName, AppStrings.Health.Body.Human.Front.rightFoot)
        XCTAssertEqual(Body.leftFoot.frontName, AppStrings.Health.Body.Human.Front.leftFoot)
        XCTAssertEqual(Body.rightArm.frontName, AppStrings.Health.Body.Human.Front.rightArm)
        XCTAssertEqual(Body.leftArm.frontName, AppStrings.Health.Body.Human.Front.leftArm)
        XCTAssertEqual(Body.rightHand.frontName, AppStrings.Health.Body.Human.Front.rightHand)
        XCTAssertEqual(Body.leftHand.frontName, AppStrings.Health.Body.Human.Front.leftHand)
    }
    
    func testBackName() {
        XCTAssertEqual(Body.head.backName, AppStrings.Health.Body.Human.Back.head)
        XCTAssertEqual(Body.rightShoulder.backName, AppStrings.Health.Body.Human.Back.rightShoulder)
        XCTAssertEqual(Body.leftShoulder.backName, AppStrings.Health.Body.Human.Back.leftShoulder)
        XCTAssertEqual(Body.rightChest.backName, AppStrings.Health.Body.Human.Back.rightChest)
        XCTAssertEqual(Body.leftChest.backName, AppStrings.Health.Body.Human.Back.leftChest)
        XCTAssertEqual(Body.stomach.backName, AppStrings.Health.Body.Human.Back.stomach)
        XCTAssertEqual(Body.hips.backName, AppStrings.Health.Body.Human.Back.hips)
        XCTAssertEqual(Body.rightThigh.backName, AppStrings.Health.Body.Human.Back.rightThigh)
        XCTAssertEqual(Body.leftThigh.backName, AppStrings.Health.Body.Human.Back.leftThigh)
        XCTAssertEqual(Body.rightKnee.backName, AppStrings.Health.Body.Human.Back.rightKnee)
        XCTAssertEqual(Body.leftKnee.backName, AppStrings.Health.Body.Human.Back.leftKnee)
        XCTAssertEqual(Body.rightShin.backName, AppStrings.Health.Body.Human.Back.rightShin)
        XCTAssertEqual(Body.leftShin.backName, AppStrings.Health.Body.Human.Back.leftShin)
        XCTAssertEqual(Body.rightFoot.backName, AppStrings.Health.Body.Human.Back.rightFoot)
        XCTAssertEqual(Body.leftFoot.backName, AppStrings.Health.Body.Human.Back.leftFoot)
        XCTAssertEqual(Body.rightArm.backName, AppStrings.Health.Body.Human.Back.rightArm)
        XCTAssertEqual(Body.leftArm.backName, AppStrings.Health.Body.Human.Back.leftArm)
        XCTAssertEqual(Body.rightHand.backName, AppStrings.Health.Body.Human.Back.rightHand)
        XCTAssertEqual(Body.leftHand.backName, AppStrings.Health.Body.Human.Back.leftHand)
    }
    
    func testHeight() {
        XCTAssertEqual(Body.head.height, 0.18)
        XCTAssertEqual(Body.rightShoulder.height, 0.07)
        XCTAssertEqual(Body.leftShoulder.height, 0.07)
        XCTAssertEqual(Body.rightChest.height, 0.11)
        XCTAssertEqual(Body.leftChest.height, 0.11)
        XCTAssertEqual(Body.stomach.height, 0.15)
        XCTAssertEqual(Body.hips.height, 0.12)
        XCTAssertEqual(Body.rightThigh.height, 0.09)
        XCTAssertEqual(Body.leftThigh.height, 0.09)
        XCTAssertEqual(Body.rightKnee.height, 0.1)
        XCTAssertEqual(Body.leftKnee.height, 0.1)
        XCTAssertEqual(Body.rightShin.height, 0.12)
        XCTAssertEqual(Body.leftShin.height, 0.12)
        XCTAssertEqual(Body.rightFoot.height, 0.08)
        XCTAssertEqual(Body.leftFoot.height, 0.08)
        XCTAssertEqual(Body.rightArm.height, 0.0)
        XCTAssertEqual(Body.leftArm.height, 0.0)
        XCTAssertEqual(Body.rightHand.height, 0.0)
        XCTAssertEqual(Body.leftHand.height, 0.0)
    }
    
    func testWidth() {
        XCTAssertEqual(Body.head.width, 0.67)
        XCTAssertEqual(Body.rightShoulder.width, 0.90)
        XCTAssertEqual(Body.leftShoulder.width, 0.90)
        XCTAssertEqual(Body.rightChest.width, 0.5)
        XCTAssertEqual(Body.leftChest.width, 0.5)
        XCTAssertEqual(Body.stomach.width, 0.5)
        XCTAssertEqual(Body.hips.width, 0.5)
        XCTAssertEqual(Body.rightThigh.width, 0.5)
        XCTAssertEqual(Body.leftThigh.width, 0.5)
        XCTAssertEqual(Body.rightKnee.width, 0.5)
        XCTAssertEqual(Body.leftKnee.width, 0.5)
        XCTAssertEqual(Body.rightShin.width, 0.5)
        XCTAssertEqual(Body.leftShin.width, 0.5)
        XCTAssertEqual(Body.rightFoot.width, 0.7)
        XCTAssertEqual(Body.leftFoot.width, 0.7)
        XCTAssertEqual(Body.rightArm.width, 0.0)
        XCTAssertEqual(Body.leftArm.width, 0.0)
        XCTAssertEqual(Body.rightHand.width, 0.0)
        XCTAssertEqual(Body.leftHand.width, 0.0)
    }
}
