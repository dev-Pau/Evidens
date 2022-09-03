//
//  AccountSettingsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/9/22.
//

private let optionCellReuseIdentifier = "OptionCellReuseIdentifier"

import UIKit

class AccountSectionViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    private var aboutOptions = ["Privacy Policy", "Terms of Use"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }
    
    private func configureNavigationBar() {
        title = "Account"
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .white
        view.addSubviews(tableView)
        tableView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsSubOptionCell.self, forCellReuseIdentifier: optionCellReuseIdentifier)
    }
}

extension AccountSectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aboutOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: optionCellReuseIdentifier, for: indexPath) as! SettingsSubOptionCell
        cell.set(settingsTitle: aboutOptions[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

