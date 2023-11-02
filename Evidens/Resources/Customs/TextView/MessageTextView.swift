//
//  MessageInputTextView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/5/23.
//

import UIKit

class MessageTextView: UITextView {
    
    private var maxHeight: CGFloat = 170
    
    var placeholder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    /// Initializes a new instance of the view with the specified frame and text container.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - textContainer: The text container object that defines the area in which the text is displayed.
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        verticalScrollIndicatorInsets.right = 40
        textContainerInset.right = 40
        
        font = UIFont.systemFont(ofSize: 17)
        isScrollEnabled = false
        clipsToBounds = true
        layer.cornerRadius = 16
        layer.borderColor = separatorColor.cgColor
        layer.borderWidth = 0.4
        tintColor = primaryColor
        
        addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholder.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            placeholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        if size.height == UIView.noIntrinsicMetric {
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
    
    @objc func handleTextDidChange() {
        invalidateIntrinsicContentSize()
        placeholder.isHidden = !text.isEmpty
    }
}
