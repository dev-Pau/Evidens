//
//  MEPostTextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/4/23.
//

import UIKit

class SecondaryTextView: UITextView {
    
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
        isSelectable = false
        isUserInteractionEnabled = true
        isEditable = false
        delaysContentTouches = false
        isScrollEnabled = false
        
        font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)

        backgroundColor = .clear
        textContainer.maximumNumberOfLines = 6
        textContainer.lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureAsExpanded() {
        textContainerInset = UIEdgeInsets.zero
        contentInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = .zero
        textColor = .label
        isSelectable = true
        isUserInteractionEnabled = true
        isEditable = false
        delaysContentTouches = false
        isScrollEnabled = false
        font = UIFont.addFont(size: 17, scaleStyle: .title2, weight: .regular)
        backgroundColor = .clear
        textContainer.maximumNumberOfLines = 0        
        translatesAutoresizingMaskIntoConstraints = false
    }
}
