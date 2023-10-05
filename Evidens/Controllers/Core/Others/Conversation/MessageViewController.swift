//
//  ChatViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/22.
//

import UIKit
import SDWebImage
import PhotosUI

private let messageTextCellReuseIdentifier = "MessageTextCellReuseIdentifier"
private let messagePhotoCellReuseIdentifier = "MessagePhotoCellReuseIdentifier"

protocol MessageViewControllerDelegate: AnyObject {
    func didCreateNewConversation(_ conversation: Conversation)
    func deleteConversation(_ conversation: Conversation)
    func didReadAllMessages(for conversation: Conversation)
    func didSendMessage(_ message: Message, for conversation: Conversation)
    func didReadConversation(_ conversation: Conversation, message: Message)
}


class MessageViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    weak var delegate: MessageViewControllerDelegate?
    private var conversation: Conversation
    
    private var user: User?
    private var message: Message?
    
    private var preview: Bool = false
    private var presented: Bool = false

    private var newConversation: Bool?
    
    private var messages = [Message]()

    private let messageInputAccessoryView = MessageInputAccessoryView()
    private var keyboardHidden: Bool = true
    private var keyboardHeight: CGFloat = 0.0
    private var didScrollToBottom: Bool = false
    
    private var firstKeyboardHeight: CGFloat = 0.0
    
    private var keyboardIsOpened: Bool = false
    
    private lazy var userImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(named: AppStrings.Assets.profile)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    
    override var inputAccessoryView: UIView? {
        get {
            return messageInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return preview ? false : true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureObservers()
        configureCollectionView()
        configureView()
        getMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)

    }

    /// Initializes a new instance of the MessageViewController with a conversation and a preview flag.
    ///
    /// - Parameters:
    ///   - conversation: The conversation to display.
    ///   - preview: A flag indicating wether the view controller is in preview mode.
    init(conversation: Conversation, user: User? = nil, preview: Bool? = false, presented: Bool? = false) {
        self.conversation = conversation
        self.user = user
        self.preview = preview ?? false
        self.presented = presented ?? false
        
        self.messages = DataService.shared.getMessages(for: conversation)

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        super.init(collectionViewLayout: layout)
    }
    
    /// Initializes a new instance of the MessageViewController with a conversation and a message to display.
    ///
    /// - Parameters:
    ///   - conversation: The conversation to display.
    ///   - message: The message to display.
    ///   - preview: A flag indicating whether the view controller is in preview mode.
    init(conversation: Conversation, message: Message, preview: Bool? = false) {
        self.conversation = conversation
        self.message = message
        self.preview = preview ?? false
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        super.init(collectionViewLayout: layout)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        
        userImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView.layer.cornerRadius = 30 / 2
        
        navigationItem.titleView = userImageView
        
        if let user = user, let image = user.profileUrl {
            userImageView.sd_setImage(with: URL(string: image))
        } else {
            if let imagePath = conversation.image, let url = URL(string: imagePath) {
                userImageView.sd_setImage(with: url)
            } else {
                userImageView.image = UIImage(named: AppStrings.Assets.profile)
            }
        }
        
        if presented {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
            navigationItem.leftBarButtonItem?.tintColor = primaryColor
        }
    }
    
    private func configureCollectionView() {
        collectionView.register(MessageTextCell.self, forCellWithReuseIdentifier: messageTextCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    private func configureView() {
        view.addSubview(collectionView)
        messageInputAccessoryView.messageDelegate = self
    }
    
    private func configureObservers() {
        keyboardHeight = messageInputAccessoryView.frame.size.height

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)

    }
    
    
    private var isShowingEmoji: Bool = false
    
    private var firstTime: Bool = true

    private var previousKeyboardNotification: NSNotification.Name = UIResponder.keyboardDidChangeFrameNotification
    private var keyboardState: KeyboardState = .closed
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
        let beginKeyboardFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else {
            return
        }
        

        let convertedKeyboardFrame = view.convert(keyboardFrame, from: view.window)
        let convertedBeginKeyboardFrame = view.convert(beginKeyboardFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillChangeFrameNotification {
            if firstTime {
                keyboardState = .closed
                firstTime = false
                return
            }
            
            keyboardHeight = convertedKeyboardFrame.size.height
            
            switch keyboardState {
                
            case .closed:
                keyboardState = .opened
                UIView.animate(withDuration: duration) {
                    self.collectionView.contentOffset.y += convertedKeyboardFrame.height - self.messageInputAccessoryView.frame.size.height
                    self.view.layoutIfNeeded()
                }
            case .opened:
                if convertedKeyboardFrame.height > convertedBeginKeyboardFrame.height {
                    keyboardState = .emoji
                    self.collectionView.contentOffset.y += convertedKeyboardFrame.height - convertedBeginKeyboardFrame.height
                    self.view.layoutIfNeeded()
                }
            case .emoji:
                if convertedKeyboardFrame.height < convertedBeginKeyboardFrame.height {
                    keyboardState = .opened
                    self.collectionView.contentOffset.y -= (convertedBeginKeyboardFrame.height - convertedKeyboardFrame.height)
                    self.view.layoutIfNeeded()
                    
                } else {
                    keyboardState = .closed
                }
            case .blocking:
                keyboardState = .closed
                keyboardHeight = messageInputAccessoryView.frame.size.height
            }
        }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            keyboardState = .blocking
        }
    }

    private func getMessages() {
        keyboardHeight = messageInputAccessoryView.frame.size.height
        
        if let message {
            messages = DataService.shared.getMessages(for: conversation, around: message)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let strongSelf = self else { return }
                if let index = strongSelf.messages.firstIndex(where: { $0.messageId == message.messageId }) {
                    strongSelf.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: false)
                    DataService.shared.readMessages(conversation: strongSelf.conversation)
                    strongSelf.delegate?.didReadAllMessages(for: strongSelf.conversation)
                }
            }
        } else {
            if !messages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let strongSelf = self else { return }
                    let lastIndexPath = IndexPath(item: strongSelf.messages.count - 1, section: 0)
                    
                    let contentHeight = strongSelf.collectionView.contentSize.height
                    let collectionViewHeight = strongSelf.collectionView.bounds.size.height
                    let contentOffsetY = contentHeight - collectionViewHeight
                    
                    if contentOffsetY > strongSelf.collectionView.contentOffset.y - strongSelf.keyboardHeight {
                        strongSelf.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)

                    }

                    if strongSelf.preview == false {
                        DataService.shared.readMessages(conversation: strongSelf.conversation)
                        strongSelf.delegate?.didReadAllMessages(for: strongSelf.conversation)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                    }
                }
            }
            
            DataService.shared.conversationExists(for: conversation.userId) { [weak self] exists in
                guard let strongSelf = self else { return }
                strongSelf.newConversation = !exists
            }
            
            observeConversation()
        }
    }
    
    private func deleteMessage(_ message: Message) {
        if let messageIndex = messages.firstIndex(where: { $0.messageId == message.messageId }) {
            DataService.shared.delete(message: message)
            messages.remove(at: messageIndex)
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [IndexPath(item: messageIndex, section: 0)])
            } completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                if strongSelf.messages.isEmpty {
                    strongSelf.delegate?.deleteConversation(strongSelf.conversation)
                }
            }
        }
    }
    
    private func observeConversation() {
        DatabaseManager.shared.observeConversation(conversation: conversation) { [weak self] newMessage in
            guard let strongSelf = self else { return }
            // Add the new message
            strongSelf.messages.append(newMessage)
            DispatchQueue.main.async {
                // Reload your collection view or update the display
                // For example, if you're using a collection view, you can call reloadData()
                strongSelf.collectionView.performBatchUpdates {
                    strongSelf.collectionView.insertItems(at: [IndexPath(item: strongSelf.messages.count - 1, section: 0)])
                } completion: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    DispatchQueue.main.async {
                        let contentHeight = strongSelf.collectionView.contentSize.height
                        let collectionViewHeight = strongSelf.collectionView.bounds.size.height
                        let contentOffsetY = contentHeight - collectionViewHeight
                        
                        if contentOffsetY > strongSelf.collectionView.contentOffset.y - strongSelf.keyboardHeight {
                            // Content is not fully visible, scroll to the bottom
                            strongSelf.collectionView.setContentOffset(CGPoint(x: 0, y: contentOffsetY + strongSelf.keyboardHeight), animated: true)
                        }
                    }
                }
            }
            
            var message = newMessage
            message.updatePhase(.read)
            
            DispatchQueue.main.async {
                strongSelf.collectionView.reloadItems(at: [IndexPath(item: strongSelf.messages.count - 1, section: 0), IndexPath(item: strongSelf.messages.count - 2, section: 0)])
            }
            
            DataService.shared.save(message: message, to: strongSelf.conversation)
            DataService.shared.readMessages(conversation: strongSelf.conversation)
            strongSelf.delegate?.didReadConversation(strongSelf.conversation, message: newMessage)
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard message == nil else { return }

        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            fetchMoreMessages()
        }
    }
    
    private var initialLoad: Bool = true
    private var scrolledToBottom: Bool = false
    
    private func fetchMoreMessages() {
        guard let oldestMessage = messages.first else { return }
        
        let olderMessages = DataService.shared.getMoreMessages(for: conversation, from: oldestMessage.sentDate)
        messages.insert(contentsOf: olderMessages, at: 0)
        
        var newIndexPaths = [IndexPath]()
        olderMessages.enumerated().forEach { index, post in
            newIndexPaths.append(IndexPath(item: index, section: 0))
            if newIndexPaths.count == olderMessages.count {
                collectionView.isScrollEnabled = false
                collectionView.performBatchUpdates {
                    collectionView.isScrollEnabled = false
                    collectionView.insertItems(at: newIndexPaths)
                    var totalHeight: CGFloat = 0.0
                    for indexPath in newIndexPaths {
                        if let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) {
                            totalHeight += layoutAttributes.frame.height
                        }
                    }
                    let contentHeight = collectionView.contentSize.height + totalHeight
                    collectionView.contentSize.height = contentHeight
                     
                } completion: { _ in
                    self.collectionView.isScrollEnabled = true

                }
                
                DispatchQueue.main.async {
                    
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension MessageViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentMessage = messages[indexPath.row]
        
        switch currentMessage.kind {
            
        case .text, .emoji:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageTextCellReuseIdentifier, for: indexPath) as! MessageTextCell
            cell.viewModel = MessageViewModel(message: currentMessage)
            cell.display = lastSenderMessage(indexOfMessage: indexPath)
            cell.displayTimestamp(firstMessageOfTheDay(indexOfMessage: indexPath))
            cell.displayTime(shouldDisplayTime(indexOfMessage: indexPath))
            cell.delegate = self
            if message?.messageId == currentMessage.messageId {
                cell.highlight()
            }
            
            return cell
        }
    }
    
    func firstMessageOfTheDay(indexOfMessage: IndexPath) -> Bool {
        let messageDate = messages[indexOfMessage.item].sentDate
        guard indexOfMessage.item > 0 else { return true }
        let previouseMessageDate = messages[indexOfMessage.item - 1].sentDate
        
        let day = Calendar.current.component(.day, from: messageDate)
        let previouseDay = Calendar.current.component(.day, from: previouseMessageDate)
        if day == previouseDay {
            return false
        } else {
            return true
        }
    }
    
    func lastSenderMessage(indexOfMessage: IndexPath) -> Bool {
        if messages.count - 1 == indexOfMessage.row {
            return true
        }
        let nextMessage = messages[indexOfMessage.row + 1]

        if nextMessage.senderId != messages[indexOfMessage.row].senderId || lastMessageOfDay(indexOfMessage: indexOfMessage)  {
            return true
        } else {
            return false
        }
    }
    
    func shouldDisplayTime(indexOfMessage: IndexPath) -> Bool {
        let currentMessage = messages[indexOfMessage.item]
        guard indexOfMessage.row > 0 else { return true }
        
        if messages.count - 1 == indexOfMessage.row {
            return true
        }
        
        let nextMessage = messages[indexOfMessage.item + 1]
        
        let messageDate = currentMessage.sentDate
        let nextMessageDate = nextMessage.sentDate
        
        let day = Calendar.current.component(.day, from: messageDate)
        let nextDay = Calendar.current.component(.day, from: nextMessageDate)
        
        if day != nextDay {
            return true
        }
        
        // Check if current message and next message have different sender IDs
        if currentMessage.senderId != nextMessage.senderId {
            return true
        }
        
        // Check if the current message state is not .failed or .sending
        if currentMessage.phase == .failed || currentMessage.phase == .sending {
            return true
        }
        
        // Check if current message and next message have different hour or minute
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: messageDate)
        let minute = calendar.component(.minute, from: messageDate)
        let nextHour = calendar.component(.hour, from: nextMessageDate)
        let nextMinute = calendar.component(.minute, from: nextMessageDate)
        
        if hour != nextHour || minute != nextMinute {
            return true
        }
        
        return false
    }
    
    func lastMessageOfDay(indexOfMessage: IndexPath) -> Bool {
        let messageDate = messages[indexOfMessage.item].sentDate
        let nextMessageIndex = indexOfMessage.item + 1
        
        guard nextMessageIndex < messages.count else {
            return true
        }
        let nextMessageDate = messages[nextMessageIndex].sentDate
        
        let currentDay = Calendar.current.component(.day, from: messageDate)
        let nextDay = Calendar.current.component(.day, from: nextMessageDate)
        
        return currentDay != nextDay
    }
}

