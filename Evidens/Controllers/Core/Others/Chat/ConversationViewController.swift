//
//  ConversationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/22.
//

import UIKit

private let reuseIdentifier = "cell"

protocol ConversationViewControllerDelegate: AnyObject {
    func didTapHideConversations()
}

/// Controller that shows list of conversations
class ConversationViewController: UIViewController {
    
    //MARK: - Properties
    
    private var conversations = [Conversation]()
    private var users = [User]()
    
    weak var delegate: ConversationViewControllerDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.isHidden = true
        table.keyboardDismissMode = .onDrag
        table.register(ChatCell.self,
                       forCellReuseIdentifier: reuseIdentifier)
        return table
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search conversations", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let emptyConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        searchBar.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.black), style: .done, target: self, action: #selector(didTapComposeButton))
    
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .done, target: self, action: #selector(didTapHideConversations))
        
        backButton.title = ""
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        configureUI()
        configureTableView()
        startListeningForConversations()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        emptyConversationsLabel.frame = CGRect(x: 10, y: (view.bounds.height-100)/2, width: view.bounds.width - 20, height: 100)
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(emptyConversationsLabel)
    }
    
    private func startListeningForConversations() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        DatabaseManager.shared.getAllConversations(forUid: uid, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.emptyConversationsLabel.isHidden = false
                    return
                }
                self?.emptyConversationsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations
                
                self?.conversations.sort(by: { $0.latestMessage.date > $1.latestMessage.date })
                
                conversations.forEach { conversation in
                    // Fetch users here
                    UserService.fetchUser(withUid: conversation.otherUserUid) { user in
                        self?.users.append(user)
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
                
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.emptyConversationsLabel.isHidden = false
                print("failed to get conversations: \(error)")
            }
        })
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - Actions
    
    //Creates a new conversation
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] user in
            //Check if user conversation already exists
            guard let strongSelf = self else { return }
            
            let currentConversation = strongSelf.conversations
            //Search if target conversation already exists in current conversations
            if let targetConversations = currentConversation.first(where: {
                $0.otherUserUid == user.uid
            }) {
                //Present the existing conversation with targetID already created in database
                let controller = ChatViewController(with: user, id: targetConversations.id)
                controller.isNewConversation = false
                controller.title = targetConversations.name
                controller.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            } else {
                //Create and present a new conversation
                strongSelf.createNewConversation(result: user)
            }
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @objc func didTapHideConversations() {
        delegate?.didTapHideConversations()
    }
    
    private func createNewConversation(result: User) {
        let user = result
        let name = result.firstName! + " " + result.lastName!
        let uid = result.uid
        //Check in database if conversation with this users exists
        //If it does, reuse conversationID
        DatabaseManager.shared.conversationExists(with: uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let conversationId):
                //Conversation exists, open the conversation with conversationID found
                let controller = ChatViewController(with: user, id: conversationId)
                controller.isNewConversation = false
                controller.title = name
                controller.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(controller, animated: true)
                
            case .failure(_):
                //There's no conversation that exists, Hi new conversation with id
                let controller = ChatViewController(with: user, id: nil)
                controller.isNewConversation = true
                controller.title = name
                controller.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
                       
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        
        cell.viewModel = ConversationViewModel(conversation: conversations[indexPath.row])
        
        let userIndex = users.firstIndex { user in
            if user.uid == conversations[indexPath.row].otherUserUid {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            cell.set(user: users[userIndex])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        let model = conversations[indexPath.row]
        openConversation(with: user, with: model)
    }
    
    func openConversation(with user: User, with model: Conversation) {
        let controller = ChatViewController(with: user, id: model.id)
        controller.title = user.firstName! + " " + user.lastName!

        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //Swipe the row away
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Get the conversationId for current indexPath row
            let conversationId = conversations[indexPath.row].id
            
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            //Delete the conversation in the database
            DatabaseManager.shared.deleteConversation(conversationId: conversationId) { success in
                if !success {
                    // Add model and row back and show error alert
                    
                    print("Failed to delete conversation")
                }
            }
            tableView.endUpdates()
        }
    }
}

extension ConversationViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        let controller = SearchViewController()

        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
    /*
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        filterConversations(with: text.lowercased())
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        filterConversations(with: text.lowercased())
    }
    
    func filterConversations(with text: String) {
        var filteredConversations = [Conversation]()
        let filteredUsers: [User] = users.filter { $0.firstName!.lowercased().contains(text) || $0.lastName!.lowercased().contains(text) }
        filteredUsers.forEach { user in
            
        }
    }
     */
}
