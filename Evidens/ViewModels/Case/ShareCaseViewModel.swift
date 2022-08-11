//
//  ShareCaseViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/8/22.
//

import UIKit

protocol ShareContentViewModel {
    func updateForm()
}

protocol ShareViewModel {
    var caseIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
}

struct ShareCaseViewModel: ShareViewModel {

    var title: String?
    var description: String?
    var numberOfSpecialities: Int?
    var numberOfDetails: Int?
    var stageSelected: Bool?
    var isFirstTime: Bool = true
    
    var hasTitle: Bool {
        return title?.isEmpty == false
    }
    
    var hasDescription: Bool {
        return description?.isEmpty == false
    }
    
    var hasNumberOfSpecialities: Bool {
        guard let numberOfSpecialities = numberOfSpecialities else { return false }
        return numberOfSpecialities > 0 ? true : false
    }
    
    var hasNumberOfDetails: Bool {
        guard let numberOfDetails = numberOfDetails else { return false }
        return numberOfDetails > 0 ? true : false
    }
    
    var hasStageSelected: Bool {
        guard let stageSelected = stageSelected else { return false }
        return stageSelected == true ? true : false
    }
    
    var caseIsValid: Bool {
        if hasTitle && hasDescription && hasNumberOfSpecialities && hasNumberOfDetails && hasStageSelected {
            return true
        } else {
            return false
        }
    }
    
    var showPrivacyMenu: Bool {
        return isFirstTime ? true : false
    }
    
    var buttonBackgroundColor: UIColor {
        return caseIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
}
