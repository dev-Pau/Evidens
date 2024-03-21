//
//  UserProfileAboutCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/22.
//

import UIKit

protocol UserProfileAboutCellDelegate: AnyObject {
    func wantsToSeeHashtag(_ hashtag: String)
    func showUrl(_ url: String)
}

class UserProfileAboutCell: UICollectionViewCell {
    
    weak var delegate: UserProfileAboutCellDelegate?
    
    private var aboutTextView = SecondaryTextView()
    
    private var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        addSubviews(aboutTextView, separator)
        
        NSLayoutConstraint.activate([
            aboutTextView.topAnchor.constraint(equalTo: topAnchor),
            aboutTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            aboutTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            aboutTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        aboutTextView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTextViewTap(_:)))
        aboutTextView.addGestureRecognizer(gestureRecognizer)
        aboutTextView.textContainer.maximumNumberOfLines = 0
    }
    
    func set(body: String) {
        aboutTextView.text = body
        _ = aboutTextView.hashtags()
    }
    
    @objc func handleTextViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: aboutTextView)
        let position = aboutTextView.closestPosition(to: location)!

        if let range = aboutTextView.tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: .layout(.left)) {
            let startIndex = aboutTextView.offset(from: aboutTextView.beginningOfDocument, to: range.start)
           
            let attributes = aboutTextView.attributedText.attributes(at: startIndex, effectiveRange: nil)
            
            if attributes.keys.contains(.link), let hashtag = attributes[.link] as? String {
                if hashtag.hasPrefix("hash:") {
                    delegate?.wantsToSeeHashtag(hashtag)
                } else {
                    delegate?.showUrl(hashtag)
                }
            } else {

            }
        }
    }
}

extension UserProfileAboutCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}
