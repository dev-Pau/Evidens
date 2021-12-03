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
        return iv
    }()
    
    private let commentTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add a comment..."
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.isScrollEnabled = false
        tv.clipsToBounds = true
        tv.layer.cornerRadius = 15
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 0.5
        tv.placeHolderShouldCenter = true
        return tv
    }()
    
    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //To overlap the main UI
        backgroundColor = .white
        
        autoresizingMask = .flexibleHeight
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8 ,paddingLeft: 8)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(postButton)
        postButton.centerY(inView: profileImageView)
        postButton.anchor(right: rightAnchor, paddingRight: 8)
        postButton.setDimensions(height:  50, width: 50)
        
        addSubview(commentTextView)
        commentTextView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8, constant: 0)
        commentTextView.anchor(right: postButton.leftAnchor, paddingRight: 8)
        
        let divider = UIView()
        divider.backgroundColor = .lightGray
        addSubview(divider)
        divider.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Auto figuring the size based on the dimensions on the view components inside the view
    //override var intrinsicContentSize: CGSize {
    //    return .zero
    //}
    
    //MARK: - Actions
    
    @objc func didTapPostButton() {
        delegate?.inputView(self, wantsToUploadComment: commentTextView.text)
    }
    
    func clearCommentTextView() {
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
    }
    
    //MARK: - Helpers
    
}
