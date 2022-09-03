//
//  ApplicationSettingsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/22.
//

import UIKit

private let settingsCellReuseIdentifier = "SettingsCellReuseIdentifier"
private let settingsFooterReuseIdentifier = "SettingsFooterReuseIdentifier"
private let settingsHeaderReuseIdentifier = "SettingsHeaderReuseIdentifier"

class ApplicationSettingsViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    private var options = ["Notifications", "Account" , "About"]
    private var images = ["bell", "person.crop.circle", "info.circle"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }
    
    let searchBar = UISearchBar()
    
    private func configureNavigationBar() {
        searchBar.isHidden = true
        navigationItem.titleView = searchBar
        
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .white
        view.addSubviews(tableView)
        tableView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsOptionCell.self, forCellReuseIdentifier: settingsCellReuseIdentifier)
        tableView.register(SettingsOptionFooter.self, forHeaderFooterViewReuseIdentifier: settingsFooterReuseIdentifier)
        tableView.register(SettingsOptionHeader.self, forHeaderFooterViewReuseIdentifier: settingsHeaderReuseIdentifier)
    }
}

extension ApplicationSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsCellReuseIdentifier, for: indexPath) as! SettingsOptionCell
        cell.selectionStyle = .none
        cell.set(settingsTitle: options[indexPath.row], settingsImage: images[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: settingsHeaderReuseIdentifier) as! SettingsOptionHeader
        return header
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: settingsFooterReuseIdentifier) as! SettingsOptionFooter
        footer.delegate = self
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        navigationItem.backBarButtonItem = backItem
        
        if indexPath.row == 0 {
            // Notifications
            let controller = NotificationSectionViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 1 {
            // Account
            let controller = AccountSectionViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else {
            // About
            let controller = AboutSettingsViewController()
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ApplicationSettingsViewController: SettingsOptionFooterDelegate {
    func didTapLogout() {
        logoutAlert {
            AuthService.logout()
            AuthService.googleLogout()
            
            UserDefaults.resetDefaults()

            DispatchQueue.main.async {
                let controller = WelcomeViewController()
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            }
        }
    }
}
