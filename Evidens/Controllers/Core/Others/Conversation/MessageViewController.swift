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
    
    private var viewModel: PrimaryMessageViewModel
    
    weak var delegate: MessageViewControllerDelegate?
  
    private var viewHasPerformedSubviewLayoutAtLeastOnce = false
    
    private let messageInputAccessoryView = MessageInputAccessoryView()
    private var keyboardHidden: Bool = true
    private var keyboardHeight: CGFloat = 0.0
    private var didScrollToBottom: Bool = false
    
    private var firstKeyboardHeight: CGFloat = 0.0
    
    private var keyboardIsOpened: Bool = false
    
    override var inputAccessoryView: UIView? {
        get {
            return messageInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return viewHasPerformedSubviewLayoutAtLeastOnce
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewHasPerformedSubviewLayoutAtLeastOnce == false {
            viewHasPerformedSubviewLayoutAtLeastOnce = true
        }
    }

    /// Initializes a new instance of the MessageViewController with a conversation and a preview flag.
    ///
    /// - Parameters:
    ///   - conversation: The conversation to display.
    ///   - preview: A flag indicating wether the view controller is in preview mode.
    init(conversation: Conversation, user: User? = nil, preview: Bool? = false, presented: Bool? = false) {
        self.viewModel = PrimaryMessageViewModel(conversation: conversation, user: user, preview: preview, presented: presented)

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
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
        self.viewModel = PrimaryMessageViewModel(conversation: conversation, message: message, preview: preview)
       
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10)
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

        navigationItem.title = viewModel.conversation.name
        
        if viewModel.presented {
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
        viewModel.getPhase { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.messageInputAccessoryView.hasConnection(phase: strongSelf.viewModel.connection ?? .none)
        }
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
            
            keyboardHeight = convertedKeyboardFrame.size.height
 
            switch keyboardState {
                
            case .closed:
                
                if viewModel.firstTime {
                    keyboardState = .closed
                    viewModel.firstTime = false
                    UIView.animate(withDuration: duration) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.collectionView.contentOffset.y += convertedKeyboardFrame.height + strongSelf.messageInputAccessoryView.frame.size.height
                        strongSelf.view.layoutIfNeeded()
                    }
                    return
                }
                
                keyboardState = .opened
                
                UIView.animate(withDuration: duration) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.collectionView.contentOffset.y += convertedKeyboardFrame.height - strongSelf.messageInputAccessoryView.frame.size.height
                    strongSelf.view.layoutIfNeeded()
                }
                
            case .opened:
                if convertedKeyboardFrame.height > convertedBeginKeyboardFrame.height {
                    keyboardState = .emoji
                    collectionView.contentOffset.y += convertedKeyboardFrame.height - convertedBeginKeyboardFrame.height
                    view.layoutIfNeeded()
                }
            case .emoji:
                if convertedKeyboardFrame.height < convertedBeginKeyboardFrame.height {
                    keyboardState = .opened
                    collectionView.contentOffset.y -= (convertedBeginKeyboardFrame.height - convertedKeyboardFrame.height)
                    view.layoutIfNeeded()
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
        
        if let message = viewModel.message {
            viewModel.messages = DataService.shared.getMessages(for: viewModel.conversation, around: message)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let strongSelf = self else { return }
                if let index = strongSelf.viewModel.messages.firstIndex(where: { $0.messageId == message.messageId }) {
                    strongSelf.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: false)
                    DataService.shared.readMessages(conversation: strongSelf.viewModel.conversation)
                    strongSelf.delegate?.didReadAllMessages(for: strongSelf.viewModel.conversation)
                }
            }
        } else {
            if !viewModel.messages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let strongSelf = self else { return }
                    let lastIndexPath = IndexPath(item: strongSelf.viewModel.messages.count - 1, section: 0)
                    
                    let contentHeight = strongSelf.collectionView.contentSize.height
                    let collectionViewHeight = strongSelf.collectionView.bounds.size.height
                    let contentOffsetY = contentHeight - collectionViewHeight
                    
                    if contentOffsetY > strongSelf.collectionView.contentOffset.y - strongSelf.keyboardHeight {
                        strongSelf.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                    }

                    if strongSelf.viewModel.preview == false {
                        DataService.shared.readMessages(conversation: strongSelf.viewModel.conversation)
                        strongSelf.delegate?.didReadAllMessages(for: strongSelf.viewModel.conversation)
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                    }
                }
            }
            
            DataService.shared.conversationExists(for: viewModel.conversation.userId) { [weak self] exists in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.newConversation = !exists
            }
            
            observeConversation()
        }
    }
    
    private func deleteMessage(_ message: Message) {
        if let messageIndex = viewModel.messages.firstIndex(where: { $0.messageId == message.messageId }) {
            DataService.shared.delete(message: message)
            viewModel.messages.remove(at: messageIndex)
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [IndexPath(item: messageIndex, section: 0)])
            } completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                if strongSelf.viewModel.messages.isEmpty {
                    strongSelf.delegate?.deleteConversation(strongSelf.viewModel.conversation)
                }
            }
        }
    }
    
    private func observeConversation() {
        DatabaseManager.shared.observeConversation(conversation: viewModel.conversation) { [weak self] newMessage in
            guard let strongSelf = self else { return }
            // Add the new message
            strongSelf.viewModel.messages.append(newMessage)
            DispatchQueue.main.async {
                // Reload your collection view or update the display
                // For example, if you're using a collection view, you can call reloadData()
                strongSelf.collectionView.performBatchUpdates {
                    strongSelf.collectionView.insertItems(at: [IndexPath(item: strongSelf.viewModel.messages.count - 1, section: 0)])
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
                strongSelf.collectionView.reloadItems(at: [IndexPath(item: strongSelf.viewModel.messages.count - 1, section: 0), IndexPath(item: strongSelf.viewModel.messages.count - 2, section: 0)])
            }
            
            DataService.shared.save(message: message, to: strongSelf.viewModel.conversation)
            DataService.shared.readMessages(conversation: strongSelf.viewModel.conversation)
            strongSelf.delegate?.didReadConversation(strongSelf.viewModel.conversation, message: newMessage)
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard viewModel.message == nil else { return }

        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            fetchMoreMessages()
        }
    }
    
    private var initialLoad: Bool = true
    private var scrolledToBottom: Bool = false
    
    private func fetchMoreMessages() {
        guard let oldestMessage = viewModel.messages.first else { return }
        
        let olderMessages = DataService.shared.getMoreMessages(for: viewModel.conversation, from: oldestMessage.sentDate)
        viewModel.messages.insert(contentsOf: olderMessages, at: 0)
        
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
        return viewModel.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentMessage = viewModel.messages[indexPath.row]
        
        switch currentMessage.kind {
            
        case .text, .emoji:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageTextCellReuseIdentifier, for: indexPath) as! MessageTextCell
            cell.viewModel = MessageViewModel(message: currentMessage)
            cell.display = lastSenderMessage(indexOfMessage: indexPath)
            cell.displayTimestamp(firstMessageOfTheDay(indexOfMessage: indexPath))
            cell.displayTime(shouldDisplayTime(indexOfMessage: indexPath))
            cell.delegate = self
            if viewModel.message?.messageId == currentMessage.messageId {
                cell.highlight()
            }
            
            return cell
        }
    }
    
    func firstMessageOfTheDay(indexOfMessage: IndexPath) -> Bool {
        let messageDate = viewModel.messages[indexOfMessage.item].sentDate
        guard indexOfMessage.item > 0 else { return true }
        let previouseMessageDate = viewModel.messages[indexOfMessage.item - 1].sentDate
        
        let day = Calendar.current.component(.day, from: messageDate)
        let previouseDay = Calendar.current.component(.day, from: previouseMessageDate)
        if day == previouseDay {
            return false
        } else {
            return true
        }
    }
    
    func lastSenderMessage(indexOfMessage: IndexPath) -> Bool {
        if viewModel.messages.count - 1 == indexOfMessage.row {
            return true
        }
        let nextMessage = viewModel.messages[indexOfMessage.row + 1]

        if nextMessage.senderId != viewModel.messages[indexOfMessage.row].senderId || lastMessageOfDay(indexOfMessage: indexOfMessage)  {
            return true
        } else {
            return false
        }
    }
    
    func shouldDisplayTime(indexOfMessage: IndexPath) -> Bool {
        let currentMessage = viewModel.messages[indexOfMessage.item]
        guard indexOfMessage.row > 0 else { return true }
        
        if viewModel.messages.count - 1 == indexOfMessage.row {
            return true
        }
        
        let nextMessage = viewModel.messages[indexOfMessage.item + 1]
        
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
        let messageDate = viewModel.messages[indexOfMessage.item].sentDate
        let nextMessageIndex = indexOfMessage.item + 1
        
        guard nextMessageIndex < viewModel.messages.count else {
            return true
        }
        let nextMessageDate = viewModel.messages[nextMessageIndex].sentDate
        
        let currentDay = Calendar.current.component(.day, from: messageDate)
        let nextDay = Calendar.current.component(.day, from: nextMessageDate)
        
        return currentDay != nextDay
    }
}

