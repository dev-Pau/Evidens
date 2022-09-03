//
//  SettingsOptionHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/9/22.
//

import UIKit

class SettingsOptionHeader: UITableViewHeaderFooterView {
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightGrayColor
        return iv
    }()
    
    private let settingsTitle: UILabel = {
        let title = UILabel()
        title.text = "Settings"
        title.textColor = .black
        title.numberOfLines = 1
        title.font = .systemFont(ofSize: 19, weight: .medium)
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews(profileImageView, settingsTitle, separatorView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 55),
            profileImageView.widthAnchor.constraint(equalToConstant: 55),
            
            settingsTitle.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            settingsTitle.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20),
            settingsTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            separatorView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
            
        ])

        
        profileImageView.layer.cornerRadius = 55 / 2
        
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        StorageManager.downloadImageURL(for: "/profile_images/\(uid)") { result in
            switch result {
                
            case .success(let url):
                self.profileImageView.sd_setImage(with: url)
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