extension MessageViewController: MessageInputAccessoryViewDelegate {
   
    func didSendMessage(message: String) {
        guard let newConversation = newConversation, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        let lines = message.components(separatedBy: .newlines)
        let trimmedLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let trimmedMessage = trimmedLines.joined(separator: "\n")

        let type: MessageKind = trimmedMessage.containsEmojiOnly ? .emoji : .text
        
        let message = Message(text: trimmedMessage, sentDate: Date().toUTCDate(), messageId: UUID().uuidString, isRead: true, senderId: uid, kind: type, phase: .sending)

        collectionView.performBatchUpdates {
            messages.append(message)
            collectionView.insertItems(at: [IndexPath(item: messages.count == 1 ? 0 : messages.count - 1, section: 0)])
           
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }

            DispatchQueue.main.async {
                let contentHeight = strongSelf.collectionView.contentSize.height
                let collectionViewHeight = strongSelf.collectionView.bounds.size.height
                let contentOffsetY = contentHeight - collectionViewHeight
                
                if contentOffsetY > strongSelf.collectionView.contentOffset.y - strongSelf.keyboardHeight {
                    // Content is not fully visible, scroll to the bottom
                    strongSelf.collectionView.setContentOffset(CGPoint(x: 0, y: contentOffsetY + strongSelf.keyboardHeight), animated: true)
                }
            }
        }
        