extension MessageViewController: MessageInputAccessoryViewDelegate {
   
    func didSendMessage(message: String) {
        
        guard let newConversation = viewModel.newConversation, let uid = UserDefaults.standard.value(forKey: "uid") as? String, let connection = viewModel.connection, connection == .connected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
            return
        }

        let lines = message.components(separatedBy: .newlines)
        let trimmedLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let trimmedMessage = trimmedLines.joined(separator: "\n")

        let type: MessageKind = trimmedMessage.containsEmojiOnly ? .emoji : .text
        
        let message = Message(text: trimmedMessage, sentDate: Date().toUTCDate(), messageId: UUID().uuidString, isRead: true, senderId: uid, kind: type, phase: .sending)

        collectionView.performBatchUpdates {
            viewModel.messages.append(message)
            collectionView.insertItems(at: [IndexPath(item: viewModel.messages.count == 1 ? 0 : viewModel.messages.count - 1, section: 0)])
           
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
            
            viewModel.newConversation?.toggle()
            
            guard let user = viewModel.user else { return }
            FileGateway.shared.saveImage(url: user.profileUrl, userId: viewModel.conversation.userId) { [weak self] url in
                guard let strongSelf = self else { return }
                
                strongSelf.viewModel.conversation.finishCreatingConversation(image: url?.absoluteString ?? nil , firstMessage: message)
                
                DataService.shared.save(conversation: strongSelf.viewModel.conversation, latestMessage: message)
                strongSelf.delegate?.didCreateNewConversation(strongSelf.viewModel.conversation)
                
                DataService.shared.edit(message: strongSelf.viewModel.messages[0], set: MessagePhase.sent.rawValue, forKey: "phase")
                
                if strongSelf.viewModel.presented {
                    NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.loadConversations), object: nil)
                }
                
