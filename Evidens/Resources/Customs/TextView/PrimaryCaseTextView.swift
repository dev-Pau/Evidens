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
        isSelectable = false
        isUserInteractionEnabled = true
        isEditable = false
        delaysContentTouches = false
        isScrollEnabled = false
        
        font = UIFont.addFont(size: 14.0, scaleStyle: .largeTitle, weight: .regular)
        
        backgroundColor = .clear
        textContainer.maximumNumberOfLines = 4
        textContainer.lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .label
    }
}
