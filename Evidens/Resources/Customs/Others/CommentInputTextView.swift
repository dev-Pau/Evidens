//
//  CommentInputTextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/7/22.
//

import UIKit

class CommentInputTextView: UITextView {
    
    //MARK: - Properties
    var maxHeight: CGFloat = 0.0
    
    var placeholderText: String? {
        didSet { placeholderLabel.text = placeholderText }
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var placeHolderShouldCenter = true {
        didSet {
            if placeHolderShouldCenter {
                placeholderLabel.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 5)
                placeholderLabel.centerY(inView: self)
            } else {
                placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 7, paddingLeft: 5)
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubviews(placeholderLabel)
        verticalScrollIndicatorInsets.right = 40
        textContainerInset.right = 40
        
        //Observer on textDidChange to update placeholder
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    
    override var intrinsicContentSize: CGSize {
            var size = super.intrinsicContentSize
           
            if size.height == UIView.noIntrinsicMetric {
                // force layout
                layoutManager.glyphRange(for: textContainer)
                size.height = layoutManager.usedRect(for: textContainer).height + textContainerInset.top + textContainerInset.bottom
            }
            
            if maxHeight > 0.0 && size.height > maxHeight {
                size.height = maxHeight
                
                if !isScrollEnabled {
                    isScrollEnabled = true
                }
            } else if isScrollEnabled {
                isScrollEnabled = false
            }
            
            return size
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func handleTextDidChange() {

        invalidateIntrinsicContentSize()
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    
}

