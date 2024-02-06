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
    func inputView(_ inputView: CommentInputAccessoryView, wantsToEditComment comment: String, forId id: String )
    @objc optional func textDidChange(_ inputView: CommentInputAccessoryView)
    @objc optional func textDidBeginEditing()
}

class CommentInputAccessoryView: UIView {
    
    //MARK: - Properties
    
    weak var accessoryViewDelegate: CommentInputAccessoryViewDelegate?
    private var bottomConstraint: NSLayoutConstraint!
    private(set) var commentId: String?
    
    let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        
        let font = UIFont.addFont(size: 17, scaleStyle: .title2, weight: .regular)
        tv.placeholderLabel.font = font
        tv.font = font
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
    
    private lazy var addCommentButton: UIButton = {
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
    
    private let saveChangesButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = .zero
        
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .zero
        configuration.baseForegroundColor = .label
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 13, scaleStyle: .title1, weight: .medium)
        configuration.attributedTitle = AttributedString(AppStrings.Global.cancel, attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
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
       
        let font = UIFont.addFont(size: 17, scaleStyle: .title2, weight: .regular)
        
        commentTextView.maxHeight = (commentTextView.font?.lineHeight ?? font.lineHeight) * 4
        addSubviews(commentTextView, addCommentButton, topView, saveChangesButton, cancelButton)

        bottomConstraint = saveChangesButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            commentTextView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            commentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            commentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentTextView.bottomAnchor.constraint(equalTo: saveChangesButton.topAnchor, constant: -6),

            bottomConstraint,
            saveChangesButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            cancelButton.centerYAnchor.constraint(equalTo: saveChangesButton.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: saveChangesButton.leadingAnchor, constant: -15),
            
            addCommentButton.trailingAnchor.constraint(equalTo: commentTextView.trailingAnchor, constant: -5),
            addCommentButton.centerYAnchor.constraint(equalTo: commentTextView.centerYAnchor),
            addCommentButton.heightAnchor.constraint(equalToConstant: 27),
            addCommentButton.widthAnchor.constraint(equalToConstant: 27),
            
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 0.4)
        ])

        saveChangesButton.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        saveChangesButton.isHidden = true
    }
    
    func set(placeholder: String) {
        commentTextView.placeholderText = placeholder
    }
    
    func set(edit: Bool, text: String? = nil, commentId: String? = nil) {
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 13, scaleStyle: .title1, weight: .semibold)
        saveChangesButton.configuration?.attributedTitle = edit ? AttributedString(AppStrings.Miscellaneous.save, attributes: container) : nil
        
        saveChangesButton.configuration?.contentInsets = edit ? NSDirectionalEdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10) : .zero
        cancelButton.configuration?.contentInsets = edit ? NSDirectionalEdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0) : .zero

        bottomConstraint.constant = edit ? -6 : 0
        saveChangesButton.isHidden = !edit
        cancelButton.isHidden = !edit
        addCommentButton.isHidden = edit

        self.commentId = commentId
        
        if edit {
            commentTextView.becomeFirstResponder()
            commentTextView.text = text
            commentTextView.handleTextDidChange()
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.layoutIfNeeded()
                strongSelf.accessoryViewDelegate?.textDidChange?(strongSelf)
            }
        } else {
            clearCommentTextView()
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.layoutIfNeeded()
                strongSelf.accessoryViewDelegate?.textDidChange?(strongSelf)
                strongSelf.commentTextView.resignFirstResponder()
            }
        }
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
    
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.layoutIfNeeded()
            strongSelf.accessoryViewDelegate?.textDidChange?(strongSelf)
            strongSelf.commentTextView.resignFirstResponder()
        }
    }
    
    @objc func handleCancel() {
        set(edit: false)
    }
    
    @objc func handleEdit() {
        guard let commentId else { return }
        accessoryViewDelegate?.inputView(self, wantsToEditComment: commentTextView.text, forId: commentId)
        set(edit: false)
    }
    
    func clearCommentTextView() {
        commentTextView.text = String()
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
        addCommentButton.isEnabled = false
        commentId = nil
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
        addCommentButton.isEnabled = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? false : true
        saveChangesButton.isEnabled = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? false : true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        accessoryViewDelegate?.textDidBeginEditing?()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
 
        if text.contains(UIPasteboard.general.string ?? "") {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.layoutIfNeeded()
                strongSelf.accessoryViewDelegate?.textDidChange?(strongSelf)
            }
        }
        
        return true
    }

}