                DatabaseManager.shared.createNewConversation(strongSelf.viewModel.conversation, with: message) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let _ = error {
                        return
                    } else {
                        strongSelf.viewModel.messages[0].updatePhase(.sent)
                        
                        DispatchQueue.main.async {
                            strongSelf.collectionView.reloadData()
                        }
                    }
                }
            }
        } else {
            delegate?.didSendMessage(message, for: viewModel.conversation)
            DataService.shared.save(message: message, to: viewModel.conversation)
            
            DatabaseManager.shared.sendMessage(to: viewModel.conversation, with: message) { [weak self] error in
                guard let strongSelf = self else { return }
                if let _ = error {
                    return
                } else {
                    strongSelf.viewModel.messages[strongSelf.viewModel.messages.count - 1].updatePhase(.sent)
                    strongSelf.delegate?.didSendMessage(strongSelf.viewModel.messages[strongSelf.viewModel.messages.count - 1], for: strongSelf.viewModel.conversation)
                    DataService.shared.edit(message: strongSelf.viewModel.messages[strongSelf.viewModel.messages.count - 1], set: MessagePhase.sent.rawValue, forKey: "phase")
                    
                    if strongSelf.viewModel.presented {
                        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.loadConversations), object: nil)
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.collectionView.reloadItems(at: [IndexPath(item: strongSelf.viewModel.messages.count - 1, section: 0), IndexPath(item: strongSelf.viewModel.messages.count - 2, section: 0)])
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
