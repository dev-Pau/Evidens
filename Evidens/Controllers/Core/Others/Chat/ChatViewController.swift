//
//  ChatViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit


class ChatViewController: MessagesViewController {
    
    //MARK: - Properties
    
    private var senderPhotoUrl: URL?
    private var otherUserPhotoUrl: URL?
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.timeZone = .current
        return formatter
    }()
    
    public let otherUserUid: String
    private var conversationId: String?
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
    
    init(with uid: String, id: String?) {
        self.otherUserUid = uid
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
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
        let view = MENavigationBarChatView(fullName: "Gerard Font")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId { listenForMessages(id: conversationId, shouldScrollToBottom: true) }
    }
    
   
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("CASE SUCCESS")
                guard !messages.isEmpty else { return }
                self?.messages = messages
                print(messages)
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
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
        inputButton.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.sendButton.setTitleColor(primaryColor, for: .normal)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([inputButton], forStack: .left, animated: false)
        
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
        
        
        actionSheet.addAction(UIAlertAction(title: "Video",
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
    
    private func presentPhotoInputActionSheet() {
        
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
        guard indexOfMessage.section > 1 else { return true }
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
        return lightColor
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
            guard let imageUrl = media.url else {
                print("cant recover image")
                return }
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
            print("We have a new conversation")
            DatabaseManager.shared.createNewConversation(withUid: otherUserUid, name: self.title ?? "User", firstMessage: message) { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                } else {
                    print("failed to send message")
                }
            }
        } else {
            //append to existing conversation data
            print("Is not a new conversation with this user, we go try send message")
            
            guard let conversationId = conversationId, let name = self.title else { return }
            DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserUid: otherUserUid, newMessage: message, completion: { success in
                if success {
                    print("messagen sent")
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
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserUid: strongSelf.otherUserUid, newMessage: message, completion: { success in
                        if success {
                            print("sent photo message")
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
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserUid: strongSelf.otherUserUid, newMessage: message, completion: { success in
                        if success {
                            print("sent photo message")
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
