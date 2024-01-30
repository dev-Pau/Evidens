//
//  ContentTimestampLabel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/23.
//

import UIKit

class ContentTimestampView: UIView {
    
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
            timeTextView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            timeTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
            
            /*
            timeTextView.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeTextView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
             */
        ])
        
        timeTextView.delegate = self
    }
    
    func set(timestamp: String) {
        let font = UIFont.addFont(size: 16, scaleStyle: .title2, weight: .regular)
      
        let aString = NSMutableAttributedString(string: timestamp)
        aString.addAttributes([.font: font, .foregroundColor: UIColor.secondaryLabel], range: (aString.string as NSString).range(of: timestamp))
        
        timeTextView.attributedText = aString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ContentTimestampView: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}
