//
//  UITextView+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/6/23.
//

import UIKit

extension UITextView {
    
    var isTextTruncated: Bool {
        var isTruncating = false
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: Int.max)) { _, _, _, glyphRange, stop in
            let truncatedRange = self.layoutManager.truncatedGlyphRange(inLineFragmentForGlyphAt: glyphRange.lowerBound)
            if truncatedRange.location != NSNotFound {
                isTruncating = true
                stop.pointee = true
            }
        }
        
        if isTruncating == false {
            let glyphRange = layoutManager.glyphRange(for: textContainer)
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            
            isTruncating = characterRange.upperBound < text.utf16.count
        }
        
        return isTruncating
    }

    func hashtags() -> [String] {
        let nsText: NSString = self.text as NSString
        let nsTxt = nsText.replacingOccurrences(of: "\\n", with: " ")
        let nsString = nsTxt.replacingOccurrences(of: "\n", with: " ")
        let paragraphStyle = self.typingAttributes[NSAttributedString.Key.paragraphStyle] ?? NSMutableParagraphStyle()
        let attrs = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.font!.pointSize),
            NSAttributedString.Key.foregroundColor: UIColor.label as Any
        ] as [NSAttributedString.Key : Any]
        
        let attrString = NSMutableAttributedString(string: nsText as String, attributes: attrs)
        
        var hashtags: [String] = []
        
        do {
            let hashtagRegexString = "[#]\\w\\S*\\b"
            let hashtagRegex = try NSRegularExpression(pattern: hashtagRegexString, options: [])
            
            let hashtagMatches = hashtagRegex.matches(in: nsString, options: [], range: NSRange(location: 0, length: nsString.utf16.count))
            
            for match in hashtagMatches {
                guard let range = Range(match.range, in: nsString) else { continue }
                let hash = nsString[range]
                let hashString = String(hash).dropFirst()
                let matchRange: NSRange = NSRange(range, in: nsString)
                attrString.addAttribute(NSAttributedString.Key.link, value: "hash:\(hashString)", range: matchRange)
                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: self.font!.pointSize), range: matchRange)
                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.link, range: matchRange)
                
                hashtags.append(String(hashString))
            }
        } catch {
            print(error)
        }
        
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.link
        ]
        self.linkTextAttributes = linkAttributes
        
        self.attributedText = attrString
        
        return hashtags
        
    }
    
    
    func getLastLineText(_ totalLines: Int) -> String? {
        let layoutManager = self.layoutManager
        let textContainer = self.textContainer
        
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        
        // Calculate the line index for the fourth line
        let lineIndex = totalLines  // Fourth line index (zero-based)
        
        var visibleLineCount = 0
        var visibleLineText = ""
        
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, usedRect, _, glyphRange, _ in
            // Check if the line is visible
            if usedRect.intersects(self.bounds) {
                // Check if it is the fourth visible line
                if visibleLineCount == lineIndex {
                    let lineCharacterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
                    
                    let lineTextRange: NSRange
                    if lineCharacterRange.location + lineCharacterRange.length <= self.text.utf16.count {
                        lineTextRange = lineCharacterRange
                    } else {
                        lineTextRange = NSRange(location: lineCharacterRange.location, length: self.text.utf16.count - lineCharacterRange.location)
                    }
                    
                    visibleLineText = (self.text as NSString).substring(with: lineTextRange)
                }
                
                visibleLineCount += 1
            }
        }
        
        return visibleLineText
    }
    
    
    func getFirstLinesText(_ lines: Int) -> String? {
        let layoutManager = self.layoutManager
        let textContainer = self.textContainer
        
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        
        // Calculate the line index for the x line
        let lineIndex = lines - 1  // Third line index (zero-based)
        
        var visibleLineCount = 0
        var visibleLineText = ""
        
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, usedRect, _, glyphRange, _ in
            // Check if the line is visible
            if usedRect.intersects(self.bounds) {
                // Check if it is within the first three visible lines
                if visibleLineCount <= lineIndex {
                    let lineCharacterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
                    
                    let lineTextRange: NSRange
                    if lineCharacterRange.location + lineCharacterRange.length <= self.text.utf16.count {
                        lineTextRange = lineCharacterRange
                    } else {
                        lineTextRange = NSRange(location: lineCharacterRange.location, length: self.text.utf16.count - lineCharacterRange.location)
                    }
                    
                    let lineText = (self.text as NSString).substring(with: lineTextRange)
                    visibleLineText += lineText + "\n"
                } else {
                    // Exit the enumeration once we have processed the first three visible lines
                    return
                }
                
                visibleLineCount += 1
            }
        }
        
        // Remove trailing newline character, if any
        if visibleLineText.last == "\n" {
            visibleLineText.removeLast()
        }
        
        return visibleLineText
    }
    
    
    func getTextThatFitsContainerWidth(width: CGFloat) -> String? {
        let layoutManager = self.layoutManager
        let textContainer = self.textContainer
        
        // Set the width constraint for the text container
        textContainer.size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        
        // Retrieve the character range that fits within the given container width
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        // Extract the text that fits within the container width
        let fittedText = (self.text as NSString).substring(with: characterRange)
        
        return fittedText
    }
}
