//
//  ConversationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/22.
//

import UIKit
import JGProgressHUD

private let reuseIdentifier = "cell"

class ConversationViewController: UIViewController {
    
    //MARK: - Properties
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ChatCell.self,
                       forCellReuseIdentifier: reuseIdentifier)
        return table
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
        configureUI()
        configureTableView()
        startListeningForConversations()
        fetchConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Conversations"
        view.addSubview(tableView)
        view.addSubview(emptyConversationsLabel)
    }
    
    private func startListeningForConversations() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        DatabaseManager.shared.getAllConversations(forUid: uid, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case.failure(let error):
                print("failed to get conversations: \(error)")
            }
        })
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - Actions
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
    
    //Creates a new conversation
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        
        vc.completion = { [weak self] result in
            //Check if user conversation already exists
            guard let strongSelf = self else { return }
            
            let currentConversation = strongSelf.conversations
            //Search if target conversation already exists in current conversations
            if let targetConversations = currentConversation.first(where: {
                $0.otherUserUid == result.uid
            }) {
                //Present the existing conversation with targetID already created in database
                let controller = ChatViewController(with: targetConversations.otherUserUid, id: targetConversations.id)
                controller.isNewConversation = false
                controller.title = targetConversations.name
                controller.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            } else {
                //Create and present a new conversation
                strongSelf.createNewConversation(result: result)
            }
        }
        let controller = UINavigationController(rootViewController: vc)
        present(controller, animated: true)
    }
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let uid = result.uid
        let controller = ChatViewController(with: uid, id: nil)
        controller.isNewConversation = true
        controller.title = name
        controller.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(controller, animated: true)
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
            //Delete the conversation in the database
            DatabaseManager.shared.deleteConversation(conversationId: conversationId) { [weak self] success in
                if success {
                    //Update the model
                    self?.conversations.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
            tableView.endUpdates()
        }
    }
    
    
    
  

}
