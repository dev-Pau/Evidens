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
    
    private let micButton = InputBarButtonItem()
    
    public let otherUserUid: String
    private var conversationId: String?
    public var isNewConversation = false
    
    private var longPressMicrophone: UILongPressGestureRecognizer!
    private var audioFileName = ""
    private var audioDuration: Date!

    
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
        configureGestureRecognizer()
        setupInputButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId { listenForMessages(id: conversationId, shouldScrollToBottom: true) }
    }
    
    private func configureGestureRecognizer() {
        longPressMicrophone = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressMicrophone.minimumPressDuration = 0.5
        longPressMicrophone.delaysTouchesBegan = true
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
        inputButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        inputButton.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([inputButton], forStack: .left, animated: false)
        
        micButton.setSize(CGSize(width: 35, height: 35), animated: false)
        micButton.setImage(UIImage(systemName: "mic"), for: .normal)
        
        micButton.addGestureRecognizer(longPressMicrophone)
        
        updateMicrophoneButtonStatus(show: true)
    }
    
    private func updateMicrophoneButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 35, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
        }
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
    
    //MARK: - Actions
    
    @objc func recordAudio() {
        switch longPressMicrophone.state {
        case .began:
            print("Recording began")
            audioDuration = Date()
            audioFileName = Date().formatRelativeString()
            print(audioFileName)
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            AudioRecorder.shared.finishRecording()
            
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                //Send message
                let finalAudioDuration = audioDuration.interval(ofComponent: .second, from: Date())
                print(finalAudioDuration)
                
                StorageManager.uploadMessageAudio(fileName: audioFileName) { result in
                    switch result {
                    case .success(let urlString):
                        print("Uploading message photo: \(urlString)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } else {
                print("No audio file found")
            }
            
            audioFileName = ""

            
        @unknown default:
            print("Unknown")
        }
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
            guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    //Configure the cell top label to display dates
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            let topCellText = MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            
            return NSAttributedString(string: topCellText, attributes: [.font: font, .foregroundColor: color])
        }
        
        return nil
    }
    
    //Cell top label size
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 18
        }
        return 0
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
            return UIColor(rgb: 0x79CBBF)
        }
        //Other recipient in conversation
        return UIColor(rgb: 0xEBEBEB)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            //Show our user profile image
            if let currentUserImageURL = self.senderPhotoUrl {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            } else {
                //Fetch url
                guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
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
            if let otherUserPhotoURL = self.otherUserPhotoUrl {
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
    }
}

//MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            let vc = PhotoViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
            
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
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        updateMicrophoneButtonStatus(show: text == "")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        guard let selfSender = self.selfSender, let messageId = createMessageId() else { return }
        print("Sending: \(text)")
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        // send message
        if isNewConversation {
            //create conversation in database
            
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
            print("is not new conversation")
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
