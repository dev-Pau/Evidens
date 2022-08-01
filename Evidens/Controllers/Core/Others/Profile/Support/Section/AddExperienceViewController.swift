//
//  AddExperienceViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class AddExperienceViewController: UIViewController {
    
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
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleTextField: UITextField = {
        let text = "Role *"
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
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var companyTextField: UITextField = {
        let text = "Company *"
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
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationTextField: UITextField = {
        let text = "Location"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        let tf = METextField(attrPlaceholder: attrString, withSpacer: false)
        //tf.delegate = self
        tf.tintColor = primaryColor
        tf.font = .systemFont(ofSize: 17, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    private lazy var squareButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "square")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
        button.configuration?.baseForegroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleProfessionConditions), for: .touchUpInside)
        return button
    }()
    
    private let professionConditionsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.text = "Currently working in this role"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = grayColor
        return label
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var startDateTextField: UITextField = {
        let text = "Start date *"
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
    
    private lazy var endDateTextField: UITextField = {
        let text = "End date *"
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
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .black
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTextView: InputTextView = {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureDatePicker()
        configureUI()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureDatePicker() {
        let startToolbar = UIToolbar()
        startToolbar.sizeToFit()
        
        let endToolbar = UIToolbar()
        endToolbar.sizeToFit()
        
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleAddStartDate))
        let endDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleAddEndDate))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        startToolbar.setItems([flexibleSpace, startDoneButton], animated: true)
        endToolbar.setItems([flexibleSpace, endDoneButton], animated: true)
        
        startDateTextField.inputAccessoryView = startToolbar
        endDateTextField.inputAccessoryView = endToolbar
        
        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker
    }
    
    private func configureUI() {
        roleLabel.attributedText = generateSuperscriptFor(text: "Role")
        companyLabel.attributedText = generateSuperscriptFor(text: "Company")
        startDateLabel.attributedText = generateSuperscriptFor(text: "Start date")
        endDateLabel.attributedText = generateSuperscriptFor(text: "End date")
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        scrollView.addSubviews(roleLabel, roleTextField, companyLabel, companyTextField, locationLabel, locationTextField, descriptionLabel, descriptionTextView, squareButton, professionConditionsLabel, startDateLabel, endDateLabel, startDateTextField, endDateTextField, separatorView, bottomSeparatorView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            roleTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            roleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            roleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            roleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            roleLabel.bottomAnchor.constraint(equalTo: roleTextField.topAnchor, constant: -2),
            roleLabel.leadingAnchor.constraint(equalTo: roleTextField.leadingAnchor),
            roleLabel.trailingAnchor.constraint(equalTo: roleTextField.trailingAnchor),
            
            companyTextField.topAnchor.constraint(equalTo: roleTextField.bottomAnchor, constant: 20),
            companyTextField.leadingAnchor.constraint(equalTo: roleTextField.leadingAnchor),
            companyTextField.trailingAnchor.constraint(equalTo: roleTextField.trailingAnchor),
            companyTextField.heightAnchor.constraint(equalToConstant: 35),
            
            companyLabel.bottomAnchor.constraint(equalTo: companyTextField.topAnchor, constant: -2),
            companyLabel.leadingAnchor.constraint(equalTo: companyTextField.leadingAnchor),
            companyLabel.trailingAnchor.constraint(equalTo: companyTextField.trailingAnchor),
            
            locationTextField.topAnchor.constraint(equalTo: companyTextField.bottomAnchor, constant: 20),
            locationTextField.leadingAnchor.constraint(equalTo: companyTextField.leadingAnchor),
            locationTextField.trailingAnchor.constraint(equalTo: companyTextField.trailingAnchor),
            locationTextField.heightAnchor.constraint(equalToConstant: 35),
            
            locationLabel.bottomAnchor.constraint(equalTo: locationTextField.topAnchor, constant: -2),
            locationLabel.leadingAnchor.constraint(equalTo: companyLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: companyLabel.trailingAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: locationTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: locationTextField.trailingAnchor),
            
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: -2),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
        
            separatorView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: locationTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: locationTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            squareButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            squareButton.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor),
            squareButton.heightAnchor.constraint(equalToConstant: 24),
            squareButton.widthAnchor.constraint(equalToConstant: 24),

            professionConditionsLabel.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            professionConditionsLabel.leadingAnchor.constraint(equalTo: squareButton.trailingAnchor, constant: 5),
            professionConditionsLabel.trailingAnchor.constraint(equalTo: locationLabel.trailingAnchor),
            
            bottomSeparatorView.topAnchor.constraint(equalTo: squareButton.bottomAnchor, constant: 10),
            bottomSeparatorView.leadingAnchor.constraint(equalTo: locationTextField.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: locationTextField.trailingAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            startDateTextField.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 20),
            startDateTextField.leadingAnchor.constraint(equalTo: squareButton.leadingAnchor),
            startDateTextField.trailingAnchor.constraint(equalTo: locationTextField.trailingAnchor),
            
            endDateTextField.topAnchor.constraint(equalTo: startDateTextField.bottomAnchor, constant: 20),
            endDateTextField.trailingAnchor.constraint(equalTo: locationTextField.trailingAnchor),
            endDateTextField.leadingAnchor.constraint(equalTo: locationTextField.leadingAnchor),
            
            startDateLabel.bottomAnchor.constraint(equalTo: startDateTextField.topAnchor, constant: -2),
            startDateLabel.leadingAnchor.constraint(equalTo: squareButton.leadingAnchor),
            
            endDateLabel.bottomAnchor.constraint(equalTo: endDateTextField.topAnchor, constant: -2),
            endDateLabel.leadingAnchor.constraint(equalTo: squareButton.leadingAnchor)
        ])
    }
    
    @objc func handleDone() {
        print("Update experience")
    }
    
    @objc func handleAddStartDate() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            startDateTextField.text = formatter.string(from: startDatePicker.date)
            view.endEditing(true)
    }
    
    @objc func handleAddEndDate() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            endDateTextField.text = formatter.string(from: endDatePicker.date)
            view.endEditing(true)
    }
    
    @objc func handleProfessionConditions() {
        conditionIsSelected.toggle()
        if conditionIsSelected {
            squareButton.configuration?.image = UIImage(systemName: "checkmark.square.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
            
            endDateTextField.isHidden = true
            endDateTextField.isUserInteractionEnabled = false
            endDateLabel.isHidden = true
            
        } else {
            squareButton.configuration?.image = UIImage(systemName: "square")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
            
            endDateTextField.isHidden = false
            endDateTextField.isUserInteractionEnabled = true
        }
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let count = text.count
        
        if textField == roleTextField {
            if count != 0 {
                roleLabel.isHidden = false
            } else {
                roleLabel.isHidden = true
            }
            
        } else if textField == companyTextField {
            if count != 0 {
                companyLabel.isHidden = false
            } else {
                companyLabel.isHidden = true
            }
            
        } else if textField == locationTextField {
            if count != 0 {
                locationLabel.isHidden = false
            } else {
                locationLabel.isHidden = true
            }
            
        } else if textField == startDateTextField {
            if count != 0 {
                startDateLabel.isHidden = false
            } else {
                startDateLabel.isHidden = true
            }
            
        } else {
            if count != 0 {
                endDateLabel.isHidden = false
            } else {
                endDateLabel.isHidden = true
            }
        }
    }
    
    func generateSuperscriptFor(text: String) -> NSMutableAttributedString {
        let text = "\(text) *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        return attrString
    }
}

extension AddExperienceViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        
        if count != 0 {
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }
}
