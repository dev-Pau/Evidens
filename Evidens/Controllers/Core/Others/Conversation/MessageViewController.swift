//
//  ChatViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/22.
//

import UIKit
//import MessageKit
//import InputBarAccessoryView
import SDWebImage
//import AVFoundation
//import AVKit
import PhotosUI

/*
protocol ChatViewControllerDelegate: AnyObject {
    func didDeleteConversation(withUser user: User, withConversationId id: String)
}
 */

private let messageTextCellReuseIdentifier = "MessageTextCellReuseIdentifier"

protocol MessageViewControllerDelegate: AnyObject {
    func didCreateNewConversation(_ conversation: Conversation)
    func deleteConversation(_ conversation: Conversation)
    func didReadAllMessages(for conversation: Conversation)
    func didSendMessage(_ message: Message, for conversation: Conversation)
}


class MessageViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    weak var delegate: MessageViewControllerDelegate?
    private var conversation: Conversation
    private var user: User?
    private var message: Message?
    private var preview: Bool = false
    private var newConversation: Bool?
    private var messages = [Message]()
    private let messageInputAccessoryView = MessageInputAccessoryView()
    
    override var inputAccessoryView: UIView? {
        get {
            return messageInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return preview ? false : true
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureView()
        getMessages()
    }
    
    /// Initializes a new instance of the MessageViewController with a conversation and a preview flag.
    ///
    /// - Parameters:
    ///   - conversation: The conversation to display.
    ///   - preview: A flag indicating wether the view controller is in preview mode.
    init(conversation: Conversation, user: User? = nil, preview: Bool? = false) {
        self.conversation = conversation
        self.user = user
        self.preview = preview ?? false
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        super.init(collectionViewLayout: layout)
    }
    
    init(conversation: Conversation, message: Message, preview: Bool? = false) {
        self.conversation = conversation
        self.message = message
        self.preview = preview ?? false
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = conversation.name
    }
    
    private func configureCollectionView() {
        collectionView.register(MessageTextCell.self, forCellWithReuseIdentifier: messageTextCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .interactive
    }
    
    private func configureView() {
        view.addSubview(collectionView)
        messageInputAccessoryView.messageDelegate = self
    }
    
    private func getMessages() {
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
            messages = DataService.shared.getMessages(for: conversation)
            if !messages.isEmpty {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let strongSelf = self else { return }
                    let lastIndexPath = IndexPath(item: strongSelf.messages.count - 1, section: 0)
                    strongSelf.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                    if strongSelf.preview == false {
                        DataService.shared.readMessages(conversation: strongSelf.conversation)
                        strongSelf.delegate?.didReadAllMessages(for: strongSelf.conversation)
                    }
                }
            }
            
            DataService.shared.conversationExists(for: conversation.userId) { [weak self] exists in
                guard let strongSelf = self else { return }
                strongSelf.newConversation = !exists
            }
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
}

extension MessageViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageTextCellReuseIdentifier, for: indexPath) as! MessageTextCell
        cell.viewModel = MessageViewModel(message: messages[indexPath.row])
        cell.display = lastSenderMessage(indexOfMessage: indexPath)
        cell.displayTimestamp(firstMessageOfTheDay(indexOfMessage: indexPath))
        cell.delegate = self
        if message?.messageId == messages[indexPath.row].messageId {
            cell.highlight()
        }
        
        return cell
        /*
        switch message.kind {
            
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageTextCellReuseIdentifier, for: indexPath) as! MessageTextCell
            cell.viewModel = MessageViewModel(message: messages[indexPath.row])
            cell.displayTimestamp(firstMessageOfTheDay(indexOfMessage: indexPath))
            return cell
        case .photo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageImageCellReuseIdentifier, for: indexPath) as! MessagePhotoCell
            cell.viewModel = MessageViewModel(message: messages[indexPath.row])
            cell.displayTimestamp(firstMessageOfTheDay(indexOfMessage: indexPath))
            return cell
        }
         */
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
        
        let type: MessageKind = message.containsEmojiOnly ? .emoji : .text
        
        let message = Message(text: message, sentDate: Date(), messageId: UUID().uuidString, isRead: true, senderId: uid, kind: type, phase: .sending)

        messages.append(message)
        
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [IndexPath(item: messages.isEmpty ? 0 : messages.count - 1, section: 0)])
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.scrollToItem(at: IndexPath(item: strongSelf.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
        
        if newConversation {

            self.newConversation?.toggle()
            
            guard let user = user else { return }
            FileGateway.shared.saveImage(url: user.profileImageUrl, userId: conversation.userId) { [weak self] url in
                guard let strongSelf = self else { return }
                
                strongSelf.conversation.finishCreatingConversation(image: url?.absoluteString ?? nil , firstMessage: message)
                
                DataService.shared.save(conversation: strongSelf.conversation, latestMessage: message)
                strongSelf.delegate?.didCreateNewConversation(strongSelf.conversation)

                DatabaseManager.shared.createNewConversation(strongSelf.conversation, with: message) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error {
                        print(error.localizedDescription)
                    } else {
                        strongSelf.messages[0].updatePhase(.sent)
                        DataService.shared.edit(message: strongSelf.messages[0], set: MessagePhase.sent.rawValue, forKey: "phase")
                        DispatchQueue.main.async {
                            strongSelf.collectionView.reloadData()
                        }
                    }
                }
            }
            // Add Conversation to Core Data
            // Display Conversation on Screen
            
            // Create Conversation
            // Send Message
            // if everything goes fine, update stage of the latest message to send
            
        } else {
            delegate?.didSendMessage(message, for: conversation)
            DataService.shared.save(message: message, to: conversation)
            DatabaseManager.shared.sendMessage(to: conversation, with: message) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    print(error.localizedDescription)
                } else {
                    strongSelf.messages[strongSelf.messages.count - 1].updatePhase(.sent)
                    strongSelf.delegate?.didSendMessage(strongSelf.messages[strongSelf.messages.count - 1], for: strongSelf.conversation)
                    DataService.shared.edit(message: strongSelf.messages[strongSelf.messages.count - 1], set: MessagePhase.sent.rawValue, forKey: "phase")
                    DispatchQueue.main.async {
                        strongSelf.collectionView.reloadItems(at: [IndexPath(item: strongSelf.messages.count - 1, section: 0), IndexPath(item: strongSelf.messages.count - 2, section: 0)])
                    }
                }
            }
        }
    }
    
    func didTapAddMedia() {
        
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

/*
class ChatViewController: MessagesViewController {
    
    //MARK: - Properties
    
    weak var delegate: ChatViewControllerDelegate?
    
    private var senderPhotoUrl: URL?
    private var otherUserPhotoUrl: URL?
    private var user: User
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.timeZone = .current
        return formatter
    }()
    
    public let otherUserUid: String
    private var conversationId: String?
    private var creationDate: TimeInterval?
    public var isNewConversation = false

    private var chatImage: UIImageView!
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return nil }
        
        return Sender(userProfileImageUrl: "",
                      senderId: uid,
                      displayName: "Pau")
    }
    
    //MARK: - Lifecycle
    
    init(with user: User, id: String?, creationDate: TimeInterval?) {
        self.user = user
        self.otherUserUid = user.uid!
        self.conversationId = id
        self.creationDate = creationDate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(handleConversationMenu))
        
        let reportAction = UIAction(title: "Report \(user.firstName!)", image: UIImage(systemName: "flag", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!) { action in
            
            let reportPopup = METopPopupView(title: "\(self.user.firstName!) has been reported", image: "checkmark.circle.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
            return
        }
        
        let deleteAction = UIAction(title: "Delete Conversation", image: UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            self.displayMEDestructiveAlert(withTitle: "Delete conversation", withMessage: "This conversation will be deleted from your inbox. Other people in the conversation will still be able to see it.", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
                self.deleteConversationAlert(withUserFirstName: self.user.firstName!) {
                    if let conversationId = self.conversationId {
                        self.delegate?.didDeleteConversation(withUser: self.user, withConversationId: conversationId)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }
        
        let markAsUnreadAction = UIAction(title: "Mark as Unread", image: UIImage(systemName: "quote.bubble", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            if let conversationId = self.conversationId {
                DatabaseManager.shared.makeLastMessageStateToIsRead(conversationID: conversationId, isReadState: false)
            }
        }
        
        let menuBarButton = UIBarButtonItem(
            title: "Add",
            image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label),
            primaryAction: nil,
            menu: UIMenu(title: "", children: [reportAction, deleteAction, markAsUnreadAction])
        )
        
        self.navigationItem.rightBarButtonItem = menuBarButton
        
        let view = MENavigationBarChatView(user: user)
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        
       
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        showMessageTimestampOnSwipeLeft = true
        
        removeMessageAvatars()
        setupInputButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true) }
    }
    
   
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, withCreationDate: creationDate, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
                
                guard !messages.isEmpty else { return }
                self.messages = messages
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    DatabaseManager.shared.makeLastMessageStateToIsRead(conversationID: id, isReadState: true)
                    
                    if shouldScrollToBottom {
                        self.messagesCollectionView.scrollToLastItem()
                    }
                }
                
            case .failure(let error):
                print("Failed to get messages: \(error)")
                
            }
        })
    }
    
    //MARK: - Helpers
    
    private func setupInputButton() {
        let inputButton = InputBarButtonItem()
        inputButton.setSize(CGSize(width: 35, height: 35), animated: false)
        inputButton.setImage(UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor), for: .normal)
        inputButton.showsMenuAsPrimaryAction = true
       
        inputButton.onTouchUpInside { [weak self] _ in
            self?.messageInputBar.inputTextView.resignFirstResponder()
            self?.presentInputActionSheet()
        }
        
        messageInputBar.sendButton.setTitleColor(primaryColor, for: .normal)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([inputButton], forStack: .left, animated: false)
        messageInputBar.inputTextView.placeholder = "Message..."
        
    }
    

    private func presentInputActionSheet() {

        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library",
                                            style: .default,
                                            handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Video Library",
                                            style: .default,
                                            handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: { _ in
        }))
        
        present(actionSheet, animated: true)
         
    }
    
    private func removeMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        let incomingLabelAlignment = LabelAlignment(
            textAlignment: .left,
            textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
        let outgoingLabelAlignment = LabelAlignment(
            textAlignment: .right,
            textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
    
    func firstMessageOfTheDay(indexOfMessage: IndexPath) -> Bool {
        let messageDate = messages[indexOfMessage.section].sentDate
        guard indexOfMessage.section > 1 else { return true }
        let previouseMessageDate = messages[indexOfMessage.section - 1].sentDate
         
        let day = Calendar.current.component(.day, from: messageDate)
        let previouseDay = Calendar.current.component(.day, from: previouseMessageDate)
        if day == previouseDay {
            return false
        } else {
            return true
        }
    }
    
    //MARK: - Actions
    
    @objc func handleConversationMenu() {
        
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {

    func currentSender() -> SenderType {
        if let sender = selfSender { return sender }
        fatalError("Self sender is nil, email should be cached")
        return Sender(userProfileImageUrl: "", senderId: "1", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    
    //Configure the cell top label to display dates
    
    //Cell top label size
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            if firstMessageOfTheDay(indexOfMessage: indexPath) {
                return 18
            }
            return 0
        }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if firstMessageOfTheDay(indexOfMessage: indexPath) {
                    let topCellText = MessageKitDateFormatter.shared.string(from: message.sentDate)
                    let font = UIFont.boldSystemFont(ofSize: 10)
                    let color = UIColor.darkGray
                    
                    return NSAttributedString(string: topCellText, attributes: [.font: font, .foregroundColor: color])
                }
                
                return nil
    }
    
    //Configure bottom label size
    //func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //return isFromCurrentSender(message: message) ? 17 : 0
            
    //}
    

    


    //Configure the color of messages
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            //Our message that we've sent
            return primaryColor
        }
        //Other recipient in conversation
        return .quaternarySystemFill
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        if isNextMessageSameSender(at: indexPath) {
            return .bubble
        } else {
            let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            return .bubbleTail(corner, .pointedEdge)
        }
        
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        //if indexPath.section == messages.count - 1 { return true }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section + 1].sender.senderId
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    /*
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

            let sender = message.sender
            if sender.senderId == selfSender?.senderId {
                //Show our user profile image
                if let currentUserImageURL = self.senderPhotoUrl {
                    avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
                } else {
                    //Fetch url
                    guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
                    let path = "profile_images/\(uid)"
                    
                    StorageManager.downloadImageURL(for: path) { [weak self] result in
                        switch result {
                        case .success(let url):
                            self?.senderPhotoUrl = url
                            DispatchQueue.main.async {
                                avatarView.sd_setImage(with: url, completed: nil)
                            }
                        case .failure(let error):
                            print("\(error)")
                        }
                    }
                }
            } else {
                //Show other user profile image
                if let _ = self.otherUserPhotoUrl {
                    avatarView.sd_setImage(with: otherUserPhotoUrl, completed: nil)
                } else {
                    //Fetch url
                    let uid = self.otherUserUid
                    let path = "profile_images/\(uid)"
                    
                    StorageManager.downloadImageURL(for: path) { [weak self] result in
                        switch result {
                        case .success(let url):
                            self?.otherUserPhotoUrl = url
                            DispatchQueue.main.async {
                                avatarView.sd_setImage(with: url, completed: nil)
                            }
                        case .failure(let error):
                            print("\(error)")
                        }
                    }
                }
            }
     */
        
//    }

}

//MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            showLoadingView()
            let dataTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
                guard let self = self else { return }
                self.dismissLoadingView()
                if let data = data {
                    DispatchQueue.main.async {
                        #warning("Trobar la manera de no fer un push normal i que directament s'obri com a home amb zoom")
                        let vc = HomeImageViewController(image: [UIImage(data: data)!], imageCount: 1, index: 0)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            dataTask.resume()
            
            //chatImage.sd_setImage(with: imageUrl)
            //let vc = HomeImageViewController(image: [chatImage.image], imageCount: 1, index: 0)
            //self.navigationController?.pushViewController(vc, animated: true)
            
        case .video(let media):
            guard let videoUrl = media.url else { return }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}




extension ChatViewController: InputBarAccessoryViewDelegate {
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        guard let selfSender = self.selfSender, let messageId = createMessageId() else { return }
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        // send message
        if isNewConversation {
            //create conversation in database
            print("We send a message on a new conversation")
            DatabaseManager.shared.createNewConversation(withUid: otherUserUid, name: self.title ?? "User", firstMessage: message) { [weak self] dateOfCreation in
                if dateOfCreation != nil {
                    print("message sent on a new conversation")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.creationDate = dateOfCreation
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                } else {
                    print("failed to send message")
                }
            }
        } else {
            // Send a message on an existing conversation
            guard let conversationId = conversationId, let name = self.title else { return }
            
                DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserUid: otherUserUid, newMessage: message, completion: { dateOfCreation in
                    if dateOfCreation != nil {
                        // If we alreaady have a creation date set return
                        if self.creationDate != nil {
                            return
                        } else {
                            self.creationDate = dateOfCreation
                            self.listenForMessages(id: conversationId, shouldScrollToBottom: true)
                        }
                    } else {
                        print("failed to send")
                    }
                })
            
        }
        //Delete text bar upon sending a message
        messagesCollectionView.reloadData()
        inputBar.inputTextView.text = ""
    }
    
    private func createMessageId() -> String? {
        //date, otherUserUid, senderUid, randomInt
        guard let currentUserUid = UserDefaults.standard.value(forKey: "uid") else { return nil }
        let uuid = UUID().uuidString
        //let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = ("\(otherUserUid)_\(currentUserUid)_\(uuid)").replacingOccurrences(of: ".", with: "")
        print("Created message id: \(newIdentifier)")
        return newIdentifier
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let name = self.title,
              let selfSender = selfSender else { return }
        
        if let image = info[.editedImage] as? UIImage,
           let imageData = image.pngData() {
            //Image
            let fileName = "photo_messaage_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            //Upload image
            StorageManager.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let urlString):
                    print("Uploading message photo: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else { return }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    
                        DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserUid: strongSelf.otherUserUid, newMessage: message, completion: { dateOfCreation in
                            if dateOfCreation != nil {
                                // If we alreaady have a creation date set return
                                if strongSelf.creationDate != nil {
                                    return
                                } else {
                                    strongSelf.creationDate = dateOfCreation
                                    strongSelf.listenForMessages(id: conversationId, shouldScrollToBottom: true)
                                }
                            } else {
                                print("failed to send photo message")
                            }
                        })
                    
                case .failure(let error):
                    print("Failed to upload photo: \(error)")
                }
            })
        } else if let videoUrl = info[.mediaURL] as? URL {
            //Video
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            //Upload video
            StorageManager.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let urlString):
                    print("Uploading message video: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else { return }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    
                        DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserUid: strongSelf.otherUserUid, newMessage: message, completion: { dateOfCreation in
                            // Check if we sent the message
                            if dateOfCreation != nil {
                                // If we alreaady have a creation date set return
                                if strongSelf.creationDate != nil {
                                    return
                                } else {
                                    strongSelf.creationDate = dateOfCreation
                                    strongSelf.listenForMessages(id: conversationId, shouldScrollToBottom: true)
                                }
                            } else {
                                print("failed to send photo message")
                            }
                        })
                    

                case .failure(let error):
                    print("Failed to upload photo: \(error)")
                }
            })
        }
    }
}
*/
