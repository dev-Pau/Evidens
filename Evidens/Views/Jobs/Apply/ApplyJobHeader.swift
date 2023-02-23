//
//  ApplyJobHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit

protocol ApplyJobHeaderDelegate: AnyObject {
    func phoneNumberIsValid(number: String, isValid: Bool)
}

class ApplyJobHeader: UICollectionReusableView {
    weak var delegate: ApplyJobHeaderDelegate?
    
    var user: User? {
        didSet {
            configureWithUser()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Contact information"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let emailAddressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.text = "Email address"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailAddressTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .whileEditing
        tf.isUserInteractionEnabled = false
        tf.tintColor = primaryColor
        return tf
    }()
    
    private let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.text = "Phone number"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.text = "+34"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var phoneNumberTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .numberPad
        tf.placeholder = "Phone number"
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        tf.tintColor = primaryColor
        return tf
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(titleLabel, profileImageView, usernameLabel, professionLabel, emailAddressLabel, emailAddressTextField, indexLabel, phoneNumberLabel, phoneNumberTextField, separatorView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 55),
            profileImageView.heightAnchor.constraint(equalToConstant: 55),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            professionLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            professionLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
                      
            emailAddressLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            emailAddressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emailAddressLabel.widthAnchor.constraint(equalToConstant: 130),
            
            emailAddressTextField.topAnchor.constraint(equalTo: emailAddressLabel.topAnchor, constant: -1),
            emailAddressTextField.leadingAnchor.constraint(equalTo: emailAddressLabel.trailingAnchor, constant: 10),
            emailAddressTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            phoneNumberLabel.topAnchor.constraint(equalTo: emailAddressLabel.bottomAnchor, constant: 10),
            phoneNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            phoneNumberLabel.widthAnchor.constraint(equalToConstant: 130),
            
            indexLabel.topAnchor.constraint(equalTo: phoneNumberLabel.topAnchor),
            indexLabel.leadingAnchor.constraint(equalTo: phoneNumberLabel.trailingAnchor, constant: 10),
            indexLabel.widthAnchor.constraint(equalToConstant: 30),
            
            phoneNumberTextField.topAnchor.constraint(equalTo: phoneNumberLabel.topAnchor, constant: -1),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 10),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        profileImageView.layer.cornerRadius = 55 / 2
    }
    
    private func configureWithUser() {
        guard let user = user else { return }
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        usernameLabel.text = user.firstName! + " " + user.lastName!
        professionLabel.text = user.profession! + " · " + user.speciality!
        emailAddressTextField.text = user.email!
    }
    
    @objc func textDidChange() {
        guard let text = phoneNumberTextField.text else { return }
        if text.count >= 9 {
            delegate?.phoneNumberIsValid(number: "+34" + text, isValid: true)
        } else {
            delegate?.phoneNumberIsValid(number: "+34" + text, isValid: false)
        }
    }
}
