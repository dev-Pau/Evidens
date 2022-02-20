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
            self?.createNewConversation(result: result)
        }
        
        let controller = UINavigationController(rootViewController: vc)
        present(controller, animated: true)
    }
    
    private func createNewConversation(result: [String: String]) {
        print("\(result)")
        guard let name = result["name"],
              let email = result["emailAddress"],
              let uid = result["uid"] else {
                  return
              }
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
        
        let controller = ChatViewController(with: model.otherUserUid, id: model.id)
        controller.title = model.name
        controller.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
