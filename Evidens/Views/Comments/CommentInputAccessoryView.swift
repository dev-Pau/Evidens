//
//  CommentInputAccessoryView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/11/21.
//

import UIKit
import SDWebImage

protocol CommentInputAccessoryViewDelegate: AnyObject {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String)
}

class CommentInputAccessoryView: UIView {
    
    //MARK: - Properties
    
    weak var delegate: CommentInputAccessoryViewDelegate?

    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.placeholderText = "Share your thoughts here..."
        tv.placeholderLabel.font = .systemFont(ofSize: 13, weight: .regular)
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.isScrollEnabled = false
        tv.clipsToBounds = true
        tv.layer.cornerRadius = 16
        tv.layer.borderColor = lightGrayColor.cgColor
        tv.layer.borderWidth = 1
        tv.isScrollEnabled = false
        tv.tintColor = primaryColor
        tv.placeHolderShouldCenter = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Post", attributes: container)
        button.isEnabled = false
        button.configuration?.baseForegroundColor = primaryColor
        button.configuration?.baseBackgroundColor = .black
        button.configuration?.titleAlignment = .trailing
        button.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = lightColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    //MARK: - Lifecycle
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        translatesAutoresizingMaskIntoConstraints = false
        
        autoresizingMask = .flexibleHeight
        
        commentTextView.delegate = self
        
        commentTextView.maxHeight = 120
        
        addSubviews(profileImageView, postButton, commentTextView, topView)
        
        NSLayoutConstraint.activate([
            
            commentTextView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            commentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            commentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70),
            commentTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            
            profileImageView.centerYAnchor.constraint(equalTo: commentTextView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            
            postButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            postButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            //postButton.widthAnchor.constraint(equalToConstant: 80),
            //postButton.heightAnchor.constraint(equalToConstant: 50),
            
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 1)

        ])
        
        profileImageView.layer.cornerRadius = 40 / 2
        guard let uid = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String else { return }
        profileImageView.sd_setImage(with: URL(string: uid))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    //MARK: - Actions
    
    @objc func didTapPostButton() {
        delegate?.inputView(self, wantsToUploadComment: commentTextView.text)
    }
    
    func clearCommentTextView() {
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
        postButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
            return CGSize.zero
    }
}

extension CommentInputAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        postButton.isEnabled = commentTextView.text.isEmpty ? false : true
    }
}
