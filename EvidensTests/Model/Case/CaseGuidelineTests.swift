//
//  CaseGuidelineTests.swift
//  EvidensTests
//
//  Created by Pau Fernández Solà on 13/12/23.
//

import XCTest
@testable import Evidens

final class CaseGuidelineTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    enum CaseGuideline: Int, CaseIterable {
        
        case classify, form, stage, submit
        
        var title: String {
            switch self {
                
            case .classify: return AppStrings.Guidelines.Case.classify
            case .form: return AppStrings.Guidelines.Case.form
            case .stage: return AppStrings.Guidelines.Case.stage
            case .submit: return AppStrings.Guidelines.Case.submit
            }
        }
        
        var content: String {
            switch self {
                
            case .classify: return AppStrings.Guidelines.Case.classifyContent
            case .form: return AppStrings.Guidelines.Case.formContent
            case .stage: return AppStrings.Guidelines.Case.stageContent
            case .submit: return AppStrings.Guidelines.Case.submitContent
            }
        }
    }
}
