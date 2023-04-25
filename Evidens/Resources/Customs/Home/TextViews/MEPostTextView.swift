//
//  MEPostTextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class MEPostTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        textContainerInset = UIEdgeInsets.zero
        contentInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = .zero
        textColor = .label
        isSelectable = true
        isUserInteractionEnabled = true
        isEditable = false
        delaysContentTouches = false
        isScrollEnabled = false
        font = .systemFont(ofSize: 16, weight: .regular)
        textContainer.maximumNumberOfLines = 4
        textContainer.lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Get the touch location
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        print("KEKL")
        // Check if the tap is within the desired range
        let linkRange = self.attributedText.string.range(of: "EVIDENCE")
        let layoutManager = self.layoutManager
        let charIndex = layoutManager.characterIndex(for: touchLocation, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if let range = linkRange {
            print("KEKL2")
            let nsRange = NSRange(range, in: self.attributedText.string)
                    if NSLocationInRange(charIndex, nsRange) {
                        // Handle the link tap here
                        // Push the view controller
                        print("inside")
                    } else {
                        print("outside")
                    }
        }
       
    }
     */
}
