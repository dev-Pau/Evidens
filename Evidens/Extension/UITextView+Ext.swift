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
        guard let font = self.font else { return [] }
        let nsText: NSString = self.text as NSString
        let nsTxt = nsText.replacingOccurrences(of: "\\n", with: " ")
        let nsString = nsTxt.replacingOccurrences(of: "\n", with: " ")
        let paragraphStyle = self.typingAttributes[NSAttributedString.Key.paragraphStyle] ?? NSMutableParagraphStyle()
        let attrs = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
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
                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: font.pointSize), range: matchRange)
                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.link, range: matchRange)
                
                hashtags.append(String(hashString))
            }
            
            
            let pattern = #"(https?:\/\/)?[\w\-~]+(\.[\w\-~]+)+(\/[\w\-~@:%]*)*(#[\w\-]*)?(\?[^\s]*)?"#
            let patternRegex = try NSRegularExpression(pattern: pattern, options: [])
            
            let patternMatches = patternRegex.matches(in: nsString, options: [], range: NSRange(location: 0, length: nsString.utf16.count))
            
            for match in patternMatches {
                guard let range = Range(match.range, in: nsString) else { continue }
                let hash = nsString[range]
                let hashString = String(hash)
                
                var newHashString = hashString
                if !hashString.hasPrefix("https://") && !hashString.hasPrefix("http://") {
                    newHashString = "https://" + hashString
                }
                
                if let url = URL(string: newHashString), let host = url.host {
                    
                    let trimUrl = host.split(separator: ".")
                    
                    if let tld = trimUrl.last, String(tld).uppercased().isDomainExtension() {
                        let matchRange: NSRange = NSRange(range, in: nsString)
                        attrString.addAttribute(NSAttributedString.Key.link, value: newHashString, range: matchRange)
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: font.pointSize), range: matchRange)
                        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.link, range: matchRange)
                    }
                }
            }
        } catch {
            print(error)
        }
        
        let selectedRange = self.selectedRange
        
        self.attributedText = attrString
        
        self.selectedRange = selectedRange

        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.link
        ]
        
        self.linkTextAttributes = linkAttributes
        
        self.attributedText = attrString
        
        return hashtags
    }
    
    func processText() -> ([String], [String]) {
        let nsText: NSString = self.text as NSString
        let nsTxt = nsText.replacingOccurrences(of: "\\n", with: " ")
        let nsString = nsTxt.replacingOccurrences(of: "\n", with: " ")
        let paragraphStyle = self.typingAttributes[NSAttributedString.Key.paragraphStyle] ?? NSMutableParagraphStyle()
        let attrs = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.font?.pointSize ?? 15),
            NSAttributedString.Key.foregroundColor: UIColor.label as Any
        ] as [NSAttributedString.Key : Any]
        
        let attrString = NSMutableAttributedString(string: nsText as String, attributes: attrs)
        
        var hashtags: [String] = []
        var links: [String] = []
        
        do {
            let hashtagRegexString = "[#]\\w\\S*\\b"
            let hashtagRegex = try NSRegularExpression(pattern: hashtagRegexString, options: [])
            
            let hashtagMatches = hashtagRegex.matches(in: nsString, options: [], range: NSRange(location: 0, length: nsString.utf16.count))
            
            for match in hashtagMatches {
                guard let range = Range(match.range, in: nsString) else { continue }
                let hash = nsString[range]
                let hashString = String(hash).dropFirst()
                let matchRange: NSRange = NSRange(range, in: nsString)
                //attrString.addAttribute(NSAttributedString.Key.link, value: "hash:\(hashString)", range: matchRange)
                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: self.font?.pointSize ?? 15), range: matchRange)
                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.link, range: matchRange)
                
                hashtags.append(String(hashString))
            }
            
            let pattern = #"(https?:\/\/)?[\w\-~]+(\.[\w\-~]+)+(\/[\w\-~@:%]*)*(#[\w\-]*)?(\?[^\s]*)?"#
            let patternRegex = try NSRegularExpression(pattern: pattern, options: [])
            
            let patternMatches = patternRegex.matches(in: nsString, options: [], range: NSRange(location: 0, length: nsString.utf16.count))
            
            for match in patternMatches {
                guard let range = Range(match.range, in: nsString) else { continue }
                let hash = nsString[range]
                let hashString = String(hash)
                
                var newHashString = hashString
                if !hashString.hasPrefix("https://") && !hashString.hasPrefix("http://") {
                    newHashString = "https://" + hashString
                }

                if let url = URL(string: newHashString), let host = url.host {
                    
                    let trimUrl = host.split(separator: ".")
                    
                    if let tld = trimUrl.last, String(tld).uppercased().isDomainExtension() {
                        let matchRange: NSRange = NSRange(range, in: nsString)
                        //attrString.addAttribute(NSAttributedString.Key.link, value: "hash:\(hashString)", range: matchRange)
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: self.font?.pointSize ?? 15), range: matchRange)
                        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.link, range: matchRange)
                        
                        links.append(String(newHashString))
                    }
                }
            }
        } catch {
            print(error)
        }
        
        let selectedRange = self.selectedRange
        
        self.attributedText = attrString
        
        self.selectedRange = selectedRange
        /*
         let linkAttributes: [NSAttributedString.Key : Any] = [
         NSAttributedString.Key.foregroundColor: UIColor.link
         ]
         
         //self.linkTextAttributes = linkAttributes
         */
        self.attributedText = attrString
        
        return (hashtags, links)
    }
    

    func addHashtags(withColor color: UIColor) {
        let nsText: NSString = self.text as NSString
        let nsTxt = nsText.replacingOccurrences(of: "\\n", with: " ")
        let nsString = nsTxt.replacingOccurrences(of: "\n", with: " ")
        let paragraphStyle = self.typingAttributes[NSAttributedString.Key.paragraphStyle] ?? NSMutableParagraphStyle()
        let attrs = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.font?.pointSize ?? 15),
            NSAttributedString.Key.foregroundColor: textColor ?? UIColor.label as Any
        ] as [NSAttributedString.Key : Any]
        
        let attrString = NSMutableAttributedString(string: nsText as String, attributes: attrs)
        
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
                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: self.font?.pointSize ?? 15), range: matchRange)
                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: matchRange)
            }
        } catch {
            print(error)
        }
        
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: color
        ]
        self.linkTextAttributes = linkAttributes
        
        self.attributedText = attrString
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

        if visibleLineText.last == "\n" {
            visibleLineText.removeLast()
        }
        
        return visibleLineText
    }
    
    
    func getTextThatFitsContainerWidth(width: CGFloat) -> String? {
        let layoutManager = self.layoutManager
        let textContainer = self.textContainer
        
        textContainer.size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        let fittedText = (self.text as NSString).substring(with: characterRange)
        
        return fittedText
    }
    
    func removeLastEmptyLine() {
        guard var text = self.text, text.isEmpty == false else {
            return
        }
        
        // Get the range of the last line
        if let range = text.rangeOfCharacter(from: .newlines, options: .backwards) {
            let lastLine = text[range.upperBound...]
            
            // Check if the last line contains only spaces or is empty
            if lastLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Remove the last line
                text.removeSubrange(range)
                self.text = text
            }
        }
    }
}
