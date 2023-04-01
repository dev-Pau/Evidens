//
//  AddLanguageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit
import JGProgressHUD

protocol AddLanguageViewControllerDelegate: AnyObject {
    func handleLanguageUpdate()
}

class AddLanguageViewController: UIViewController {
    
    weak var delegate: AddLanguageViewControllerDelegate?
    
    public var completion: (([String]) -> (Void))?
    
    var userIsEditing = false
    private var previousLanguage: String = ""
    
    private var language = Language(name: "", proficiency: "")
    
    private var languageSelected: String = ""
    private var proficiencySelected: String = ""
    
    private let progressIndicator = JGProgressHUD()
    
    private var textFieldChanged: UITextField!

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = CustomLabel(placeholder: "Add language")
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Adding languages you know will make you stand out in your industry."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
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
        tf.delegate = self
        tf.clearButtonMode = .never
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    private lazy var languageProficiencyLabel: UILabel = {
        let label = UILabel()
        label.text = "Proficiency *"
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var languageProficiencyTextField: UITextField = {
        let text = "Proficiency *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        let tf = METextField(attrPlaceholder: attrString, withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        tf.clearButtonMode = .never
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }

    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: userIsEditing ? "Edit" : "Add", style: .done, target: self, action: #selector(handleDone))
        titleLabel.text = userIsEditing ? "Edit Language" : "Add Language"
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        languageLabel.attributedText = generateSuperscriptFor(text: "Language")
        languageProficiencyLabel.attributedText = generateSuperscriptFor(text: "Proficiency")
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(languageLabel, titleLabel, infoLabel, languageTextField, languageProficiencyLabel, languageProficiencyTextField)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            languageTextField.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 60),
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
        guard language.proficiency != "", language.name != "" else { return }
        progressIndicator.show(in: view)
        if userIsEditing == false {
            DatabaseManager.shared.uploadLanguage(language: language) { uploaded in
                self.progressIndicator.dismiss(animated: true)
                guard uploaded else {
                    // Language already registered by the user
                    let reportPopup = METopPopupView(title: "\(self.language.name.capitalized) is already registered on your profile. Try adding a new language.", image: "xmark.octagon.fill", popUpType: .destructive)
                    reportPopup.showTopPopup(inView: self.view)
                    return
                }
                // Language has been uploaded successfully. Dismiss the current view & upload the profile
                self.delegate?.handleLanguageUpdate()
                self.navigationController?.popViewController(animated: true)
                
            }
        } else {
            DatabaseManager.shared.updateLanguage(language: language) { uploaded in
                if uploaded {
                    self.progressIndicator.dismiss(animated: true)
                    self.delegate?.handleLanguageUpdate()
                    self.navigationController?.popViewController(animated: true)
                }

                /*
                if let count = self.navigationController?.viewControllers.count {
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[count - 2 - 1])!, animated: true)
                }
                 */
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
    
    func configureWithLanguage(language: Language) {
        self.language = language
        languageTextField.text = language.name
        languageProficiencyTextField.text = language.proficiency
        textDidChange(languageTextField)
        textDidChange(languageProficiencyTextField)
        languageTextField.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

extension AddLanguageViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        languageTextField.resignFirstResponder()
        languageProficiencyTextField.resignFirstResponder()
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.scrollDirection = .vertical
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let controller = SupportSectionViewController(collectionViewLayout: layout)
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        textFieldChanged = textField
        
        if textField == languageProficiencyTextField {
            controller.collectionData = Sections.getAllLanguageLevels()
            controller.previousValue = language.proficiency
        } else {
            controller.collectionData = Sections.getAllLanguages()
            controller.previousValue = language.name
        }
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
}

extension AddLanguageViewController: SupportSectionViewControllerDelegate {
    func didTapSectionOption(optionText: String) {
        if textFieldChanged == languageProficiencyTextField {
            languageProficiencyTextField.text = optionText
            language.proficiency = optionText
            textDidChange(languageProficiencyTextField)
        } else {
            languageTextField.text = optionText
            language.name = optionText
            textDidChange(languageTextField)
        }
    }
}

