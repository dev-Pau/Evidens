//
//  String+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/6/23.
//

import UIKit

/// An extension of String.
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
    
    /// Checks if the email format is valid.
    var emailIsValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    /// Localizes the given string key.
    /// - Parameters:
    ///   - key: The key to localize.
    /// - Returns: The localized string.
    func localized(key: String) -> String {
        return NSLocalizedString(key,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: self,
                                 comment: self
        )
    }
    
    /// Processes the web link in the string.
    /// - Returns: The processed web link.
    func processWebLink() -> String {
        
        let trimmedText = self.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedText.isEmpty else {
            return ""
        }
        
        let pattern = #"(https?:\/\/)?[\w\-~]+(\.[\w\-~]+)+(\/[\w\-~@:%]*)*(#[\w\-]*)?(\?[^\s]*)?"#
        
        let linkPred = NSPredicate(format:"SELF MATCHES %@", pattern)
        
        if linkPred.evaluate(with: trimmedText) {
            if !trimmedText.hasPrefix("https://") && !trimmedText.hasPrefix("http://") {
                return "https://" + trimmedText
            } else {
                return trimmedText
            }
        } else {
            return self
        }
    }
    
    /// Checks if the string is a valid domain extension.
    /// - Returns: A boolean indicating whether the string is a valid domain extension.
    func isDomainExtension() -> Bool {
        guard let fileURL = Bundle.main.url(forResource: "tlds", withExtension: "json") else {
            return false
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]]
            return jsonArray?.contains(where: { $0["tld"] == self }) ?? false
        } catch {
            return false
        }
    }
}



