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
        font = .systemFont(ofSize: 14, weight: .regular)
        backgroundColor = .clear
        adjustsFontForContentSizeCategory = false
        textContainer.maximumNumberOfLines = 4
        textContainer.lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .label
    }
}
