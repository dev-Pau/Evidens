//
//  MessageInputAccessoryView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/5/23.
//

import UIKit

protocol MessageInputAccessoryViewDelegate: AnyObject {
    func didSendMessage(message: String)
}

class MessageInputAccessoryView: UIView {
    
    // MARK: - Properties
    
    weak var messageDelegate: MessageInputAccessoryViewDelegate?
    private let messageTextView = MessageTextView()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.isEnabled = true
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.upArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: 23, height: 23))
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.sizeToFit()
        return button
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let connectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .largeTitle, weight: .regular)
        label.textColor = primaryGray
        label.text = AppStrings.Error.message
        return label
    }()
    
    private let infoImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.circleInfoFill)?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray)
        iv.contentMode = .scaleAspectFill
        return iv
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
        backgroundColor = .systemBackground
        messageTextView.placeholder.text = AppStrings.Placeholder.message
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = .flexibleHeight

        addSubviews(connectionLabel, infoImage, messageTextView, sendButton, topView)
        NSLayoutConstraint.activate([
           
            infoImage.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            infoImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoImage.heightAnchor.constraint(equalToConstant: 20),
            infoImage.widthAnchor.constraint(equalToConstant: 20),
            
            connectionLabel.topAnchor.constraint(equalTo: infoImage.topAnchor),
            connectionLabel.leadingAnchor.constraint(equalTo: infoImage.trailingAnchor, constant: 5),
            connectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            messageTextView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            messageTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6),

            sendButton.trailingAnchor.constraint(equalTo: messageTextView.trailingAnchor, constant: -5),
            sendButton.centerYAnchor.constraint(equalTo: messageTextView.centerYAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 27),
            sendButton.widthAnchor.constraint(equalToConstant: 27),
            
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        messageTextView.delegate = self
        
        infoImage.isHidden = true
        connectionLabel.isHidden = true
        messageTextView.isHidden = true
        sendButton.isHidden = true
    }
    
    func resignTextViewFirstResponder() {
        messageTextView.resignFirstResponder()
    }
    
    func hasConnection(phase: ConnectPhase) {

        switch phase {
        case .connected:
            messageTextView.isHidden = false
            sendButton.isHidden = false
        case .pending, .received, .rejected, .withdraw, .unconnect, .none:
            infoImage.isHidden = false
            connectionLabel.isHidden = false
        }
    }

    // MARK: - Actions
    
    @objc func handleSendMessage() {
        guard let text = messageTextView.text else { return }
        messageDelegate?.didSendMessage(message: text)
        messageTextView.text = String()
        messageTextView.text = nil
        messageTextView.placeholder.isHidden = false
        messageTextView.invalidateIntrinsicContentSize()
        sendButton.isEnabled = false
    }
}

extension MessageInputAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        sendButton.isEnabled = text.isEmpty ? false : true
    }
}
