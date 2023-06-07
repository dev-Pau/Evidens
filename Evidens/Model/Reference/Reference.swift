//
//  Reference.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/4/23.
//

import UIKit

/// The model for a Reference. 
struct Reference {
    var option: ReferenceOptions
    var referenceText: String
    
    /// Creates an instance of a Reference with option and referenceText properties.
    ///
    /// - Parameters:
    ///   - option: The option for the instance.
    ///   - referenceText: The reference text for the instance.
    init(option: ReferenceOptions, referenceText: String) {
        self.option = option
        self.referenceText = referenceText
    }
}
