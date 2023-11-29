//
//  PrimaryCaseTextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/23.
//

import UIKit

class PrimaryCaseTextView: UITextView {
    
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
        isSelectable = true
        isUserInteractionEnabled = true
        isEditable = false
        delaysContentTouches = false
        isScrollEnabled = false
        let customFontSize: CGFloat = 14.0
        let fontMetrics = UIFontMetrics(forTextStyle: .footnote)
        let scaledFontSize = fontMetrics.scaledValue(for: customFontSize)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
        backgroundColor = .clear
        textContainer.maximumNumberOfLines = 4
        textContainer.lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .label
    }
}
