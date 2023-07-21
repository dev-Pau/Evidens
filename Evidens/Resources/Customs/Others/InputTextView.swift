//
//  InputTextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit

class InputTextView: UITextView {
    
    //MARK: - Properties
    
    var placeholderText: String? {
        didSet { placeholderLabel.text = placeholderText }
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var placeHolderShouldCenter = true {
        didSet {
            if placeHolderShouldCenter {
                placeholderLabel.anchor(left: leftAnchor, right: rightAnchor)
                placeholderLabel.centerY(inView: self)
            } else {
                NSLayoutConstraint.activate([
                    placeholderLabel.topAnchor.constraint(equalTo: topAnchor),
                    placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                    placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
                ])
            }
        }
    }

    //MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
      
        //Observer on textDidChange to update placeholder
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func handleTextDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    
}
