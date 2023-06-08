//
//  MessageInputAccessoryView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/5/23.
//

import UIKit

protocol MessageInputAccessoryViewDelegate: AnyObject {
    func didSendMessage(message: String)
    func didTapAddMedia()
}

class MessageInputAccessoryView: UIView {
    
    // MARK: - Properties
    
    weak var messageDelegate: MessageInputAccessoryViewDelegate?
    private let messageTextView = MessageTextView()
    
    private var messageTextViewLeadingAnchor: NSLayoutConstraint!

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.isEnabled = true
        button.configuration?.baseBackgroundColor = .systemGreen
        button.configuration?.image = UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.sizeToFit()
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.isEnabled = true
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.addTarget(self, action: #selector(handleAddMedia), for: .touchUpInside)
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    // MARK: - Lifecycle
    
    /// Initializes a new instance of the view with the specified frame.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the view, measured in points.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:  - Helpers
    
    private func configure() {
        messageTextView.placeholder.text = AppStrings.Placeholder.message
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = .flexibleHeight
        
        messageTextViewLeadingAnchor = messageTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 47)
        addSubviews(addButton, messageTextView, sendButton, topView)
        NSLayoutConstraint.activate([
            messageTextView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            //messageTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            messageTextViewLeadingAnchor,
            messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6),
            
            addButton.bottomAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: -5),
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            addButton.heightAnchor.constraint(equalToConstant: 27),
            addButton.widthAnchor.constraint(equalToConstant: 27),
            
            sendButton.trailingAnchor.constraint(equalTo: messageTextView.trailingAnchor, constant: -5),
            sendButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 27),
            sendButton.widthAnchor.constraint(equalToConstant: 27),
            
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        messageTextView.delegate = self
    }

    // MARK: - Actions
    
    
    @objc func handleSendMessage() {
        guard let text = messageTextView.text else { return }
        messageDelegate?.didSendMessage(message: text)
    }
    
    @objc func handleAddMedia() {
        messageDelegate?.didTapAddMedia()
    }
}

extension MessageInputAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        sendButton.isEnabled = text.isEmpty ? false : true
        addButton.isEnabled = text.isEmpty ? true : false
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            if text.isEmpty {
                strongSelf.messageTextViewLeadingAnchor.constant = 47
                strongSelf.addButton.alpha = 1
            } else {
                strongSelf.messageTextViewLeadingAnchor.constant = 10
                strongSelf.addButton.alpha = 0
            }
            strongSelf.layoutIfNeeded()
        }
    }
}
