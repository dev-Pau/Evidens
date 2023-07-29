//
//  Reference.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/4/23.
//

import UIKit

/// The model for a Reference. 
struct Reference {
    var option: ReferenceKind
    var referenceText: String
    
    /// Creates an instance of a Reference with option and referenceText properties.
    ///
    /// - Parameters:
    ///   - option: The option for the instance.
    ///   - referenceText: The reference text for the instance.
    init(option: ReferenceKind, referenceText: String) {
        self.option = option
        self.referenceText = referenceText
    }
    
    /// Creates an instance of a Reference using a dictionary containing the reference data and the reference kind.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the reference data.
    ///   - kind: The `ReferenceKind` specifying the type of reference.
    init(dictionary: [String: Any], kind: ReferenceKind) {
        self.referenceText = dictionary["content"] as? String ?? ""
        self.option = kind
    }
}
