//
//  ApplyJobHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit

protocol ApplyJobHeaderDelegate: AnyObject {
    func didTapShowPrivacyRules()
    func phoneNumberIsValid(number: String?)
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
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.delegate = self
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedText = NSMutableAttributedString(string: "To apply for this job, you will need to provide some basic information or details. For more information, you can tap our ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular), .foregroundColor: UIColor.secondaryLabel])
        attributedText.append(NSMutableAttributedString(string: "privacy rules", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: primaryColor]))
        
        attributedText.addAttribute(NSAttributedString.Key.link, value: "privacyInformation", range: (attributedText.string as NSString).range(of: "privacy rules"))
        // link: value(forKey: "presentCommunityInformation"),
        attributedText.append(NSMutableAttributedString(string: ".", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular), .foregroundColor: UIColor.secondaryLabel]))
        
        tv.attributedText = attributedText
        return tv
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .quaternarySystemFill
        iv.image = UIImage(named: "user.profile")
        iv.clipsToBounds = true
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
    
    private lazy var phoneNumberTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.textColor = primaryColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .whileEditing
        tf.keyboardType = .numberPad
        //tf.placeholder = "Insert your phone number here"
        tf.attributedPlaceholder = NSAttributedString(string: "Insert your phone number here", attributes: [.foregroundColor: UIColor.secondaryLabel])
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        tf.tintColor = primaryColor
        return tf
    }()
    
    private let midSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
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
        addSubviews(titleLabel, descriptionTextView, midSeparatorView, profileImageView, usernameLabel, professionLabel, /*indexLabel, phoneNumberLabel,*/ phoneNumberTextField, separatorView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -4),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            midSeparatorView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 4),
            midSeparatorView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            midSeparatorView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            midSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            profileImageView.topAnchor.constraint(equalTo: midSeparatorView.bottomAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 55),
            profileImageView.heightAnchor.constraint(equalToConstant: 55),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            professionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            professionLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            professionLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            /*
            phoneNumberLabel.topAnchor.constraint(equalTo: emailAddressLabel.bottomAnchor, constant: 10),
            phoneNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            phoneNumberLabel.widthAnchor.constraint(equalToConstant: 130),
            
            indexLabel.topAnchor.constraint(equalTo: phoneNumberLabel.topAnchor),
            indexLabel.leadingAnchor.constraint(equalTo: phoneNumberLabel.trailingAnchor, constant: 10),
            indexLabel.widthAnchor.constraint(equalToConstant: 30),
            indexLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            */
            phoneNumberTextField.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 15),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            phoneNumberTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: phoneNumberTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: phoneNumberTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
        
        profileImageView.layer.cornerRadius = 55 / 2
    }
    
    private func configureWithUser() {
        guard let user = user else { return }
        usernameLabel.text = user.firstName! + " " + user.lastName!
        professionLabel.text = user.profession! + " • " + user.speciality!
        emailAddressTextField.text = user.email!
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    @objc func textDidChange() {
        guard let text = phoneNumberTextField.text else { return }
        if text.count >= 9 {
            delegate?.phoneNumberIsValid(number: "+34" + text)
        } else {
            delegate?.phoneNumberIsValid(number: nil)
        }
    }
}

extension ApplyJobHeader: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "privacyInformation" {
            delegate?.didTapShowPrivacyRules()
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
    
    /*
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView == phoneNumberTextField else { return true }
        let currentText = phoneNumberTextField.text ?? ""
        let replacementRange = Range(range, in: currentText)!
        
        let updatedText = currentText.replacingCharacters(in: replacementRange, with: text)
        let numericText = updatedText.components(separatedBy: .decimalDigits.inverted).joined()
        let formattedText = formatPhoneNumber(numericText)
        phoneNumberTextField.text = formattedText
        return false
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        var formattedPhoneNumber = ""
        var digits = 0
        for i in 0..<phoneNumber.count {
            if digits == 3 {
                formattedPhoneNumber += " "
                digits = 0
            }
            formattedPhoneNumber += String(phoneNumber[phoneNumber.index(phoneNumber.startIndex, offsetBy: i)])
            digits += 1
        }
        
        return formattedPhoneNumber
    }
     */
}
