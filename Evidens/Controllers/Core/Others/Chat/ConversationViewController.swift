//
//  ConversationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/22.
//

import UIKit

private let reuseIdentifier = "cell"

/// Controller that shows list of conversations
class ConversationViewController: UIViewController {
    
    //MARK: - Properties
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ChatCell.self,
                       forCellReuseIdentifier: reuseIdentifier)
        return table
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search messages", attributes: [.font : UIFont.systemFont(ofSize: 15)])
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        navigationItem.rightBarButtonItem?.tintColor = .black
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
        navigationItem.titleView = searchBar
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
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
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
                $0.otherUserUid == user.objectID
            }) {
                //Present the existing conversation with targetID already created in database
                let controller = ChatViewController(with: targetConversations.otherUserUid, id: targetConversations.id)
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
    
    private func createNewConversation(result: SearchUser) {
        let name = result.firstName
        let uid = result.objectID
        //Check in database if conversation with this users exists
        //If it does, reuse conversationID
        DatabaseManager.shared.conversationExists(with: uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let conversationId):
                //Conversation exists, open the conversation with conversationID found
                let controller = ChatViewController(with: uid, id: conversationId)
                controller.isNewConversation = false
                controller.title = name
                controller.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(controller, animated: true)
                
            case .failure(_):
                //There's no conversation that exists, create new conversation with id
                let controller = ChatViewController(with: uid, id: nil)
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
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        let controller = ChatViewController(with: model.otherUserUid, id: model.id)
        controller.title = model.name
        controller.navigationItem.largeTitleDisplayMode = .never
        
        //let backItem = UIBarButtonItem()
        //backItem.title = ""
        //navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
