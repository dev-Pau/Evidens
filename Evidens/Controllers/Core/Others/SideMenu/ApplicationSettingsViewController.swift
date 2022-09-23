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
    
    enum SettingsOptions: String, CaseIterable {
        case about = "About"
        
        var image: String {
            switch self {
            case .about:
                return "info.circle"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }
  
    private func configureNavigationBar() {
        title = "Settings"
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
    }
}

extension ApplicationSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsCellReuseIdentifier, for: indexPath) as! SettingsOptionCell
        cell.selectionStyle = .none
        cell.set(settingsTitle: SettingsOptions.allCases[indexPath.row].rawValue, settingsImage: SettingsOptions.allCases[indexPath.row].image)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = SettingsOptions.allCases[indexPath.row]
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        
        switch selectedOption {
            
        case .about:
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
