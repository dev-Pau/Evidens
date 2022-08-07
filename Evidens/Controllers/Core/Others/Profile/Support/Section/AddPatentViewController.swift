//
//  AddPatentViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class AddPatentViewController: UIViewController {
    
    private var conditionIsSelected: Bool = false
    
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
    
    private let patentTitleLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var patentTitleTextField: UITextField = {
        let text = "Patent title *"
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
    
    private let patentNumberLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var patentNumberTextField: UITextField = {
        let text = "Patent number *"
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
    
    private lazy var patentDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var patentDescriptionTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Description"
        tv.placeholderLabel.font = .systemFont(ofSize: 17, weight: .medium)
        tv.placeholderLabel.textColor = .systemGray2
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = blackColor
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.backgroundColor = lightColor
        tv.layer.cornerRadius = 5
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
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
        label.text = "Worked in group? Add others that contributed to the patent"
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
        configureUI()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        patentTitleLabel.attributedText = generateSuperscriptFor(text: "Patent title")
        patentNumberLabel.attributedText = generateSuperscriptFor(text: "Patent number")
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        scrollView.addSubviews(patentTitleLabel, patentTitleTextField, patentNumberLabel, patentNumberTextField, patentDescriptionLabel, patentDescriptionTextView, separatorView, addContributorsButton, contributorsLabel, contributorsDescriptionLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            patentTitleTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            patentTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            patentTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            patentTitleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            patentTitleLabel.bottomAnchor.constraint(equalTo: patentTitleTextField.topAnchor, constant: -2),
            patentTitleLabel.leadingAnchor.constraint(equalTo: patentTitleTextField.leadingAnchor),
            patentTitleLabel.trailingAnchor.constraint(equalTo: patentTitleTextField.trailingAnchor),
            
            patentNumberTextField.topAnchor.constraint(equalTo: patentTitleTextField.bottomAnchor, constant: 20),
            patentNumberTextField.leadingAnchor.constraint(equalTo: patentTitleTextField.leadingAnchor),
            patentNumberTextField.trailingAnchor.constraint(equalTo: patentTitleTextField.trailingAnchor),
            patentNumberTextField.heightAnchor.constraint(equalToConstant: 35),
            
            patentNumberLabel.bottomAnchor.constraint(equalTo: patentNumberTextField.topAnchor, constant: -2),
            patentNumberLabel.leadingAnchor.constraint(equalTo: patentNumberTextField.leadingAnchor),
            patentNumberLabel.trailingAnchor.constraint(equalTo: patentNumberTextField.trailingAnchor),
            
            patentDescriptionTextView.topAnchor.constraint(equalTo: patentNumberTextField.bottomAnchor, constant: 20),
            patentDescriptionTextView.leadingAnchor.constraint(equalTo: patentNumberTextField.leadingAnchor),
            patentDescriptionTextView.trailingAnchor.constraint(equalTo: patentNumberTextField.trailingAnchor),
            
            patentDescriptionLabel.bottomAnchor.constraint(equalTo: patentDescriptionTextView.topAnchor, constant: -2),
            patentDescriptionLabel.leadingAnchor.constraint(equalTo: patentDescriptionTextView.leadingAnchor),
            patentDescriptionLabel.trailingAnchor.constraint(equalTo: patentDescriptionTextView.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: patentDescriptionTextView.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: patentDescriptionLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: patentDescriptionLabel.trailingAnchor),
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
    
    private func updatePatentForm() {
        guard let text = patentTitleTextField.text, let number = patentNumberTextField.text else { return }
        if !text.isEmpty && !number.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func handleDone() {
        guard let title = patentTitleTextField.text, let number = patentNumberTextField.text else { return }
        DatabaseManager.shared.uploadPatent(title: title, number: number, description: patentDescriptionTextView.text) { uploaded in
            print("patent uploaded")
        }
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let count = text.count
        
        if textField == patentTitleTextField {
            if count != 0 {
                patentTitleLabel.isHidden = false
            } else {
                patentTitleLabel.isHidden = true
            }
            
        } else if textField == patentNumberTextField {
            if count != 0 {
                patentNumberLabel.isHidden = false
            } else {
                patentNumberLabel.isHidden = true
            }
        }
        
        updatePatentForm()
    }
    
    func generateSuperscriptFor(text: String) -> NSMutableAttributedString {
        let text = "\(text) *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        return attrString
    }
}

extension AddPatentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        
        if count != 0 {
            patentDescriptionLabel.isHidden = false
        } else {
            patentDescriptionLabel.isHidden = true
        }
    }
}
