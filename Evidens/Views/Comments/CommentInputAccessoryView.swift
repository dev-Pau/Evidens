//
//  CommentInputAccessoryView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/11/21.
//

import UIKit
import SDWebImage

@objc protocol CommentInputAccessoryViewDelegate: AnyObject {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String)
    @objc optional func textDidChange(_ inputView: CommentInputAccessoryView)
    @objc optional func textDidBeginEditing()
}

class CommentInputAccessoryView: UIView {
    
    //MARK: - Properties
    
    weak var accessoryViewDelegate: CommentInputAccessoryViewDelegate?

    let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.isScrollEnabled = false
        tv.clipsToBounds = true
        tv.layer.cornerRadius = 16
        tv.layer.borderColor = separatorColor.cgColor
        tv.layer.borderWidth = 0.4
        tv.isScrollEnabled = false
        tv.tintColor = primaryColor
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var postRoundedButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.isEnabled = false
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.upArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    //MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        translatesAutoresizingMaskIntoConstraints = false
        
        autoresizingMask = .flexibleHeight
        
        commentTextView.delegate = self
        
        //commentTextView.maxHeight = 170
        commentTextView.maxHeight = (commentTextView.font?.lineHeight ?? UIFont.systemFont(ofSize: 17).lineHeight) * 4
        addSubviews(commentTextView, postRoundedButton, topView)
        
        NSLayoutConstraint.activate([
            
            commentTextView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            commentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6),

            postRoundedButton.trailingAnchor.constraint(equalTo: commentTextView.trailingAnchor, constant: -5),
            postRoundedButton.centerYAnchor.constraint(equalTo: commentTextView.centerYAnchor),
            postRoundedButton.heightAnchor.constraint(equalToConstant: 27),
            postRoundedButton.widthAnchor.constraint(equalToConstant: 27),
            
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func set(placeholder: String) {
        commentTextView.placeholderText = placeholder
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 commentTextView.layer.borderColor = separatorColor.cgColor
             }
         }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    //MARK: - Actions
    
    @objc func didTapPostButton() {
        accessoryViewDelegate?.inputView(self, wantsToUploadComment: commentTextView.text)
        clearCommentTextView()
    }
    
    func clearCommentTextView() {
        commentTextView.text = String()
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
        postRoundedButton.isEnabled = false
        commentTextView.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
            return CGSize.zero
    }
}

extension CommentInputAccessoryView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard let phase = UserDefaults.getPhase(), phase == .verified else {
            ContentManager.shared.permissionAlert(kind: .comment)
            return false
        }

        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        accessoryViewDelegate?.textDidChange?(self)
        postRoundedButton.isEnabled = commentTextView.text.isEmpty ? false : true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        accessoryViewDelegate?.textDidBeginEditing?()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
    }
}
