//
//  String+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/6/23.
//

import Foundation

extension String {
    
    /// Checks if the string contains only emoji characters.
    ///
    /// - Returns: A boolean value indicating whether the string contains only emoji.
    var containsEmojiOnly: Bool {
        return unicodeScalars.allSatisfy { scalar in
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                0x1F680...0x1F6FF, // Transport and Map
                0x2600...0x26FF,   // Misc symbols
                0x2700...0x27BF,   // Dingbats
                0xFE00...0xFE0F:   // Variation Selectors
                return true
            default:
                return false
            }
        }
    }
}
    
