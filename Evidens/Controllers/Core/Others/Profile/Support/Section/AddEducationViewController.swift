//
//  AddEducationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

protocol AddEducationViewControllerDelegate: AnyObject {
    func handleUpdateEducation()
}

class AddEducationViewController: UIViewController {
    
    weak var delegate: AddEducationViewControllerDelegate?
    
    private var conditionIsSelected: Bool = false
    
    private var userIsEditing = false
    private var previousDegree: String = ""
    private var previousSchool: String = ""
    private var previousField: String = ""
    
    
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
    
    private let schoolLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var schoolTextField: UITextField = {
        let text = "School *"
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
    
    private let degreeTypeLabel: UILabel = {
        let label = UILabel()
        //label.text = "Title"
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var degreeTypeTextField: UITextField = {
        let text = "Degree *"
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
    
    private let fieldOfStudyLabel: UILabel = {
        let label = UILabel()
        label.textColor = grayColor
        label.isHidden = true
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fieldOfStudyTextField: UITextField = {
        let text = "Field of study *"
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
    
    private lazy var squareButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "square")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
        button.configuration?.baseForegroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleProfessionConditions), for: .touchUpInside)
        return button
    }()
    
    private let educationConditionsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.text = "Currently studying this degree type"
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
        schoolLabel.attributedText = generateSuperscriptFor(text: "School")
        degreeTypeLabel.attributedText = generateSuperscriptFor(text: "Degree")
        fieldOfStudyLabel.attributedText = generateSuperscriptFor(text: "Field of study")
        startDateLabel.attributedText = generateSuperscriptFor(text: "Start date")
        endDateLabel.attributedText = generateSuperscriptFor(text: "End date")
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        
        scrollView.addSubviews(schoolLabel, schoolTextField, degreeTypeLabel, degreeTypeTextField, fieldOfStudyLabel, fieldOfStudyTextField, squareButton, educationConditionsLabel, startDateLabel, endDateLabel, startDateTextField, endDateTextField, separatorView, bottomSeparatorView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            schoolTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            schoolTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            schoolTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            schoolTextField.heightAnchor.constraint(equalToConstant: 35),
            
            schoolLabel.bottomAnchor.constraint(equalTo: schoolTextField.topAnchor, constant: -2),
            schoolLabel.leadingAnchor.constraint(equalTo: schoolTextField.leadingAnchor),
            schoolLabel.trailingAnchor.constraint(equalTo: schoolTextField.trailingAnchor),
            
            degreeTypeTextField.topAnchor.constraint(equalTo: schoolTextField.bottomAnchor, constant: 20),
            degreeTypeTextField.leadingAnchor.constraint(equalTo: schoolTextField.leadingAnchor),
            degreeTypeTextField.trailingAnchor.constraint(equalTo: schoolTextField.trailingAnchor),
            degreeTypeTextField.heightAnchor.constraint(equalToConstant: 35),
            
            degreeTypeLabel.bottomAnchor.constraint(equalTo: degreeTypeTextField.topAnchor, constant: -2),
            degreeTypeLabel.leadingAnchor.constraint(equalTo: degreeTypeTextField.leadingAnchor),
            degreeTypeLabel.trailingAnchor.constraint(equalTo: degreeTypeTextField.trailingAnchor),
            
            fieldOfStudyTextField.topAnchor.constraint(equalTo: degreeTypeTextField.bottomAnchor, constant: 20),
            fieldOfStudyTextField.leadingAnchor.constraint(equalTo: degreeTypeTextField.leadingAnchor),
            fieldOfStudyTextField.trailingAnchor.constraint(equalTo: degreeTypeTextField.trailingAnchor),
            fieldOfStudyTextField.heightAnchor.constraint(equalToConstant: 35),
            
            fieldOfStudyLabel.bottomAnchor.constraint(equalTo: fieldOfStudyTextField.topAnchor, constant: -2),
            fieldOfStudyLabel.leadingAnchor.constraint(equalTo: degreeTypeLabel.leadingAnchor),
            fieldOfStudyLabel.trailingAnchor.constraint(equalTo: degreeTypeLabel.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: fieldOfStudyTextField.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: fieldOfStudyTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: fieldOfStudyTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            squareButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            squareButton.leadingAnchor.constraint(equalTo: fieldOfStudyLabel.leadingAnchor),
            squareButton.heightAnchor.constraint(equalToConstant: 24),
            squareButton.widthAnchor.constraint(equalToConstant: 24),

            educationConditionsLabel.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            educationConditionsLabel.leadingAnchor.constraint(equalTo: squareButton.trailingAnchor, constant: 5),
            educationConditionsLabel.trailingAnchor.constraint(equalTo: fieldOfStudyLabel.trailingAnchor),
            
            bottomSeparatorView.topAnchor.constraint(equalTo: squareButton.bottomAnchor, constant: 10),
            bottomSeparatorView.leadingAnchor.constraint(equalTo: fieldOfStudyTextField.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: fieldOfStudyTextField.trailingAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            startDateTextField.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 20),
            startDateTextField.leadingAnchor.constraint(equalTo: squareButton.leadingAnchor),
            startDateTextField.trailingAnchor.constraint(equalTo: fieldOfStudyTextField.trailingAnchor),
            
            endDateTextField.topAnchor.constraint(equalTo: startDateTextField.bottomAnchor, constant: 20),
            endDateTextField.trailingAnchor.constraint(equalTo: fieldOfStudyTextField.trailingAnchor),
            endDateTextField.leadingAnchor.constraint(equalTo: fieldOfStudyTextField.leadingAnchor),
            
            startDateLabel.bottomAnchor.constraint(equalTo: startDateTextField.topAnchor, constant: -2),
            startDateLabel.leadingAnchor.constraint(equalTo: squareButton.leadingAnchor),
            
            endDateLabel.bottomAnchor.constraint(equalTo: endDateTextField.topAnchor, constant: -2),
            endDateLabel.leadingAnchor.constraint(equalTo: squareButton.leadingAnchor)
        ])
    }
    
