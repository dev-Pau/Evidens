//
//  AccountSettingsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/9/22.
//

private let optionCellReuseIdentifier = "OptionCellReuseIdentifier"

import UIKit

class AboutSettingsViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    enum AccountOptions: String, CaseIterable {
        case privacyPolicy = "Privacy Policy"
        case termsOfUse = "Tems of Use"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }
    
    private func configureNavigationBar() {
        title = "Account"
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .systemBackground
        view.addSubviews(tableView)
        tableView.frame = view.bounds
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsSubOptionCell.self, forCellReuseIdentifier: optionCellReuseIdentifier)
    }
}

extension AboutSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: optionCellReuseIdentifier, for: indexPath) as! SettingsSubOptionCell
        cell.set(settingsTitle: AccountOptions.allCases[indexPath.row].rawValue)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = AccountOptions.allCases[indexPath.row]

        switch selection {
        case .privacyPolicy:

            let controller = PrivacyPolicyViewController()
            
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        case .termsOfUse:
            let controller = TermsOfUseViewController()
            
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
}

