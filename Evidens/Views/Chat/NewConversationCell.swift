//
//  NewConversationCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/2/22.
//
import UIKit
import SDWebImage


class NewConversationCell: UITableViewCell {
    
    //MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    

    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.anchor(top: contentView.topAnchor,
                                left: contentView.leftAnchor,
                                paddingTop: 10,
                                paddingLeft: 10,
                                width: 50,
                                height: 50)
        
        usernameLabel.anchor(top: profileImageView.topAnchor,
                             left: profileImageView.rightAnchor,
                             paddingLeft: 20,
                             width: contentView.bounds.width - 20 - profileImageView.bounds.width,
                             height: 50)
    }
    
    
    
    //MARK: - Helpers
    
    public func configure(with model: SearchResult) {
        self.usernameLabel.text = model.name

        let path = "/profile_images/\(model.uid)"
        ImageUploader.downloadImageURL(for: path, completion: { [weak self] result in
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
    
    //MARK: - Actions
}