    func updateEducationModel() {
        guard let school = schoolTextField.text, let degree = degreeTypeTextField.text, let field = fieldOfStudyTextField.text, let startDate = startDateTextField.text, let endDate = endDateTextField.text else { return }
           
        navigationItem.rightBarButtonItem?.isEnabled = !school.isEmpty && !degree.isEmpty && !field.isEmpty && !startDate.isEmpty && (!endDate.isEmpty || conditionIsSelected) ? true : false
    }
    
    @objc func handleDone() {
        guard let school = schoolTextField.text, let degree = degreeTypeTextField.text, let field = fieldOfStudyTextField.text, let startDate = startDateTextField.text, let endDate = endDateTextField.text else { return }
        
        let endDateText = conditionIsSelected ? "Present" : endDate
        
        showLoadingView()
        
        if userIsEditing {
            DatabaseManager.shared.updateEducation(previousDegree: previousDegree, previousSchool: previousSchool, previousField: previousField, school: school, degree: degree, field: field, startDate: startDate, endDate: endDate) { uploaded in
                print("upldated education")
                self.dismissLoadingView()
                self.delegate?.handleUpdateEducation()
                if let count = self.navigationController?.viewControllers.count {
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[count - 2 - 1])!, animated: true)
                }
            }
        } else {
            
            DatabaseManager.shared.uploadEducation(school: school, degree: degree, field: field, startDate: startDate, endDate: endDateText) { uploaded in
                print("Uploaded education")
                self.dismissLoadingView()
                self.delegate?.handleUpdateEducation()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func handleAddStartDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        startDateTextField.text = formatter.string(from: startDatePicker.date)
        textDidChange(startDateTextField)
        view.endEditing(true)
    }
    
    @objc func handleAddEndDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        endDateTextField.text = formatter.string(from: endDatePicker.date)
        textDidChange(endDateTextField)
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
        
        updateEducationModel()
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let count = text.count
        
        if textField == schoolTextField {
            if count != 0 {
                schoolLabel.isHidden = false
            } else {
                schoolLabel.isHidden = true
            }
            
        } else if textField == degreeTypeTextField {
            if count != 0 {
                degreeTypeLabel.isHidden = false
            } else {
                degreeTypeLabel.isHidden = true
            }
            
        } else if textField == fieldOfStudyTextField {
            if count != 0 {
                fieldOfStudyLabel.isHidden = false
            } else {
                fieldOfStudyLabel.isHidden = true
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
        
        updateEducationModel()
    }
    
    func generateSuperscriptFor(text: String) -> NSMutableAttributedString {
        let text = "\(text) *"
        let attrString = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium), .baselineOffset: 1], range: NSRange(location: text.count - 1, length: 1))
        return attrString
    }
    
    func configureWithPublication(school: String, degree: String, field: String, startDate: String, endDate: String) {
        userIsEditing = true
        previousDegree = degree
        previousSchool = school
        previousField = field
        
        print(startDate)
        print(endDate)
        
        schoolTextField.text = school
        degreeTypeTextField.text = degree
        fieldOfStudyTextField.text = field
        
        startDateTextField.text = startDate
        endDateTextField.text = endDate
    
        textDidChange(schoolTextField)
        textDidChange(degreeTypeTextField)
        textDidChange(startDateTextField)
        textDidChange(fieldOfStudyTextField)
        textDidChange(endDateTextField)
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}
