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
                0xFE00...0xFE0F,   // Variation Selectors
                0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                0x1F1E6...0x1F1FF, // Regional Indicator Symbols
                0x1F910...0x1F96B, // Emoticons (Additional)
                0x1F980...0x1F991, // Food and Drink Symbols
                0x1F9C0...0x1F9C0, // Face with Monocle Emoji
                0x1F9E0...0x1F9FF: // Faces (Additional)
                return true
            default:
                return false
            }
        }
    }
}