        if newConversation {
            
            self.newConversation?.toggle()
            
            guard let user = user else { return }
            FileGateway.shared.saveImage(url: user.profileUrl, userId: conversation.userId) { [weak self] url in
                guard let strongSelf = self else { return }
                
                strongSelf.conversation.finishCreatingConversation(image: url?.absoluteString ?? nil , firstMessage: message)
                
                DataService.shared.save(conversation: strongSelf.conversation, latestMessage: message)
                strongSelf.delegate?.didCreateNewConversation(strongSelf.conversation)
                
                DataService.shared.edit(message: strongSelf.messages[0], set: MessagePhase.sent.rawValue, forKey: "phase")
                
                if strongSelf.presented {
                    NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.loadConversations), object: nil)
                }
                
                DatabaseManager.shared.createNewConversation(strongSelf.conversation, with: message) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let _ = error {
                        return
                    } else {
                        strongSelf.messages[0].updatePhase(.sent)
                        
                        DispatchQueue.main.async {
                            strongSelf.collectionView.reloadData()
                        }
                    }
                }
            }
        } else {
            delegate?.didSendMessage(message, for: conversation)
            DataService.shared.save(message: message, to: conversation)
            
            DatabaseManager.shared.sendMessage(to: conversation, with: message) { [weak self] error in
                guard let strongSelf = self else { return }
                if let _ = error {
                    return
                } else {
                    strongSelf.messages[strongSelf.messages.count - 1].updatePhase(.sent)
                    strongSelf.delegate?.didSendMessage(strongSelf.messages[strongSelf.messages.count - 1], for: strongSelf.conversation)
                    DataService.shared.edit(message: strongSelf.messages[strongSelf.messages.count - 1], set: MessagePhase.sent.rawValue, forKey: "phase")
                    
                    if strongSelf.presented {
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.loadConversations), object: nil)
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.collectionView.reloadItems(at: [IndexPath(item: strongSelf.messages.count - 1, section: 0), IndexPath(item: strongSelf.messages.count - 2, section: 0)])
                    }
                }
            }
        }
    }
}

extension MessageViewController: MessageCellDelegate {
    func didTapMenuOption(message: Message, _ option: MessageMenu) {
        switch option {
        case .copy:
            break
        case .share:
            break
        case .delete:
            deleteMessage(message)
        case .resend:
            break
        }
    }
}
