//
//  AddLanguageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class AddLanguageViewController: UIViewController {
    
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
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var languageTextField: UITextField = {
        let text = "Language *"
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
    
    private lazy var languageProficiencyLabel: UILabel = {
        let label = UILabel()
        label.text = "Proficiency"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var languageProficiencyTextField: UITextField = {
        let attrString = NSMutableAttributedString(string: "Proficiency", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        let tf = METextField(attrPlaceholder: attrString, withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        languageLabel.attributedText = generateSuperscriptFor(text: "Language")
        languageProficiencyLabel.attributedText = generateSuperscriptFor(text: "Proficiency")
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        scrollView.addSubviews(languageLabel, languageTextField, languageProficiencyLabel, languageProficiencyTextField)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            languageTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            languageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            languageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            languageTextField.heightAnchor.constraint(equalToConstant: 35),
            
            languageLabel.bottomAnchor.constraint(equalTo: languageTextField.topAnchor, constant: -2),
            languageLabel.leadingAnchor.constraint(equalTo: languageTextField.leadingAnchor),
            languageLabel.trailingAnchor.constraint(equalTo: languageTextField.trailingAnchor),
            
            languageProficiencyTextField.topAnchor.constraint(equalTo: languageTextField.bottomAnchor, constant: 20),
            languageProficiencyTextField.leadingAnchor.constraint(equalTo: languageTextField.leadingAnchor),
            languageProficiencyTextField.trailingAnchor.constraint(equalTo: languageTextField.trailingAnchor),
            languageProficiencyTextField.heightAnchor.constraint(equalToConstant: 35),
            
            languageProficiencyLabel.bottomAnchor.constraint(equalTo: languageProficiencyTextField.topAnchor, constant: -2),
            languageProficiencyLabel.leadingAnchor.constraint(equalTo: languageProficiencyTextField.leadingAnchor),
            languageProficiencyLabel.trailingAnchor.constraint(equalTo: languageProficiencyTextField.trailingAnchor)
        ])
    }
    
    @objc func handleDone() {
        guard let language = languageTextField.text, let proficiency = languageProficiencyTextField.text else { return }
        DatabaseManager.shared.uploadLanguage(language: language, proficiency: proficiency) { uploaded in
            if uploaded {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let count = text.count
        
        if textField == languageTextField {
            if count != 0 {
                languageLabel.isHidden = false
            } else {
                languageLabel.isHidden = true
            }
            
        } else if textField == languageProficiencyTextField {
            if count != 0 {
                languageProficiencyLabel.isHidden = false
            } else {
                languageProficiencyLabel.isHidden = true
            }
        }
        
        guard let language = languageTextField.text, let proficiency = languageProficiencyTextField.text else { return }
        navigationItem.rightBarButtonItem?.isEnabled = !language.isEmpty && !proficiency.isEmpty ? true : false

    }
    
    func generateSuperscriptFor(text: String) -> NSMutableAttributedString {
        let text = "\(text) *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        return attrString
    }
}

