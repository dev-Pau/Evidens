//
//  AddPublicationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class AddPublicationViewController: UIViewController {
    
    private var userIsEditing = false
    private var previousPublication: String = ""
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let publicationTitleLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var publicationTitleTextField: UITextField = {
        let text = "Publication title *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        let tf = METextField(attrPlaceholder: attrString, withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    private let urlPublicationLabel: UILabel = {
        let label = UILabel()
        //label.text = "Publication URL *"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var urlPublicationTextField: UITextField = {
        let text = "Publication URL *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        let tf = METextField(attrPlaceholder: attrString, withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    private let publicationDateLabel: UILabel = {
        let label = UILabel()
        //label.text = "Date"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var publicationDateTextField: UITextField = {
        let text = "Date *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        let tf = METextField(attrPlaceholder: attrString, withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    let publicationDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contributorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Contributors"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private let contributorsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Worked in group? Add others that contributed to the publication"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        return label
    }()
    
    private let addContributorsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .mini
        button.configuration?.title = "Contributor"
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureDatePicker()
        configureUI()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleAddDate))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        publicationDateTextField.inputAccessoryView = toolbar
        publicationDateTextField.inputView = publicationDatePicker
        
    }
    
    private func configureUI() {
        publicationTitleLabel.attributedText = generateSuperscriptFor(text: "Publication title")
        urlPublicationLabel.attributedText = generateSuperscriptFor(text: "Publication URL")
        publicationDateLabel.attributedText = generateSuperscriptFor(text: "Date")
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        scrollView.addSubviews(publicationTitleLabel, publicationTitleTextField, separatorView, addContributorsButton, contributorsLabel, contributorsDescriptionLabel, urlPublicationTextField, urlPublicationLabel, publicationDateLabel, publicationDateTextField)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            publicationTitleTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            publicationTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            publicationTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            publicationTitleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            publicationTitleLabel.bottomAnchor.constraint(equalTo: publicationTitleTextField.topAnchor, constant: -2),
            publicationTitleLabel.leadingAnchor.constraint(equalTo: publicationTitleTextField.leadingAnchor),
            publicationTitleLabel.trailingAnchor.constraint(equalTo: publicationTitleTextField.trailingAnchor),
            
            urlPublicationTextField.topAnchor.constraint(equalTo: publicationTitleTextField.bottomAnchor, constant: 20),
            urlPublicationTextField.leadingAnchor.constraint(equalTo: publicationTitleTextField.leadingAnchor),
            urlPublicationTextField.trailingAnchor.constraint(equalTo: publicationTitleTextField.trailingAnchor),
            
            urlPublicationLabel.bottomAnchor.constraint(equalTo: urlPublicationTextField.topAnchor, constant: -2),
            urlPublicationLabel.leadingAnchor.constraint(equalTo: urlPublicationTextField.leadingAnchor),
            urlPublicationLabel.trailingAnchor.constraint(equalTo: urlPublicationTextField.trailingAnchor),
            
            publicationDateTextField.topAnchor.constraint(equalTo: urlPublicationTextField.bottomAnchor, constant: 20),
            publicationDateTextField.leadingAnchor.constraint(equalTo: urlPublicationTextField.leadingAnchor),
            publicationDateTextField.trailingAnchor.constraint(equalTo: urlPublicationTextField.trailingAnchor),
            
            publicationDateLabel.bottomAnchor.constraint(equalTo: publicationDateTextField.topAnchor, constant: -2),
            publicationDateLabel.leadingAnchor.constraint(equalTo: publicationDateTextField.leadingAnchor),
            publicationDateLabel.trailingAnchor.constraint(equalTo: publicationDateTextField.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: publicationDateTextField.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: publicationDateTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: publicationDateTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            addContributorsButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            addContributorsButton.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            
            contributorsLabel.centerYAnchor.constraint(equalTo: addContributorsButton.centerYAnchor),
            contributorsLabel.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            contributorsLabel.trailingAnchor.constraint(equalTo: addContributorsButton.trailingAnchor, constant: -10),
            
            contributorsDescriptionLabel.topAnchor.constraint(equalTo: addContributorsButton.bottomAnchor, constant: 5),
            contributorsDescriptionLabel.leadingAnchor.constraint(equalTo: contributorsLabel.leadingAnchor),
            contributorsDescriptionLabel.trailingAnchor.constraint(equalTo: contributorsLabel.trailingAnchor),
        ])
    }
    
    func updatePublicationForm() {
        guard let title = publicationTitleTextField.text, let dateText = publicationDateTextField.text, let url = urlPublicationTextField.text  else { return }
        navigationItem.rightBarButtonItem?.isEnabled = !title.isEmpty && !dateText.isEmpty && !url.isEmpty  ? true : false
    }
    
    @objc func handleDone() {
        guard let title = publicationTitleTextField.text, let url = urlPublicationTextField.text, let date = publicationDateTextField.text else { return }
        
        if userIsEditing {
            print("user is editing calling to update")
            print(previousPublication)
            DatabaseManager.shared.updatePublication(previousPublication: previousPublication, publicationTitle: title, publicationUrl: url, publicationDate: date) { uploaded in
                if uploaded {
                    print("Publication updated")
                }
            }
        } else {
            DatabaseManager.shared.uploadPublication(title: title, url: url, date: date) { uploaded in
                if uploaded {
                    print("Publication uploaded")
                }
            }
        }
        
    }
    
    @objc func handleAddDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        publicationDateTextField.text = formatter.string(from: publicationDatePicker.date)
        textDidChange(publicationDateTextField)
        view.endEditing(true)
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let count = text.count
        
        if textField == publicationTitleTextField {
            if count != 0 {
                publicationTitleLabel.isHidden = false
            } else {
                publicationTitleLabel.isHidden = true
            }
            
            updatePublicationForm()
        }
        
        if textField == publicationDateTextField {
            if count != 0 {
                publicationDateLabel.isHidden = false
            } else {
                publicationDateLabel.isHidden = true
            }
        }
        
        if textField == urlPublicationTextField {
            if count != 0 {
                urlPublicationLabel.isHidden = false
            } else {
                urlPublicationLabel.isHidden = true
            }
        }
        
        updatePublicationForm()
    }
    
    func generateSuperscriptFor(text: String) -> NSMutableAttributedString {
        let text = "\(text) *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        return attrString
    }
    
    func configureWithPublication(publicationTitle: String, publicationUrl: String, publicationDate: String) {
        userIsEditing = true
        previousPublication = publicationTitle
        
        publicationTitleTextField.text = publicationTitle
        urlPublicationTextField.text = publicationUrl
        publicationDateTextField.text = publicationDate

        textDidChange(publicationTitleTextField)
        textDidChange(urlPublicationTextField)
        textDidChange(publicationDateTextField)
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}
