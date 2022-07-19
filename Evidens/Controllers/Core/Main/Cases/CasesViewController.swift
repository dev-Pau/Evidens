//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

class CasesViewController: UIViewController {
    
    private var cases = [Case]() {
        didSet { tableView.reloadData() }
    }
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = lightColor
        return collectionView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = lightColor
        return tableView
    }()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCases()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.resignFirstResponder()
        
    }
    
    private func fetchCases() {
        CaseService.fetchCases { cases in
            self.cases = cases
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .plain, target: self, action: #selector(didTapChat))
        
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        userImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        userImageView.layer.cornerRadius = 35 / 2
        let profileImageItem = UIBarButtonItem(customView: userImageView)
        userImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
        navigationItem.leftBarButtonItem = profileImageItem
        
        navigationItem.titleView = searchBar
        
    }
    
    private func configureUI() {
        searchBar.delegate = self
    }
    
    private func configureCollectionView() {
        //collectionView.register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellWithReuseIdentifier: <#T##String#>)
        
        
        
         tableView.register(CaseTextCell.self, forCellReuseIdentifier: caseTextCellReuseIdentifier)
         tableView.register(CaseTextImageCell.self, forCellReuseIdentifier: caseTextImageCellReuseIdentifier)
         tableView.delegate = self
         tableView.dataSource = self
         tableView.rowHeight = UITableView.automaticDimension
         tableView.estimatedRowHeight = 400
         tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
         view.addSubview(tableView)
         
    }
    
    @objc func didTapChat() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        navigationItem.backBarButtonItem = backItem
        
        let controller = ConversationViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CasesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cases.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cases[indexPath.row].type.rawValue == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
            cell.selectionStyle = .none
            cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
            cell.selectionStyle = .none
            cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if cases[indexPath.row].type.rawValue == 0 {
            return 500
        } else {
            return 500
        }
    }
    
}

//MARK: - UISearchBarDelegate

extension CasesViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        navigationItem.backBarButtonItem = backItem
        
        let controller = SearchViewController()
        navigationController?.pushViewController(controller, animated: true)

        return true
    }
}
