//
//  SeeOthersCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class UserProfileSeeOthersCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.layer.contentsGravity = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = primaryColor
        label.numberOfLines = 2
        label.textAlignment = .center
        label.layer.contentsGravity = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubviews(profileImageView, nameLabel, professionLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 3),
            
            professionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            professionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
        ])
        
        profileImageView.layer.cornerRadius = 60/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(userInfo: [String: String]) {
        guard let uid = userInfo["uid"] else { return }
        nameLabel.text = userInfo["name"]
        professionLabel.text = userInfo["profession"]
        
        
        let path = "/profile_images/\(uid)"
        StorageManager.downloadImageURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.profileImageView.sd_setImage(with: url, completed: nil)
                }
                
            case.failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }
     
}