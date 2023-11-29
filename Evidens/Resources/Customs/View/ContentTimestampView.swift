//
//  ContentTimestampLabel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/23.
//

import UIKit

protocol ContentTimestampViewDelegate: AnyObject {
    func didTapEvidence()
}

class ContentTimestampView: UIView {
    
    weak var delegate: ContentTimestampViewDelegate?
    
    private var timeTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = .zero
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = .zero
        return tv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(timeTextView, separatorView)
        NSLayoutConstraint.activate([
            timeTextView.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        timeTextView.delegate = self
    }
    
    func set(timestamp: String) {
        
        let regularFont = UIFont.preferredFont(forTextStyle: .callout)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold.rawValue
            ]
        ])
        
        let boldFont = UIFont(descriptor: heavyFontDescriptor, size: 0)
        
        
        let aString = NSMutableAttributedString(string: timestamp)
        aString.addAttributes([.font: regularFont, .foregroundColor: UIColor.secondaryLabel], range: (aString.string as NSString).range(of: timestamp))
        
        aString.addAttributes([.font: boldFont, .foregroundColor: UIColor.label, .link: NSAttributedString.Key("presentReference")], range: (aString.string as NSString).range(of: AppStrings.Miscellaneous.evidence))
        
        timeTextView.attributedText = aString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ContentTimestampView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "presentReference" {
            delegate?.didTapEvidence()
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}
